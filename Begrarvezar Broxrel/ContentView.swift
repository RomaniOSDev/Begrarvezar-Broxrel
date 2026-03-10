//
//  ContentView.swift
//  Begrarvezar Broxrel
//
//  Created by Роман Главацкий on 10.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var storage = AppStorageManager()

    var body: some View {
        NavigationStack {
            Group {
                if storage.hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingContainerView()
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
        }
        .environmentObject(storage)
    }
}

