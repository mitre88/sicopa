import Foundation
import SwiftUI
import Combine

// MARK: - Caché funcional con LRU
final class FunctionalCache<Key: Hashable, Value> {
    private let maxSize: Int
    private var cache: [Key: (value: Value, timestamp: Date)] = [:]
    private let queue = DispatchQueue(label: "cache.queue", attributes: .concurrent)
    
    init(maxSize: Int = 100) {
        self.maxSize = maxSize
    }
    
    // Función pura para obtener valor
    func get(_ key: Key) -> Value? {
        queue.sync {
            if let item = cache[key] {
                // Actualizar timestamp (inmutable)
                cache[key] = (value: item.value, timestamp: Date())
                return item.value
            }
            return nil
        }
    }
    
    // Función para establecer valor con limpieza LRU
    func set(_ key: Key, value: Value) {
        queue.async(flags: .barrier) {
            self.cache[key] = (value: value, timestamp: Date())
            
            // Limpieza LRU si excede el tamaño máximo
            if self.cache.count > self.maxSize {
                let oldestKey = self.cache
                    .min { $0.value.timestamp < $1.value.timestamp }?
                    .key
                
                if let keyToRemove = oldestKey {
                    self.cache.removeValue(forKey: keyToRemove)
                }
            }
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}

// MARK: - Índice de búsqueda optimizado
struct SearchIndex {
    let rfcIndex: [String: Set<Int>] // RFC -> líneas
    let nameIndex: [String: Set<Int>] // Palabras del nombre -> líneas
    let records: [PayrollRecord]
    
    // Búsqueda funcional recursiva por RFC
    func searchByRFC(_ rfc: String) -> [PayrollRecord] {
        guard !rfc.isEmpty else { return [] }
        
        let upperRFC = rfc.uppercased()
        
        // Búsqueda exacta primero
        if let lineIndices = rfcIndex[upperRFC] {
            return lineIndices.compactMap { records.indices.contains($0) ? records[$0] : nil }
        }
        
        // Búsqueda parcial si no hay coincidencia exacta
        if rfc.count >= 4 {
            return rfcIndex
                .filter { $0.key.contains(upperRFC) }
                .flatMap { $0.value }
                .compactMap { records.indices.contains($0) ? records[$0] : nil }
                .removingDuplicates()
        }
        
        return []
    }
    
    // Búsqueda funcional recursiva por nombre
    func searchByName(_ name: String) -> [PayrollRecord] {
        guard !name.isEmpty else { return [] }
        
        let searchTerms = name
            .uppercased()
            .split(separator: " ")
            .map(String.init)
        
        // Función recursiva para encontrar intersección de resultados
        func findIntersection(terms: [String], currentIndices: Set<Int>? = nil) -> Set<Int> {
            guard let term = terms.first else { return currentIndices ?? [] }
            
            let termIndices = nameIndex
                .filter { $0.key.contains(term) }
                .flatMap { $0.value }
                .reduce(into: Set<Int>()) { $0.insert($1) }
            
            let newIndices = currentIndices.map { $0.intersection(termIndices) } ?? termIndices
            
            return findIntersection(terms: Array(terms.dropFirst()), currentIndices: newIndices)
        }
        
        let matchingIndices = findIntersection(terms: searchTerms)
        
        return matchingIndices
            .compactMap { records.indices.contains($0) ? records[$0] : nil }
            .sorted { $0.nombre < $1.nombre }
    }
}

// MARK: - Servicio de búsqueda optimizado funcionalmente
@MainActor
final class SimpleSearchService: ObservableObject {
    private var searchIndex: SearchIndex?
    private let cache = FunctionalCache<String, [PayrollRecord]>(maxSize: 50)
    private let loadQueue = DispatchQueue(label: "csv.load", qos: .userInitiated)
    private var isLoaded = false
    
    init() {
        Task {
            await loadCSVOptimized()
        }
    }
    
    // MARK: - Carga optimizada del CSV con índices
    private func loadCSVOptimized() async {
        guard !isLoaded else { return }
        
        await withCheckedContinuation { continuation in
            loadQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                
                print("📁 Cargando CSV de forma optimizada...")
                
                // Intentar cargar el archivo
                guard let csvContent = self.loadCSVContent() else {
                    print("❌ Error al cargar CSV")
                    continuation.resume()
                    return
                }
                
                // Procesar líneas de forma funcional
                let lines = csvContent
                    .components(separatedBy: .newlines)
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                
                // Parsear registros y crear índices en paralelo
                let (records, rfcIndex, nameIndex) = self.processCSVFunctionally(lines: lines)
                
                // Actualizar en el main thread
                Task { @MainActor in
                    self.searchIndex = SearchIndex(
                        rfcIndex: rfcIndex,
                        nameIndex: nameIndex,
                        records: records
                    )
                    self.isLoaded = true
                    print("✅ Índices creados: \(rfcIndex.count) RFCs, \(nameIndex.count) términos de nombre")
                }
                
                continuation.resume()
            }
        }
    }
    
    // MARK: - Carga funcional del contenido CSV
    private func loadCSVContent() -> String? {
        // Buscar el archivo CSV
        var csvURL: URL?
        
        // 1) Intentar en el bundle
        csvURL = Bundle.main.url(forResource: "payroll_data", withExtension: "csv")
        
        // 2) Fallback: ruta de desarrollo
        if csvURL == nil {
            let devPath = "/Users/dr.alexmitre/Desktop/sicopa/sicopa/payroll_data.csv"
            if FileManager.default.fileExists(atPath: devPath) {
                csvURL = URL(fileURLWithPath: devPath)
            }
        }
        
        guard let finalURL = csvURL else { return nil }
        
        // Intentar diferentes encodings
        let encodings: [String.Encoding] = [.utf8, .isoLatin1, .windowsCP1252]
        
        return encodings.compactMap { encoding in
            try? String(contentsOf: finalURL, encoding: encoding)
        }.first
    }
    
    // MARK: - Procesamiento funcional del CSV
    private func processCSVFunctionally(lines: [String]) -> ([PayrollRecord], [String: Set<Int>], [String: Set<Int>]) {
        var records: [PayrollRecord] = []
        var rfcIndex: [String: Set<Int>] = [:]
        var nameIndex: [String: Set<Int>] = [:]
        
        // Procesar líneas en paralelo usando concurrencia estructurada
        let processedData = lines.dropFirst().enumerated().compactMap { (index, line) -> (PayrollRecord, String, String)? in
            guard let record = parsePayrollRecordOptimized(from: line) else { return nil }
            return (record, record.rfc.uppercased(), record.nombre.uppercased())
        }
        
        // Construir índices
        for (index, (record, rfc, name)) in processedData.enumerated() {
            records.append(record)
            
            // Índice RFC
            rfcIndex[rfc, default: []].insert(index)
            
            // Índice de nombre (por palabras)
            let nameWords = name.split(separator: " ").map(String.init)
            for word in nameWords {
                nameIndex[word, default: []].insert(index)
            }
        }
        
        return (records, rfcIndex, nameIndex)
    }
    
    // MARK: - Búsqueda optimizada con caché
    func searchByRFC(_ rfc: String) async -> [PayrollRecord] {
        // Verificar caché primero
        let cacheKey = "rfc:\(rfc.uppercased())"
        if let cached = cache.get(cacheKey) {
            print("✅ Resultado desde caché para RFC: \(rfc)")
            return cached
        }
        
        // Esperar a que se carguen los datos
        while !isLoaded {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        }
        
        guard let index = searchIndex else { return [] }
        
        // Búsqueda usando índice
        let results = index.searchByRFC(rfc)
        
        // Guardar en caché
        cache.set(cacheKey, value: results)
        
        print("✅ Encontrados \(results.count) cheques para RFC: \(rfc)")
        return results
    }
    
    // MARK: - Búsqueda por nombre optimizada
    func searchByName(_ name: String) async -> [PayrollRecord] {
        // Verificar caché
        let cacheKey = "name:\(name.uppercased())"
        if let cached = cache.get(cacheKey) {
            print("✅ Resultado desde caché para nombre: \(name)")
            return cached
        }
        
        // Esperar datos
        while !isLoaded {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        guard let index = searchIndex else { return [] }
        
        // Búsqueda usando índice
        let results = index.searchByName(name)
        
        // Guardar en caché
        cache.set(cacheKey, value: results)
        
        print("✅ Encontrados \(results.count) registros para nombre: \(name)")
        return results
    }
    
    // Limpiar caché
    func clearCache() {
        cache.clear()
    }
}

// MARK: - Parser optimizado de registros
private func parsePayrollRecordOptimized(from line: String) -> PayrollRecord? {
    let components = line.components(separatedBy: ",")
    
    guard components.count >= 11 else { return nil }
    
    // Funciones helper inline para mejor rendimiento
    let clean: (String) -> String = { str in
        str.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
    }
    
    let safeDouble: (String) -> Double = { str in
        Double(clean(str)) ?? 0.0
    }
    
    // Extraer datos básicos
    let record = PayrollRecord(
        plaza: clean(components[0]),
        grupo: clean(components[1]),
        rfc: clean(components[2]),
        nombre: clean(components[3]),
        liquido: safeDouble(components[4]),
        cct: components.count > 5 ? clean(components[5]) : "",
        cheque: components.count > 6 ? clean(components[6]) : "",
        puesto_cdc: components.count > 7 ? clean(components[7]) : "",
        desde_pag: components.count > 8 ? clean(components[8]) : "",
        hasta_pag: components.count > 9 ? clean(components[9]) : "",
        motivo: components.count > 10 ? clean(components[10]) : "",
        conceptos: extractConceptos(from: components, clean: clean),
        importes: extractImportes(from: components, safeDouble: safeDouble)
    )
    
    return record
}

// MARK: - Extracción funcional de conceptos
private func extractConceptos(from components: [String], clean: (String) -> String) -> [String] {
    guard components.count > 48 else { return [] }
    
    let maxConceptos = min(37, components.count - 48)
    
    return (0..<maxConceptos).compactMap { i in
        let conceptoIndex = 11 + i
        guard conceptoIndex < components.count else { return nil }
        
        let concepto = clean(components[conceptoIndex])
        return (!concepto.isEmpty && concepto.lowercased() != "nan") ? concepto : nil
    }
}

// MARK: - Extracción funcional de importes
private func extractImportes(from components: [String], safeDouble: (String) -> Double) -> [Double] {
    guard components.count > 48 else { return [] }
    
    let maxImportes = min(37, components.count - 48)
    
    return (0..<maxImportes).compactMap { i in
        let importeIndex = 48 + i
        guard importeIndex < components.count else { return nil }
        
        return safeDouble(components[importeIndex])
    }
}

// MARK: - Extensión para remover duplicados
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
} 