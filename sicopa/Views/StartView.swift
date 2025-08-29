import SwiftUI

struct StartView: View {
    @State private var animate = false
    @State private var showingHero = false
    @State private var showingContent = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo Liquid Glass con burbujas animadas
                LiquidGlassBackground()
                
                VStack(spacing: 32) {
                    Spacer(minLength: 0)
                    
                    // Hero animado
                    if showingHero {
                        hero
                            .transition(.liquidScale)
                    }
                    
                    // Contenido principal
                    if showingContent {
                        VStack(spacing: 24) {
                            title
                            subtitle
                            primaryCTA
                            appearanceToggle
                        }
                        .transition(.liquidSlide)
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                animateIn()
            }
        }
    }
    
    // MARK: - Animación de entrada
    private func animateIn() {
        withAnimation(FluidAnimation.elastic.delay(0.3)) {
            showingHero = true
        }
        
        withAnimation(FluidAnimation.elastic.delay(0.6)) {
            showingContent = true
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.0)) {
            animate = true
        }
    }
    
    // MARK: - Hero Icon
    private var hero: some View {
        ZStack {
            // Contenedor con morfismo líquido
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.clear)
                .frame(width: 180, height: 180)
                .liquidMorphism(cornerRadius: 32)
                .scaleEffect(animate ? 1.05 : 0.95)
                .shadow(
                    color: Color.liquidPrimary.opacity(0.3),
                    radius: animate ? 30 : 20,
                    x: 0,
                    y: animate ? 15 : 10
                )
            
            // Icono con gradiente dinámico
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 72, weight: .semibold))
                .foregroundStyle(Color.liquidGradient)
                .scaleEffect(animate ? 1.0 : 0.9)
                .rotationEffect(.degrees(animate ? 5 : -5))
        }
    }
    
    // MARK: - Título
    private var title: some View {
        Text("CDC Mobile")
            .font(.system(size: 42, weight: .bold, design: .rounded))
            .foregroundStyle(
                isDarkMode 
                    ? AnyShapeStyle(.white)
                    : AnyShapeStyle(Color.liquidGradient)
            )
            .shadow(color: Color.liquidPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Subtítulo
    private var subtitle: some View {
        Text("Consulta de nómina con estilo Liquid Glass")
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .opacity(0.9)
    }
    
    // MARK: - Botón principal
    private var primaryCTA: some View {
        NavigationLink(destination: SimpleSearchView()) {
            HStack(spacing: 12) {
                Text("Comenzar Búsqueda")
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .rotationEffect(.degrees(animate ? 0 : -45))
            }
        }
        .buttonStyle(LiquidGlassButton())
        .shadow(
            color: Color.liquidPrimary.opacity(0.4),
            radius: 20,
            x: 0,
            y: 10
        )
        .scaleEffect(animate ? 1.02 : 0.98)
        .onTapGesture {
            HapticManager.impact(.medium)
        }
    }
    
    // MARK: - Toggle de apariencia
    private var appearanceToggle: some View {
        HStack(spacing: 16) {
            // Icono animado
            ZStack {
                if isDarkMode {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(isDarkMode ? 0 : 180))
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                } else {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 24, weight: .medium))
                                                 .foregroundStyle(
                             AnyShapeStyle(LinearGradient(
                                 colors: [.orange, .yellow],
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing
                             ))
                         )
                        .rotationEffect(.degrees(isDarkMode ? -180 : 0))
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .animation(FluidAnimation.elastic, value: isDarkMode)
            
            Toggle(isDarkMode ? "Modo oscuro" : "Modo claro", isOn: $isDarkMode)
                .toggleStyle(LiquidToggleStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .liquidGlass(cornerRadius: 16, intensity: 0.8)
        .frame(maxWidth: 320)
        .onChange(of: isDarkMode) { _ in
            HapticManager.selection()
        }
    }
}

// MARK: - Toggle Liquid Glass personalizado
struct LiquidToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.system(size: 16, weight: .medium, design: .rounded))
            
            Spacer()
            
            ZStack {
                // Fondo del toggle
                Capsule()
                    .fill(configuration.isOn ? AnyShapeStyle(Color.liquidGradient) : AnyShapeStyle(Color.gray.opacity(0.3)))
                    .frame(width: 50, height: 30)
                
                // Círculo del toggle
                Circle()
                    .fill(.white)
                    .frame(width: 26, height: 26)
                    .shadow(
                        color: .black.opacity(0.2),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(FluidAnimation.bounce, value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
} 