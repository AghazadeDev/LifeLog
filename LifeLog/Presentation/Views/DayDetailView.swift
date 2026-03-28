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
            // Notes
            Section {
                ForEach(notes, id: \.id) { note in
                    NavigationLink(value: note) {
                        noteRow(note)
                    }
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let mood = note.mood {
                    Text(mood)
                }
                Text(note.createdAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Text(note.text)
                .font(.subheadline)
                .lineLimit(6)

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
    }
}
