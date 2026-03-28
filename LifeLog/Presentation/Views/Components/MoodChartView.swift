import SwiftUI
import Charts

struct MoodTrendChartView: View {
    let moodTrend: [(date: Date, mood: String)]
    var lang = LanguageManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.localizedString("stats.moodTrend"))
                .font(.headline)

            if moodTrend.isEmpty {
                Text(lang.localizedString("stats.noMoodData"))
                    .foregroundStyle(.secondary)
                    .font(.caption)
            } else {
                Chart {
                    ForEach(moodTrend.indices, id: \.self) { i in
                        let entry = moodTrend[i]
                        let value = Mood(emoji: entry.mood)?.numericValue ?? 3
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Mood", value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)

                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("Mood", value)
                        )
                    }
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self),
                               let mood = Mood.allCases.first(where: { Int($0.numericValue) == v }) {
                                Text(mood.emoji)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }
}

struct MoodDistributionChartView: View {
    let distribution: [String: Int]
    var lang = LanguageManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.localizedString("stats.moodDistribution"))
                .font(.headline)

            if distribution.isEmpty {
                Text(lang.localizedString("stats.noMoodData"))
                    .foregroundStyle(.secondary)
                    .font(.caption)
            } else {
                Chart {
                    ForEach(Mood.allCases) { mood in
                        let count = distribution[mood.emoji] ?? 0
                        BarMark(
                            x: .value("Mood", mood.emoji),
                            y: .value("Count", count)
                        )
                        .foregroundStyle(colorForMood(mood))
                    }
                }
                .frame(height: 150)
            }
        }
    }

    private func colorForMood(_ mood: Mood) -> Color {
        switch mood {
        case .great: return .green
        case .good: return .mint
        case .neutral: return .yellow
        case .bad: return .orange
        case .terrible: return .red
        }
    }
}
