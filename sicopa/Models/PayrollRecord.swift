import Foundation

// MARK: - Modelo optimizado de registro de nómina
struct PayrollRecord: Identifiable, Codable, Hashable {
    let id = UUID()
    let plaza: String
    let grupo: String
    let rfc: String
    let nombre: String
    let liquido: Double
    let cct: String
    let cheque: String
    let puesto_cdc: String
    let desde_pag: String
    let hasta_pag: String
    let motivo: String
    let conceptos: [String]
    let importes: [Double]
    
    // MARK: - Propiedades computadas con funciones puras
    
    // Nombre formateado con capitalización correcta
    var formattedName: String {
        formatName(nombre)
    }
    
    // Total de percepciones (importes positivos) - función pura recursiva
    var totalPercepciones: Double {
        calculatePercepciones(importes: importes)
    }
    
    // Total de deducciones (importes negativos) - función pura recursiva
    var totalDeducciones: Double {
        calculateDeducciones(importes: importes)
    }
    
    // Período formateado
    var periodFormatted: String {
        formatPeriod(desde: desde_pag, hasta: hasta_pag)
    }
    
    // Búsqueda de concepto específico - función pura
    func hasConcepto(_ searchTerm: String) -> Bool {
        conceptos.contains { concepto in
            concepto.uppercased().contains(searchTerm.uppercased())
        }
    }
    
    // Obtener importe para un concepto específico
    func importeForConcepto(at index: Int) -> Double? {
        guard index >= 0 && index < importes.count else { return nil }
        return importes[index]
    }
}

// MARK: - Funciones puras para cálculos

// Función recursiva para calcular percepciones
private func calculatePercepciones(importes: [Double], index: Int = 0, sum: Double = 0) -> Double {
    guard index < importes.count else { return sum }
    
    let newSum = importes[index] > 0 ? sum + importes[index] : sum
    return calculatePercepciones(importes: importes, index: index + 1, sum: newSum)
}

// Función recursiva para calcular deducciones
private func calculateDeducciones(importes: [Double], index: Int = 0, sum: Double = 0) -> Double {
    guard index < importes.count else { return sum }
    
    let newSum = importes[index] < 0 ? sum + abs(importes[index]) : sum
    return calculateDeducciones(importes: importes, index: index + 1, sum: newSum)
}

// Función pura para formatear nombres
private func formatName(_ name: String) -> String {
    name
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: " ")
        .map { word in
            word.prefix(1).capitalized + word.dropFirst().lowercased()
        }
        .joined(separator: " ")
}

// Función pura para formatear período
private func formatPeriod(desde: String, hasta: String) -> String {
    guard !desde.isEmpty && !hasta.isEmpty else { 
        return "Período no especificado"
    }
    return "\(desde) al \(hasta)"
}

// MARK: - Parser CSV funcional y optimizado
struct PayrollCSVParser {
    
    // Parser principal con procesamiento funcional
    static func parseRecords(from csvContent: String) -> [PayrollRecord] {
        let lines = csvContent
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        guard lines.count > 1 else { return [] }
        
        // Procesar líneas en paralelo usando map funcional
        return lines
            .dropFirst() // Saltar header
            .compactMap { parseLine($0) }
    }
    
    // Parser de línea individual optimizado
    static func parseLine(_ line: String, debug: Bool = false) -> PayrollRecord? {
        let components = line.components(separatedBy: ",")
        
        guard components.count >= 11 else {
            if debug {
                print("❌ Línea con pocos campos: \(components.count)")
            }
            return nil
        }
        
        // Funciones helper locales para mejor rendimiento
        let clean: (String) -> String = { str in
            str.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\"", with: "")
        }
        
        let safeDouble: (String) -> Double = { str in
            Double(clean(str)) ?? 0.0
        }
        
        // Extraer datos usando acceso funcional
        let (conceptos, importes) = extractConceptosImportes(
            from: components,
            clean: clean,
            safeDouble: safeDouble
        )
        
        return PayrollRecord(
            plaza: components.indices.contains(0) ? clean(components[0]) : "",
            grupo: components.indices.contains(1) ? clean(components[1]) : "",
            rfc: components.indices.contains(2) ? clean(components[2]) : "",
            nombre: components.indices.contains(3) ? clean(components[3]) : "",
            liquido: components.indices.contains(4) ? safeDouble(components[4]) : 0.0,
            cct: components.indices.contains(5) ? clean(components[5]) : "",
            cheque: components.indices.contains(6) ? clean(components[6]) : "",
            puesto_cdc: components.indices.contains(7) ? clean(components[7]) : "",
            desde_pag: components.indices.contains(8) ? clean(components[8]) : "",
            hasta_pag: components.indices.contains(9) ? clean(components[9]) : "",
            motivo: components.indices.contains(10) ? clean(components[10]) : "",
            conceptos: conceptos,
            importes: importes
        )
    }
    
    // Extracción funcional de conceptos e importes
    private static func extractConceptosImportes(
        from components: [String],
        clean: (String) -> String,
        safeDouble: (String) -> Double
    ) -> ([String], [Double]) {
        guard components.count > 48 else { return ([], []) }
        
        let maxItems = min(37, components.count - 48)
        
        let results = (0..<maxItems).compactMap { i -> (String, Double)? in
            let conceptoIndex = 11 + i
            let importeIndex = 48 + i
            
            guard conceptoIndex < components.count && importeIndex < components.count else {
                return nil
            }
            
            let concepto = clean(components[conceptoIndex])
            guard !concepto.isEmpty && concepto.lowercased() != "nan" else {
        return nil
    }
            
            let importe = safeDouble(components[importeIndex])
            return (concepto, importe)
        }
        
        let conceptos = results.map { $0.0 }
        let importes = results.map { $0.1 }
        
        return (conceptos, importes)
    }
} 

// MARK: - Extensiones funcionales para formateo de moneda
extension Double {
    // Formateo a moneda mexicana - función pura
    func toMexicanCurrency() -> String {
        formatCurrency(amount: self, includeCents: true)
    }
    
    // Formateo especial para líquido (centavos a pesos)
    func toLiquidoCurrency() -> String {
        formatCurrency(amount: self / 100.0, includeCents: true)
    }
}

// Función pura para formatear moneda
private func formatCurrency(amount: Double, includeCents: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = includeCents ? 2 : 0
    formatter.minimumFractionDigits = includeCents ? 2 : 0
    
    return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
} 

// MARK: - Validaciones funcionales
extension PayrollRecord {
    // Validar que el registro tenga datos mínimos
    var isValid: Bool {
        !rfc.isEmpty && !nombre.isEmpty && liquido > 0
    }
    
    // Validar RFC con expresión regular
    var hasValidRFC: Bool {
        validateRFC(rfc)
    }
    }
    
// Función pura para validar RFC mexicano
private func validateRFC(_ rfc: String) -> Bool {
    let rfcPattern = "^[A-Z&Ñ]{3,4}[0-9]{6}[A-Z0-9]{3}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", rfcPattern)
    return predicate.evaluate(with: rfc.uppercased())
}
