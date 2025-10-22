# Integración de Firebase Authentication en SICOPA

## Resumen de Cambios

Se ha integrado Firebase Authentication en tu aplicación iOS SICOPA para proporcionar gestión persistente de cuentas de usuario.

## Archivos Modificados

### 1. [sicopaApp.swift](sicopa/sicopaApp.swift)
- Importado `FirebaseCore`
- Agregado `FirebaseApp.configure()` en el inicializador
- Agregado `FirebaseManager` como `@StateObject` y `@EnvironmentObject`

### 2. [ContentView.swift](sicopa/ContentView.swift)
- Reemplazado `@AppStorage("isLoggedIn")` por `firebaseManager.isAuthenticated`
- El estado de autenticación ahora se gestiona completamente por Firebase
- La sesión persiste automáticamente entre lanzamientos de la app

### 3. [LoginView.swift](sicopa/Views/LoginView.swift)
- Cambiado de autenticación hardcoded a Firebase Authentication
- Cambiado campo "Usuario" por "Correo electrónico"
- Implementada autenticación asíncrona con Firebase
- Agregado manejo de errores con mensajes en español
- Agregado botón de navegación a pantalla de registro

### 4. [StartView.swift](sicopa/Views/StartView.swift)
- Implementado logout con Firebase
- Manejo de errores al cerrar sesión
- Integrado con `FirebaseManager`

## Archivos Nuevos Creados

### 1. [FirebaseManager.swift](sicopa/Managers/FirebaseManager.swift)
Manager centralizado para gestionar autenticación de Firebase con las siguientes funcionalidades:

**Propiedades:**
- `currentUser`: Usuario actual de Firebase
- `isAuthenticated`: Estado de autenticación booleano
- `authError`: Errores de autenticación con mensajes en español

**Métodos:**
- `signIn(email:password:)`: Iniciar sesión
- `signUp(email:password:)`: Registrar nuevo usuario
- `signOut()`: Cerrar sesión
- `resetPassword(email:)`: Restablecer contraseña

**Características:**
- Singleton pattern para acceso global
- Listener de estado de autenticación automático
- Manejo de errores con mensajes localizados en español
- Programación funcional con async/await

### 2. [RegisterView.swift](sicopa/Views/RegisterView.swift)
Vista de registro de usuarios con:
- Validación de email
- Validación de contraseña (mínimo 6 caracteres)
- Confirmación de contraseña
- Indicadores visuales de requisitos
- Integración con Firebase Authentication
- Diseño Liquid Glass consistente con la app

### 3. [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
Guía completa paso a paso para configurar Firebase en el proyecto.

## Pasos Siguientes para Completar la Integración

### 1. Instalar Firebase SDK

En Xcode:
1. **File > Add Package Dependencies...**
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Seleccionar versión más reciente
4. Agregar productos:
   - ✅ FirebaseAuth
   - ✅ FirebaseCore

### 2. Configurar Firebase Console

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Agregar app iOS con tu Bundle ID
3. Descargar `GoogleService-Info.plist`
4. Arrastrar el archivo al proyecto en Xcode
5. Habilitar Email/Password en Authentication

### 3. Crear Usuarios de Prueba

**Opción A - Desde Firebase Console:**
- Ve a Authentication > Users > Add user
- Crea usuarios de prueba

**Opción B - Desde la App:**
- Usa la nueva pantalla de registro (`RegisterView`)
- Los usuarios se crean automáticamente en Firebase

## Características Implementadas

✅ **Autenticación con Email/Password**
- Login seguro con Firebase
- Validación de credenciales

✅ **Registro de Usuarios**
- Pantalla de registro completa
- Validación de contraseñas
- Confirmación de contraseña

✅ **Sesión Persistente**
- Los usuarios permanecen autenticados entre lanzamientos
- No es necesario iniciar sesión cada vez
- Gestión automática de estado

✅ **Cierre de Sesión**
- Logout seguro con Firebase
- Limpieza automática de estado

✅ **Manejo de Errores**
- Mensajes en español
- Validación de email
- Feedback visual y háptico

✅ **Diseño Consistente**
- Estilo Liquid Glass en todas las pantallas
- Animaciones fluidas
- Feedback háptico
- Tema oscuro/claro

## Flujo de Usuario

### Primera vez:
1. Usuario abre la app → Splash Screen
2. No hay sesión → muestra LoginView
3. Usuario hace clic en "Regístrate"
4. Completa formulario de registro
5. Firebase crea la cuenta
6. Usuario es autenticado automáticamente
7. Navega a StartView

### Lanzamientos posteriores:
1. Usuario abre la app → Splash Screen
2. Firebase detecta sesión activa
3. Usuario va directo a StartView (sin login)

### Cerrar sesión:
1. Usuario hace clic en "Cerrar Sesión" en StartView
2. Firebase cierra la sesión
3. Usuario regresa a LoginView

## Programación Funcional

Todo el código sigue paradigmas funcionales como solicitaste:

```swift
// Ejemplo de uso funcional en FirebaseManager
func signIn(email: String, password: String) async throws {
    let result = try await Auth.auth().signIn(withEmail: email, password: password)
    // ...
}

// Uso de Task para manejo asíncrono
Task {
    try await firebaseManager.signIn(email: email, password: password)
}
```

## Fuentes San Francisco Pro

Todas las vistas usan San Francisco Pro:
- Sistema por defecto en iOS
- Configuración global en `sicopaApp.swift`
- Font weights apropiados (regular, medium, semibold, bold)

## Documentación de Referencia

- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Guía detallada de configuración
- [Firebase Auth Docs](https://firebase.google.com/docs/auth/ios/start)
- [Firebase Console](https://console.firebase.google.com/)

## Solución de Problemas

Si tienes algún problema durante la configuración, consulta la sección de "Solución de Problemas" en [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

## Próximas Mejoras Opcionales

- Recuperación de contraseña
- Verificación de email
- Login con Apple
- Login con Google
- Perfil de usuario
- Cambio de contraseña desde la app
