# Configuración de Firebase para SICOPA

Esta guía te ayudará a configurar Firebase Authentication en tu app iOS SICOPA.

## 1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Nombra tu proyecto (ejemplo: "SICOPA")
4. Sigue los pasos del asistente

## 2. Agregar iOS App a Firebase

1. En la consola de Firebase, selecciona tu proyecto
2. Haz clic en el ícono de iOS para agregar una app iOS
3. **Bundle ID**: Debes usar el mismo Bundle ID de tu proyecto Xcode
   - Abre tu proyecto en Xcode
   - Selecciona el target "sicopa"
   - En la pestaña "General", copia el "Bundle Identifier"
   - Pégalo en Firebase Console
4. **Apodo de la app** (opcional): "SICOPA iOS"
5. Haz clic en "Registrar app"

## 3. Descargar y Configurar GoogleService-Info.plist

1. Firebase te proporcionará un archivo `GoogleService-Info.plist`
2. **Descarga** este archivo
3. **Arrastra** el archivo `GoogleService-Info.plist` a tu proyecto Xcode:
   - Asegúrate de que esté en la carpeta `sicopa`
   - Marca la casilla "Copy items if needed"
   - Asegúrate de que esté agregado al target "sicopa"

## 4. Agregar Firebase SDK al Proyecto

1. En Xcode, abre tu proyecto
2. Ve a **File > Add Package Dependencies...**
3. Pega esta URL: `https://github.com/firebase/firebase-ios-sdk`
4. En "Dependency Rule", selecciona "Up to Next Major Version" con la versión más reciente
5. Haz clic en "Add Package"
6. Selecciona los siguientes productos (solo marca estos):
   - ✅ **FirebaseAuth**
   - ✅ **FirebaseCore**
7. Haz clic en "Add Package"

## 5. Habilitar Authentication en Firebase Console

1. En Firebase Console, ve a tu proyecto
2. En el menú lateral, haz clic en **"Authentication"**
3. Haz clic en **"Get started"**
4. Ve a la pestaña **"Sign-in method"**
5. Habilita **"Email/Password"**:
   - Haz clic en "Email/Password"
   - Activa el interruptor "Enable"
   - Haz clic en "Save"

## 6. Crear Usuarios de Prueba

### Opción A: Desde Firebase Console
1. Ve a **Authentication > Users**
2. Haz clic en **"Add user"**
3. Ingresa email y contraseña
4. Haz clic en "Add user"

### Opción B: Desde tu App
1. Compila y ejecuta tu app en el simulador
2. En la pantalla de login, ingresa un email y contraseña nuevos
3. Firebase creará automáticamente el usuario la primera vez

**Nota**: Para crear usuarios desde la app, necesitarás modificar el `LoginView` para incluir un botón de registro. Por ahora, usa la opción A para crear usuarios de prueba.

## 7. Compilar y Probar

1. En Xcode, selecciona tu simulador o dispositivo
2. Presiona **Cmd + B** para compilar
3. Si hay errores, verifica que:
   - `GoogleService-Info.plist` esté en el target correcto
   - Los paquetes de Firebase estén correctamente instalados
4. Presiona **Cmd + R** para ejecutar
5. Prueba el login con las credenciales que creaste

## 8. Verificar el Estado del Usuario

Para verificar que la autenticación funciona:

1. En Firebase Console, ve a **Authentication > Users**
2. Deberías ver a los usuarios que han iniciado sesión
3. Puedes ver la última vez que iniciaron sesión

## Características Implementadas

✅ **Login persistente**: Los usuarios permanecen autenticados aunque cierren la app
✅ **Gestión de sesión**: La sesión se gestiona automáticamente con Firebase
✅ **Logout**: Cierre de sesión seguro
✅ **Manejo de errores**: Mensajes de error en español
✅ **Validación de email**: Firebase valida automáticamente el formato del email

## Agregar Funcionalidad de Registro (Opcional)

Si deseas permitir que los usuarios se registren desde la app, puedes crear una nueva vista de registro o agregar un botón en `LoginView`.

Ejemplo de código para agregar en un nuevo `RegisterView`:

```swift
// En LoginView, agrega un botón:
Button("¿No tienes cuenta? Regístrate") {
    // Navegar a RegisterView
}

// En RegisterView, usa:
try await firebaseManager.signUp(email: email, password: password)
```

## Solución de Problemas

### Error: "FirebaseApp.configure() must be called before instantiation"
- Asegúrate de que `FirebaseApp.configure()` se llame en `sicopaApp.swift` antes de cualquier uso de Firebase

### Error: "No GoogleService-Info.plist found"
- Verifica que el archivo `GoogleService-Info.plist` esté en la raíz del proyecto
- Asegúrate de que esté agregado al target correcto en Xcode

### Error de compilación con Firebase
- Limpia el build folder: **Product > Clean Build Folder** (Cmd + Shift + K)
- Cierra y vuelve a abrir Xcode
- Verifica que tengas la última versión de Xcode

## Recursos Adicionales

- [Documentación de Firebase Authentication](https://firebase.google.com/docs/auth/ios/start)
- [Firebase Console](https://console.firebase.google.com/)
- [Guía de inicio rápido de Firebase iOS](https://firebase.google.com/docs/ios/setup)
