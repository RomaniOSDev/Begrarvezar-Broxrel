//
//  PatternPairsGame.swift
//  Begrarvezar Broxrel
//
//  Created by Hughesan Drew on 10.03.2026.
//

import SwiftUI
import Combine

final class PatternPairsViewModel: ObservableObject {
    struct Card: Identifiable {
        let id: Int
        let symbolIndex: Int
        var isRevealed: Bool = false
        var isMatched: Bool = false
    }

    @Published var cards: [Card] = []
    @Published var remainingSeconds: Int = 0
    @Published var attempts: Int = 0
    @Published var isCompleted: Bool = false

    private var firstIndex: Int?
    private var timerCancellable: AnyCancellable?
    private let level: LevelIdentifier
    private let totalTime: Int

    init(level: LevelIdentifier) {
        self.level = level
        let pairCount: Int
        switch level.difficulty {
        case .easy:
            pairCount = 4
            totalTime = 70
        case .normal:
            pairCount = 6
            totalTime = 55
        case .hard:
            pairCount = 8
            totalTime = 45
        }

        remainingSeconds = totalTime
        var deck: [Card] = []
        var idCounter = 0
        for symbol in 0..<pairCount {
            deck.append(Card(id: idCounter, symbolIndex: symbol))
            idCounter += 1
            deck.append(Card(id: idCounter, symbolIndex: symbol))
            idCounter += 1
        }
        cards = deck.shuffled()
        startTimer()
    }

    private func startTimer() {
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.remainingSeconds > 0 && !self.isCompleted {
                    self.remainingSeconds -= 1
                }
                if self.remainingSeconds == 0 && !self.isCompleted {
                    self.isCompleted = true
                    self.timerCancellable?.cancel()
                }
            }
    }

    func tapCard(_ card: Card) {
        guard !isCompleted, remainingSeconds > 0 else { return }
        guard let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard !cards[idx].isMatched, !cards[idx].isRevealed else { return }

        cards[idx].isRevealed = true

        if let firstIndex {
            attempts += 1
            let firstCard = cards[firstIndex]
            if firstCard.symbolIndex == cards[idx].symbolIndex {
                cards[firstIndex].isMatched = true
                cards[idx].isMatched = true
                self.firstIndex = nil
                checkCompletion()
                Haptics.light()
            } else {
                let currentIndex = idx
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                    guard let self else { return }
                    if !self.cards[firstIndex].isMatched {
                        self.cards[firstIndex].isRevealed = false
                    }
                    if !self.cards[currentIndex].isMatched {
                        self.cards[currentIndex].isRevealed = false
                    }
                    self.firstIndex = nil
                }
            }
        } else {
            firstIndex = idx
        }
    }

    private func checkCompletion() {
        if cards.allSatisfy({ $0.isMatched }) {
            isCompleted = true
            timerCancellable?.cancel()
            Haptics.success()
        }
    }

    func makeResult() -> LevelResult {
        let matchedPairs = cards.filter { $0.isMatched }.count / 2
        let totalPairs = cards.count / 2
        let accuracy = totalPairs == 0 ? 0 : Double(matchedPairs) / Double(max(attempts, 1))

        let stars: Int
        let timeRatio = Double(remainingSeconds) / Double(totalTime)
        switch level.difficulty {
        case .easy:
            stars = timeRatio > 0.6 && accuracy > 0.6 ? 3 : (timeRatio > 0.3 && accuracy > 0.4 ? 2 : 1)
        case .normal:
            stars = timeRatio > 0.55 && accuracy > 0.6 ? 3 : (timeRatio > 0.3 && accuracy > 0.45 ? 2 : 1)
        case .hard:
            stars = timeRatio > 0.5 && accuracy > 0.6 ? 3 : (timeRatio > 0.25 && accuracy > 0.45 ? 2 : 1)
        }
        let elapsed = Double(totalTime - remainingSeconds)
        return LevelResult(stars: stars, timeSeconds: elapsed, accuracy: accuracy)
    }
}

struct PatternPairsGameView: View {
    @StateObject private var viewModel: PatternPairsViewModel
    let isPractice: Bool
    let onComplete: (LevelResult) -> Void

    init(level: LevelIdentifier, isPractice: Bool = false, onComplete: @escaping (LevelResult) -> Void) {
        _viewModel = StateObject(wrappedValue: PatternPairsViewModel(level: level))
        self.isPractice = isPractice
        self.onComplete = onComplete
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Pattern Pairs")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                    .padding(.top, 16)

                Text("Watch the grid, flip tiles and connect matching symbols before time runs out.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                timerView

                gridView

                Button(action: finishRound) {
                    Text("Finish round")
                        .font(.headline)
                        .foregroundColor(.appBackground)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appPrimary)
                        )
                }
                .padding(.horizontal, 16)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

                Spacer(minLength: 24)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    private var timerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Time left")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text("\(viewModel.remainingSeconds)s")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.appTextPrimary)
            }
            GeometryReader { geo in
                let width = geo.size.width
                let ratio = max(0, CGFloat(viewModel.remainingSeconds) / CGFloat(max(viewModel.remainingSeconds, 1)))
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appAccent)
                            .frame(width: width * ratio),
                        alignment: .leading
                    )
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 16)
    }

    private var gridView: some View {
        let total = viewModel.cards.count
        let side = total <= 8 ? 4 : 4
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: side)

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.cards) { card in
                cardView(card: card)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.appSurface)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
        )
        .padding(.horizontal, 16)
    }

    private func cardView(card: PatternPairsViewModel.Card) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.appSurface)

            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.appAccent.opacity(card.isRevealed || card.isMatched ? 0.9 : 0.4), lineWidth: 2)

            if card.isRevealed || card.isMatched {
                symbolView(for: card.symbolIndex)
                    .opacity(card.isMatched ? 1.0 : 0.9)
                    .scaleEffect(card.isMatched ? 1.08 : 1.0)
                    .transition(.scale.combined(with: .opacity))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.2), Color.appAccent.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(8)
            }
        }
        .frame(height: 70)
        .rotation3DEffect(
            .degrees(card.isRevealed || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: card.isRevealed)
        .onTapGesture {
            viewModel.tapCard(card)
        }
    }

    private func symbolView(for index: Int) -> some View {
        let clamped = max(0, index % 4)
        switch clamped {
        case 0:
            return AnyView(
                StarShape()
                    .fill(Color.appPrimary)
                    .frame(width: 22, height: 22)
            )
        case 1:
            return AnyView(
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.appTextPrimary.opacity(0.2), lineWidth: 2)
                    )
            )
        case 2:
            return AnyView(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.appPrimary)
                    .frame(width: 22, height: 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.appTextPrimary.opacity(0.2), lineWidth: 2)
                    )
            )
        default:
            return AnyView(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 24, height: 12)
            )
        }
    }

    private func finishRound() {
        let result = viewModel.makeResult()
        onComplete(result)
    }
}

