import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @State private var showResetAlert: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    statsSection
                    achievementsSection
                    resetSection
                    settingsLinkSection
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Reset all progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                storage.resetAll()
            }
        } message: {
            Text("This will clear stars, levels and statistics across all activities.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Player overview")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.appTextPrimary)

            Text("Track your progress, highlights and total play time.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.appTextSecondary)
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.appTextPrimary)

            HomeStatsView()
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Highlights")
                .font(.headline)
                .foregroundColor(.appTextPrimary)

            VStack(spacing: 12) {
                highlightRow(
                    title: "First full clear",
                    description: "Finish any level with at least one star.",
                    active: storage.completedLevelsCount > 0
                )
                highlightRow(
                    title: "Perfect sparkle",
                    description: "Reach a three-star result on any challenge.",
                    active: storage.hasPerfectThreeStarRun
                )
                highlightRow(
                    title: "All modes sampled",
                    description: "Play at least one round in each activity.",
                    active: storage.hasPlayedAllActivitiesOnce
                )
                highlightRow(
                    title: "Star collector I",
                    description: "Gather at least 30 stars across all levels.",
                    active: storage.hasStarMilestone30
                )
                highlightRow(
                    title: "Star collector II",
                    description: "Gather at least 60 stars across all levels.",
                    active: storage.hasStarMilestone60
                )
                highlightRow(
                    title: "Star collector III",
                    description: "Reach 100 total stars in your journey.",
                    active: storage.hasStarMilestone100
                )
                highlightRow(
                    title: "Three-star streak",
                    description: "Complete 10 rounds with three shining stars.",
                    active: storage.totalThreeStarRounds >= 10
                )
                highlightRow(
                    title: "Fast finisher",
                    description: "Clear any round in under 20 seconds.",
                    active: storage.hasFastFinisher
                )
                highlightRow(
                    title: "Sharp focus",
                    description: "Reach at least 95% accuracy in a single round.",
                    active: storage.hasSharpAccuracy
                )
                highlightRow(
                    title: "Daily rhythm I",
                    description: "Maintain a 3-day streak of daily runs.",
                    active: storage.hasDailyStreak3
                )
                highlightRow(
                    title: "Daily rhythm II",
                    description: "Maintain a 7-day streak of daily runs.",
                    active: storage.hasDailyStreak7
                )
            }
        }
    }

    private func highlightRow(title: String, description: String, active: Bool) -> some View {
        HStack(spacing: 12) {
            StarShape()
                .fill(active ? Color.appPrimary : Color.appSurface)
                .frame(width: 28, height: 28)
                .shadow(
                    color: active ? Color.appPrimary.opacity(0.8) : .clear,
                    radius: 8, x: 0, y: 4
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                Text(description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.appSurface)
        )
    }

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data")
                .font(.headline)
                .foregroundColor(.appTextPrimary)

            Button(action: {
                showResetAlert = true
            }) {
                Text("Reset all progress")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.appBackground)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appPrimary)
                    )
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
    }

    private var settingsLinkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More")
                .font(.headline)
                .foregroundColor(.appTextPrimary)

            NavigationLink {
                SettingsView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appPrimary)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appSurface.opacity(0.9))
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("App settings")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.appTextPrimary)
                        Text("Rate, privacy details and terms.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.appTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.appSurface)
                )
            }
        }
    }
}

