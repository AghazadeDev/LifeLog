import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            Tab("Today", systemImage: "square.and.pencil") {
                TodayView(viewModel: TodayViewModel(modelContext: modelContext))
            }
            Tab("History", systemImage: "clock") {
                HistoryView(viewModel: HistoryViewModel(modelContext: modelContext))
            }
            Tab("Stats", systemImage: "chart.bar") {
                StatsView(viewModel: StatsViewModel(modelContext: modelContext))
            }
        }
    }
}
