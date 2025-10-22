# Configuración de Supabase para SICOPA

Este documento describe paso a paso cómo configurar la base de datos en Supabase para el proyecto SICOPA.

## Información de Conexión

- **URL del proyecto**: `https://mdiuxixvvkhnwdakjeub.supabase.co`
- **API Key**: Ya está configurada en el código

## Paso 1: Crear la Tabla de Registros de Nómina

Accede a tu proyecto de Supabase y ejecuta el siguiente SQL en el **SQL Editor**:

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

-- Crear índices para mejorar el rendimiento
CREATE INDEX idx_payroll_records_user_id ON payroll_records(user_id);
CREATE INDEX idx_payroll_records_rfc ON payroll_records(rfc);
CREATE INDEX idx_payroll_records_created_at ON payroll_records(created_at DESC);

-- Habilitar Row Level Security (RLS)
ALTER TABLE payroll_records ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios registros
CREATE POLICY "Users can view their own payroll records"
    ON payroll_records
    FOR SELECT
    USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios registros
CREATE POLICY "Users can insert their own payroll records"
    ON payroll_records
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios registros
CREATE POLICY "Users can update their own payroll records"
    ON payroll_records
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios registros
CREATE POLICY "Users can delete their own payroll records"
    ON payroll_records
    FOR DELETE
    USING (auth.uid() = user_id);

-- Función para actualizar automáticamente updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at automáticamente
CREATE TRIGGER update_payroll_records_updated_at
    BEFORE UPDATE ON payroll_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

## Paso 2: Configurar la Autenticación

1. Ve a **Authentication > Settings** en tu proyecto de Supabase
2. Asegúrate de que **Enable email confirmations** esté configurado según tus preferencias:
   - Si quieres que los usuarios confirmen su email antes de poder iniciar sesión, déjalo activado
   - Si quieres que los usuarios puedan iniciar sesión inmediatamente, desactívalo

3. Configura las URLs de redirección en **Authentication > URL Configuration**:
   - Agrega tu esquema de URL personalizado si planeas usar deep linking

## Paso 3: Verificar la Instalación

Para verificar que todo está funcionando correctamente:

1. Compila y ejecuta tu app en Xcode
2. Intenta registrar un nuevo usuario
3. Verifica en Supabase Dashboard:
   - Ve a **Authentication > Users** para ver el usuario creado
   - Ve a **Table Editor > payroll_records** para verificar que la tabla existe

## Estructura de Datos

### Tabla: `payroll_records`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | UUID | Identificador único del registro |
| `user_id` | UUID | ID del usuario (referencia a auth.users) |
| `plaza` | TEXT | Plaza del empleado |
| `grupo` | TEXT | Grupo del empleado |
| `rfc` | TEXT | RFC del empleado |
| `nombre` | TEXT | Nombre completo del empleado |
| `liquido` | NUMERIC | Cantidad líquida a recibir |
| `cct` | TEXT | Centro de Costo |
| `cheque` | TEXT | Número de cheque |
| `puesto_cdc` | TEXT | Puesto en el CDC |
| `desde_pag` | TEXT | Fecha inicio del periodo de pago |
| `hasta_pag` | TEXT | Fecha fin del periodo de pago |
| `motivo` | TEXT | Motivo del pago |
| `conceptos` | TEXT[] | Array de conceptos de pago |
| `importes` | NUMERIC[] | Array de importes correspondientes |
| `created_at` | TIMESTAMP | Fecha de creación del registro |
| `updated_at` | TIMESTAMP | Fecha de última actualización |

## Funcionalidades Implementadas

### Autenticación
- ✅ Registro de usuarios con email/password
- ✅ Inicio de sesión
- ✅ Cierre de sesión
- ✅ Recuperación de contraseña
- ✅ Gestión de estado de autenticación

### Base de Datos
- ✅ Guardar registros de nómina
- ✅ Consultar registros de nómina por usuario
- ✅ Row Level Security (RLS) para proteger datos
- ✅ Índices optimizados para búsquedas rápidas

## Uso en el Código

### Guardar un registro de nómina:
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
    do {
        try await SupabaseManager.shared.savePayrollRecord(record)
        print("✅ Registro guardado exitosamente")
    } catch {
        print("❌ Error al guardar: \(error)")
    }
}
```

### Consultar registros de nómina:
```swift
Task {
    do {
        let records = try await SupabaseManager.shared.fetchPayrollRecords()
        print("📊 Registros obtenidos: \(records.count)")
    } catch {
        print("❌ Error al consultar: \(error)")
    }
}
```

## Seguridad

- ✅ **Row Level Security (RLS)**: Cada usuario solo puede acceder a sus propios datos
- ✅ **API Key Segura**: La API key está configurada en el código (considera moverla a un archivo de configuración para producción)
- ✅ **Autenticación JWT**: Supabase usa JWT para autenticar las solicitudes
- ✅ **HTTPS**: Todas las comunicaciones son encriptadas

## Próximos Pasos

1. Implementar sincronización automática de registros
2. Agregar búsqueda y filtrado de registros
3. Implementar caché local para modo offline
4. Agregar notificaciones push para nuevos registros

## Recursos

- [Documentación de Supabase](https://supabase.com/docs)
- [Supabase Swift SDK](https://github.com/supabase/supabase-swift)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
