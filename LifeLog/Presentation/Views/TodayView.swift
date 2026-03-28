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
                // Daily Prompt
                Section {
                    promptCard
                }
                .listRowBackground(Color.accentColor.opacity(0.08))

                // Pinned Notes
                if !viewModel.pinnedNotes.isEmpty {
                    Section(lang.localizedString("today.pinned")) {
                        ForEach(viewModel.pinnedNotes, id: \.id) { note in
                            NavigationLink(value: note) {
                                noteRow(note, pinned: true)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                viewModel.deleteNote(viewModel.pinnedNotes[index])
                            }
                        }
                    }
                }

                // Regular Notes
                Section {
                    ForEach(viewModel.todayNotes, id: \.id) { note in
                        NavigationLink(value: note) {
                            noteRow(note, pinned: false)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            viewModel.deleteNote(viewModel.todayNotes[index])
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if viewModel.todayNotes.isEmpty && viewModel.pinnedNotes.isEmpty {
                    ContentUnavailableView(
                        lang.localizedString("today.empty"),
                        systemImage: "pencil.line"
                    )
                }
            }
            .navigationTitle(lang.localizedString("tab.today"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddEntry, onDismiss: {
                viewModel.loadNotes()
            }) {
                AddEntryView(viewModel: AddEntryViewModel(
                    modelContext: modelContext
                ))
            }
            .navigationDestination(for: NoteEntry.self) { note in
                NoteDetailView(note: note)
            }
            .onAppear { viewModel.loadNotes() }
        }
    }

    private func noteRow(_ note: NoteEntry, pinned: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let mood = note.mood {
                    Text(mood)
                }
                Text(note.createdAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if pinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Text(note.text)
                .font(.subheadline)
                .lineLimit(4)

            if !note.tags.isEmpty || note.photoData != nil {
                HStack(spacing: 6) {
                    if note.photoData != nil {
                        Image(systemName: "photo")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(note.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                viewModel.togglePin(note)
            } label: {
                Image(systemName: note.isPinned ? "pin.slash" : "pin")
            }
            .tint(.orange)
        }
    }

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(lang.localizedString("today.prompt"), systemImage: "lightbulb")
                .font(.caption.bold())
                .foregroundStyle(.red)
            Text(viewModel.dailyPrompt)
                .font(.subheadline)
                .italic()
        }
        .onTapGesture {
            viewModel.showAddEntry = true
        }
    }

}
