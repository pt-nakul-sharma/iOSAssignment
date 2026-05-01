//
//  SplashView.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        if isActive {
            RootView()
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color.teal, Color.blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)

                    VStack(spacing: 8) {
                        Text("iOSAssignment")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Text("Learning Management System")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .opacity(textOpacity)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    iconScale = 1.0
                    iconOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                    textOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
