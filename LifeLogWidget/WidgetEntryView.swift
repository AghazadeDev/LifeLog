import SwiftUI
import WidgetKit

struct LifeLogWidgetEntryView: View {
    var entry: LifeLogEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.closed")
                    .foregroundStyle(.accentColor)
                Text("LifeLog")
                    .font(.caption.bold())
            }

            Spacer()

            if let mood = entry.dominantMood {
                Text(mood)
                    .font(.title)
            }

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
                Text("\(entry.currentStreak)")
                    .font(.title2.bold())
            }

            Text("\(entry.todayCount) today")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumWidget: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "book.closed")
                        .foregroundStyle(.accentColor)
                    Text("LifeLog")
                        .font(.headline)
                }

                Spacer()

                if let mood = entry.dominantMood {
                    Text(mood)
                        .font(.largeTitle)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading) {
                        Text("\(entry.currentStreak) days")
                            .font(.headline)
                        Text("Current streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "note.text")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading) {
                        Text("\(entry.todayCount)")
                            .font(.headline)
                        Text("Entries today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
    }
}
