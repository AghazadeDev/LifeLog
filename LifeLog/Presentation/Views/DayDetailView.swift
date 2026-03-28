import SwiftUI

struct DayDetailView: View {
    let day: DayEntry
    let notes: [NoteEntry]

    var body: some View {
        List(notes, id: \.id) { note in
            HStack(alignment: .top) {
                Text(note.createdAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
                Text(note.text)
            }
        }
        .listStyle(.plain)
        .navigationTitle(day.date.formatted(.dateTime.year().month().day()))
    }
}
