import SwiftUI

// MARK: - Menu Items
enum MenuItem: String, CaseIterable {
    case search = "magnifyingglass"
    case darkMode = "moon.fill"
    case export = "square.and.arrow.up"
    case settings = "gearshape.fill"
    case about = "info.circle.fill"
    
    var title: String {
        switch self {
        case .search: return "Búsqueda"
        case .darkMode: return "Modo Oscuro"
        case .export: return "Exportar"
        case .settings: return "Configuración"
        case .about: return "Acerca de"
        }
    }
}

// MARK: - Bottom Menu View
struct BottomMenuView: View {
    @Binding var isMenuOpen: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedItem: MenuItem?
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var showingExport = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Overlay para cerrar menú
            if isMenuOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isMenuOpen = false
                        }
                    }
                    .transition(.opacity)
            }
            
            // Menú expandido
            if isMenuOpen {
                menuExpandedView
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
            
            // Botón principal del menú
            menuToggleButton
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isMenuOpen)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingExport) {
            ExportView()
        }
    }
    
    // MARK: - Menu Toggle Button
    private var menuToggleButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isMenuOpen.toggle()
            }
        }) {
            ZStack {
                // Fondo Liquid Glass con efecto de burbuja
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Icono con rotación
                Image(systemName: isMenuOpen ? "xmark" : "ellipsis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(isMenuOpen ? 180 : 0))
                    .scaleEffect(isMenuOpen ? 0.9 : 1.0)
            }
        }
        .padding(.bottom, 34)
        .scaleEffect(isMenuOpen ? 1.1 : 1.0)
    }
    
    // MARK: - Expanded Menu
    private var menuExpandedView: some View {
        VStack(spacing: 20) {
            // Items del menú con efectos bubble
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(MenuItem.allCases, id: \.self) { item in
                    menuItemButton(item)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 30)
        }
        .background(
            // Fondo Liquid Glass con blur
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -10)
                
                // Efecto de brillo superior
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 110)
    }
    
    // MARK: - Menu Item Button
    private func menuItemButton(_ item: MenuItem) -> some View {
        Button(action: {
            handleMenuItemTap(item)
        }) {
            VStack(spacing: 8) {
                ZStack {
                    // Fondo con efecto bubble
                    Circle()
                        .fill(.regularMaterial)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.2), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    // Icono con efectos especiales para Dark Mode
                    if item == .darkMode {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(
                                isDarkMode 
                                    ? LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .rotationEffect(.degrees(isDarkMode ? 180 : 0))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isDarkMode)
                    } else {
                        Image(systemName: item.rawValue)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: getItemColors(item),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                Text(item.title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .scaleEffect(selectedItem == item ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedItem)
    }
    
    // MARK: - Helper Functions
    private func getItemColors(_ item: MenuItem) -> [Color] {
        switch item {
        case .search: return [.blue, .cyan]
        case .darkMode: return [.indigo, .purple]
        case .export: return [.green, .mint]
        case .settings: return [.gray, .secondary]
        case .about: return [.orange, .pink]
        }
    }
    
    private func handleMenuItemTap(_ item: MenuItem) {
        // Efecto de selección
        selectedItem = item
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedItem = nil
        }
        
        // Acción según el item
        switch item {
        case .search:
            // Ya estamos en búsqueda, cerrar menú
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isMenuOpen = false
            }
            
        case .darkMode:
            // Toggle Dark Mode con haptic feedback
            if #available(iOS 17.0, *) {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isDarkMode.toggle()
            }
            
        case .export:
            showingExport = true
            
        case .settings:
            showingSettings = true
            
        case .about:
            showingAbout = true
        }
        
        // Cerrar menú después de la acción (excepto para dark mode)
        if item != .darkMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isMenuOpen = false
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("autoExport") private var autoExport = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Apariencia") {
                    HStack {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundStyle(isDarkMode ? .orange : .indigo)
                        Text("Modo Oscuro")
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                    }
                }
                
                Section("Interacción") {
                    HStack {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundStyle(.blue)
                        Text("Vibración Háptica")
                        Spacer()
                        Toggle("", isOn: $enableHaptics)
                    }
                }
                
                Section("Exportación") {
                    HStack {
                        Image(systemName: "square.and.arrow.up.on.square")
                            .foregroundStyle(.green)
                        Text("Auto-exportar datos")
                        Spacer()
                        Toggle("", isOn: $autoExport)
                    }
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 40)
                
                VStack(spacing: 12) {
                    Text("SICOPA Mobile")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Versión 1.0")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text("Sistema de consulta de nóminas con diseño Liquid Glass para iOS 26")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Desarrollado con ❤️")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text("© 2024 CDC SICOPA")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.tertiary)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    Text("Exportar Datos")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Exporta los datos de nómina en diferentes formatos")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 16) {
                    exportButton(title: "Exportar como PDF", icon: "doc.fill", color: .red)
                    exportButton(title: "Exportar como CSV", icon: "tablecells.fill", color: .green)
                    exportButton(title: "Compartir por Email", icon: "envelope.fill", color: .blue)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Exportar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportButton(title: String, icon: String, color: Color) -> some View {
        Button(action: {
            // TODO: Implementar exportación
            print("Exportando: \(title)")
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
} 