import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @State private var showDailyRun: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroHeader
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                    HomeStatsView()
                        .padding(.horizontal, 16)

                    dailyRunCard
                        .padding(.horizontal, 16)

                    quickActionsRow
                        .padding(.horizontal, 16)

                    Text("Activities")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                        .padding(.horizontal, 16)

                    VStack(spacing: 16) {
                        ActivitySummaryCard(
                            title: "Shape Shifter",
                            subtitle: "Guide pieces into soft outlines using smooth touch gestures."
                        )
                        ActivitySummaryCard(
                            title: "Color Craze",
                            subtitle: "Match flowing colors before the sequence fades away."
                        )
                        ActivitySummaryCard(
                            title: "Pattern Pairs",
                            subtitle: "Flip tiles, track positions and reveal matching pairs."
                        )
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 32)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .sheet(isPresented: $showDailyRun) {
                DailyRunView()
                    .environmentObject(storage)
            }
        }
    }

    private var heroHeader: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick spark sessions")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text("Drop into a short challenge, collect stars and come back anytime.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 90)

                VStack(spacing: 6) {
                    StarShape()
                        .fill(Color.appBackground)
                        .frame(width: 26, height: 26)
                        .shadow(color: Color.appBackground.opacity(0.6), radius: 6, x: 0, y: 4)

                    Text("\(storage.totalStars)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.appBackground)
                    Text("stars")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.appBackground.opacity(0.9))
                }
            }
        }
    }

    private var dailyRunCard: some View {
        Button(action: { showDailyRun = true }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.appBackground.opacity(0.18))
                        .frame(width: 52, height: 52)
                    StarShape()
                        .fill(Color.appBackground)
                        .frame(width: 26, height: 26)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily run")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.appBackground)
                    Text("Complete one streak across all three activities.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.appBackground.opacity(0.92))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(storage.dailyStars)★")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.appBackground)
                    Text("Streak \(storage.dailyStreak)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.appBackground.opacity(0.9))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            NavigationLink {
                ActivitiesRootView()
            } label: {
                quickActionCard(
                    title: "Jump into levels",
                    subtitle: "Pick a mode and climb through stars.",
                    iconSystemName: "square.grid.2x2"
                )
            }

            NavigationLink {
                ActivitiesRootView()
            } label: {
                quickActionCard(
                    title: "Practice run",
                    subtitle: "Warm up without touching your progress.",
                    iconSystemName: "wand.and.stars"
                )
            }
        }
    }

    private func quickActionCard(title: String, subtitle: String, iconSystemName: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconSystemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appPrimary)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appSurface.opacity(0.9))
                    )
                Spacer()
            }

            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.appSurface)
        )
    }
}

struct HomeStatsView: View {
    @EnvironmentObject private var storage: AppStorageManager

    private var formattedPlayTime: String {
        let minutes = Int(storage.totalPlayTime) / 60
        let seconds = Int(storage.totalPlayTime) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            statBlock(title: "Total stars", value: "\(storage.totalStars)")
            statBlock(title: "Sessions", value: "\(storage.totalActivitiesPlayed)")
            statBlock(title: "Play time", value: formattedPlayTime)
        }
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface)
        )
    }
}

struct ActivitySummaryCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    StarShape()
                        .fill(Color.appBackground)
                        .frame(width: 26, height: 26)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appSurface)
        )
    }
}

