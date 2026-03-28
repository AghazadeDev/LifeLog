import Foundation

struct JournalPromptService {
    private static let promptKeys: [String] = [
        "prompt.01", "prompt.02", "prompt.03", "prompt.04", "prompt.05",
        "prompt.06", "prompt.07", "prompt.08", "prompt.09", "prompt.10",
        "prompt.11", "prompt.12", "prompt.13", "prompt.14", "prompt.15",
        "prompt.16", "prompt.17", "prompt.18", "prompt.19", "prompt.20",
        "prompt.21", "prompt.22", "prompt.23", "prompt.24", "prompt.25",
        "prompt.26", "prompt.27", "prompt.28", "prompt.29", "prompt.30",
    ]

    func todayPrompt() -> String {
        let lang = LanguageManager.shared
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        let index = (dayOfYear - 1) % Self.promptKeys.count
        return lang.localizedString(Self.promptKeys[index])
    }
}
