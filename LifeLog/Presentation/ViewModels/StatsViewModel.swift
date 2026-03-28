import Foundation
import SwiftData
import Observation

@Observable
final class StatsViewModel {
    var stats = JournalStats(totalDays: 0, totalNotes: 0, currentStreak: 0,
                             longestStreak: 0, averageNotesPerDay: 0,
                             moodDistribution: [:], moodTrend: [], topTags: [])
    var weeklyReport: String?
    var monthlyReport: String?
    var journalReview: String?
    var isLoadingWeekly = false
    var isLoadingMonthly = false
    var isLoadingReview = false

    private let journalUseCase: JournalUseCase
    private let statsUseCase = StatsUseCase()

    init(modelContext: ModelContext) {
        self.journalUseCase = JournalUseCase(modelContext: modelContext)
        loadStats()
    }

    func loadStats() {
        let days = journalUseCase.fetchAllDays()
        stats = statsUseCase.calculate(from: days)
    }

    func generateWeeklyReport() {
        if #available(iOS 26.0, *) {
            Task {
                isLoadingWeekly = true
                let days = journalUseCase.fetchAllDays()
                let calendar = Calendar.current
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now)!
                let recentDays = days.filter { $0.date >= weekAgo }
                let ai = AIService()
                weeklyReport = await ai.generateWeeklySummary(from: recentDays)
                isLoadingWeekly = false
            }
        }
    }

    func generateMonthlyReport() {
        if #available(iOS 26.0, *) {
            Task {
                isLoadingMonthly = true
                let days = journalUseCase.fetchAllDays()
                let calendar = Calendar.current
                let monthAgo = calendar.date(byAdding: .month, value: -1, to: .now)!
                let recentDays = days.filter { $0.date >= monthAgo }
                let ai = AIService()
                monthlyReport = await ai.generateMonthlySummary(from: recentDays)
                isLoadingMonthly = false
            }
        }
    }

    func generateJournalReview() {
        if #available(iOS 26.0, *) {
            Task {
                isLoadingReview = true
                let days = journalUseCase.fetchAllDays()
                let ai = AIService()
                journalReview = await ai.generateJournalReview(from: days)
                isLoadingReview = false
            }
        }
    }
}
