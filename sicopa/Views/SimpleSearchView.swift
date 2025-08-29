import SwiftUI

struct SimpleSearchView: View {
    @StateObject private var viewModel = SimpleSearchViewModel()
    @State private var isMenuOpen = false
    @State private var showResults = false
    @State private var searchFieldAnimated = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo Liquid Glass
                LiquidGlassBackground()
                
                VStack(spacing: 0) {
                    // Header con búsqueda mejorado
                    searchHeader
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                    
                    // Contenido principal con animaciones
                    mainContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Menú inferior Liquid Glass
                BottomMenuView(isMenuOpen: $isMenuOpen)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            animateSearchField()
        }
    }
    
    // MARK: - Animaciones
    private func animateSearchField() {
        withAnimation(FluidAnimation.elastic.delay(0.3)) {
            searchFieldAnimated = true
        }
        
        // Auto-focus en el campo de búsqueda
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isSearchFocused = true
        }
    }
    
    // MARK: - Search Header Mejorado
    private var searchHeader: some View {
        VStack(spacing: 20) {
            // Logo animado
            HStack(spacing: 12) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color.liquidGradient)
                    .rotationEffect(.degrees(searchFieldAnimated ? 0 : -180))
                    .scaleEffect(searchFieldAnimated ? 1 : 0.5)
                
                Text("CDC Mobile")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        isDarkMode 
                            ? AnyShapeStyle(.white)
                            : AnyShapeStyle(Color.liquidGradient)
                    )
            }
            .padding(.bottom, 8)
            
            Text("Búsqueda de Talón de Cheque")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .opacity(searchFieldAnimated ? 1 : 0)
                .offset(y: searchFieldAnimated ? 0 : 20)
            
            // Campo de búsqueda con Liquid Glass
            if searchFieldAnimated {
                HStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(
                            isSearchFocused 
                                ? AnyShapeStyle(Color.liquidGradient)
                                : AnyShapeStyle(Color.secondary)
                        )
                        .animation(FluidAnimation.smooth, value: isSearchFocused)
                    
                    TextField("RFC o Nombre del empleado", text: $viewModel.searchText)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .textFieldStyle(.plain)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .focused($isSearchFocused)
                    
                    // Indicadores de estado
                    if viewModel.isLoading {
                        LiquidLoadingIndicator()
                            .transition(.scale.combined(with: .opacity))
                    } else if !viewModel.searchText.isEmpty {
                        Button(action: {
                            HapticManager.selection()
                            viewModel.clearSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding(20)
                .liquidGlass(cornerRadius: 16, intensity: isSearchFocused ? 1.0 : 0.8)
                .scaleEffect(isSearchFocused ? 1.02 : 1.0)
                .animation(FluidAnimation.bounce, value: isSearchFocused)
                .transition(.liquidScale)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Main Content con animaciones mejoradas
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch viewModel.state {
                case .idle:
                    emptyStateAnimated
                        .transition(.liquidScale)
                    
                case .searching:
                    searchingStateAnimated
                        .transition(.liquidScale)
                    
                case .found(let records):
                    resultsListAnimated(records: records)
                        .transition(.liquidSlide)
                    
                case .notFound:
                    notFoundStateAnimated
                        .transition(.liquidScale)
                    
                case .error(let message):
                    errorStateAnimated(message: message)
                        .transition(.liquidScale)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
        .animation(FluidAnimation.elastic, value: viewModel.state)
    }
    
    // MARK: - Estados con animaciones mejoradas
    private var emptyStateAnimated: some View {
        VStack(spacing: 24) {
            ZStack {
                // Efecto de morfismo para el ícono
                Circle()
                    .fill(Color.clear)
                    .frame(width: 120, height: 120)
                    .liquidMorphism(
                        cornerRadius: 60,
                        colors: [.liquidPrimary.opacity(0.3), .liquidSecondary.opacity(0.3)]
                    )
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(.secondary.opacity(0.6))
            }
            
            Text("Buscar Empleado")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("Ingresa el RFC o nombre del empleado para ver su talón de cheque")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    private var searchingStateAnimated: some View {
        VStack(spacing: 24) {
            // Indicador de carga líquido grande
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.liquidGradient)
                        .frame(width: 30, height: 30)
                        .scaleEffect(animationScale(for: index))
                        .opacity(animationOpacity(for: index))
                        .offset(x: xOffset(for: index))
                }
            }
            .frame(height: 60)
            
            Text("Buscando...")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 100)
        .onAppear {
            HapticManager.impact(.light)
        }
    }
    
    // Funciones helper para animación de búsqueda
    @State private var searchAnimation = false
    
    private func animationScale(for index: Int) -> CGFloat {
        searchAnimation ? 1.2 : 0.8
    }
    
    private func animationOpacity(for index: Int) -> Double {
        searchAnimation ? 0.5 : 1.0
    }
    
    private func xOffset(for index: Int) -> CGFloat {
        CGFloat(index - 1) * 40
    }
    
    private var notFoundStateAnimated: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, value: viewModel.state)
            }
            
            Text("No encontrado")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("No se encontró ningún empleado con '\(viewModel.searchText)'")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 100)
        .onAppear {
            HapticManager.notification(.warning)
        }
    }
    
    private func errorStateAnimated(message: String) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse, value: viewModel.state)
            }
            
            Text("Error")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(message)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 100)
        .onAppear {
            HapticManager.notification(.error)
        }
    }
    
    // MARK: - Lista de resultados con animaciones
    private func resultsListAnimated(records: [PayrollRecord]) -> some View {
        VStack(spacing: 20) {
            // Header mejorado
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.green)
                        
                        Text("\(records.count) resultado\(records.count == 1 ? "" : "s")")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    if records.count > 1 {
                        let uniqueRFCs = Set(records.map { $0.rfc })
                        HStack(spacing: 6) {
                            Image(systemName: uniqueRFCs.count == 1 ? "person.fill" : "person.2.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(uniqueRFCs.count == 1 ? .blue : .green)
                            
                            Text(uniqueRFCs.count == 1 
                                ? "\(records.count) cheques del mismo empleado"
                                : "\(uniqueRFCs.count) empleados diferentes")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 8)
            .onAppear {
                HapticManager.notification(.success)
            }
            
            // Lista con animación escalonada
            LazyVStack(spacing: 16) {
                ForEach(records.indices, id: \.self) { index in
                    NavigationLink(destination: PaystubDetailView(record: records[index])) {
                        resultCardAnimated(record: records[index], index: index, totalCount: records.count)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing)
                                    .combined(with: .opacity)
                                    .animation(FluidAnimation.elastic.delay(Double(index) * 0.1)),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Tarjeta de resultado mejorada
    private func resultCardAnimated(record: PayrollRecord, index: Int, totalCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header con animaciones
            HStack {
                // Número de cheque animado
                if totalCount > 1 {
                    ZStack {
                        Circle()
                            .fill(Color.liquidGradient)
                            .frame(width: 32, height: 32)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Información del empleado
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.formattedName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Label(record.rfc, systemImage: "person.text.rectangle")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Monto con efecto shimmer
                VStack(alignment: .trailing, spacing: 4) {
                    Text(record.liquido.toLiquidoCurrency())
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .contentTransition(.numericText())
                    
                    Label("Cheque \(record.cheque)", systemImage: "doc.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.blue)
                }
            }
            
            // Divider con gradiente
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.secondary.opacity(0.1),
                            Color.secondary.opacity(0.3),
                            Color.secondary.opacity(0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            // Resumen financiero mejorado
            HStack(spacing: 0) {
                // Percepciones
                VStack(alignment: .leading, spacing: 4) {
                    Label("Percepciones", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    
                    Text(record.totalPercepciones.toMexicanCurrency())
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Deducciones
                VStack(alignment: .center, spacing: 4) {
                    Label("Deducciones", systemImage: "minus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                    
                    Text(record.totalDeducciones.toMexicanCurrency())
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                
                // Neto
                VStack(alignment: .trailing, spacing: 4) {
                    Label("Neto", systemImage: "equal.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    Text(record.liquido.toLiquidoCurrency())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // Indicador de conceptos
            if record.conceptos.count > 0 {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue)
                    
                    Text("\(record.conceptos.count) conceptos")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 20)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 5
        )
        .scaleEffect(1.0)
        .onTapGesture {
            HapticManager.selection()
        }
    }
} 