//
//  DailyRunView.swift
//  Begrarvezar Broxrel
//
//  Created by Hughesan Drew on 10.03.2026.
//

import SwiftUI

struct DailyRunView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @Environment(\.dismiss) private var dismiss

    @State private var stepIndex: Int = 0
    @State private var accumulatedStars: Int = 0

    private let sequence: [LevelIdentifier] = [
        LevelIdentifier(activity: .shapeShifter, difficulty: .normal, index: 1),
        LevelIdentifier(activity: .colorCraze, difficulty: .normal, index: 1),
        LevelIdentifier(activity: .patternMatch, difficulty: .normal, index: 1)
    ]

    var body: some View {
        NavigationStack {
            if stepIndex < sequence.count {
                ActivityRouterView(level: sequence[stepIndex]) { result in
                    storage.registerResult(
                        for: sequence[stepIndex],
                        stars: result.stars,
                        timeSeconds: result.timeSeconds,
                        accuracy: result.accuracy
                    )
                    accumulatedStars += result.stars
                    let next = stepIndex + 1
                    if next < sequence.count {
                        stepIndex = next
                    } else {
                        storage.registerDailyStars(accumulatedStars)
                        dismiss()
                    }
                }
            } else {
                VStack {
                    Text("Daily run complete")
                        .foregroundColor(.appTextPrimary)
                    Button("Close") { dismiss() }
                        .foregroundColor(.appPrimary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackground.ignoresSafeArea())
            }
        }
    }
}

