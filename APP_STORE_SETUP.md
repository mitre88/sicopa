# 🚀 Configuración de App Store Connect - SICOPA

Este documento te guía paso a paso para resolver el error de contratos y subir tu app a App Store Connect.

---

## ⚠️ Error: "You do not have required contracts"

Este error ocurre porque necesitas **aceptar los acuerdos legales** de Apple antes de poder distribuir apps.

**ID del Error**: `fbf5304a-c854-48bc-809e-6cd6362e1519`

---

## ✅ SOLUCIÓN: Aceptar Contratos en App Store Connect

### Paso 1: Ir a App Store Connect

1. Abre tu navegador
2. Ve a: **https://appstoreconnect.apple.com**
3. Inicia sesión con tu **Apple ID de desarrollador**

### Paso 2: Revisar Contratos Pendientes

Una vez dentro de App Store Connect:

1. En la página principal, busca un **banner amarillo/rojo** en la parte superior
2. El banner dirá algo como:
   ```
   ⚠️ "Agreements need to be reviewed"
   o
   ⚠️ "Contratos pendientes de revisión"
   ```

3. Haz clic en **"Review"** o **"Revisar"**

### Paso 3: Aceptar Contratos

1. Se abrirá la página de **Agreements, Tax, and Banking**
2. Verás una lista de contratos pendientes
3. Los contratos más comunes son:
   - ✅ **Paid Applications Agreement** (Aplicaciones de pago)
   - ✅ **Apple Developer Program License Agreement**
   - ✅ **iOS Developer Program License Agreement**

4. Para cada contrato:
   - Click en el contrato
   - Lee los términos (o desplázate hasta el final)
   - Marca la casilla **"I have read and agree to the Apple Developer Program License Agreement"**
   - Click en **"Submit"** o **"Enviar"**

### Paso 4: Completar Información Bancaria y Fiscal (Si es necesario)

Si planeas vender apps o tener compras dentro de la app:

1. Ve a **"Agreements, Tax, and Banking"**
2. Completa:
   - ✅ **Contact Information** (Información de contacto)
   - ✅ **Bank Information** (Información bancaria)
   - ✅ **Tax Forms** (Formularios fiscales)

**Nota**: Si tu app es **gratuita** y **sin compras**, puedes omitir esto.

---

## 🔍 Verificar Estado de Contratos

### Método 1: Desde la Página Principal

1. Ve a: https://appstoreconnect.apple.com
2. Si NO ves ningún banner amarillo/rojo, los contratos están aceptados ✅

### Método 2: Desde el Menú

1. Click en tu nombre (esquina superior derecha)
2. Selecciona **"Agreements, Tax, and Banking"**
3. Deberías ver:
   ```
   ✅ Paid Applications - Active
   ✅ iOS Developer Program - Active
   ```

---

## 🎯 Después de Aceptar los Contratos

### Esperar Procesamiento

Apple puede tardar **hasta 24-48 horas** en procesar los contratos aceptados.

**Normalmente tarda**: 5-30 minutos

### Reintentar en Xcode

1. **Cierra Xcode** completamente (Cmd + Q)
2. **Espera 10-15 minutos** después de aceptar los contratos
3. Abre Xcode de nuevo
4. Intenta archivar y subir de nuevo:
   - **Product → Archive**
   - **Distribute App**
   - **App Store Connect**

---

## 📱 Proceso Completo para Subir a App Store

### Paso 1: Crear App en App Store Connect

1. Ve a: https://appstoreconnect.apple.com
2. Click en **"My Apps"** (Mis Apps)
3. Click en el botón **"+"** (arriba a la izquierda)
4. Selecciona **"New App"** (Nueva App)

**Información requerida**:
- **Platform**: iOS
- **Name**: SICOPA
- **Primary Language**: Spanish (es-MX)
- **Bundle ID**: `next-tech.sicopa` (el que está en tu proyecto)
- **SKU**: `sicopa-001` (puede ser cualquier identificador único)
- **User Access**: Full Access

### Paso 2: Completar Información de la App

#### General Information
- **App Name**: SICOPA
- **Subtitle**: Sistema de Consulta de Pagos
- **Privacy Policy URL**: (si tienes uno)

#### Category
- **Primary Category**: Business
- **Secondary Category**: Productivity

#### Description
```
SICOPA es un sistema profesional para consulta de nóminas con diseño
Liquid Glass moderno.

Características:
✨ Interfaz moderna con efectos Liquid Glass
🔐 Autenticación segura con Supabase
☁️ Datos persistentes en la nube
📊 Búsqueda rápida de registros de nómina
🌙 Modo oscuro
```

#### Keywords
```
nomina, pagos, sueldos, consulta, rrhh, recursos humanos
```

#### Screenshots
Necesitarás capturas de pantalla:
- **iPhone 6.7"** (iPhone 15 Pro Max): 3-10 screenshots
- **iPhone 6.5"** (iPhone 11 Pro Max): 3-10 screenshots
- **iPad Pro 12.9"** (opcional): 1-5 screenshots

**Tamaños requeridos**:
- iPhone 6.7": 1290 x 2796 pixels
- iPhone 6.5": 1242 x 2688 pixels
- iPad Pro 12.9": 2048 x 2732 pixels

### Paso 3: Configurar Versión

1. Ve a **App Store** → **iOS App** → **Version Information**
2. **Version**: 1.0
3. **Copyright**: 2024 Dr. Alex Mitre

### Paso 4: Configurar Privacy

1. Ve a **App Privacy**
2. Marca las categorías de datos que recopila tu app:
   - **Email Address** (para autenticación)
   - **User Content** (datos de nómina)

3. Para cada categoría, indica:
   - ✅ Used for App Functionality
   - ✅ Linked to User Identity

### Paso 5: Archivar en Xcode

1. En Xcode, selecciona **Any iOS Device (arm64)** como destino
2. Ve a **Product → Archive**
3. Espera a que compile (puede tomar 2-5 minutos)
4. Se abrirá la ventana **Organizer** con tu archivo

### Paso 6: Distribuir

1. En **Organizer**, selecciona tu archivo
2. Click en **"Distribute App"**
3. Selecciona **"App Store Connect"**
4. Click **"Upload"**
5. Selecciona opciones:
   - ✅ Upload your app's symbols (para crashes)
   - ✅ Manage version and build number (automático)
6. Click **"Next"**
7. Revisa el resumen
8. Click **"Upload"**

### Paso 7: Procesar en App Store Connect

1. La app tardará **10-30 minutos** en procesar
2. Recibirás un email cuando esté lista
3. Ve a App Store Connect
4. Selecciona tu app
5. En **Build**, selecciona el build que subiste

### Paso 8: Enviar a Revisión

1. Completa toda la información requerida
2. Click en **"Save"**
3. Click en **"Add for Review"** (Agregar para revisión)
4. Responde las preguntas de Export Compliance
5. Click en **"Submit for Review"**

---

## ⚠️ Problemas Comunes

### Error: "No Bundle ID Found"

**Solución**:
1. Ve a https://developer.apple.com
2. **Certificates, Identifiers & Profiles**
3. **Identifiers**
4. Click en **"+"** para crear un nuevo App ID
5. Bundle ID: `next-tech.sicopa`

### Error: "Invalid Code Signing"

**Solución**:
1. En Xcode, ve a **Signing & Capabilities**
2. Asegúrate de que **Automatically manage signing** esté marcado
3. Selecciona tu **Team** (cuenta de desarrollador)

### Error: "Missing Compliance"

**Solución**:
1. En App Store Connect, ve a tu app
2. **App Information**
3. **Export Compliance Information**
4. Si tu app NO usa encriptación fuerte, marca **"No"**

---

## 💰 Costos

### Apple Developer Program
- **$99 USD/año** (obligatorio para publicar en App Store)
- Incluye:
  - Acceso a App Store Connect
  - Distribución en App Store
  - TestFlight para beta testing
  - Certificados de desarrollador

### Renovación
- Se renueva automáticamente cada año
- Recibirás un email 30 días antes del vencimiento

---

## 📅 Tiempo de Revisión

### Revisión de Apple
- **Promedio**: 24-48 horas
- **Mínimo**: 12 horas
- **Máximo**: 5-7 días

### Estados de Revisión
1. **Waiting for Review** - En cola
2. **In Review** - Siendo revisada
3. **Pending Developer Release** - Aprobada, esperando que la publiques
4. **Ready for Sale** - Publicada en App Store
5. **Rejected** - Rechazada (recibirás detalles del por qué)

---

## 📚 Recursos Útiles

- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer](https://developer.apple.com)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

## 🎯 Checklist Antes de Subir

Antes de enviar a revisión, asegúrate de:

- [ ] Contratos aceptados en App Store Connect
- [ ] App creada en App Store Connect
- [ ] Bundle ID configurado
- [ ] Iconos de app agregados (1024x1024 y todos los tamaños)
- [ ] Screenshots tomados y subidos
- [ ] Descripción y palabras clave completas
- [ ] Privacy Policy (si aplica)
- [ ] Información de contacto completa
- [ ] Build subido desde Xcode
- [ ] Build procesado y seleccionado en App Store Connect
- [ ] Toda la información de la app completa
- [ ] Export Compliance configurado

---

## 🆘 Ayuda Adicional

Si necesitas ayuda:
1. **Apple Developer Support**: https://developer.apple.com/support/
2. **Foros de Apple**: https://developer.apple.com/forums/
3. **Stack Overflow**: https://stackoverflow.com/questions/tagged/app-store-connect

---

**¡Buena suerte con tu publicación en App Store!** 🚀

