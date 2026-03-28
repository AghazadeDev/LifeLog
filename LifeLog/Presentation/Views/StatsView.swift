import SwiftUI
import Charts

struct StatsView: View {
    @State private var viewModel: StatsViewModel
    private var lang = LanguageManager.shared

    init(viewModel: StatsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                // Core Stats
                Section(lang.localizedString("stats.overview")) {
                    statRow(
                        title: lang.localizedString("stats.totalDays"),
                        value: "\(viewModel.stats.totalDays)",
                        icon: "calendar"
                    )
                    statRow(
                        title: lang.localizedString("stats.totalNotes"),
                        value: "\(viewModel.stats.totalNotes)",
                        icon: "note.text"
                    )
                    statRow(
                        title: lang.localizedString("stats.currentStreak"),
                        value: String(format: lang.localizedString("stats.days"), viewModel.stats.currentStreak),
                        icon: "flame"
                    )
                    statRow(
                        title: lang.localizedString("stats.longestStreak"),
                        value: String(format: lang.localizedString("stats.days"), viewModel.stats.longestStreak),
                        icon: "trophy"
                    )
                    statRow(
                        title: lang.localizedString("stats.avgPerDay"),
                        value: String(format: "%.1f", viewModel.stats.averageNotesPerDay),
                        icon: "chart.line.uptrend.xyaxis"
                    )
                }

                // Mood Trend
                if !viewModel.stats.moodTrend.isEmpty {
                    Section {
                        MoodTrendChartView(moodTrend: viewModel.stats.moodTrend)
                    }
                }

                // Mood Distribution
                if !viewModel.stats.moodDistribution.isEmpty {
                    Section {
                        MoodDistributionChartView(distribution: viewModel.stats.moodDistribution)
                    }
                }

                // Top Tags
                if !viewModel.stats.topTags.isEmpty {
                    Section(lang.localizedString("stats.topTags")) {
                        ForEach(viewModel.stats.topTags, id: \.tag) { item in
                            HStack {
                                if let predefined = JournalTag(rawValue: item.tag) {
                                    Image(systemName: predefined.icon)
                                        .foregroundStyle(.secondary)
                                }
                                Text(item.tag)
                                Spacer()
                                Text("\(item.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // AI Reports
                if #available(iOS 26.0, *) {
                    Section(lang.localizedString("stats.aiReports")) {
                        NavigationLink {
                            AIReviewView(viewModel: viewModel)
                        } label: {
                            Label(lang.localizedString("ai.journalReview"), systemImage: "sparkles")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(lang.localizedString("tab.stats"))
            .onAppear { viewModel.loadStats() }
        }
    }

    private func statRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
