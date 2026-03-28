import SwiftUI

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel
    @State private var selectedDay: DayEntry?
    private var lang = LanguageManager.shared

    init(viewModel: HistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View mode picker
                Picker("", selection: $viewModel.viewMode) {
                    Text(lang.localizedString("history.listView"))
                        .tag(HistoryViewMode.list)
                    Text(lang.localizedString("history.calendarView"))
                        .tag(HistoryViewMode.calendar)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                // Tag filter
                if !viewModel.allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            tagFilterChip(nil, title: lang.localizedString("history.allTags"))
                            ForEach(viewModel.allTags, id: \.self) { tag in
                                tagFilterChip(tag, title: tag)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }

                // Content
                if viewModel.viewMode == .calendar {
                    ScrollView {
                        CalendarGridView(
                            calendarData: viewModel.calendarData,
                            days: viewModel.days
                        ) { day in
                            selectedDay = day
                        }
                    }
                } else {
                    listContent
                }
            }
            .navigationTitle(lang.localizedString("tab.history"))
            .searchable(text: $viewModel.searchText, prompt: lang.localizedString("history.search"))
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.search()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.exportJournal()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let url = viewModel.exportFileURL {
                    ShareSheet(items: [url])
                }
            }
            .navigationDestination(item: $selectedDay) { day in
                DayDetailView(day: day, notes: viewModel.notesForDay(day)) { note in
                    viewModel.deleteNote(note)
                }
            }
            .navigationDestination(for: NoteEntry.self) { note in
                NoteDetailView(note: note)
            }
            .onAppear { viewModel.loadDays() }
            .overlay {
                if viewModel.filteredDays.isEmpty && viewModel.searchText.isEmpty {
                    ContentUnavailableView(
                        lang.localizedString("history.empty"),
                        systemImage: "calendar"
                    )
                }
            }
        }
    }

    private var listContent: some View {
        List {
            if !viewModel.searchText.isEmpty && !viewModel.searchResults.isEmpty {
                Section(lang.localizedString("history.searchResults")) {
                    ForEach(viewModel.searchResults, id: \.id) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                if let mood = note.mood {
                                    Text(mood)
                                }
                                Text(note.createdAt, format: .dateTime.year().month().day().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(note.text)
                                .lineLimit(2)
                        }
                    }
                }
            } else {
                ForEach(viewModel.filteredDays, id: \.id) { day in
                    NavigationLink {
                        DayDetailView(day: day, notes: viewModel.notesForDay(day)) { note in
                            viewModel.deleteNote(note)
                        }
                    } label: {
                        HStack {
                            if let mood = day.dominantMood {
                                Text(mood)
                            }
                            Text(day.date, format: .dateTime.year().month().day())
                            Spacer()
                            Text(String(format: lang.localizedString("history.entryCount"), day.notes.count))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func tagFilterChip(_ tag: String?, title: String) -> some View {
        let isSelected = viewModel.selectedTag == tag
        return Button {
            viewModel.filterByTag(tag)
        } label: {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
