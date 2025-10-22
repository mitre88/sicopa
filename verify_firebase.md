# Lista de Verificación - Firebase Integration

Usa esta lista para verificar que la integración de Firebase esté completa.

## ☐ Checklist de Configuración

### Firebase Console
- [ ] Proyecto creado en Firebase Console
- [ ] App iOS agregada al proyecto
- [ ] Bundle ID coincide con el de Xcode
- [ ] `GoogleService-Info.plist` descargado
- [ ] Authentication habilitado
- [ ] Email/Password habilitado como método de sign-in
- [ ] Al menos un usuario de prueba creado

### Xcode - Archivos
- [ ] `GoogleService-Info.plist` agregado al proyecto
- [ ] `GoogleService-Info.plist` incluido en el target "sicopa"
- [ ] Firebase SDK agregado vía Swift Package Manager
- [ ] `FirebaseAuth` instalado
- [ ] `FirebaseCore` instalado

### Xcode - Código
- [ ] `sicopaApp.swift` importa `FirebaseCore`
- [ ] `FirebaseApp.configure()` se llama en `init()`
- [ ] `FirebaseManager` agregado como `@StateObject`
- [ ] `FirebaseManager` inyectado como `@EnvironmentObject`

### Archivos Nuevos Creados
- [ ] `sicopa/Managers/FirebaseManager.swift` existe
- [ ] `sicopa/Views/RegisterView.swift` existe
- [ ] Archivos modificados: `LoginView.swift`, `StartView.swift`, `ContentView.swift`

### Compilación
- [ ] El proyecto compila sin errores (Cmd + B)
- [ ] No hay warnings relacionados con Firebase
- [ ] La app se ejecuta en el simulador (Cmd + R)

## ☐ Checklist de Funcionalidad

### Login
- [ ] Puedes iniciar sesión con credenciales válidas
- [ ] Los errores se muestran con credenciales inválidas
- [ ] El indicador de carga aparece durante el login
- [ ] Feedback háptico funciona
- [ ] Después del login exitoso, navegas a StartView

### Registro
- [ ] Puedes acceder a la pantalla de registro desde LoginView
- [ ] La validación de contraseña funciona (mínimo 6 caracteres)
- [ ] La confirmación de contraseña valida correctamente
- [ ] Los indicadores de requisitos se actualizan en tiempo real
- [ ] Puedes crear una nueva cuenta
- [ ] Después del registro exitoso, navegas a StartView
- [ ] El nuevo usuario aparece en Firebase Console > Authentication > Users

### Sesión Persistente
- [ ] Después de iniciar sesión, cierra completamente la app
- [ ] Vuelve a abrir la app
- [ ] El usuario sigue autenticado (va directo a StartView)

### Logout
- [ ] Puedes cerrar sesión desde StartView
- [ ] Después del logout, regresas a LoginView
- [ ] No puedes acceder a StartView sin autenticación

### Errores
- [ ] Los mensajes de error están en español
- [ ] Email inválido muestra mensaje apropiado
- [ ] Contraseña incorrecta muestra mensaje apropiado
- [ ] Usuario no encontrado muestra mensaje apropiado

## Comandos Útiles

### Limpiar Build
```bash
# En Xcode: Product > Clean Build Folder (Cmd + Shift + K)
```

### Ver Logs de Firebase
En Xcode, revisa la consola para ver:
```
[Firebase/Core][I-COR000001] Configured Firebase
[Firebase/Auth][I-AUT000001] Auth initialized
```

### Verificar Bundle ID
```bash
cd /Users/dr.alexmitre/Desktop/sicopa
# Busca CFBundleIdentifier en Info.plist
grep -A 1 "CFBundleIdentifier" sicopa/Info.plist
```

## Solución Rápida de Problemas

### "GoogleService-Info.plist not found"
1. Verifica que el archivo esté en la raíz del proyecto
2. En Xcode, selecciona el archivo
3. En File Inspector, asegúrate de que "Target Membership" incluya "sicopa"

### "Module 'FirebaseCore' not found"
1. File > Add Package Dependencies
2. Agrega `https://github.com/firebase/firebase-ios-sdk`
3. Selecciona FirebaseCore y FirebaseAuth

### "No error but can't login"
1. Ve a Firebase Console
2. Authentication > Users
3. Verifica que el usuario existe
4. Verifica que la contraseña sea correcta

### La app se cierra inesperadamente
1. Revisa la consola de Xcode para ver el error
2. Verifica que `FirebaseApp.configure()` se llame antes de usar Firebase
3. Limpia el build folder (Cmd + Shift + K)

## Recursos

- [Guía de Setup](FIREBASE_SETUP.md)
- [Resumen de Integración](INTEGRACION_FIREBASE.md)
- [Firebase Console](https://console.firebase.google.com/)
- [Documentación Firebase iOS](https://firebase.google.com/docs/ios/setup)

## Estado de la Integración

**Fecha de integración:** $(date)

**Archivos modificados:**
- ✅ sicopaApp.swift
- ✅ ContentView.swift
- ✅ LoginView.swift
- ✅ StartView.swift

**Archivos creados:**
- ✅ FirebaseManager.swift
- ✅ RegisterView.swift

**Pendiente:**
- [ ] Agregar Firebase SDK en Xcode
- [ ] Configurar Firebase Console
- [ ] Agregar GoogleService-Info.plist
- [ ] Crear usuarios de prueba
- [ ] Probar funcionalidad completa

---

Una vez completados todos los items de esta lista, tu integración de Firebase estará completa y funcionando! 🎉
