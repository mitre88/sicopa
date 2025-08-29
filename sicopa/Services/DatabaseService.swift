import Foundation
import SQLite3

// MARK: - Servicio de base de datos funcional
@MainActor
final class DatabaseService: ObservableObject {
    private var db: OpaquePointer?
    private let dbPath: String
    
    init() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        dbPath = documentsPath.appendingPathComponent("payroll.sqlite").path
        
        Task { @MainActor in
            await initializeDatabase()
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    // MARK: - Funciones puras para configuración
    private func initializeDatabase() async {
        guard sqlite3_open(dbPath, &db) == SQLITE_OK else {
            print("Error opening database: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        
        await createTable()
        await loadCSVDataIfNeeded()
    }
    
    private func createTable() async {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS payroll_records (
                id TEXT PRIMARY KEY,
                plaza TEXT,
                grupo TEXT,
                rfc TEXT NOT NULL,
                nombre TEXT NOT NULL,
                liquido REAL,
                cct TEXT,
                cheque TEXT,
                puesto_cdc TEXT,
                desde_pag TEXT,
                hasta_pag TEXT,
                motivo TEXT,
                conceptos TEXT,
                importes TEXT
            );
            
            CREATE INDEX IF NOT EXISTS idx_rfc ON payroll_records(rfc);
            CREATE INDEX IF NOT EXISTS idx_nombre ON payroll_records(nombre);
            CREATE INDEX IF NOT EXISTS idx_cct ON payroll_records(cct);
            CREATE VIRTUAL TABLE IF NOT EXISTS payroll_fts USING fts5(
                rfc, nombre, cct, content='payroll_records'
            );
        """
        
        guard sqlite3_exec(db, createTableSQL, nil, nil, nil) == SQLITE_OK else {
            print("Error creating table: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
    }
    
    private func loadCSVDataIfNeeded() async {
        // Cargar datos solo si la BD está vacía para mejorar rendimiento
        let currentCount = await getRecordCount()
        if currentCount == 0 {
            print("🆕 BD vacía, inicializando y cargando CSV...")
            await dropAndRecreateDatabase()
        } else {
            print("✅ BD existente con \(currentCount) registros, no se recarga CSV.")
            return
        }
        
        print("🔄 Intentando cargar datos del CSV...")
        
        // Intentar cargar desde el bundle principal
        var csvPath: URL?
        
        csvPath = Bundle.main.url(forResource: "payroll_data", withExtension: "csv")
        
        if csvPath == nil {
            print("⚠️ No se encontró payroll_data.csv en el bundle, intentando ruta alternativa...")
            
            // Debug: Mostrar contenido del bundle
            print("📂 Recursos del bundle:")
            if let bundlePath = Bundle.main.resourcePath {
                let files = try? FileManager.default.contentsOfDirectory(atPath: bundlePath)
                files?.forEach { print("   - \($0)") }
            }
            
            // Intentar ruta alternativa para desarrollo
            let alternativePath = "/Users/dr.alexmitre/Desktop/sicopa/sicopa/payroll_data.csv"
            if FileManager.default.fileExists(atPath: alternativePath) {
                csvPath = URL(fileURLWithPath: alternativePath)
                print("🔧 Usando ruta de desarrollo: \(alternativePath)")
            }
        }
        
        guard let finalCSVPath = csvPath else {
            print("❌ Error: No se pudo encontrar el archivo CSV en ninguna ubicación")
            return
        }
        
        print("✅ Archivo CSV encontrado en: \(finalCSVPath)")
        
        // Verificar tamaño del archivo
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: finalCSVPath.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            print("📁 Tamaño del archivo: \(fileSize) bytes (\(fileSize / 1024 / 1024) MB)")
            
            if fileSize > 10 * 1024 * 1024 { // Más de 10MB
                print("⚠️ Archivo grande detectado (\(fileSize / 1024 / 1024)MB), usando método eficiente...")
                await loadCSVInChunks(from: finalCSVPath)
                return
            }
        } catch {
            print("⚠️ No se pudo obtener el tamaño del archivo: \(error)")
        }
        
        // Intentar diferentes encodings
        var csvContent: String?
        
        // Intentar UTF-8 primero
        csvContent = try? String(contentsOf: finalCSVPath, encoding: .utf8)
        
        if csvContent == nil {
            print("⚠️ UTF-8 falló, intentando Latin1...")
            csvContent = try? String(contentsOf: finalCSVPath, encoding: .isoLatin1)
        }
        
        if csvContent == nil {
            print("⚠️ Latin1 falló, intentando Windows-1252...")
            csvContent = try? String(contentsOf: finalCSVPath, encoding: .windowsCP1252)
        }
        
        guard let finalCSVContent = csvContent else {
            print("❌ Error: No se pudo leer el contenido del archivo CSV con ningún encoding")
            return
        }
        
        print("📄 Tamaño del archivo CSV: \(finalCSVContent.count) caracteres")
        let lines = finalCSVContent.components(separatedBy: .newlines)
        print("📄 Líneas totales en el CSV: \(lines.count)")
        
        print("🔄 Parseando registros del CSV...")
        let records = PayrollCSVParser.parseRecords(from: finalCSVContent)
        print("✅ Registros parseados: \(records.count)")
        
        if !records.isEmpty {
            print("📋 Primer registro parseado:")
            let first = records[0]
            print("   RFC: \(first.rfc)")
            print("   Nombre: \(first.nombre)")
            print("   Líquido: \(first.liquido)")
        }
        
        await insertRecords(records)
        
        let finalCount = await getRecordCount()
        print("🎯 Registros finales en BD: \(finalCount)")
    }
    
    // Función para insertar un solo registro
    private func insertRecord(_ record: PayrollRecord) async {
        await insertRecords([record])
    }
    
    // Método para cargar archivos CSV grandes línea por línea (eficiente en memoria)
    private func loadCSVInChunks(from url: URL) async {
        print("🔄 Cargando CSV línea por línea para evitar problemas de memoria...")
        
        guard let inputStream = InputStream(url: url) else {
            print("❌ No se pudo crear InputStream")
            return
        }
        
        inputStream.open()
        defer { inputStream.close() }
        
        var recordCount = 0
        var headerProcessed = false
        var lineBuffer = ""
        let bufferSize = 8192 // 8KB buffer
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        // Procesar en lotes pequeños para reducir presión de memoria
        var recordBatch: [PayrollRecord] = []
        let batchSize = 50 // Insertar cada 50 registros
        
        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(buffer, maxLength: bufferSize)
            
            if bytesRead > 0 {
                guard let stringData = String(bytes: UnsafeBufferPointer(start: buffer, count: bytesRead), encoding: .utf8) ??
                      String(bytes: UnsafeBufferPointer(start: buffer, count: bytesRead), encoding: .isoLatin1) else {
                    print("❌ Error decodificando datos")
                    continue
                }
                
                lineBuffer += stringData
                let lines = lineBuffer.components(separatedBy: .newlines)
                
                // Procesar todas las líneas excepto la última (que puede estar incompleta)
                for i in 0..<(lines.count - 1) {
                    let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !headerProcessed {
                        headerProcessed = true
                        continue
                    }
                    
                                            if !line.isEmpty {
                            let shouldDebug = recordCount < 5  // Debug primeros 5 registros
                            if let record = PayrollCSVParser.parseLine(line, debug: shouldDebug) {
                                recordBatch.append(record)
                                recordCount += 1
                            
                            // Insertar en lotes para evitar problemas de memoria
                            if recordBatch.count >= batchSize {
                                await insertRecords(recordBatch)
                                recordBatch.removeAll(keepingCapacity: true)
                                print("📊 Procesados \(recordCount) registros...")
                            }
                        }
                    }
                }
                
                // Mantener la última línea para el siguiente chunk
                lineBuffer = lines.last ?? ""
            }
        }
        
                    // Procesar última línea si queda
            if !lineBuffer.isEmpty && headerProcessed {
                let shouldDebug = recordCount < 5
                if let record = PayrollCSVParser.parseLine(lineBuffer, debug: shouldDebug) {
                    recordBatch.append(record)
                    recordCount += 1
                }
            }
        
        // Insertar últimos registros
        if !recordBatch.isEmpty {
            await insertRecords(recordBatch)
        }
        
        print("✅ Carga eficiente completada: \(recordCount) registros")
    }
    
    // Función para limpiar y recrear la base de datos
    private func dropAndRecreateDatabase() async {
        let dropSQL = "DROP TABLE IF EXISTS payroll_records"
        let dropFTSSQL = "DROP TABLE IF EXISTS payroll_fts"
        
        guard sqlite3_exec(db, dropSQL, nil, nil, nil) == SQLITE_OK,
              sqlite3_exec(db, dropFTSSQL, nil, nil, nil) == SQLITE_OK else {
            print("❌ Error eliminando tablas")
            return
        }
        
        await createTable()
        print("✅ Base de datos recreada exitosamente")
    }
    
    // MARK: - Funciones funcionales para operaciones de base de datos
    func searchRecords(query: String) async -> [PayrollRecord] {
        let searchQuery = query.trimmingCharacters(in: .whitespaces)
        print("🔍 DatabaseService.searchRecords llamado con query: '\(searchQuery)'")
        
        if searchQuery.isEmpty {
            print("🔍 Query vacío, devolviendo 50 registros generales")
            return await getAllRecords(limit: 50)
        }
        
        print("🔍 Realizando búsqueda específica para: '\(searchQuery)'")
        let results = await performSearch(query: searchQuery)
        print("🔍 Búsqueda completada: \(results.count) resultados encontrados")
        
        // Debug: mostrar primeros resultados
        results.prefix(3).forEach { record in
            print("   - \(record.nombre) (\(record.rfc))")
        }
        
        return results
    }
    
    private func performSearch(query: String) async -> [PayrollRecord] {
        print("🔍 performSearch ejecutándose con query: '\(query)'")
        
        let sql = """
            SELECT * FROM payroll_records 
            WHERE rfc LIKE ? OR nombre LIKE ? OR cct LIKE ?
            ORDER BY 
                CASE 
                    WHEN rfc = ? THEN 1
                    WHEN rfc LIKE ? THEN 2
                    WHEN nombre LIKE ? THEN 3
                    ELSE 4
                END
            LIMIT 100
        """
        
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing search statement: \(String(cString: sqlite3_errmsg(db)))")
            return []
        }
        
        defer { sqlite3_finalize(statement) }
        
        let likeQuery = "%\(query)%"
        print("🔍 Parámetros de búsqueda: likeQuery='\(likeQuery)', exactQuery='\(query)'")
        
        // Bind parameters
        sqlite3_bind_text(statement, 1, likeQuery, -1, nil)
        sqlite3_bind_text(statement, 2, likeQuery, -1, nil)
        sqlite3_bind_text(statement, 3, likeQuery, -1, nil)
        sqlite3_bind_text(statement, 4, query, -1, nil)
        sqlite3_bind_text(statement, 5, "\(query)%", -1, nil)
        sqlite3_bind_text(statement, 6, "\(query)%", -1, nil)
        
        let results = extractRecords(from: statement)
        print("🔍 SQL ejecutado exitosamente, \(results.count) registros extraídos")
        
        return results
    }
    
    private func getAllRecords(limit: Int) async -> [PayrollRecord] {
        let sql = "SELECT * FROM payroll_records ORDER BY nombre LIMIT ?"
        
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing get all statement")
            return []
        }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_int(statement, 1, Int32(limit))
        
        return extractRecords(from: statement)
    }
    
    // Función pura para extraer registros del statement
    private func extractRecords(from statement: OpaquePointer?) -> [PayrollRecord] {
        var records: [PayrollRecord] = []
        
        while sqlite3_step(statement) == SQLITE_ROW {
            // Función helper para extraer string de forma segura
            func safeString(_ columnIndex: Int32) -> String {
                if let ptr = sqlite3_column_text(statement, columnIndex) {
                    return String(cString: ptr)
                }
                return ""
            }
            
            // Extraer datos de forma segura (sin guard que descarta registros)
            let plaza = safeString(1)
            let grupo = safeString(2)
            let rfc = safeString(3)
            let nombre = safeString(4)
            let liquido = sqlite3_column_double(statement, 5)
            let cct = safeString(6)
            let cheque = safeString(7)
            let puesto_cdc = safeString(8)
            let desde_pag = safeString(9)
            let hasta_pag = safeString(10)
            let motivo = safeString(11)
            
            // Debug: imprimir los primeros registros
            if records.count < 3 {
                print("🔍 BD Debug - RFC: '\(rfc)', Nombre: '\(nombre)', Líquido: \(liquido)")
            }
            
            // Manejar conceptos e importes de manera segura
            let conceptosString = safeString(12)
            let importesString = safeString(13)
            
            let conceptos = conceptosString.isEmpty ? [] : conceptosString.components(separatedBy: "|")
            let importes = importesString.isEmpty ? [] : importesString.components(separatedBy: "|")
                .compactMap { Double($0) }
            
            let record = PayrollRecord(
                plaza: plaza,
                grupo: grupo,
                rfc: rfc,
                nombre: nombre,
                liquido: liquido,
                cct: cct,
                cheque: cheque,
                puesto_cdc: puesto_cdc,
                desde_pag: desde_pag,
                hasta_pag: hasta_pag,
                motivo: motivo,
                conceptos: conceptos,
                importes: importes
            )
            
            records.append(record)
        }
        
        return records
    }
    
    private func insertRecords(_ records: [PayrollRecord]) async {
        let sql = """
            INSERT OR REPLACE INTO payroll_records 
            (id, plaza, grupo, rfc, nombre, liquido, cct, cheque, puesto_cdc, 
             desde_pag, hasta_pag, motivo, conceptos, importes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing insert statement")
            return
        }
        
        defer { sqlite3_finalize(statement) }
        
        // Procesar records en lotes para mejor rendimiento
        await processRecordsInBatches(records, statement: statement, batchSize: 100)
    }
    
    // Función recursiva para procesar records en lotes
    private func processRecordsInBatches(_ records: [PayrollRecord], statement: OpaquePointer?, batchSize: Int) async {
        guard !records.isEmpty else { return }
        
        let batch = Array(records.prefix(batchSize))
        let remaining = Array(records.dropFirst(batchSize))
        
        // Procesar lote actual
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        
        for record in batch {
            await insertSingleRecord(record, statement: statement)
        }
        
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        // Procesar recursivamente el resto
        if !remaining.isEmpty {
            await processRecordsInBatches(remaining, statement: statement, batchSize: batchSize)
        }
    }
    
    private func insertSingleRecord(_ record: PayrollRecord, statement: OpaquePointer?) async {
        sqlite3_reset(statement)
        
        let conceptosString = record.conceptos.joined(separator: "|")
        let importesString = record.importes.map { String($0) }.joined(separator: "|")
        
        sqlite3_bind_text(statement, 1, record.id.uuidString, -1, nil)
        sqlite3_bind_text(statement, 2, record.plaza, -1, nil)
        sqlite3_bind_text(statement, 3, record.grupo, -1, nil)
        sqlite3_bind_text(statement, 4, record.rfc, -1, nil)
        sqlite3_bind_text(statement, 5, record.nombre, -1, nil)
        sqlite3_bind_double(statement, 6, record.liquido)
        sqlite3_bind_text(statement, 7, record.cct, -1, nil)
        sqlite3_bind_text(statement, 8, record.cheque, -1, nil)
        sqlite3_bind_text(statement, 9, record.puesto_cdc, -1, nil)
        sqlite3_bind_text(statement, 10, record.desde_pag, -1, nil)
        sqlite3_bind_text(statement, 11, record.hasta_pag, -1, nil)
        sqlite3_bind_text(statement, 12, record.motivo, -1, nil)
        sqlite3_bind_text(statement, 13, conceptosString, -1, nil)
        sqlite3_bind_text(statement, 14, importesString, -1, nil)
        
        sqlite3_step(statement)
    }
    
    func getRecordCount() async -> Int {
        let sql = "SELECT COUNT(*) FROM payroll_records"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            return 0
        }
        
        defer { sqlite3_finalize(statement) }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            return Int(sqlite3_column_int(statement, 0))
        }
        
        return 0
    }
} 