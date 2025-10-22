# Ejemplos de Uso - SICOPA con Supabase

Este documento contiene ejemplos prácticos de cómo usar Supabase en la aplicación SICOPA.

---

## 📋 Tabla de Contenidos

1. [Autenticación](#autenticación)
2. [Gestión de Registros de Nómina](#gestión-de-registros-de-nómina)
3. [Manejo de Errores](#manejo-de-errores)
4. [Ejemplos Avanzados](#ejemplos-avanzados)

---

## 🔐 Autenticación

### Registro de Usuario

```swift
import SwiftUI

struct MiVistaDeRegistro: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Contraseña", text: $password)

            Button("Registrarse") {
                Task {
                    do {
                        try await supabaseManager.signUp(
                            email: email,
                            password: password
                        )
                        // Usuario registrado exitosamente
                    } catch {
                        errorMessage = "Error al registrar"
                        showError = true
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
}
```

### Inicio de Sesión

```swift
struct MiVistaDeLogin: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Contraseña", text: $password)

            Button("Iniciar Sesión") {
                Task {
                    do {
                        try await supabaseManager.signIn(
                            email: email,
                            password: password
                        )
                        // Login exitoso
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
}
```

### Cerrar Sesión

```swift
Button("Cerrar Sesión") {
    Task {
        do {
            try await supabaseManager.signOut()
            // Sesión cerrada exitosamente
        } catch {
            print("Error al cerrar sesión: \(error)")
        }
    }
}
```

### Recuperar Contraseña

```swift
Button("Olvidé mi contraseña") {
    Task {
        do {
            try await supabaseManager.resetPassword(email: email)
            // Email de recuperación enviado
        } catch {
            print("Error: \(error)")
        }
    }
}
```

### Verificar Estado de Autenticación

```swift
struct MiVista: View {
    @EnvironmentObject var supabaseManager: SupabaseManager

    var body: some View {
        Group {
            if supabaseManager.isAuthenticated {
                Text("Bienvenido, \(supabaseManager.currentUser?.email ?? "")")
            } else {
                Text("Por favor, inicia sesión")
            }
        }
    }
}
```

---

## 📊 Gestión de Registros de Nómina

### Guardar un Registro

```swift
func guardarRegistroDeNomina() {
    let record = PayrollRecord(
        plaza: "001",
        grupo: "A",
        rfc: "MIAJ850101XYZ",
        nombre: "Juan Pérez García",
        liquido: 15000.00,
        cct: "12DES0001K",
        cheque: "001234",
        puesto_cdc: "Docente de Tiempo Completo",
        desde_pag: "01/01/2024",
        hasta_pag: "15/01/2024",
        motivo: "Pago Quincenal",
        conceptos: [
            "Sueldo Base",
            "Compensación",
            "Estímulo Docente",
            "ISR",
            "ISSSTE"
        ],
        importes: [
            12000.00,
            2000.00,
            1500.00,
            -800.00,
            -700.00
        ]
    )

    Task {
        do {
            try await SupabaseManager.shared.savePayrollRecord(record)
            print("✅ Registro guardado exitosamente")
        } catch {
            print("❌ Error al guardar: \(error.localizedDescription)")
        }
    }
}
```

### Consultar Registros del Usuario

```swift
struct MisRegistrosView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var records: [PayrollRecord] = []
    @State private var isLoading = false

    var body: some View {
        List(records) { record in
            VStack(alignment: .leading) {
                Text(record.nombre)
                    .font(.headline)
                Text("RFC: \(record.rfc)")
                    .font(.caption)
                Text(record.liquido.toLiquidoCurrency())
                    .font(.title3)
                    .foregroundColor(.green)
            }
        }
        .task {
            await cargarRegistros()
        }
    }

    func cargarRegistros() async {
        isLoading = true

        do {
            records = try await supabaseManager.fetchPayrollRecords()
            print("📊 Registros cargados: \(records.count)")
        } catch {
            print("❌ Error al cargar: \(error)")
        }

        isLoading = false
    }
}
```

### Filtrar Registros por RFC

```swift
func buscarPorRFC(rfc: String) async -> [PayrollRecord] {
    do {
        let todosLosRegistros = try await SupabaseManager.shared.fetchPayrollRecords()
        return todosLosRegistros.filter { $0.rfc == rfc }
    } catch {
        print("Error: \(error)")
        return []
    }
}
```

### Calcular Estadísticas

```swift
struct EstadisticasView: View {
    @State private var records: [PayrollRecord] = []

    var totalPercibido: Double {
        records.reduce(0.0) { $0 + $1.totalPercepciones }
    }

    var totalDeducido: Double {
        records.reduce(0.0) { $0 + $1.totalDeducciones }
    }

    var liquidoTotal: Double {
        records.reduce(0.0) { $0 + $1.liquido }
    }

    var body: some View {
        VStack(spacing: 20) {
            StatCard(
                title: "Total Percibido",
                value: totalPercibido.toMexicanCurrency()
            )

            StatCard(
                title: "Total Deducido",
                value: totalDeducido.toMexicanCurrency()
            )

            StatCard(
                title: "Líquido Total",
                value: liquidoTotal.toMexicanCurrency()
            )
        }
        .task {
            do {
                records = try await SupabaseManager.shared.fetchPayrollRecords()
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

---

## ⚠️ Manejo de Errores

### Capturar Errores Específicos

```swift
func manejarAutenticacion(email: String, password: String) {
    Task {
        do {
            try await supabaseManager.signIn(email: email, password: password)
            // Login exitoso
        } catch {
            // Acceder al error específico de Supabase
            if let authError = supabaseManager.authError {
                switch authError.message {
                case let msg where msg.contains("Invalid login credentials"):
                    print("❌ Credenciales incorrectas")
                case let msg where msg.contains("Email already registered"):
                    print("❌ Email ya registrado")
                default:
                    print("❌ Error: \(authError.message)")
                }
            }
        }
    }
}
```

### Mostrar Errores al Usuario

```swift
struct LoginViewConErrores: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var showAlert = false
    @State private var alertMessage = ""

    func login() {
        Task {
            do {
                try await supabaseManager.signIn(email: email, password: password)
            } catch {
                await MainActor.run {
                    alertMessage = supabaseManager.authError?.message
                        ?? "Error desconocido"
                    showAlert = true
                }
            }
        }
    }

    var body: some View {
        // ... tu vista
            .alert("Error de Autenticación", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
    }
}
```

---

## 🚀 Ejemplos Avanzados

### Sincronización Automática

```swift
class PayrollSyncService: ObservableObject {
    @Published var records: [PayrollRecord] = []
    private let supabaseManager = SupabaseManager.shared

    // Sincronizar cada 30 segundos
    func startAutoSync() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            Task {
                await self.sync()
            }
        }
    }

    func sync() async {
        do {
            records = try await supabaseManager.fetchPayrollRecords()
            print("🔄 Sincronización exitosa: \(records.count) registros")
        } catch {
            print("❌ Error en sincronización: \(error)")
        }
    }
}
```

### Guardar Múltiples Registros

```swift
func importarRegistrosCSV(csvURL: URL) async {
    // Leer CSV y parsear
    let csvContent = try? String(contentsOf: csvURL)
    guard let content = csvContent else { return }

    let records = PayrollCSVParser.parseRecords(from: content)

    // Guardar todos los registros
    for record in records {
        do {
            try await SupabaseManager.shared.savePayrollRecord(record)
            print("✅ Guardado: \(record.nombre)")
        } catch {
            print("❌ Error guardando \(record.nombre): \(error)")
        }
    }

    print("📊 Importación completa: \(records.count) registros")
}
```

### Búsqueda en Tiempo Real

```swift
struct BusquedaEnTiempoReal: View {
    @State private var searchText = ""
    @State private var allRecords: [PayrollRecord] = []

    var filteredRecords: [PayrollRecord] {
        if searchText.isEmpty {
            return allRecords
        }
        return allRecords.filter { record in
            record.nombre.localizedCaseInsensitiveContains(searchText) ||
            record.rfc.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText)

            List(filteredRecords) { record in
                RecordRow(record: record)
            }
        }
        .task {
            do {
                allRecords = try await SupabaseManager.shared.fetchPayrollRecords()
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

### Validación Antes de Guardar

```swift
func guardarConValidacion(record: PayrollRecord) async throws {
    // Validar que el registro sea válido
    guard record.isValid else {
        throw ValidationError.invalidRecord
    }

    // Validar RFC
    guard record.hasValidRFC else {
        throw ValidationError.invalidRFC
    }

    // Guardar si pasa todas las validaciones
    try await SupabaseManager.shared.savePayrollRecord(record)
}

enum ValidationError: Error, LocalizedError {
    case invalidRecord
    case invalidRFC

    var errorDescription: String? {
        switch self {
        case .invalidRecord:
            return "El registro no contiene datos válidos"
        case .invalidRFC:
            return "El RFC no tiene el formato correcto"
        }
    }
}
```

---

## 💡 Tips y Mejores Prácticas

### 1. Usar Task para Operaciones Asíncronas

```swift
// ✅ Correcto
Button("Guardar") {
    Task {
        try await supabaseManager.savePayrollRecord(record)
    }
}

// ❌ Incorrecto (no funciona en sincronía)
Button("Guardar") {
    try await supabaseManager.savePayrollRecord(record) // Error!
}
```

### 2. Manejar Estados de Carga

```swift
@State private var isLoading = false

func cargarDatos() {
    isLoading = true

    Task {
        do {
            let records = try await supabaseManager.fetchPayrollRecords()
            await MainActor.run {
                self.records = records
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
```

### 3. Actualizar UI en Main Thread

```swift
Task {
    let records = try await supabaseManager.fetchPayrollRecords()

    // Actualizar UI en el Main Thread
    await MainActor.run {
        self.records = records
        self.isLoading = false
    }
}
```

---

## 🔗 Enlaces Útiles

- [Documentación de Supabase](https://supabase.com/docs)
- [Supabase Swift SDK](https://github.com/supabase/supabase-swift)
- [SUPABASE_SETUP.md](SUPABASE_SETUP.md)
- [README.md](README.md)

---

**¿Tienes más preguntas?** Consulta la documentación oficial o abre un issue en GitHub.
