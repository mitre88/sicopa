//
//  SupabaseManager.swift
//  sicopa
//
//  Created by Dr. Alex Mitre
//

import Foundation
import Supabase
import Combine

/// Manager centralizado para gestionar autenticación y base de datos de Supabase
final class SupabaseManager: ObservableObject {

    // MARK: - Singleton
    static let shared = SupabaseManager()

    // MARK: - Supabase Client
    let client: SupabaseClient

    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var authError: AuthError?

    // MARK: - Private Properties
    private var authStateTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        // Configuración de Supabase
        let supabaseURL = URL(string: "https://mdiuxixvvkhnwdakjeub.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kaXV4aXh2dmtobndkYWtqZXViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwOTE5MzAsImV4cCI6MjA3NjY2NzkzMH0.01KujKFTStAZXAr9rUR_fTHwr064ZNdR2upYJ-C1hU4"

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )

        setupAuthStateListener()
    }

    deinit {
        authStateTask?.cancel()
    }

    // MARK: - Auth State Listener

    /// Configura el listener de estado de autenticación
    private func setupAuthStateListener() {
        authStateTask = Task { [weak self] in
            guard let self = self else { return }

            // Escuchar cambios de estado de autenticación
            for await state in await self.client.auth.authStateChanges {
                await MainActor.run {
                    switch state.event {
                    case .initialSession, .signedIn, .tokenRefreshed:
                        self.currentUser = state.session?.user
                        self.isAuthenticated = state.session != nil
                    case .signedOut:
                        self.currentUser = nil
                        self.isAuthenticated = false
                    default:
                        break
                    }
                }
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
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )

            await MainActor.run { [weak self] in
                self?.currentUser = session.user
                self?.isAuthenticated = true
                self?.authError = nil
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.authError = AuthError.from(supabaseError: error)
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
            let session = try await client.auth.signUp(
                email: email,
                password: password
            )

            await MainActor.run { [weak self] in
                self?.currentUser = session.user
                self?.isAuthenticated = true
                self?.authError = nil
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.authError = AuthError.from(supabaseError: error)
            }
            throw error
        }
    }

    /// Cierra la sesión del usuario actual
    func signOut() async throws {
        do {
            try await client.auth.signOut()

            await MainActor.run { [weak self] in
                self?.currentUser = nil
                self?.isAuthenticated = false
                self?.authError = nil
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.authError = AuthError.from(supabaseError: error)
            }
            throw error
        }
    }

    /// Restablece la contraseña del usuario
    /// - Parameter email: Email del usuario
    func resetPassword(email: String) async throws {
        do {
            try await client.auth.resetPasswordForEmail(email)

            await MainActor.run { [weak self] in
                self?.authError = nil
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.authError = AuthError.from(supabaseError: error)
            }
            throw error
        }
    }

    // MARK: - Database Methods

    /// Guarda un registro de nómina en Supabase
    /// - Parameter record: Registro de nómina a guardar
    func savePayrollRecord(_ record: PayrollRecord) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotAuthenticated
        }

        // Crear estructura para insertar en la base de datos
        let recordData: [String: Any] = [
            "user_id": userId.uuidString,
            "plaza": record.plaza,
            "grupo": record.grupo,
            "rfc": record.rfc,
            "nombre": record.nombre,
            "liquido": record.liquido,
            "cct": record.cct,
            "cheque": record.cheque,
            "puesto_cdc": record.puesto_cdc,
            "desde_pag": record.desde_pag,
            "hasta_pag": record.hasta_pag,
            "motivo": record.motivo,
            "conceptos": record.conceptos,
            "importes": record.importes,
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]

        try await client.database
            .from("payroll_records")
            .insert(recordData)
            .execute()
    }

    /// Obtiene todos los registros de nómina del usuario actual
    /// - Returns: Array de registros de nómina
    func fetchPayrollRecords() async throws -> [PayrollRecord] {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotAuthenticated
        }

        let response: [PayrollRecordDTO] = try await client.database
            .from("payroll_records")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        // Convertir DTOs a modelos PayrollRecord
        return response.map { $0.toPayrollRecord() }
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

    static func from(supabaseError error: Error) -> AuthError {
        let errorMessage = error.localizedDescription

        // Mapear errores comunes de Supabase a mensajes en español
        if errorMessage.contains("Invalid login credentials") {
            return AuthError(
                title: "Error de autenticación",
                message: "Correo o contraseña incorrectos"
            )
        } else if errorMessage.contains("Email already registered") {
            return AuthError(
                title: "Error de registro",
                message: "Este correo electrónico ya está registrado"
            )
        } else if errorMessage.contains("Password should be at least 6 characters") {
            return AuthError(
                title: "Error de contraseña",
                message: "La contraseña debe tener al menos 6 caracteres"
            )
        } else if errorMessage.contains("Invalid email") {
            return AuthError(
                title: "Error de email",
                message: "El correo electrónico no es válido"
            )
        } else if errorMessage.contains("Network") || errorMessage.contains("network") {
            return AuthError(
                title: "Error de conexión",
                message: "Verifica tu conexión a internet"
            )
        } else {
            return AuthError(
                title: "Error",
                message: errorMessage
            )
        }
    }
}

// MARK: - Supabase Error

enum SupabaseError: Error, LocalizedError {
    case userNotAuthenticated
    case invalidData

    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Usuario no autenticado"
        case .invalidData:
            return "Datos inválidos"
        }
    }
}

// MARK: - Data Transfer Objects

/// DTO para recibir datos de Supabase
struct PayrollRecordDTO: Codable {
    let id: String?
    let user_id: String
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
    let created_at: String?

    /// Convierte el DTO a un modelo PayrollRecord
    func toPayrollRecord() -> PayrollRecord {
        PayrollRecord(
            plaza: plaza,
            grupo: grupo,
            rfc: rfc,
            nombre: nombre,
            liquido: liquido,
            cct: cct,
            cheque: cheque,
            puesto_cdc: puesto_cdc,
            desde_pag: desde_pag,
            hasta_pag: hasta_pag,
            motivo: motivo,
            conceptos: conceptos,
            importes: importes
        )
    }
}
