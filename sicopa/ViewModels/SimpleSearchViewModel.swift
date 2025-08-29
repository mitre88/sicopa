import Foundation
import SwiftUI
import Combine

// MARK: - Estado de búsqueda simple
enum SimpleSearchState: Equatable {
    case idle
    case searching
    case found([PayrollRecord])
    case notFound
    case error(String)
    
    static func == (lhs: SimpleSearchState, rhs: SimpleSearchState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.searching, .searching), (.notFound, .notFound):
            return true
        case (.found(let lhsRecords), .found(let rhsRecords)):
            return lhsRecords.count == rhsRecords.count
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - ViewModel simple para búsqueda
@MainActor
final class SimpleSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var state: SimpleSearchState = .idle
    @Published var isLoading = false
    
    private let searchService = SimpleSearchService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Auto-búsqueda al escribir (con delay)
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task {
                    await self?.performSearch(text)
                }
            }
            .store(in: &cancellables)
    }
    
    // Realizar búsqueda
    func performSearch(_ query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedQuery.isEmpty else {
            state = .idle
            return
        }
        
        isLoading = true
        state = .searching
        
        print("🔍 Iniciando búsqueda: \(trimmedQuery)")
        
        // Intentar como RFC primero - ahora devuelve array
        let rfcResults = await searchService.searchByRFC(trimmedQuery)
        if !rfcResults.isEmpty {
            state = .found(rfcResults)
            print("✅ Encontrados \(rfcResults.count) cheques para RFC: \(trimmedQuery)")
        } else {
            // Si no es RFC, buscar por nombre (puede devolver múltiples resultados)
            let nameResults = await searchService.searchByName(trimmedQuery)
            if !nameResults.isEmpty {
                state = .found(nameResults)
                print("✅ Encontrados \(nameResults.count) resultados por nombre")
            } else {
                state = .notFound
                print("❌ No se encontraron resultados para: \(trimmedQuery)")
            }
        }
        
        isLoading = false
    }
    
    // Búsqueda manual
    func search() {
        Task {
            await performSearch(searchText)
        }
    }
    
    // Limpiar búsqueda
    func clearSearch() {
        searchText = ""
        state = .idle
    }
} 