import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Observable
final class AIService {
    var isProcessing = false
    var lastError: String?

    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    private func respond(to prompt: String) async -> String? {
        isProcessing = true
        lastError = nil
        defer { isProcessing = false }

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            lastError = error.localizedDescription
            return nil
        }
    }

    func generateTags(for text: String) async -> [String] {
        let prompt = """
        Categorize the following journal entry into one or more tags from this list: \
        work, health, personal, goals, family, travel, learning, finance, social, creativity.
        Return ONLY the matching tags separated by commas, nothing else.

        Entry: \(text)
        """
        guard let response = await respond(to: prompt) else { return [] }
        return response
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    func analyzeMood(for text: String) async -> String? {
        let emojis = Mood.allCases.map { $0.emoji }
        let prompt = """
        Analyze the mood of this journal entry. \
        Reply with ONLY one emoji from this list: \(emojis.joined(separator: " "))

        Entry: \(text)
        """
        guard let response = await respond(to: prompt) else { return nil }
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        return Mood(emoji: trimmed) != nil ? trimmed : nil
    }

    func generateDailyInsight(from notes: [NoteEntry]) async -> String? {
        guard !notes.isEmpty else { return nil }
        let entries = notes.map { "[\($0.createdAt.formatted(.dateTime.hour().minute()))] \($0.text)" }
            .joined(separator: "\n")
        let prompt = """
        Based on these journal entries from today, write a brief reflective insight (2-3 sentences) \
        that helps the user reflect on their day. Be warm and thoughtful.

        \(entries)
        """
        return await respond(to: prompt)
    }

    func generateWeeklySummary(from days: [DayEntry]) async -> String? {
        guard !days.isEmpty else { return nil }
        let summary = days.map { day in
            let date = day.date.formatted(.dateTime.month().day())
            let noteTexts = day.notes.map { $0.text }.joined(separator: "; ")
            let mood = day.dominantMood ?? "N/A"
            return "[\(date)] Mood: \(mood) | \(noteTexts)"
        }.joined(separator: "\n")

        let prompt = """
        Analyze these journal entries from the past week. Provide:
        1. Overall mood pattern
        2. Key themes and patterns
        3. One actionable suggestion for next week
        Keep it concise (5-6 sentences max).

        \(summary)
        """
        return await respond(to: prompt)
    }

    func generateMonthlySummary(from days: [DayEntry]) async -> String? {
        guard !days.isEmpty else { return nil }
        let summary = days.map { day in
            let date = day.date.formatted(.dateTime.month().day())
            let count = day.notes.count
            let mood = day.dominantMood ?? "N/A"
            return "[\(date)] \(count) entries, mood: \(mood)"
        }.joined(separator: "\n")

        let prompt = """
        Analyze these journal entries from the past month. Provide:
        1. Overall mood trend
        2. Most productive patterns
        3. Areas of growth
        4. Two suggestions for the coming month
        Keep it concise (6-8 sentences max).

        \(summary)
        """
        return await respond(to: prompt)
    }

    func generateJournalReview(from days: [DayEntry]) async -> String? {
        guard !days.isEmpty else { return nil }
        let summary = days.prefix(30).map { day in
            let date = day.date.formatted(.dateTime.month().day())
            let mood = day.dominantMood ?? ""
            let texts = day.notes.prefix(5).map { $0.text }.joined(separator: "; ")
            return "[\(date)] \(mood) \(texts)"
        }.joined(separator: "\n")

        let prompt = """
        You are a thoughtful life coach reviewing someone's journal. Analyze these entries and provide:
        1. **Mood Analysis**: Overall emotional patterns and shifts
        2. **Key Themes**: Recurring topics and interests
        3. **Strengths**: Positive habits and behaviors observed
        4. **Suggestions**: Personalized advice for well-being and growth

        Be empathetic, constructive, and specific. Keep the review under 200 words.

        \(summary)
        """
        return await respond(to: prompt)
    }

    func generateContextualPrompt(from recentNotes: [NoteEntry]) async -> String? {
        let context = recentNotes.prefix(5).map { $0.text }.joined(separator: "; ")
        let prompt = """
        Based on these recent journal entries, generate ONE thoughtful journaling prompt \
        that encourages deeper reflection. Return only the prompt question, nothing else.

        Recent entries: \(context)
        """
        return await respond(to: prompt)
    }
}
