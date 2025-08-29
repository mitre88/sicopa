//
//  sicopaApp.swift
//  sicopa
//
//  Created by Dr. Alex Mitre on 28/07/25.
//

import SwiftUI

@main
struct sicopaApp: App {
    @StateObject private var appearanceManager = AppearanceManager()
    
    init() {
        // Configuración global de la app
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .font(.custom("SF Pro Display", size: 17)) // San Francisco Pro globalmente [[memory:2881685]]
                .environmentObject(appearanceManager)
                .onAppear {
                    // Configuración inicial de la app
                    configureInitialState()
                }
        }
    }
    
    // MARK: - Configuración de apariencia global
    private func setupAppearance() {
        // Configurar la fuente San Francisco Pro para toda la app
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: UIFont(name: "SF Pro Display", size: 18) ?? UIFont.systemFont(ofSize: 18)
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "SF Pro Display", size: 34) ?? UIFont.systemFont(ofSize: 34)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configurar tab bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Deshabilitar animaciones innecesarias para mejor rendimiento
        UIView.setAnimationsEnabled(true)
        
        // Configurar tint color global
        UIView.appearance().tintColor = UIColor(Color.liquidPrimary)
    }
    
    // MARK: - Configuración inicial
    private func configureInitialState() {
        // Pre-cargar el servicio de búsqueda para mejor rendimiento
        _ = SimpleSearchService()
    }
}

// MARK: - Gestor de apariencia
class AppearanceManager: ObservableObject {
    @Published var currentTheme: ColorScheme?
    @AppStorage("isDarkMode") var isDarkMode = false
    
    init() {
        // Sincronizar con la preferencia del sistema si no hay preferencia guardada
        if !UserDefaults.standard.bool(forKey: "hasSetAppearancePreference") {
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
        UserDefaults.standard.set(true, forKey: "hasSetAppearancePreference")
        
        // Haptic feedback
        HapticManager.selection()
    }
}
