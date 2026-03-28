import Foundation

enum Mood: String, CaseIterable, Identifiable {
    case great
    case good
    case neutral
    case bad
    case terrible

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good: return "😊"
        case .neutral: return "😐"
        case .bad: return "😕"
        case .terrible: return "😢"
        }
    }

    var numericValue: Double {
        switch self {
        case .great: return 5
        case .good: return 4
        case .neutral: return 3
        case .bad: return 2
        case .terrible: return 1
        }
    }

    var localizedKey: String {
        "mood.\(rawValue)"
    }

    init?(emoji: String) {
        guard let match = Mood.allCases.first(where: { $0.emoji == emoji }) else {
            return nil
        }
        self = match
    }
}
