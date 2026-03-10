//
//  ShapeShifterGame.swift
//  Begrarvezar Broxrel
//
//  Created by Hughesan Drew on 10.03.2026.
//

import SwiftUI
import Combine

final class ShapeShifterViewModel: ObservableObject {
    @Published var pieces: [ShapePiece] = []
    @Published var isCompleted: Bool = false
    @Published var startDate: Date = Date()

    let level: LevelIdentifier

    init(level: LevelIdentifier) {
        self.level = level
        generatePieces()
        startDate = Date()
    }

    private func generatePieces() {
        let count: Int
        switch level.difficulty {
        case .easy:
            count = 2
        case .normal:
            count = 3
        case .hard:
            count = 4
        }

        var generated: [ShapePiece] = []
        generated.reserveCapacity(count)

        // Варианты раскладок зависят от номера уровня
        let pattern = level.index % 3

        for index in 0..<count {
            let kind: ShapePiece.Kind = index % 2 == 0 ? .square : .circle

            let baseX = CGFloat(index - (count - 1) / 2) * 70
            let targetY: CGFloat
            let startY: CGFloat
            let startX: CGFloat

            switch pattern {
            case 0:
                // Классическая горизонтальная линия
                targetY = -40
                startY = 120
                startX = baseX
            case 1:
                // Диагональная раскладка
                targetY = -60 + CGFloat(index) * 30
                startY = 140 - CGFloat(index) * 20
                startX = baseX * 1.1
            default:
                // Раскладка дугой
                let arc = CGFloat(index) - CGFloat(count - 1) / 2
                targetY = -30 - abs(arc) * 20
                startY = 130 + abs(arc) * 10
                startX = baseX * 1.2
            }

            let target = CGSize(width: startX, height: targetY)
            let current = CGSize(width: startX * 0.9, height: startY)

            let piece = ShapePiece(
                id: index,
                kind: kind,
                targetOffset: target,
                currentOffset: current,
                isPlaced: false
            )
            generated.append(piece)
        }

        pieces = generated
    }

    func dragPiece(id: Int, translation: CGSize, end: Bool) {
        guard let index = pieces.firstIndex(where: { $0.id == id }) else { return }
        var piece = pieces[index]
        if end {
            let dx = piece.targetOffset.width - (piece.currentOffset.width + translation.width)
            let dy = piece.targetOffset.height - (piece.currentOffset.height + translation.height)
            let distance = sqrt(dx * dx + dy * dy)
            if distance < 30 {
                piece.currentOffset = piece.targetOffset
                piece.isPlaced = true
                Haptics.light()
            } else {
                piece.currentOffset = CGSize(
                    width: piece.currentOffset.width + translation.width,
                    height: piece.currentOffset.height + translation.height
                )
            }
            pieces[index] = piece
            checkCompletion()
        } else {
            var temp = piece
            temp.currentOffset = CGSize(
                width: piece.currentOffset.width + translation.width,
                height: piece.currentOffset.height + translation.height
            )
            pieces[index] = temp
        }
    }

    private func checkCompletion() {
        if pieces.allSatisfy({ $0.isPlaced }) {
            isCompleted = true
            Haptics.success()
        }
    }

    func makeResult() -> LevelResult {
        let elapsed = Date().timeIntervalSince(startDate)
        let accuracy = Double(pieces.filter { $0.isPlaced }.count) / Double(pieces.count)
        let stars: Int
        switch level.difficulty {
        case .easy:
            stars = elapsed < 25 && accuracy > 0.9 ? 3 : (elapsed < 40 && accuracy > 0.8 ? 2 : 1)
        case .normal:
            stars = elapsed < 35 && accuracy > 0.9 ? 3 : (elapsed < 55 && accuracy > 0.8 ? 2 : 1)
        case .hard:
            stars = elapsed < 45 && accuracy > 0.9 ? 3 : (elapsed < 70 && accuracy > 0.8 ? 2 : 1)
        }
        return LevelResult(stars: stars, timeSeconds: elapsed, accuracy: accuracy)
    }
}

struct ShapePiece: Identifiable {
    enum Kind {
        case square
        case circle
    }

    let id: Int
    let kind: Kind
    let targetOffset: CGSize
    var currentOffset: CGSize
    var isPlaced: Bool
}

struct ShapeShifterGameView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @StateObject private var viewModel: ShapeShifterViewModel
    let isPractice: Bool
    let onComplete: (LevelResult) -> Void

    init(level: LevelIdentifier, isPractice: Bool = false, onComplete: @escaping (LevelResult) -> Void) {
        _viewModel = StateObject(wrappedValue: ShapeShifterViewModel(level: level))
        self.isPractice = isPractice
        self.onComplete = onComplete
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Shape Shifter")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                    .padding(.top, 16)

                Text("Slide and place each glowing piece into its soft outline.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.appSurface)
                        .frame(height: 280)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.appAccent.opacity(0.6), lineWidth: 1.5)
                        )

                    GeometryReader { geo in
                        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                        ForEach(viewModel.pieces) { piece in
                            targetShape(for: piece)
                                .stroke(Color.appAccent.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                                .frame(width: 70, height: 70)
                                .position(
                                    x: center.x + piece.targetOffset.width,
                                    y: center.y + piece.targetOffset.height
                                )
                        }

                        ForEach(viewModel.pieces) { piece in
                            draggableShape(for: piece)
                                .frame(width: 70, height: 70)
                                .position(
                                    x: center.x + piece.currentOffset.width,
                                    y: center.y + piece.currentOffset.height
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 300)

                Button(action: {
                    let result = viewModel.makeResult()
                    if isPractice {
                        storage.registerDailyStars(0)
                    }
                    onComplete(result)
                }) {
                    Text(viewModel.isCompleted ? "Finish round" : "Give up")
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

    private func targetShape(for piece: ShapePiece) -> some Shape {
        switch piece.kind {
        case .square:
            return AnyShape(RoundedRectangle(cornerRadius: 16))
        case .circle:
            return AnyShape(Circle())
        }
    }

    private func draggableShape(for piece: ShapePiece) -> some View {
        let base = targetShape(for: piece)
        let color: Color = piece.isPlaced ? .appPrimary : .appAccent

        return base
            .fill(color)
            .shadow(color: color.opacity(0.8), radius: 10, x: 0, y: 6)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !piece.isPlaced {
                            viewModel.dragPiece(id: piece.id, translation: value.translation, end: false)
                        }
                    }
                    .onEnded { value in
                        if !piece.isPlaced {
                            viewModel.dragPiece(id: piece.id, translation: value.translation, end: true)
                        }
                    }
            )
    }
}

struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        self.pathBuilder = { rect in
            wrapped.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

