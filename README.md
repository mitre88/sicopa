# SICOPA - Sistema de Consulta de Pagos

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2016.0+-lightgrey.svg)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

Una aplicación iOS moderna para consulta de nóminas con diseño Liquid Glass y autenticación en la nube.

</div>

---

## 📱 Características

- ✨ **Diseño Liquid Glass**: Interfaz moderna con efectos visuales fluidos
- 🔐 **Autenticación Segura**: Login y registro con Supabase
- ☁️ **Datos en la Nube**: Sincronización automática de registros de nómina
- 🔒 **Seguridad RLS**: Row Level Security para protección de datos
- 🌙 **Modo Oscuro**: Soporte completo para tema claro y oscuro
- 📊 **Búsqueda Optimizada**: Sistema de búsqueda rápida de registros
- 🎨 **Animaciones Fluidas**: Transiciones suaves y feedback háptico

---

## 🏗️ Arquitectura

### Tecnologías Utilizadas

- **Swift 5.9+**: Lenguaje de programación
- **SwiftUI**: Framework de UI declarativa
- **Supabase**: Backend as a Service
  - Authentication
  - PostgreSQL Database
  - Row Level Security (RLS)
- **Combine**: Programación reactiva
- **San Francisco Pro**: Tipografía nativa de Apple

### Estructura del Proyecto

```
sicopa/
├── Models/
│   └── PayrollRecord.swift          # Modelo de registros de nómina
├── Views/
│   ├── LoginView.swift              # Vista de inicio de sesión
│   ├── RegisterView.swift           # Vista de registro
│   ├── StartView.swift              # Vista principal
│   └── SimpleSearchView.swift       # Vista de búsqueda
├── Managers/
│   ├── SupabaseManager.swift        # Gestión de Supabase
│   └── AppearanceManager.swift      # Gestión de apariencia
├── Styles/
│   └── LiquidGlass/                 # Estilos Liquid Glass
└── sicopaApp.swift                  # Punto de entrada
```

---

## 🚀 Instalación

### Requisitos Previos

- Xcode 15.0 o superior
- iOS 16.0 o superior
- Cuenta de Supabase (gratuita)

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/mitre88/sicopa.git
cd sicopa
```

### Paso 2: Instalar Dependencias

1. Abre `sicopa.xcodeproj` en Xcode
2. Ve a **File → Add Package Dependencies...**
3. Agrega el paquete de Supabase:
   ```
   https://github.com/supabase/supabase-swift
   ```
4. Selecciona la versión más reciente (2.x.x)
5. Marca las siguientes dependencias:
   - ✅ Supabase
   - ✅ Auth
   - ✅ PostgREST
   - ✅ Realtime

### Paso 3: Configurar Supabase

#### 3.1 Crear Proyecto en Supabase

1. Ve a [app.supabase.com](https://app.supabase.com)
2. Crea un nuevo proyecto
3. Anota tu **Project URL** y **API Key (anon/public)**

#### 3.2 Configurar la Base de Datos

1. En tu proyecto de Supabase, ve a **SQL Editor**
2. Ejecuta el siguiente SQL:

```sql
-- Crear tabla para almacenar registros de nómina
CREATE TABLE payroll_records (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    plaza TEXT NOT NULL,
    grupo TEXT NOT NULL,
    rfc TEXT NOT NULL,
    nombre TEXT NOT NULL,
    liquido NUMERIC NOT NULL,
    cct TEXT NOT NULL,
    cheque TEXT NOT NULL,
    puesto_cdc TEXT NOT NULL,
    desde_pag TEXT NOT NULL,
    hasta_pag TEXT NOT NULL,
    motivo TEXT NOT NULL,
    conceptos TEXT[] NOT NULL,
    importes NUMERIC[] NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Crear índices
CREATE INDEX idx_payroll_records_user_id ON payroll_records(user_id);
CREATE INDEX idx_payroll_records_rfc ON payroll_records(rfc);
CREATE INDEX idx_payroll_records_created_at ON payroll_records(created_at DESC);

-- Habilitar Row Level Security
ALTER TABLE payroll_records ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
CREATE POLICY "Users can view their own payroll records"
    ON payroll_records FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payroll records"
    ON payroll_records FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own payroll records"
    ON payroll_records FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own payroll records"
    ON payroll_records FOR DELETE
    USING (auth.uid() = user_id);
```

#### 3.3 Actualizar Credenciales en el Código

Abre `sicopa/Managers/SupabaseManager.swift` y actualiza:

```swift
let supabaseURL = URL(string: "TU_PROJECT_URL")!
let supabaseKey = "TU_ANON_KEY"
```

### Paso 4: Compilar y Ejecutar

1. Selecciona un simulador o dispositivo
2. Presiona `Cmd + R` para compilar y ejecutar

---

## 📖 Uso

### Registro de Usuario

1. Abre la aplicación
2. Toca **"¿No tienes cuenta? Regístrate"**
3. Ingresa tu email y contraseña
4. Toca **"Crear Cuenta"**

### Inicio de Sesión

1. Ingresa tu email y contraseña
2. Toca **"Iniciar Sesión"**
3. Accederás a la vista principal

### Guardar Registros de Nómina

```swift
let record = PayrollRecord(
    plaza: "001",
    grupo: "A",
    rfc: "ABCD123456XYZ",
    nombre: "Juan Pérez",
    liquido: 15000.00,
    cct: "12345",
    cheque: "001234",
    puesto_cdc: "Docente",
    desde_pag: "01/01/2024",
    hasta_pag: "15/01/2024",
    motivo: "Quincenal",
    conceptos: ["Sueldo Base", "Bono"],
    importes: [12000.00, 3000.00]
)

Task {
    try await SupabaseManager.shared.savePayrollRecord(record)
}
```

### Consultar Registros

```swift
Task {
    let records = try await SupabaseManager.shared.fetchPayrollRecords()
    print("Registros: \(records.count)")
}
```

---

## 🔐 Seguridad

- ✅ **Row Level Security (RLS)**: Cada usuario solo puede acceder a sus propios datos
- ✅ **Autenticación JWT**: Token seguro en cada solicitud
- ✅ **HTTPS**: Todas las comunicaciones encriptadas
- ✅ **Validación de datos**: En cliente y servidor
- ⚠️ **Nota**: Para producción, mueve las credenciales de Supabase a variables de entorno

---

## 🎨 Diseño Liquid Glass

El proyecto utiliza un sistema de diseño personalizado "Liquid Glass" que incluye:

- **Morfismo Líquido**: Efectos de vidrio esmerilado
- **Gradientes Dinámicos**: Colores fluidos y animados
- **Animaciones Elásticas**: Transiciones suaves
- **Feedback Háptico**: Respuesta táctil en interacciones
- **Tipografía San Francisco Pro**: Fuente nativa de Apple

---

## 📚 Documentación Adicional

- [SUPABASE_SETUP.md](SUPABASE_SETUP.md) - Guía detallada de configuración de Supabase
- [Documentación de Supabase](https://supabase.com/docs)
- [Supabase Swift SDK](https://github.com/supabase/supabase-swift)

---

## 🛠️ Desarrollo

### Roadmap

- [ ] Sincronización en tiempo real con Realtime
- [ ] Modo offline con caché local
- [ ] Exportar reportes en PDF
- [ ] Notificaciones push
- [ ] Compartir registros
- [ ] Búsqueda avanzada con filtros
- [ ] Gráficas y estadísticas

### Contribuir

1. Fork el proyecto
2. Crea una rama: `git checkout -b feature/nueva-funcionalidad`
3. Commit tus cambios: `git commit -m 'Agregar nueva funcionalidad'`
4. Push a la rama: `git push origin feature/nueva-funcionalidad`
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**Dr. Alex Mitre**

- GitHub: [@mitre88](https://github.com/mitre88)

---

## 🙏 Agradecimientos

- [Supabase](https://supabase.com) - Backend as a Service
- [Apple](https://developer.apple.com) - Swift y SwiftUI
- Comunidad de Swift

---

<div align="center">

**Hecho con ❤️ y Swift**

</div>
