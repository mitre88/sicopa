import SwiftUI

// MARK: - Sistema de Diseño Liquid Glass iOS 26
// Implementación completa del estilo Liquid Glass con efectos avanzados

// MARK: - Colores del Sistema
extension Color {
    // Colores principales con efecto líquido
    static let liquidPrimary = Color(red: 0.0, green: 0.478, blue: 1.0) // Azul fluido
    static let liquidSecondary = Color(red: 0.584, green: 0.0, blue: 0.827) // Púrpura líquido
    static let liquidAccent = Color(red: 0.0, green: 0.827, blue: 0.584) // Verde agua
    
    // Gradientes líquidos
    static let liquidGradient = LinearGradient(
        colors: [.liquidPrimary, .liquidSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let liquidGradientReversed = LinearGradient(
        colors: [.liquidSecondary, .liquidPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Colores de vidrio
    static let glassWhite = Color.white.opacity(0.08)
    static let glassBlack = Color.black.opacity(0.05)
    static let glassBorder = Color.white.opacity(0.2)
    
    // Colores arcoíris para efectos especiales
    static let rainbow1 = Color(red: 1.0, green: 0.0, blue: 0.0)      // Rojo
    static let rainbow2 = Color(red: 1.0, green: 0.5, blue: 0.0)      // Naranja
    static let rainbow3 = Color(red: 1.0, green: 1.0, blue: 0.0)      // Amarillo
    static let rainbow4 = Color(red: 0.0, green: 1.0, blue: 0.0)      // Verde
    static let rainbow5 = Color(red: 0.0, green: 0.0, blue: 1.0)      // Azul
    static let rainbow6 = Color(red: 0.5, green: 0.0, blue: 1.0)      // Violeta
    
    // Función pura para obtener color adaptativo
    static func adaptive(light: Color, dark: Color, colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? dark : light
    }
}

// MARK: - Efectos de Vidrio Líquido
struct LiquidGlassEffect: ViewModifier {
    let cornerRadius: CGFloat
    let intensity: Double
    @Environment(\.colorScheme) var colorScheme
    
    init(cornerRadius: CGFloat = 20, intensity: Double = 1.0) {
        self.cornerRadius = cornerRadius
        self.intensity = intensity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Capa base de vidrio
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(0.8 * intensity)
                    
                    // Efecto de difuminado interno
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1 * intensity),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                    
                    // Borde brillante
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3 * intensity),
                                    Color.white.opacity(0.1 * intensity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: colorScheme == .dark 
                    ? Color.black.opacity(0.3 * intensity)
                    : Color.black.opacity(0.1 * intensity),
                radius: 20 * intensity,
                x: 0,
                y: 10 * intensity
            )
    }
}

// MARK: - Efecto de Morphismo Líquido
struct LiquidMorphismEffect: ViewModifier {
    let shape: RoundedRectangle
    let colors: [Color]
    @State private var animateGradient = false
    
    init(cornerRadius: CGFloat = 20, colors: [Color] = [.liquidPrimary, .liquidSecondary]) {
        self.shape = RoundedRectangle(cornerRadius: cornerRadius)
        self.colors = colors
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Capa de morfismo animado
                    shape
                        .fill(
                            AngularGradient(
                                colors: colors + colors,
                                center: .center,
                                startAngle: .degrees(animateGradient ? 0 : 360),
                                endAngle: .degrees(animateGradient ? 360 : 720)
                            )
                        )
                        .blur(radius: 20)
                        .opacity(0.3)
                    
                    // Capa de vidrio
                    shape
                        .fill(.ultraThinMaterial)
                    
                    // Efecto de luz interna
                    shape
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.2, y: 0.2),
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                    
                    // Borde luminoso
                    shape
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    animateGradient = true
                }
            }
    }
}

// MARK: - Efecto de Burbuja Flotante
struct FloatingBubbleEffect: View {
    @State private var animate = false
    let size: CGFloat
    let color: Color
    let delay: Double
    
    init(size: CGFloat = 100, color: Color = .liquidPrimary, delay: Double = 0) {
        self.size = size
        self.color = color
        self.delay = delay
    }
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.2),
                        color.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .blur(radius: 10)
            .offset(y: animate ? -30 : 30)
            .scaleEffect(animate ? 1.1 : 0.9)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}

// MARK: - Botón Liquid Glass
struct LiquidGlassButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -200
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Gradiente base
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.liquidGradient)
                        .opacity(isEnabled ? 1.0 : 0.6)
                    
                    // Efecto shimmer
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .blendMode(.screen)
                    
                    // Borde brillante
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: Color.liquidPrimary.opacity(0.3),
                radius: configuration.isPressed ? 5 : 15,
                x: 0,
                y: configuration.isPressed ? 2 : 8
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .onAppear {
                withAnimation(
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 200
                }
            }
    }
}

// MARK: - Campo de Texto Liquid Glass
struct LiquidGlassTextField: TextFieldStyle {
    @FocusState private var isFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                ZStack {
                    // Fondo de vidrio
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                    
                    // Borde animado al focus
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? AnyShapeStyle(Color.liquidGradient) : AnyShapeStyle(Color.glassBorder),
                            lineWidth: isFocused ? 2 : 1
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }
            )
            .focused($isFocused)
    }
}

// MARK: - Vista de Fondo Liquid Glass
struct LiquidGlassBackground: View {
    @State private var animateBlobs = false
    
    var body: some View {
        ZStack {
            // Color base adaptativo
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Blobs animados
            FloatingBubbleEffect(size: 300, color: .liquidPrimary, delay: 0)
                .position(x: 100, y: 200)
            
            FloatingBubbleEffect(size: 250, color: .liquidSecondary, delay: 1)
                .position(x: 300, y: 400)
            
            FloatingBubbleEffect(size: 200, color: .liquidAccent, delay: 2)
                .position(x: 200, y: 600)
            
            // Gradiente superior
            LinearGradient(
                colors: [
                    Color.liquidPrimary.opacity(0.1),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Animaciones Fluidas
struct FluidAnimation {
    static let bounce = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let elastic = Animation.spring(response: 0.6, dampingFraction: 0.5)
    static let morphing = Animation.easeInOut(duration: 0.8)
}

// MARK: - Modificadores de Conveniencia
extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, intensity: Double = 1.0) -> some View {
        self.modifier(LiquidGlassEffect(cornerRadius: cornerRadius, intensity: intensity))
    }
    
    func liquidMorphism(cornerRadius: CGFloat = 20, colors: [Color] = [.liquidPrimary, .liquidSecondary]) -> some View {
        self.modifier(LiquidMorphismEffect(cornerRadius: cornerRadius, colors: colors))
    }
    
    func glassCard() -> some View {
        self
            .padding(20)
            .liquidGlass()
            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Transiciones Personalizadas
extension AnyTransition {
    static var liquidScale: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.2).combined(with: .opacity)
        )
    }
    
    static var liquidSlide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    static var bubble: AnyTransition {
        .scale.combined(with: .opacity)
    }
}

// MARK: - Efectos de Haptic Feedback
struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Indicador de Carga Líquido
struct LiquidLoadingIndicator: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.liquidGradient)
                    .frame(width: 15, height: 15)
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .opacity(animate ? 0.5 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: animate
                    )
                    .offset(x: CGFloat(index - 1) * 25)
            }
        }
        .onAppear {
            animate = true
        }
    }
} 