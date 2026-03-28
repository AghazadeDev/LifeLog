import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodayViewModel

    init(viewModel: TodayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List(viewModel.todayNotes, id: \.id) { note in
                HStack(alignment: .top) {
                    Text(note.createdAt, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)
                    Text(note.text)
                }
            }
            .listStyle(.plain)
            .overlay {
                if viewModel.todayNotes.isEmpty {
                    ContentUnavailableView("No entries yet", systemImage: "pencil.line")
                }
            }
            .navigationTitle("Today")
            .toolbar {
                Button {
                    viewModel.showAddEntry = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showAddEntry, onDismiss: {
                viewModel.loadNotes()
            }) {
                AddEntryView(viewModel: AddEntryViewModel(
                    modelContext: modelContext
                ))
            }
            .onAppear { viewModel.loadNotes() }
        }
    }
}
