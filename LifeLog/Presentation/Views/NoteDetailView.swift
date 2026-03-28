import SwiftUI

struct NoteDetailView: View {
    let note: NoteEntry
    var lang = LanguageManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    if let mood = note.mood {
                        Text(mood)
                            .font(.title2)
                    }
                    Text(note.createdAt, format: .dateTime.year().month().day().hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.orange)
                    }
                }

                Text(note.text)
                    .font(.body)

                if let photoData = note.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if !note.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(note.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
