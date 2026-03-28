import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    private var lang = LanguageManager.shared

    var body: some View {
        TabView {
            Tab(lang.localizedString("tab.today"), systemImage: "square.and.pencil") {
                TodayView(viewModel: TodayViewModel(modelContext: modelContext))
            }
            Tab(lang.localizedString("tab.history"), systemImage: "clock") {
                HistoryView(viewModel: HistoryViewModel(modelContext: modelContext))
            }
            Tab(lang.localizedString("tab.stats"), systemImage: "chart.bar") {
                StatsView(viewModel: StatsViewModel(modelContext: modelContext))
            }
            Tab(lang.localizedString("tab.settings"), systemImage: "gearshape") {
                SettingsView()
            }
        }
    }
}
