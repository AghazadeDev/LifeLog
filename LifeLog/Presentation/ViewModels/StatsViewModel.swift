import Foundation
import SwiftData
import Observation

@Observable
final class StatsViewModel {
    var stats = JournalStats(totalDays: 0, currentStreak: 0, longestStreak: 0)

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
}
