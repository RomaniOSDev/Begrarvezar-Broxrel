//
//  OnboardingViews.swift
//  Begrarvezar Broxrel
//
//  Created by Hughesan Drew on 10.03.2026.
//

import SwiftUI

enum OnboardingStyle {
    case shapes
    case colors
    case cards
}

struct OnboardingContainerView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @State private var currentPage: Int = 0

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    title: "Shape your move",
                    message: "Drag, rotate and place glowing pieces into soft outlines.",
                    style: .shapes
                )
                .tag(0)

                OnboardingPageView(
                    title: "Chase the colors",
                    message: "Swipe through flowing tiles to match the target sequence.",
                    style: .colors
                )
                .tag(1)

                OnboardingPageView(
                    title: "Flip and find pairs",
                    message: "Watch the grid, track positions and uncover hidden pairs.",
                    style: .cards
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))

            HStack(spacing: 16) {
                Button(action: {
                    storage.markOnboardingSeen()
                }) {
                    Text("Skip")
                        .font(.headline)
                        .foregroundColor(.appTextSecondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.appTextSecondary.opacity(0.4), lineWidth: 1)
                        )
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)

                Button(action: {
                    if currentPage < 2 {
                        withAnimation(.easeInOut) {
                            currentPage += 1
                        }
                    } else {
                        storage.markOnboardingSeen()
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Start playing")
                        .font(.headline)
                        .foregroundColor(.appBackground)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.appPrimary)
                        )
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

struct OnboardingPageView: View {
    let title: String
    let message: String
    let style: OnboardingStyle
    @State private var animate: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 32)

                OnboardingCanvas(style: style, animate: animate)
                    .frame(height: 260)
                    .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.appTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    Text(message)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                Spacer(minLength: 32)
            }
        }
        .background(Color.appBackground)
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.7, blendDuration: 0.4)) {
                animate = true
            }
        }
    }
}

struct OnboardingCanvas: View {
    let style: OnboardingStyle
    let animate: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appBackground],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.appAccent.opacity(0.3), lineWidth: 1.5)
                )

            switch style {
            case .shapes:
                ShapeShifterIllustration(animate: animate)
            case .colors:
                ColorCrazeIllustration(animate: animate)
            case .cards:
                CardGridIllustration(animate: animate)
            }
        }
        .padding(8)
    }
}

struct ShapeShifterIllustration: View {
    let animate: Bool

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let base = size * 0.2

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .foregroundColor(.appAccent.opacity(0.7))
                    .frame(width: base * 2.6, height: base * 2)
                    .offset(x: -base * 0.6, y: -base * 0.5)

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appPrimary.opacity(0.9))
                    .frame(width: base * 1.8, height: base * 1.8)
                    .rotationEffect(.degrees(animate ? -6 : 10))
                    .offset(x: animate ? -base * 0.2 : -base, y: animate ? -base * 0.2 : -base * 0.6)
                    .shadow(color: Color.appPrimary.opacity(0.7), radius: 12, x: 0, y: 8)
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: animate)

                Circle()
                    .strokeBorder(Color.appAccent.opacity(0.8), lineWidth: 2)
                    .frame(width: base * 1.6, height: base * 1.6)
                    .offset(x: base * 0.9, y: base * 0.4)

                Circle()
                    .fill(Color.appAccent)
                    .frame(width: base * 1.1, height: base * 1.1)
                    .offset(x: animate ? base * 0.6 : base * 1.1, y: animate ? base * 0.15 : base * 0.6)
                    .shadow(color: Color.appAccent.opacity(0.8), radius: 10, x: 0, y: 6)
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animate)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ColorCrazeIllustration: View {
    let animate: Bool

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let tileWidth = size.width / 5

            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.5 + Double(index) * 0.1),
                                Color.appAccent.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                        )
                        .frame(width: tileWidth * 0.9)
                        .offset(y: animate ? CGFloat(index % 2 == 0 ? -8 : 8) : 0)
                        .animation(
                            .easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                            value: animate
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CardGridIllustration: View {
    let animate: Bool

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cardWidth = size.width / 3.4

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    cardView(flipped: animate)
                        .frame(width: cardWidth)
                    cardView(flipped: false)
                        .frame(width: cardWidth)
                }
                HStack(spacing: 10) {
                    cardView(flipped: false)
                        .frame(width: cardWidth)
                    cardView(flipped: animate)
                        .frame(width: cardWidth)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func cardView(flipped: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.appSurface)
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)

            if flipped {
                StarShape()
                    .fill(Color.appPrimary)
                    .frame(width: 26, height: 26)
                    .shadow(color: Color.appPrimary.opacity(0.8), radius: 8, x: 0, y: 4)
                    .transition(.scale.combined(with: .opacity))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.appAccent.opacity(0.7), style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                    .padding(8)
            }
        }
        .rotation3DEffect(.degrees(flipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.9, dampingFraction: 0.7), value: flipped)
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 5
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.45
        var path = Path()

        for i in 0..<(points * 2) {
            let angle = Double(i) * Double.pi / Double(points)
            let radius = (i % 2 == 0) ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

