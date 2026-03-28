import SwiftUI

struct StatsView: View {
    @State private var viewModel: StatsViewModel
    private var lang = LanguageManager.shared

    init(viewModel: StatsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                statRow(
                    title: lang.localizedString("stats.totalDays"),
                    value: "\(viewModel.stats.totalDays)",
                    icon: "calendar"
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
