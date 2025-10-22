# 🎨 Iconos de SICOPA - Diseño Liquid Glass

Este documento describe el diseño y especificaciones de los iconos de la aplicación SICOPA.

---

## 🎯 Diseño del Icono

### Concepto Visual

El icono de SICOPA utiliza el mismo lenguaje de diseño **Liquid Glass** de la aplicación:

- **Gradiente Azul-Morado**: De `#3B82F6` (azul) a `#8B5CF6` (morado)
- **Forma Redondeada**: Esquinas con radio de 22.5% (estándar iOS)
- **Símbolo Central**: Documento con lupa (representando consulta de nómina)
- **Estilo Minimalista**: Similar a avatares por defecto de WhatsApp/Facebook

### Elementos del Diseño

1. **Fondo Gradiente**
   - Color inicio: RGB(59, 130, 246) - Azul
   - Color fin: RGB(139, 92, 246) - Morado
   - Transición suave vertical

2. **Documento (Blanco)**
   - Rectángulo redondeado
   - 3 líneas horizontales (representando texto)
   - Posicionado en el lado izquierdo

3. **Lupa (Blanco)**
   - Círculo con borde
   - Mango diagonal
   - Posicionado en el lado derecho
   - Superpuesto al documento

---

## 📐 Tamaños Generados

### iPhone

| Tamaño | Escala | Uso | Archivo |
|--------|--------|-----|---------|
| 20pt | 2x (40x40) | Notificaciones | `icon_40_20.png` |
| 20pt | 3x (60x60) | Notificaciones | `icon_60.png` |
| 29pt | 2x (58x58) | Ajustes | `icon_58_29.png` |
| 29pt | 3x (87x87) | Ajustes | `icon_87.png` |
| 40pt | 2x (80x80) | Spotlight | `icon_80_40.png` |
| 40pt | 3x (120x120) | Spotlight | `icon_120_40.png` |
| 60pt | 2x (120x120) | App Icon | `icon_120_60.png` |
| 60pt | 3x (180x180) | App Icon | `icon_180.png` |

### iPad

| Tamaño | Escala | Uso | Archivo |
|--------|--------|-----|---------|
| 20pt | 1x (20x20) | Notificaciones | `icon_20.png` |
| 20pt | 2x (40x40) | Notificaciones | `icon_40_40.png` |
| 29pt | 1x (29x29) | Ajustes | `icon_29.png` |
| 29pt | 2x (58x58) | Ajustes | `icon_58_20.png` |
| 40pt | 1x (40x40) | Spotlight | `icon_40_20.png` |
| 40pt | 2x (80x80) | Spotlight | `icon_80_20.png` |
| 76pt | 1x (76x76) | App Icon | `icon_76.png` |
| 76pt | 2x (152x152) | App Icon | `icon_152.png` |
| 83.5pt | 2x (167x167) | iPad Pro | `icon_167.png` |

### App Store

| Tamaño | Uso | Archivo |
|--------|-----|---------|
| 1024x1024 | App Store Marketing | `icon_1024.png` |

---

## 🎨 Paleta de Colores

```swift
// Gradiente principal
let gradientStart = UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1.0)  // #3B82F6
let gradientEnd = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1.0)    // #8B5CF6

// Símbolo
let symbolColor = UIColor.white.withAlphaComponent(0.9)  // Blanco con 90% opacidad

// Líneas del documento
let lineColor = UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 0.8)  // Azul con 80% opacidad
```

---

## 📁 Estructura de Archivos

```
Assets.xcassets/
└── AppIcon.appiconset/
    ├── Contents.json           # Configuración de iconos
    ├── icon_1024.png          # 1024x1024 (9.1 KB)
    ├── icon_180.png           # 180x180 (1.6 KB)
    ├── icon_167.png           # 167x167 (1.5 KB)
    ├── icon_152.png           # 152x152 (1.4 KB)
    ├── icon_120_60.png        # 120x120 (1.1 KB)
    ├── icon_120_40.png        # 120x120 (1.1 KB)
    ├── icon_87.png            # 87x87 (822 B)
    ├── icon_80_40.png         # 80x80 (733 B)
    ├── icon_80_20.png         # 80x80 (733 B)
    ├── icon_76.png            # 76x76 (739 B)
    ├── icon_60.png            # 60x60 (584 B)
    ├── icon_58_29.png         # 58x58 (582 B)
    ├── icon_58_20.png         # 58x58 (582 B)
    ├── icon_40_20.png         # 40x40 (387 B)
    ├── icon_40_40.png         # 40x40 (387 B)
    ├── icon_29.png            # 29x29 (328 B)
    └── icon_20.png            # 20x20 (246 B)
```

**Total**: 17 archivos PNG + 1 JSON

---

## ✅ Cumplimiento con Apple

Los iconos cumplen con todas las **[especificaciones de Apple](https://developer.apple.com/design/human-interface-guidelines/app-icons)**:

- ✅ Todos los tamaños requeridos
- ✅ Formato PNG sin transparencia
- ✅ Esquinas redondeadas aplicadas automáticamente por iOS
- ✅ Colores RGB (sin alpha channel)
- ✅ Resolución correcta para pantallas Retina

---

## 🚀 Cómo se Generaron

Los iconos fueron generados usando **Python + PIL (Pillow)** con el siguiente proceso:

1. **Crear gradiente**: Interpolación vertical de azul a morado
2. **Aplicar esquinas redondeadas**: Radio del 22.5% del tamaño
3. **Dibujar documento**: Rectángulo blanco con 3 líneas
4. **Dibujar lupa**: Círculo + mango diagonal
5. **Exportar PNG**: Todos los tamaños requeridos

### Script de Generación

El script está disponible en `/tmp/generate_icons.py` y puede ser ejecutado nuevamente con:

```bash
python3 /tmp/generate_icons.py
```

---

## 🎯 Uso en Xcode

Los iconos están configurados automáticamente en `Contents.json` y serán reconocidos por Xcode:

1. Abre el proyecto en Xcode
2. Ve a **Assets.xcassets → AppIcon**
3. Verás todos los iconos asignados correctamente
4. No se requiere configuración adicional

---

## 📸 Vista Previa

Para ver los iconos en tu Mac:

```bash
# Abrir la carpeta de iconos
open sicopa/Assets.xcassets/AppIcon.appiconset/

# Ver el icono grande (App Store)
open sicopa/Assets.xcassets/AppIcon.appiconset/icon_1024.png
```

---

## 🎨 Personalización Futura

Si necesitas modificar el diseño:

1. Edita el script `/tmp/generate_icons.py`
2. Cambia los colores, el símbolo o el diseño
3. Ejecuta el script de nuevo
4. Los iconos se regenerarán automáticamente

### Ejemplo: Cambiar Colores

```python
# En generate_icons.py, modifica estas líneas:
COLOR_START = (255, 100, 100)   # Rojo
COLOR_END = (255, 200, 100)     # Naranja
```

---

## 📚 Referencias

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [App Icon Sizes - iOS](https://developer.apple.com/design/human-interface-guidelines/foundations/app-icons)
- [PIL/Pillow Documentation](https://pillow.readthedocs.io/)

---

**Diseñado con ❤️ para SICOPA** | Estilo Liquid Glass | iOS Professional Standards

