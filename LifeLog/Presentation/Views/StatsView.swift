import SwiftUI

struct StatsView: View {
    @State private var viewModel: StatsViewModel

    init(viewModel: StatsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                statRow(title: "Total Days", value: "\(viewModel.stats.totalDays)", icon: "calendar")
                statRow(title: "Current Streak", value: "\(viewModel.stats.currentStreak) days", icon: "flame")
                statRow(title: "Longest Streak", value: "\(viewModel.stats.longestStreak) days", icon: "trophy")
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stats")
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
