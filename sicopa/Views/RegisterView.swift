//
//  RegisterView.swift
//  sicopa
//
//  Created by Dr. Alex Mitre
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var supabaseManager: SupabaseManager

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isShowingPassword = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var registerSuccess = false

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

                    // Formulario de registro
                    registerForm

                    // Botón de registro
                    registerButton

                    // Botón para volver al login
                    backToLoginButton

                    Spacer()
                }
                .padding(.horizontal, 24)
                .alert("Error de registro", isPresented: $showingError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $registerSuccess) {
                StartView()
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

                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(Color.liquidGradient)
            }

            VStack(spacing: 8) {
                Text("Crear Cuenta")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        isDarkMode
                            ? AnyShapeStyle(.white)
                            : AnyShapeStyle(Color.liquidGradient)
                    )

                Text("Regístrate en SICOPA")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Register Form

    private var registerForm: some View {
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
                            .textContentType(.newPassword)
                    } else {
                        SecureField("Contraseña", text: $password)
                            .textContentType(.newPassword)
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

            // Campo de confirmar contraseña
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color.liquidPrimary)
                        .frame(width: 20)

                    if isShowingPassword {
                        TextField("Confirmar contraseña", text: $confirmPassword)
                            .textContentType(.newPassword)
                    } else {
                        SecureField("Confirmar contraseña", text: $confirmPassword)
                            .textContentType(.newPassword)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .liquidGlass(cornerRadius: 12, intensity: 0.8)
            }

            // Indicador de requisitos de contraseña
            if !password.isEmpty {
                passwordRequirements
            }
        }
    }

    // MARK: - Password Requirements

    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: 8) {
            RequirementRow(
                text: "Mínimo 6 caracteres",
                isMet: password.count >= 6
            )

            RequirementRow(
                text: "Las contraseñas coinciden",
                isMet: !confirmPassword.isEmpty && password == confirmPassword
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 12, intensity: 0.6)
    }

    // MARK: - Register Button

    private var registerButton: some View {
        Button(action: performRegister) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Text("Crear Cuenta")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .buttonStyle(LiquidGlassButton())
        .disabled(!isFormValid || isLoading)
        .shadow(
            color: Color.liquidPrimary.opacity(0.4),
            radius: 20,
            x: 0,
            y: 10
        )
    }

    // MARK: - Back to Login Button

    private var backToLoginButton: some View {
        Button(action: {
            HapticManager.impact(.light)
            dismiss()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .medium))
                Text("Volver al inicio de sesión")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .liquidGlass(cornerRadius: 12, intensity: 0.6)
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !email.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }

    // MARK: - Functions

    private func performRegister() {
        // Haptic feedback
        HapticManager.impact(.medium)

        // Validar que las contraseñas coincidan
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden"
            showingError = true
            HapticManager.notification(.error)
            return
        }

        isLoading = true

        Task {
            do {
                // Registrar usuario con Supabase
                try await supabaseManager.signUp(email: email, password: password)

                // Registro exitoso
                await MainActor.run {
                    isLoading = false

                    withAnimation(FluidAnimation.elastic) {
                        registerSuccess = true
                    }

                    // Haptic de éxito
                    HapticManager.notification(.success)
                }
            } catch {
                // Error de registro
                await MainActor.run {
                    isLoading = false

                    // Configurar mensaje de error
                    if let authError = supabaseManager.authError {
                        errorMessage = authError.message
                    } else {
                        errorMessage = "Error al crear la cuenta. Inténtalo de nuevo."
                    }

                    showingError = true

                    // Haptic de error
                    HapticManager.notification(.error)
                }
            }
        }
    }
}

// MARK: - Requirement Row

struct RequirementRow: View {
    let text: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isMet ? .green : .secondary)
                .font(.system(size: 14, weight: .medium))

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isMet ? .primary : .secondary)
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(SupabaseManager.shared)
}
