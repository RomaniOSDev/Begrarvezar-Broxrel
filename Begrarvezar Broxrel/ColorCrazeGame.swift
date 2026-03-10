import SwiftUI
import Combine

final class ColorCrazeViewModel: ObservableObject {
    struct Tile: Identifiable {
        let id: Int
        var index: Int
    }

    @Published var tiles: [Tile] = []
    @Published var targetSequence: [Int] = []
    @Published var isCompleted: Bool = false
    @Published var startDate: Date = Date()

    let level: LevelIdentifier
    let palette: [Color] = [.appPrimary, .appAccent, .appSurface, .appTextPrimary]

    init(level: LevelIdentifier) {
        self.level = level
        generateGrid()
        startDate = Date()
    }

    private func gridSize() -> Int {
        switch level.difficulty {
        case .easy: return 2
        case .normal: return 3
        case .hard: return 3
        }
    }

    private func sequenceLength() -> Int {
        switch level.difficulty {
        case .easy: return 3
        case .normal: return 4
        case .hard: return 5
        }
    }

    private func generateGrid() {
        let size = gridSize()
        let total = size * size
        tiles = (0..<total).map { Tile(id: $0, index: Int.random(in: 0..<palette.count)) }

        targetSequence = (0..<sequenceLength()).map { _ in Int.random(in: 0..<palette.count) }
    }

    func cycleTile(id: Int, directionUp: Bool) {
        guard let idx = tiles.firstIndex(where: { $0.id == id }) else { return }
        var tile = tiles[idx]
        let count = palette.count
        tile.index = (tile.index + (directionUp ? 1 : -1) + count) % count
        tiles[idx] = tile
        evaluateCompletion()
        Haptics.light()
    }

    private func evaluateCompletion() {
        let sampleIndices = tiles.prefix(targetSequence.count).map { $0.index }
        isCompleted = sampleIndices == targetSequence
    }

    func makeResult() -> LevelResult {
        let elapsed = Date().timeIntervalSince(startDate)
        let sampleIndices = tiles.prefix(targetSequence.count).map { $0.index }
        let matches = zip(sampleIndices, targetSequence).filter { $0.0 == $0.1 }.count
        let accuracy = targetSequence.isEmpty ? 0 : Double(matches) / Double(targetSequence.count)

        let stars: Int
        switch level.difficulty {
        case .easy:
            stars = elapsed < 25 && accuracy > 0.9 ? 3 : (elapsed < 40 && accuracy > 0.7 ? 2 : 1)
        case .normal:
            stars = elapsed < 30 && accuracy > 0.9 ? 3 : (elapsed < 45 && accuracy > 0.7 ? 2 : 1)
        case .hard:
            stars = elapsed < 35 && accuracy > 0.9 ? 3 : (elapsed < 50 && accuracy > 0.7 ? 2 : 1)
        }
        return LevelResult(stars: stars, timeSeconds: elapsed, accuracy: accuracy)
    }
}

struct ColorCrazeGameView: View {
    @StateObject private var viewModel: ColorCrazeViewModel
    let isPractice: Bool
    let onComplete: (LevelResult) -> Void

    init(level: LevelIdentifier, isPractice: Bool = false, onComplete: @escaping (LevelResult) -> Void) {
        _viewModel = StateObject(wrappedValue: ColorCrazeViewModel(level: level))
        self.isPractice = isPractice
        self.onComplete = onComplete
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Color Craze")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                    .padding(.top, 16)

                Text("Swipe each tile up or down to align the opening sequence.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                targetRow

                gridView

                Button(action: finishRound) {
                    Text(viewModel.isCompleted ? "Finish round" : "End attempt")
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
        .background(
            LinearGradient(
                colors: [.appBackground, .appSurface],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
        )
    }

    private var targetRow: some View {
        VStack(spacing: 8) {
            Text("Target sequence")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)

            HStack(spacing: 8) {
                ForEach(Array(viewModel.targetSequence.enumerated()), id: \.offset) { item in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.palette[item.element])
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appTextPrimary.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appSurface)
            )
        }
        .padding(.horizontal, 16)
    }

    private var gridView: some View {
        let size = viewModel.tiles.count
        let side = Int(Double(size).squareRoot())
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: side)

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.tiles) { tile in
                tileView(tile: tile)
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

    private func tileView(tile: ColorCrazeViewModel.Tile) -> some View {
        let color = viewModel.palette[tile.index]
        return RoundedRectangle(cornerRadius: 16)
            .fill(color)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appTextPrimary.opacity(0.15), lineWidth: 1)
            )
            .frame(height: 60)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        let directionUp = value.translation.height < 0
                        viewModel.cycleTile(id: tile.id, directionUp: directionUp)
                    }
            )
    }

    private func finishRound() {
        let result = viewModel.makeResult()
        onComplete(result)
    }
}

