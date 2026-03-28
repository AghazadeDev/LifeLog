import SwiftUI

struct DayDetailView: View {
    let day: DayEntry
    @State private var notes: [NoteEntry]
    private var lang = LanguageManager.shared
    private var onDelete: ((NoteEntry) -> Void)?

    init(day: DayEntry, notes: [NoteEntry], onDelete: ((NoteEntry) -> Void)? = nil) {
        self.day = day
        _notes = State(initialValue: notes)
        self.onDelete = onDelete
    }

    var body: some View {
        List {
            // AI Summary
            if let summary = day.aiSummary {
                Section(lang.localizedString("dayDetail.aiSummary")) {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Notes
            Section {
                ForEach(notes, id: \.id) { note in
                    noteRow(note)
                }
                .onDelete { offsets in
                    for index in offsets {
                        let note = notes[index]
                        onDelete?(note)
                    }
                    notes.remove(atOffsets: offsets)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(day.date.formatted(.dateTime.year().month().day()))
    }

    private func noteRow(_ note: NoteEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                if let mood = note.mood {
                    Text(mood)
                }
                Text(note.createdAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
                Text(note.text)
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            if let photoData = note.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if !note.tags.isEmpty || !note.aiTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(note.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        ForEach(note.aiTags, id: \.self) { tag in
                            HStack(spacing: 2) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 8))
                                Text(tag)
                            }
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
}
