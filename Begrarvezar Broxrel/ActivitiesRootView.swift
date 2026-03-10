//
//  ActivitiesRootView.swift
//  Begrarvezar Broxrel
//
//  Created by Hughesan Drew on 10.03.2026.
//

import SwiftUI

struct ActivitiesRootView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @State private var activity: ActivityKind = .shapeShifter
    @State private var difficulty: Difficulty = .easy
    @State private var selectedLevel: LevelIdentifier?
    @State private var pendingResult: (LevelIdentifier, LevelResult)?

    private let levelsPerDifficulty = 9

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pick your challenge")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.appTextPrimary)
                        .padding(.top, 24)

                    activitySelector

                    difficultySelector

                    levelsHeader

                    levelGrid
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    colors: [Color.appBackground, Color.appSurface],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationDestination(item: $selectedLevel) { level in
                ActivityRouterView(level: level) { result in
                    storage.registerResult(
                        for: level,
                        stars: result.stars,
                        timeSeconds: result.timeSeconds,
                        accuracy: result.accuracy
                    )
                    pendingResult = (level, result)
                    selectedLevel = nil
                }
            }
            .sheet(item: Binding(
                get: {
                    pendingResult.map { WrappedResult(id: $0.0, level: $0.0, result: $0.1) }
                },
                set: { wrapped in
                    pendingResult = wrapped.map { ($0.level, $0.result) }
                })
            ) { wrapped in
                ResultView(
                    stars: wrapped.result.stars,
                    timeSeconds: wrapped.result.timeSeconds,
                    accuracy: wrapped.result.accuracy,
                    onNext: {
                        let nextIndex = wrapped.level.index + 1
                        if nextIndex <= levelsPerDifficulty {
                            let next = LevelIdentifier(
                                activity: wrapped.level.activity,
                                difficulty: wrapped.level.difficulty,
                                index: nextIndex
                            )
                            if storage.isLevelUnlocked(next, maxLevels: levelsPerDifficulty) {
                                selectedLevel = next
                            }
                        }
                        pendingResult = nil
                    },
                    onRetry: {
                        selectedLevel = wrapped.level
                        pendingResult = nil
                    },
                    onBackToLevels: {
                        pendingResult = nil
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var levelsHeader: some View {
        let allThreeStar = (1...levelsPerDifficulty).allSatisfy { index in
            let id = LevelIdentifier(activity: activity, difficulty: difficulty, index: index)
            return storage.bestStars(for: id) == 3
        }

        return HStack(spacing: 8) {
            Text("Levels")
                .font(.headline)
                .foregroundColor(.appTextSecondary)

            if allThreeStar {
                StarShape()
                    .fill(Color.appPrimary)
                    .frame(width: 16, height: 16)
                Text("Perfect row")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.appAccent)
            }
            Spacer()
        }
    }

    private var activitySelector: some View {
        HStack(spacing: 8) {
            activityButton(.shapeShifter, label: "Shape")
            activityButton(.colorCraze, label: "Color")
            activityButton(.patternMatch, label: "Pairs")
        }
    }

    private func activityButton(_ kind: ActivityKind, label: String) -> some View {
        Button(action: { activity = kind }) {
            Text(label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(kind == activity ? .appBackground : .appTextSecondary)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(kind == activity ? Color.appPrimary : Color.appSurface)
                )
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private var difficultySelector: some View {
        HStack(spacing: 8) {
            difficultyButton(.easy, label: "Easy")
            difficultyButton(.normal, label: "Normal")
            difficultyButton(.hard, label: "Hard")
        }
    }

    private func difficultyButton(_ diff: Difficulty, label: String) -> some View {
        Button(action: { difficulty = diff }) {
            Text(label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(diff == difficulty ? .appBackground : .appTextSecondary)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(diff == difficulty ? Color.appPrimary : Color.appSurface)
                )
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private var levelGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1...levelsPerDifficulty, id: \.self) { index in
                let level = LevelIdentifier(activity: activity, difficulty: difficulty, index: index)
                let stars = storage.bestStars(for: level)
                let unlocked = storage.isLevelUnlocked(level, maxLevels: levelsPerDifficulty)

                Button(action: {
                    if unlocked {
                        selectedLevel = level
                    }
                }) {
                    LevelCellView(index: index, stars: stars, unlocked: unlocked)
                }
                .disabled(!unlocked)
            }
        }
    }
}

private struct WrappedResult: Identifiable {
    let id: LevelIdentifier
    let level: LevelIdentifier
    let result: LevelResult
}

struct LevelCellView: View {
    let index: Int
    let stars: Int
    let unlocked: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appBackground.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)

            VStack(spacing: 6) {
                Text("#\(index)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(unlocked ? .appTextPrimary : .appTextSecondary.opacity(0.6))

                ZStack {
                    if stars == 3 {
                        Circle()
                            .stroke(Color.appAccent.opacity(0.9), lineWidth: 2)
                            .frame(width: 26, height: 26)
                            .shadow(color: Color.appAccent.opacity(0.7), radius: 6, x: 0, y: 3)
                    }
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            StarShape()
                                .fill(i < stars ? Color.appPrimary : Color.appSurface.opacity(0.8))
                                .frame(width: 12, height: 12)
                        }
                    }
                }

                Image(systemName: unlocked ? "lock.open" : "lock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(unlocked ? .appAccent : .appTextSecondary.opacity(0.7))
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity, minHeight: 72)
    }
}

