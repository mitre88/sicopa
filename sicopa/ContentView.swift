//  ContentView.swift
//  sicopa
//  Created by Dr. Alex Mitre on 28/07/25.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var supabaseManager: SupabaseManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                // Splash screen con animación liquid
                SplashView()
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
            } else {
                // Vista según estado de autenticación de Supabase
                if supabaseManager.isAuthenticated {
                    StartView()
                        .preferredColorScheme(isDarkMode ? .dark : .light)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 1.1).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    LoginView()
                        .preferredColorScheme(isDarkMode ? .dark : .light)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 1.1).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
        }
        .animation(FluidAnimation.morphing, value: showSplash)
        .animation(FluidAnimation.morphing, value: supabaseManager.isAuthenticated)
        .onAppear {
            // Mostrar splash por 1.5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSplash = false
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashView: View {
    @State private var animateLogo = false
    @State private var animateText = false
    
    var body: some View {
        ZStack {
            // Fondo con efecto liquid glass
            LiquidGlassBackground()
            
            VStack(spacing: 24) {
                // Logo animado
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 150, height: 150)
                        .liquidMorphism(
                            cornerRadius: 75,
                            colors: [.liquidPrimary, .liquidSecondary]
                        )
                        .scaleEffect(animateLogo ? 1.0 : 0.5)
                        .opacity(animateLogo ? 1.0 : 0.0)
                    
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 70, weight: .semibold))
                        .foregroundStyle(Color.liquidGradient)
                        .scaleEffect(animateLogo ? 1.0 : 0.5)
                        .rotationEffect(.degrees(animateLogo ? 0 : -90))
                }
                
                // Texto animado
                VStack(spacing: 8) {
                    Text("SICOPA")
                        .font(.custom("SF Pro Display", size: 42, relativeTo: .largeTitle))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.liquidGradient)
                        .opacity(animateText ? 1.0 : 0.0)
                        .offset(y: animateText ? 0 : 20)
                    
                    Text("Sistema de Consulta de Pagos")
                        .font(.custom("SF Pro Display", size: 18, relativeTo: .headline))
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .opacity(animateText ? 1.0 : 0.0)
                        .offset(y: animateText ? 0 : 20)
                }
            }
        }
        .onAppear {
            // Animaciones en cascada
            withAnimation(FluidAnimation.elastic.delay(0.2)) {
                animateLogo = true
            }
            
            withAnimation(FluidAnimation.elastic.delay(0.5)) {
                animateText = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppearanceManager())
}
