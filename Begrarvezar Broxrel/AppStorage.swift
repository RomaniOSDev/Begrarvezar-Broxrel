//
//  AppStorage.swift
//  Begrarvezar Broxrel
//
//  Created by Hughesan Drew on 10.03.2026.
//

import Foundation
import Combine

enum ActivityKind: String, CaseIterable, Codable {
    case shapeShifter
    case colorCraze
    case patternMatch
}

enum Difficulty: String, CaseIterable, Codable {
    case easy
    case normal
    case hard
}

struct LevelIdentifier: Hashable, Codable, Identifiable {
    var id: String {
        "\(activity.rawValue)_\(difficulty.rawValue)_\(index)"
    }
    let activity: ActivityKind
    let difficulty: Difficulty
    let index: Int
}

struct LevelResult: Codable {
    let stars: Int
    let timeSeconds: Double
    let accuracy: Double
}

extension Notification.Name {
    static let didResetAllProgress = Notification.Name("didResetAllProgress")
}

final class AppStorageManager: ObservableObject {
    @Published private(set) var levelResults: [String: LevelResult] = [:]
    @Published private(set) var totalPlayTime: TimeInterval = 0
    @Published private(set) var totalActivitiesPlayed: Int = 0
    @Published var hasSeenOnboarding: Bool = false
    @Published private(set) var dailyStars: Int = 0
    @Published private(set) var dailyDateIdentifier: String = ""
    @Published private(set) var dailyStreak: Int = 0

    private let defaults: UserDefaults

    private struct Keys {
        static let levelResults = "levelResults"
        static let totalPlayTime = "totalPlayTime"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let dailyStars = "dailyStars"
        static let dailyDateIdentifier = "dailyDateIdentifier"
        static let dailyStreak = "dailyStreak"
    }

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        load()
    }

    private func load() {
        if let data = defaults.data(forKey: Keys.levelResults),
           let decoded = try? JSONDecoder().decode([String: LevelResult].self, from: data) {
            levelResults = decoded
        }
        totalPlayTime = defaults.double(forKey: Keys.totalPlayTime)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        dailyStars = defaults.integer(forKey: Keys.dailyStars)
        dailyDateIdentifier = defaults.string(forKey: Keys.dailyDateIdentifier) ?? ""
        dailyStreak = defaults.integer(forKey: Keys.dailyStreak)
    }

    private func persistLevelResults() {
        if let data = try? JSONEncoder().encode(levelResults) {
            defaults.set(data, forKey: Keys.levelResults)
        }
    }

    private func persistStats() {
        defaults.set(totalPlayTime, forKey: Keys.totalPlayTime)
        defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed)
    }

    private func persistOnboarding() {
        defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding)
    }

    private func persistDaily() {
        defaults.set(dailyStars, forKey: Keys.dailyStars)
        defaults.set(dailyDateIdentifier, forKey: Keys.dailyDateIdentifier)
        defaults.set(dailyStreak, forKey: Keys.dailyStreak)
    }

    func levelKey(for id: LevelIdentifier) -> String {
        "\(id.activity.rawValue)_\(id.difficulty.rawValue)_\(id.index)"
    }

    func result(for id: LevelIdentifier) -> LevelResult? {
        levelResults[levelKey(for: id)]
    }

    func bestStars(for id: LevelIdentifier) -> Int {
        levelResults[levelKey(for: id)]?.stars ?? 0
    }

    func isLevelUnlocked(_ id: LevelIdentifier, maxLevels: Int) -> Bool {
        if id.index == 1 { return true }
        let previous = LevelIdentifier(activity: id.activity, difficulty: id.difficulty, index: id.index - 1)
        return bestStars(for: previous) > 0
    }

    func registerResult(for id: LevelIdentifier, stars: Int, timeSeconds: Double, accuracy: Double) {
        let clampedStars = max(0, min(stars, 3))
        let key = levelKey(for: id)
        let existing = levelResults[key]
        if let existing, existing.stars >= clampedStars {
            // Keep better or equal result
            levelResults[key] = existing
        } else {
            levelResults[key] = LevelResult(stars: clampedStars, timeSeconds: timeSeconds, accuracy: accuracy)
        }
        totalPlayTime += max(0, timeSeconds)
        totalActivitiesPlayed += 1
        persistLevelResults()
        persistStats()
    }

    func registerDailyStars(_ stars: Int) {
        let todayId = Self.todayIdentifier()
        if dailyDateIdentifier != todayId {
            // Новый день
            if let previousDate = Self.date(fromIdentifier: dailyDateIdentifier),
               let today = Self.date(fromIdentifier: todayId),
               Calendar.current.dateComponents([.day], from: previousDate, to: today).day == 1 {
                dailyStreak += 1
            } else if dailyDateIdentifier.isEmpty {
                dailyStreak = 1
            } else {
                dailyStreak = 1
            }
            dailyDateIdentifier = todayId
            dailyStars = 0
        }
        dailyStars += max(0, stars)
        persistDaily()
    }

    func markOnboardingSeen() {
        hasSeenOnboarding = true
        persistOnboarding()
    }

    // MARK: - Achievements (computed)

    var totalStars: Int {
        levelResults.values.reduce(0) { $0 + $1.stars }
    }

    var completedLevelsCount: Int {
        levelResults.values.filter { $0.stars > 0 }.count
    }

    var hasPerfectThreeStarRun: Bool {
        levelResults.values.contains { $0.stars == 3 }
    }

    var hasPlayedAllActivitiesOnce: Bool {
        let activities = Set(
            levelResults
                .keys
                .compactMap { key -> ActivityKind? in
                    let parts = key.split(separator: "_")
                    guard let first = parts.first else { return nil }
                    return ActivityKind(rawValue: String(first))
                }
        )
        return ActivityKind.allCases.allSatisfy { activities.contains($0) }
    }

    var totalThreeStarRounds: Int {
        levelResults.values.filter { $0.stars == 3 }.count
    }

    var hasStarMilestone30: Bool {
        totalStars >= 30
    }

    var hasStarMilestone60: Bool {
        totalStars >= 60
    }

    var hasStarMilestone100: Bool {
        totalStars >= 100
    }

    var hasDailyStreak3: Bool {
        dailyStreak >= 3
    }

    var hasDailyStreak7: Bool {
        dailyStreak >= 7
    }

    var hasFastFinisher: Bool {
        levelResults.values.contains { $0.timeSeconds < 20 }
    }

    var hasSharpAccuracy: Bool {
        levelResults.values.contains { $0.accuracy >= 0.95 }
    }

    // MARK: - Helpers (dates)

    private static func todayIdentifier() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private static func date(fromIdentifier id: String) -> Date? {
        guard !id.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: id)
    }

    // MARK: - Reset

    func resetAll() {
        levelResults = [:]
        totalPlayTime = 0
        totalActivitiesPlayed = 0
        hasSeenOnboarding = false
        dailyStars = 0
        dailyDateIdentifier = ""
        dailyStreak = 0

        defaults.removeObject(forKey: Keys.levelResults)
        defaults.removeObject(forKey: Keys.totalPlayTime)
        defaults.removeObject(forKey: Keys.totalActivitiesPlayed)
        defaults.removeObject(forKey: Keys.hasSeenOnboarding)
        defaults.removeObject(forKey: Keys.dailyStars)
        defaults.removeObject(forKey: Keys.dailyDateIdentifier)
        defaults.removeObject(forKey: Keys.dailyStreak)

        NotificationCenter.default.post(name: .didResetAllProgress, object: nil)
    }
}

