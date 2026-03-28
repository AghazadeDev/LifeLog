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
            ForEach(notes, id: \.id) { note in
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
                    let note = notes[index]
                    onDelete?(note)
                }
                notes.remove(atOffsets: offsets)
            }
        }
        .listStyle(.plain)
        .navigationTitle(day.date.formatted(.dateTime.year().month().day()))
    }
}
