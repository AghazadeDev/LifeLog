import Foundation

enum JournalTag: String, CaseIterable, Identifiable {
    case work
    case health
    case personal
    case goals
    case family
    case travel
    case learning
    case finance
    case social
    case creativity

    var id: String { rawValue }

    var localizedKey: String {
        "tag.\(rawValue)"
    }

    var icon: String {
        switch self {
        case .work: return "briefcase"
        case .health: return "heart"
        case .personal: return "person"
        case .goals: return "target"
        case .family: return "house"
        case .travel: return "airplane"
        case .learning: return "book"
        case .finance: return "dollarsign.circle"
        case .social: return "person.2"
        case .creativity: return "paintbrush"
        }
    }
}
