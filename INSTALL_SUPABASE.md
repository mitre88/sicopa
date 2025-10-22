# 📦 Cómo Instalar Supabase en Xcode - Guía Detallada

## ⚠️ SI EL MÉTODO NORMAL NO FUNCIONA

### Método 1: Desde Xcode (Recomendado)

1. **Abre Xcode**
2. **Abre sicopa.xcodeproj**
3. Click en el **ícono del proyecto** en el navegador izquierdo (sicopa en azul)
4. En la barra superior, selecciona el **PROJECT** "sicopa" (no el TARGET)
5. Ve a la pestaña **"Package Dependencies"**
6. Click en el botón **"+"** (abajo a la izquierda)
7. Pega esta URL:
   ```
   https://github.com/supabase/supabase-swift.git
   ```
8. Click **"Add Package"**
9. Selecciona: Supabase, Auth, PostgREST, Realtime
10. Click **"Add Package"**

---

### Método 2: Si ves errores de "Unable to resolve"

Puede ser un problema de Git. Verifica:

1. Abre **Terminal**
2. Ejecuta:
   ```bash
   git --version
   ```
   Deberías ver algo como "git version 2.x.x"

3. Si no tienes Git instalado:
   ```bash
   xcode-select --install
   ```

4. Después de instalar, vuelve a intentar en Xcode

---

### Método 3: Verificar Xcode Command Line Tools

1. Abre **Terminal**
2. Ejecuta:
   ```bash
   xcode-select -p
   ```
   Debería mostrar: `/Applications/Xcode.app/Contents/Developer`

3. Si muestra otro path o error:
   ```bash
   sudo xcode-select --reset
   xcode-select --install
   ```

4. Reinicia Xcode e intenta de nuevo

---

### Método 4: Limpiar Todo y Empezar de Nuevo

En **Terminal**, ejecuta estos comandos:

```bash
# Limpiar caché de Swift Package Manager
rm -rf ~/Library/Caches/org.swift.swiftpm

# Limpiar DerivedData de Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Limpiar caché de Xcode
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

Luego:
1. **Cierra Xcode completamente** (Cmd + Q)
2. **Reinicia tu Mac** (opcional pero recomendado)
3. Abre Xcode e intenta agregar el paquete de nuevo

---

### Método 5: Agregar desde Swift Package Index

1. Ve a: https://swiftpackageindex.com/supabase/supabase-swift
2. Verás instrucciones de instalación
3. Usa la URL que aparece ahí

---

### Método 6: Usar CocoaPods (Última Opción)

Si nada de lo anterior funciona, Supabase también está disponible via CocoaPods:

1. Instala CocoaPods si no lo tienes:
   ```bash
   sudo gem install cocoapods
   ```

2. Navega a tu proyecto:
   ```bash
   cd /Users/dr.alexmitre/Desktop/sicopa
   ```

3. Crea un Podfile:
   ```bash
   pod init
   ```

4. Edita el Podfile y agrega:
   ```ruby
   platform :ios, '16.0'
   use_frameworks!

   target 'sicopa' do
     pod 'Supabase', '~> 2.0'
   end
   ```

5. Instala:
   ```bash
   pod install
   ```

6. **IMPORTANTE**: A partir de ahora, abre **sicopa.xcworkspace** en lugar de sicopa.xcodeproj

---

## 🆘 Errores Comunes

### Error: "Authentication required"
- Ve a **Xcode → Preferences → Accounts**
- Agrega tu cuenta de GitHub (opcional)

### Error: "Rate limit exceeded"
- Espera 1 hora y vuelve a intentar
- O agrega una cuenta de GitHub en Xcode Preferences

### Error: "Package.resolved is corrupted"
- Borra el archivo Package.resolved:
  ```bash
  rm /Users/dr.alexmitre/Desktop/sicopa/sicopa.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
  ```
- Intenta de nuevo

---

## ✅ Verificar que Funcionó

1. En Xcode, ve al navegador de archivos (panel izquierdo)
2. Deberías ver una carpeta **"Package Dependencies"**
3. Dentro: **supabase-swift**
4. Compila el proyecto: **Cmd + B**
5. Si compila sin errores, ¡funcionó! 🎉

---

## 🤝 Necesitas Ayuda

Si nada de esto funciona, dime:
- ¿Qué método intentaste?
- ¿Qué error exacto aparece?
- ¿Qué versión de macOS tienes?
