import SwiftUI

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel

    init(viewModel: HistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List(viewModel.days, id: \.id) { day in
                NavigationLink {
                    DayDetailView(day: day, notes: viewModel.notesForDay(day))
                } label: {
                    HStack {
                        Text(day.date, format: .dateTime.year().month().day())
                        Spacer()
                        Text("\(day.notes.count) entries")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("History")
            .toolbar {
                Button("Export") {
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
                    ContentUnavailableView("No history yet", systemImage: "calendar")
                }
            }
        }
    }
}
