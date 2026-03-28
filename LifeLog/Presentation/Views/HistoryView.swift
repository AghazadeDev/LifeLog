import SwiftUI

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel
    private var lang = LanguageManager.shared

    init(viewModel: HistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List(viewModel.days, id: \.id) { day in
                NavigationLink {
                    DayDetailView(day: day, notes: viewModel.notesForDay(day)) { note in
                        viewModel.deleteNote(note)
                    }
                } label: {
                    HStack {
                        Text(day.date, format: .dateTime.year().month().day())
                        Spacer()
                        Text(String(format: lang.localizedString("history.entryCount"), day.notes.count))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(lang.localizedString("tab.history"))
            .toolbar {
                Button(lang.localizedString("history.export")) {
                    viewModel.exportJournal()
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let url = viewModel.exportFileURL {
                    ShareSheet(items: [url])
                }
            }
            .onAppear { viewModel.loadDays() }
            .overlay {
                if viewModel.days.isEmpty {
                    ContentUnavailableView(
                        lang.localizedString("history.empty"),
                        systemImage: "calendar"
                    )
                }
            }
        }
    }
}
