import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodayViewModel
    private var lang = LanguageManager.shared

    init(viewModel: TodayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.todayNotes, id: \.id) { note in
                    HStack(alignment: .top) {
                        Text(note.createdAt, format: .dateTime.hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .leading)
                        Text(note.text)
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        viewModel.deleteNote(viewModel.todayNotes[index])
                    }
                }
            }
            .listStyle(.plain)
            .overlay {
                if viewModel.todayNotes.isEmpty {
                    ContentUnavailableView(
                        lang.localizedString("today.empty"),
                        systemImage: "pencil.line"
                    )
                }
            }
            .navigationTitle(lang.localizedString("tab.today"))
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
