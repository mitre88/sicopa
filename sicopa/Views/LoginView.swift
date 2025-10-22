import SwiftUI

struct LoginView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingPassword = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var loginSuccess = false
    @State private var showingRegister = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo Liquid Glass
                LiquidGlassBackground()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo y título
                    logoSection
                    
                    // Formulario de login
                    loginForm
                    
                    // Botón de login
                    loginButton

                    // Botón de registro
                    registerButton

                    Spacer()
                }
                .padding(.horizontal, 24)
                .alert("Error de autenticación", isPresented: $showingError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $loginSuccess) {
                StartView()
            }
            .fullScreenCover(isPresented: $showingRegister) {
                RegisterView()
            }
        }
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.clear)
                    .frame(width: 120, height: 120)
                    .liquidMorphism(cornerRadius: 32)
                    .shadow(
                        color: Color.liquidPrimary.opacity(0.3),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                
                Image(systemName: "person.badge.key.fill")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(Color.liquidGradient)
            }
            
            VStack(spacing: 8) {
                Text("Iniciar Sesión")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        isDarkMode 
                            ? AnyShapeStyle(.white)
                            : AnyShapeStyle(Color.liquidGradient)
                    )
                
                Text("Accede al sistema SICOPA")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 16) {
            // Campo de email
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(Color.liquidPrimary)
                        .frame(width: 20)

                    TextField("Correo electrónico", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .liquidGlass(cornerRadius: 12, intensity: 0.8)
            }
            
            // Campo de contraseña
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color.liquidPrimary)
                        .frame(width: 20)
                    
                    if isShowingPassword {
                        TextField("Contraseña", text: $password)
                            .textContentType(.password)
                    } else {
                        SecureField("Contraseña", text: $password)
                            .textContentType(.password)
                    }
                    
                    Button(action: {
                        isShowingPassword.toggle()
                        HapticManager.selection()
                    }) {
                        Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .liquidGlass(cornerRadius: 12, intensity: 0.8)
            }
        }
    }
    
    // MARK: - Login Button
    private var loginButton: some View {
        Button(action: performLogin) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Text("Iniciar Sesión")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .buttonStyle(LiquidGlassButton())
        .disabled(email.isEmpty || password.isEmpty || isLoading)
        .shadow(
            color: Color.liquidPrimary.opacity(0.4),
            radius: 20,
            x: 0,
            y: 10
        )
    }

    // MARK: - Register Button

    private var registerButton: some View {
        Button(action: {
            HapticManager.impact(.light)
            showingRegister = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 16, weight: .medium))
                Text("¿No tienes cuenta? Regístrate")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .liquidGlass(cornerRadius: 12, intensity: 0.6)
        }
    }

    // MARK: - Functions

    private func performLogin() {
        // Haptic feedback
        HapticManager.impact(.medium)
        isLoading = true

        Task {
            do {
                // Intentar autenticación con Supabase
                try await supabaseManager.signIn(email: email, password: password)

                // Login exitoso
                await MainActor.run {
                    isLoading = false

                    withAnimation(FluidAnimation.elastic) {
                        loginSuccess = true
                    }

                    // Haptic de éxito
                    HapticManager.notification(.success)
                }
            } catch {
                // Error de autenticación
                await MainActor.run {
                    isLoading = false

                    // Configurar mensaje de error
                    if let authError = supabaseManager.authError {
                        errorMessage = authError.message
                    } else {
                        errorMessage = "Error al iniciar sesión. Verifica tus credenciales."
                    }

                    showingError = true

                    // Haptic de error
                    HapticManager.notification(.error)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}