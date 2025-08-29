import SwiftUI

struct PaystubDetailView: View {
    let record: PayrollRecord
    @Environment(\.dismiss) private var dismiss
    @State private var showingContent = false
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if showingContent {
                    // Header principal
                    headerCard
                        .transition(.liquidScale)
                    
                    // Resumen financiero destacado
                    financialSummaryCard
                        .transition(.liquidSlide)
                    
                    // Tabs para organizar información
                    tabSelector
                        .transition(.liquidScale)
                    
                    // Contenido según tab seleccionado
                    Group {
                        switch selectedTab {
                        case 0:
                            employeeInfoCard
                                .transition(.liquidSlide)
                        case 1:
                            percepcionesCard
                                .transition(.liquidSlide)
                        case 2:
                            deduccionesCard
                                .transition(.liquidSlide)
                        default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(24)
            .padding(.bottom, 50)
        }
        .background(LiquidGlassBackground())
        .navigationTitle("Detalle de Pago")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .onAppear {
            animateIn()
        }
    }
    
    // MARK: - Animaciones
    private func animateIn() {
        withAnimation(FluidAnimation.elastic.delay(0.1)) {
            showingContent = true
        }
        HapticManager.impact(.light)
    }
    
    // MARK: - Header Principal
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Icono con efecto morphismo
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 80, height: 80)
                    .liquidMorphism(cornerRadius: 40)
                
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color.liquidGradient)
                    .symbolEffect(.bounce, value: showingContent)
            }
            
            // Información del empleado
            VStack(spacing: 8) {
                Text(record.formattedName)
                    .font(.custom("SF Pro Display", size: 26, relativeTo: .title))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text("RFC: \(record.rfc)")
                    .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            // Badges informativos
            HStack(spacing: 12) {
                InfoBadge(
                    icon: "doc.fill",
                    text: "Cheque \(record.cheque)",
                    colors: [.blue, .cyan]
                )
                
                if !record.cct.isEmpty {
                    InfoBadge(
                        icon: "building.2.fill",
                        text: record.cct,
                        colors: [.purple, .pink]
                    )
                }
            }
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Resumen Financiero
    private var financialSummaryCard: some View {
        VStack(spacing: 20) {
            // Título de sección
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.liquidGradient)
                
                Text("Resumen Financiero")
                    .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Grid de montos
            HStack(spacing: 16) {
                // Percepciones
                FinancialMetricCard(
                    title: "Percepciones",
                    amount: record.totalPercepciones,
                    icon: "plus.circle.fill",
                    color: .green
                )
                
                // Deducciones
                FinancialMetricCard(
                    title: "Deducciones",
                    amount: record.totalDeducciones,
                    icon: "minus.circle.fill",
                    color: .red
                )
            }
            
            // Monto neto destacado
            VStack(spacing: 12) {
                Text("IMPORTE NETO")
                    .font(.custom("SF Pro Display", size: 14, relativeTo: .caption))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Text(record.liquido.toLiquidoCurrency())
                    .font(.custom("SF Pro Display", size: 36, relativeTo: .largeTitle))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText())
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
            )
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 8) {
            TabButton(
                title: "Información",
                icon: "person.fill",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            TabButton(
                title: "Percepciones",
                icon: "plus.circle.fill",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            TabButton(
                title: "Deducciones",
                icon: "minus.circle.fill",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Información del Empleado
    private var employeeInfoCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                icon: "person.text.rectangle",
                title: "Información del Empleado"
            )
            
            VStack(spacing: 16) {
                InfoRow(label: "Plaza", value: record.plaza, icon: "mappin.circle.fill")
                InfoRow(label: "Grupo", value: record.grupo, icon: "person.3.fill")
                InfoRow(label: "Puesto", value: record.puesto_cdc, icon: "briefcase.fill")
                InfoRow(label: "Período", value: record.periodFormatted, icon: "calendar")
                InfoRow(label: "Motivo", value: record.motivo, icon: "doc.text.fill")
            }
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Percepciones
    private var percepcionesCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                icon: "plus.circle.fill",
                title: "Percepciones",
                color: .green
            )
            
            if record.conceptos.isEmpty {
                EmptyStateView(
                    icon: "tray.fill",
                    message: "No hay percepciones registradas"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(record.conceptos.enumerated()), id: \.offset) { index, concepto in
                        if let importe = record.importeForConcepto(at: index), importe > 0 {
                            ConceptRow(
                                concepto: concepto,
                                importe: importe,
                                color: .green,
                                index: index
                            )
                        }
                    }
                }
            }
            
            // Total
            TotalRow(
                title: "Total Percepciones",
                amount: record.totalPercepciones,
                color: .green
            )
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Deducciones
    private var deduccionesCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                icon: "minus.circle.fill",
                title: "Deducciones",
                color: .red
            )
            
            if record.conceptos.isEmpty {
                EmptyStateView(
                    icon: "tray.fill",
                    message: "No hay deducciones registradas"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(record.conceptos.enumerated()), id: \.offset) { index, concepto in
                        if let importe = record.importeForConcepto(at: index), importe < 0 {
                            ConceptRow(
                                concepto: concepto,
                                importe: abs(importe),
                                color: .red,
                                index: index
                            )
                        }
                    }
                }
            }
            
            // Total
            TotalRow(
                title: "Total Deducciones",
                amount: record.totalDeducciones,
                color: .red
            )
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Botón de compartir
    private var shareButton: some View {
        Button(action: sharePaystub) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.liquidGradient)
        }
    }
    
    private func sharePaystub() {
        HapticManager.selection()
        // TODO: Implementar funcionalidad de compartir
        print("Compartir talón de cheque")
    }
}

// MARK: - Componentes reutilizables

struct InfoBadge: View {
    let icon: String
    let text: String
    let colors: [Color]
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.custom("SF Pro Display", size: 14, relativeTo: .caption))
                .fontWeight(.medium)
        }
        .foregroundStyle(
            LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.glassBorder, lineWidth: 0.5)
                )
        )
    }
}

struct FinancialMetricCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.custom("SF Pro Display", size: 14, relativeTo: .caption))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Text(amount.toMexicanCurrency())
                .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.custom("SF Pro Display", size: 14, relativeTo: .caption))
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AnyShapeStyle(Color.liquidGradient) : AnyShapeStyle(Color.clear))
            )
        }
        .animation(FluidAnimation.smooth, value: isSelected)
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    var color: Color = .primary
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color == .primary ? AnyShapeStyle(Color.liquidGradient) : AnyShapeStyle(color))
            
            Text(title)
                .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            Text(label)
                .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value.isEmpty ? "No especificado" : value)
                .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ConceptRow: View {
    let concepto: String
    let importe: Double
    let color: Color
    let index: Int
    
    @State private var isVisible = false
    
    var body: some View {
        HStack {
            Text(concepto)
                .font(.custom("SF Pro Display", size: 15, relativeTo: .body))
                .foregroundStyle(.primary)
                .lineLimit(2)
            
            Spacer()
            
            Text(importe.toMexicanCurrency())
                .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(FluidAnimation.smooth.delay(Double(index) * 0.05)) {
                isVisible = true
            }
        }
    }
}

struct TotalRow: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(amount.toMexicanCurrency())
                .font(.custom("SF Pro Display", size: 18, relativeTo: .title3))
                .fontWeight(.bold)
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}
