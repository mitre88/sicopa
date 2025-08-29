# 🧠 Test de IQ Profesional - Matrices Progresivas de Raven

Una aplicación iOS moderna que implementa un test de coeficiente intelectual basado en las famosas Matrices Progresivas de Raven, desarrollada con **SwiftUI** y el estilo **Liquid Glass de iOS 26**.

## ✨ Características Principales

### 🎯 Test Profesional de IQ
- **20 preguntas** tipo Matrices Progresivas de Raven
- **4 niveles de dificultad**: Básico, Intermedio, Avanzado, Experto
- **8 categorías de patrones**: Secuencias, Rotaciones, Matrices, Combinaciones, etc.
- **Cálculo estimado de IQ** basado en escalas estándar

### 🎨 Diseño Liquid Glass iOS 26
- **Efectos translúcidos** con capas de vidrio dinámicas
- **Animaciones suaves** y transiciones fluidas
- **Gradientes dinámicos** y efectos de profundidad
- **Burbujas animadas** de fondo
- **Tipografía San Francisco Pro** [[memory:2881685]]

### 📊 Análisis Detallado
- **Estadísticas completas** de rendimiento
- **Gráficos circulares** de distribución de respuestas
- **Análisis por pregunta** individual
- **Historial de tests** guardado localmente
- **Métricas de tiempo** por pregunta

## 🏗️ Arquitectura

### 🔧 Tecnologías Utilizadas
- **Swift 6.2** con **SwiftUI**
- **Programación Funcional** y **Recursiva** [[memory:2313742]]
- **Patrón MVVM** con **Reducer Pattern**
- **Funciones Puras** para cálculos de IQ
- **@StateObject** y **@Published** para reactividad

### 📁 Estructura del Proyecto
```
sicopa/
├── Models/
│   └── PayrollRecord.swift        # RavenQuestion + TestResult models
├── ViewModels/
│   └── SearchViewModel.swift      # RavenTestViewModel + TestStatisticsViewModel
├── Views/
│   ├── WelcomeView.swift         # Pantalla de bienvenida con Liquid Glass
│   ├── MainSearchView.swift      # RavenTestView - Vista principal del test
│   └── PayrollDetailView.swift   # TestResultView - Resultados detallados
├── Services/
│   ├── DatabaseService.swift     # RavenTestService (funciones puras)
│   └── SimpleSearchService.swift # Servicios auxiliares
└── Assets.xcassets/              # Iconos e imágenes de matrices
```

## 🧩 Tipos de Preguntas Implementadas

### 1. **Secuencias Básicas** (Preguntas 1-6)
- ✅ Progresión de puntos
- ✅ Alternancia de colores
- ✅ Reducción gradual
- ✅ Direcciones de flechas

### 2. **Patrones Intermedios** (Preguntas 7-12)
- ✅ Tamaño progresivo
- ✅ Rotación y orientación
- ✅ Duplicación de formas
- ✅ División progresiva

### 3. **Matrices Avanzadas** (Preguntas 13-17)
- ✅ Posición en cuadrícula
- ✅ Combinación XOR
- ✅ Reflejo horizontal
- ✅ Líneas curvas con patrones

### 4. **Lógica Experta** (Preguntas 18-20)
- ✅ Partes encajadas
- ✅ Operaciones avanzadas
- ✅ Simetría diagonal
- ✅ Combinación de atributos únicos

## 🎮 Flujo de Usuario

### 1. **Pantalla de Bienvenida**
```swift
WelcomeView()
├── Logo animado con efecto Liquid Glass
├── Descripción del test
├── Características (Sin límite de tiempo, 20 preguntas, IQ estimado)
├── Botón "Comenzar Test"
└── Modal "¿Qué son las Matrices de Raven?"
```

### 2. **Test Principal**
```swift
RavenTestView()
├── Header con progreso y timer
├── Título y categoría de la pregunta
├── Imagen de la matriz (placeholder)
├── Descripción del patrón
├── 4 opciones de respuesta (A, B, C, D)
└── Botón de confirmación
```

### 3. **Resultados**
```swift
TestResultView()
├── IQ Score principal con animación
├── Nivel de rendimiento (Muy Superior, Superior, etc.)
├── Estadísticas detalladas (aciertos, tiempo, errores)
├── Gráfico circular de distribución
├── Análisis pregunta por pregunta
└── Botones (Repetir test, Salir)
```

## 📈 Sistema de Puntuación

### Escala de IQ Implementada
| Precisión | Rango IQ | Clasificación |
|-----------|----------|---------------|
| 95-100%   | 145-160  | 🏆 Muy Superior |
| 90-94%    | 130-144  | ⭐ Superior |
| 85-89%    | 120-129  | 👍 Promedio Alto |
| 75-84%    | 110-119  | 👍 Promedio Alto |
| 60-74%    | 90-109   | 👌 Promedio |
| 45-59%    | 80-89    | 📈 Promedio Bajo |
| 30-44%    | 70-79    | 💪 Fronterizo |
| <30%      | 55-69    | 💪 Por Debajo del Promedio |

### Funciones de Cálculo Puras
```swift
static func calculateEstimatedIQ(correctAnswers: Int, totalQuestions: Int) -> Int {
    let accuracy = Double(correctAnswers) / Double(totalQuestions)
    // Implementación basada en curva normal (μ=100, σ=15)
}
```

## 🎨 Componentes de UI Liquid Glass

### Efectos Visuales
- **`.ultraThinMaterial`** para fondos translúcidos
- **`LinearGradient`** con colores dinámicos
- **`RoundedRectangle`** con corner radius suave
- **`.shadow()`** para profundidad
- **`.scaleEffect()`** y **`.rotationEffect()`** para animaciones

### Transiciones
```swift
.transition(.asymmetric(
    insertion: .scale.combined(with: .opacity),
    removal: .opacity
))
```

### Animaciones de Entrada
```swift
withAnimation(.easeOut(duration: 1.0)) {
    animateResults = true
}
```

## 📸 Assets Requeridos

### Imágenes de Matrices (Pendientes)
Las siguientes imágenes deben ser agregadas a `Assets.xcassets/`:

#### Preguntas Básicas
- `raven_question_1.png` - Secuencia de cuadrados con puntos
- `raven_question_2.png` - Triángulos alternando colores
- `raven_question_3.png` - Matriz 2x2 de progresión de tamaño

#### Opciones de Respuesta (por pregunta)
- `raven_1_option_a.png` - Cuadrado con 4 puntos ✅
- `raven_1_option_b.png` - Cuadrado con 3 puntos
- `raven_1_option_c.png` - Cuadrado con 5 puntos
- `raven_1_option_d.png` - Triángulo con 4 puntos

*Total: 20 preguntas + 80 opciones = 100 imágenes*

## 🧪 Testing

### Tests Unitarios Sugeridos
```swift
func testIQCalculation() {
    let iq = RavenTestService.calculateEstimatedIQ(correctAnswers: 18, totalQuestions: 20)
    XCTAssertEqual(iq, 135, accuracy: 10)
}

func testQuestionValidation() {
    let questions = RavenTestService.getAllQuestions()
    XCTAssertEqual(questions.count, 20)
    XCTAssertTrue(questions.allSatisfy { $0.options.count == 4 })
}
```

### UI Tests
```swift
func testTestFlow() {
    let app = XCUIApplication()
    app.launch()
    
    app.buttons["Comenzar Test"].tap()
    app.buttons["A"].tap()
    app.buttons["Confirmar Respuesta"].tap()
    // ... continuar con el flujo
}
```

## 🚀 Instalación y Configuración

### Requisitos
- **Xcode 26+**
- **iOS 26.0+**
- **Swift 6.2**

### Configuración
1. Clona el repositorio
2. Abre `sicopa.xcodeproj`
3. Agrega las imágenes de matrices a Assets.xcassets
4. Compila y ejecuta

```bash
git clone [repositorio]
cd sicopa
open sicopa.xcodeproj
```

## 📱 Funcionalidades Implementadas

### ✅ Completado
- [x] **Modelo de datos** para preguntas de Raven
- [x] **ViewModel funcional** con patrón Reducer
- [x] **Interfaz Liquid Glass** para bienvenida
- [x] **Vista principal del test** con animaciones
- [x] **Sistema de resultados** con análisis detallado
- [x] **Cálculo de IQ** con escalas estándar
- [x] **20 preguntas profesionales** implementadas
- [x] **Localización** en español
- [x] **Programación funcional** [[memory:2313742]]

### 🔄 En Progreso
- [ ] **Imágenes de matrices** (placeholders actualmente)
- [ ] **Tests unitarios y UI**
- [ ] **Optimizaciones de rendimiento**
- [ ] **Accesibilidad VoiceOver**

### 📋 Pendiente
- [ ] **Foundation Models** para IA on-device
- [ ] **Internacionalización** inglés
- [ ] **App Store** preparación
- [ ] **Analytics** de uso

## 🎯 Próximos Pasos

1. **Crear las 100 imágenes** de matrices de Raven
2. **Implementar tests** unitarios y de UI
3. **Optimizar rendimiento** con lazy loading
4. **Agregar IA on-device** con Foundation Models
5. **Preparar para App Store** con metadata completo

## 🤝 Contribuciones

Este proyecto implementa un test de IQ profesional siguiendo las mejores prácticas de desarrollo iOS moderno con SwiftUI y programación funcional.

---

**Desarrollado con** ❤️ **usando SwiftUI, programación funcional y el estilo Liquid Glass de iOS 26** 