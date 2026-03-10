//
//  ResultView.swift
//  Begrarvezar Broxrel
//
//  Created by Hughesan Drew on 10.03.2026.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var storage: AppStorageManager

    let stars: Int
    let timeSeconds: Double
    let accuracy: Double
    let onNext: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void

    @State private var revealedStars: Int = 0
    @State private var showBanner: Bool = false

    private var unlockedLabel: String? {
        if stars == 3, storage.totalThreeStarRounds >= 10 {
            return "Three-star streak"
        } else if timeSeconds < 20 {
            return "Fast finisher"
        } else if accuracy >= 0.95 {
            return "Sharp focus"
        } else if storage.hasStarMilestone100 {
            return "Star collector III"
        } else if storage.hasStarMilestone60 {
            return "Star collector II"
        } else if storage.hasStarMilestone30 {
            return "Star collector I"
        } else {
            return nil
        }
    }

    private var nextStarGoal: (current: Int, target: Int)? {
        let total = storage.totalStars
        if total < 30 { return (total, 30) }
        if total < 60 { return (total, 60) }
        if total < 100 { return (total, 100) }
        return nil
    }

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color.appBackground, Color.appSurface],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 24)

                Text("Round complete")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)

                starRow

                statsSection

                actionButtons

                Spacer()
            }

            if showBanner {
                bannerView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            animateStars()
            checkAchievement()
        }
    }

    private var starRow: some View {
        HStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { index in
                StarShape()
                    .fill(index < revealedStars ? Color.appPrimary : Color.appSurface)
                    .frame(width: 40, height: 40)
                    .shadow(
                        color: index < revealedStars ? Color.appPrimary.opacity(0.8) : .clear,
                        radius: 12, x: 0, y: 6
                    )
                    .scaleEffect(index < revealedStars ? 1.0 : 0.7)
                    .opacity(index < revealedStars ? 1.0 : 0.3)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                            .delay(Double(index) * 0.15),
                        value: revealedStars
                    )
            }
        }
    }

    private var statsSection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Time")
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text(String(format: "%.1fs", timeSeconds))
                    .foregroundColor(.appTextPrimary)
            }

            HStack {
                Text("Accuracy")
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text("\(Int(accuracy * 100))%")
                    .foregroundColor(.appTextPrimary)
            }

            if let unlockedLabel {
                HStack(spacing: 8) {
                    StarShape()
                        .fill(Color.appPrimary)
                        .frame(width: 18, height: 18)
                    Text("Unlocked: \(unlockedLabel)")
                        .foregroundColor(.appTextPrimary)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Spacer()
                }
                .padding(.top, 4)
            }

            if let next = nextStarGoal {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Next badge")
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        Text("\(next.current)/\(next.target)★")
                            .foregroundColor(.appTextPrimary)
                    }
                    GeometryReader { geo in
                        let ratio = CGFloat(min(max(next.current, 0), next.target)) / CGFloat(max(next.target, 1))
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appSurface.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.appAccent)
                                    .frame(width: geo.size.width * ratio),
                                alignment: .leading
                            )
                    }
                    .frame(height: 8)
                }
                .padding(.top, 4)
            }
        }
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appBackground.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 10)
        )
        .padding(.horizontal, 16)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onNext) {
                Text("Next level")
                    .font(.headline)
                    .foregroundColor(.appBackground)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appPrimary)
                    )
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            Button(action: onRetry) {
                Text("Retry")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appSurface)
                    )
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            Button(action: onBackToLevels) {
                Text("Back to levels")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
    }

    private var bannerView: some View {
        HStack(spacing: 10) {
            StarShape()
                .fill(Color.appPrimary)
                .frame(width: 26, height: 26)
                .shadow(color: Color.appPrimary.opacity(0.8), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("New highlight")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                Text("You reached a fresh performance milestone.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.appSurface)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func animateStars() {
        revealedStars = 0
        for i in 0..<min(3, stars) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                revealedStars = i + 1
            }
        }
    }

    private func checkAchievement() {
        if stars == 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    showBanner = true
                }
            }
        }
    }
}

