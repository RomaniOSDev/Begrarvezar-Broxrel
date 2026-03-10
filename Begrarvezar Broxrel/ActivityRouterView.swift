import SwiftUI

struct ActivityRouterView: View {
    let level: LevelIdentifier
    let isPractice: Bool
    let onComplete: (LevelResult) -> Void

    init(level: LevelIdentifier, isPractice: Bool = false, onComplete: @escaping (LevelResult) -> Void) {
        self.level = level
        self.isPractice = isPractice
        self.onComplete = onComplete
    }

    var body: some View {
        switch level.activity {
        case .shapeShifter:
            ShapeShifterGameView(level: level, isPractice: isPractice, onComplete: onComplete)
        case .colorCraze:
            ColorCrazeGameView(level: level, isPractice: isPractice, onComplete: onComplete)
        case .patternMatch:
            PatternPairsGameView(level: level, isPractice: isPractice, onComplete: onComplete)
        }
    }
}

