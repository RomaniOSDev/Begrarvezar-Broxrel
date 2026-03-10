import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Settings")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.appTextPrimary)
                        .padding(.top, 24)

                    VStack(spacing: 12) {
                        settingsButton(
                            title: "Rate this experience",
                            subtitle: "Share quick feedback in the store.",
                            icon: "star.fill",
                            action: rateApp
                        )

                        settingsButton(
                            title: "Privacy policy",
                            subtitle: "Read how your data is handled.",
                            icon: "lock.fill",
                            action: openPrivacy
                        )

                        settingsButton(
                            title: "Terms of use",
                            subtitle: "Review the usage guidelines.",
                            icon: "doc.text.fill",
                            action: openTerms
                        )
                    }
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
        }
    }

    private func settingsButton(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appPrimary)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.appSurface.opacity(0.9))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface, Color.appBackground.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
            )
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

private func openPrivacy() {
    if let url = URL(string: "https://adminka.site/riprenstrifekarzor107.site/privacy/24") {
        UIApplication.shared.open(url)
    }
}

private func openTerms() {
    if let url = URL(string: "https://adminka.site/riprenstrifekarzor107.site/terms/24") {
        UIApplication.shared.open(url)
    }
}

private func rateApp() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        SKStoreReviewController.requestReview(in: windowScene)
    }
}

