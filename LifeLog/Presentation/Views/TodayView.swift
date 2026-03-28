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

                // AI Daily Insight
                if viewModel.dailyInsight != nil || viewModel.isLoadingInsight {
                    Section(lang.localizedString("today.aiInsight")) {
                        insightCard
                    }
                }

                // Pinned Notes
                if !viewModel.pinnedNotes.isEmpty {
                    Section(lang.localizedString("today.pinned")) {
                        ForEach(viewModel.pinnedNotes, id: \.id) { note in
                            noteRow(note, pinned: true)
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
                        noteRow(note, pinned: false)
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
                ToolbarItem(placement: .secondaryAction) {
                    if #available(iOS 26.0, *) {
                        Button {
                            viewModel.loadDailyInsight()
                        } label: {
                            Label(lang.localizedString("today.getInsight"), systemImage: "sparkles")
                        }
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
            .onAppear { viewModel.loadNotes() }
        }
    }

    private func noteRow(_ note: NoteEntry, pinned: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                if let mood = note.mood {
                    Text(mood)
                }
                Text(note.createdAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
                Text(note.text)
                    .lineLimit(3)
                Spacer()
                if pinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            if let photoData = note.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            if !note.tags.isEmpty || !note.aiTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(note.tags + note.aiTags, id: \.self) { tag in
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

    private var insightCard: some View {
        Group {
            if viewModel.isLoadingInsight {
                HStack {
                    ProgressView()
                    Text(lang.localizedString("ai.analyzing"))
                        .foregroundStyle(.secondary)
                }
            } else if let insight = viewModel.dailyInsight {
                Text(insight)
                    .font(.subheadline)
            }
        }
    }
}
