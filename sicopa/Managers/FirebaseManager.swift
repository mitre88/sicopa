//
//  FirebaseManager.swift
//  sicopa
//
//  Created by Dr. Alex Mitre
//

import Foundation
import FirebaseAuth
import FirebaseCore
import Combine

/// Manager centralizado para gestionar autenticación de Firebase
final class FirebaseManager: ObservableObject {

    // MARK: - Singleton
    static let shared = FirebaseManager()

    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var authError: AuthError?

    // MARK: - Private Properties
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    // MARK: - Initialization
    private init() {
        setupAuthStateListener()
    }

    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }

    // MARK: - Auth State Listener

    /// Configura el listener de estado de autenticación
    private func setupAuthStateListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = user != nil
            }
        }
    }

    // MARK: - Authentication Methods

    /// Inicia sesión con email y contraseña
    /// - Parameters:
    ///   - email: Email del usuario
    ///   - password: Contraseña del usuario
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)

            DispatchQueue.main.async { [weak self] in
                self?.currentUser = result.user
                self?.isAuthenticated = true
                self?.authError = nil
            }
        } catch let error as NSError {
            DispatchQueue.main.async { [weak self] in
                self?.authError = AuthError(from: error)
            }
            throw error
        }
    }

    /// Registra un nuevo usuario con email y contraseña
    /// - Parameters:
    ///   - email: Email del usuario
    ///   - password: Contraseña del usuario
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            DispatchQueue.main.async { [weak self] in
                self?.currentUser = result.user
                self?.isAuthenticated = true
                self?.authError = nil
            }
        } catch let error as NSError {
            DispatchQueue.main.async { [weak self] in
                self?.authError = AuthError(from: error)
            }
            throw error
        }
    }

    /// Cierra la sesión del usuario actual
    func signOut() throws {
        do {
            try Auth.auth().signOut()

            DispatchQueue.main.async { [weak self] in
                self?.currentUser = nil
                self?.isAuthenticated = false
                self?.authError = nil
            }
        } catch let error as NSError {
            DispatchQueue.main.async { [weak self] in
                self?.authError = AuthError(from: error)
            }
            throw error
        }
    }

    /// Restablece la contraseña del usuario
    /// - Parameter email: Email del usuario
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)

            DispatchQueue.main.async { [weak self] in
                self?.authError = nil
            }
        } catch let error as NSError {
            DispatchQueue.main.async { [weak self] in
                self?.authError = AuthError(from: error)
            }
            throw error
        }
    }
}

// MARK: - Auth Error Model

/// Modelo de errores de autenticación
struct AuthError: Identifiable {
    let id = UUID()
    let title: String
    let message: String

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    init(from error: NSError) {
        self.title = "Error de autenticación"

        // Mapear códigos de error de Firebase a mensajes en español
        switch AuthErrorCode.Code(rawValue: error.code) {
        case .emailAlreadyInUse:
            self.message = "Este correo electrónico ya está registrado"
        case .invalidEmail:
            self.message = "El correo electrónico no es válido"
        case .weakPassword:
            self.message = "La contraseña debe tener al menos 6 caracteres"
        case .userNotFound:
            self.message = "No se encontró un usuario con este correo"
        case .wrongPassword:
            self.message = "La contraseña es incorrecta"
        case .networkError:
            self.message = "Error de conexión. Verifica tu internet"
        case .tooManyRequests:
            self.message = "Demasiados intentos. Inténtalo más tarde"
        case .userDisabled:
            self.message = "Esta cuenta ha sido deshabilitada"
        default:
            self.message = error.localizedDescription
        }
    }
}
