import Foundation
import SwiftData

final class SwiftDataStore {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([DayEntry.self, NoteEntry.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            let url = config.url
            let related = [
                url,
                url.deletingPathExtension().appendingPathExtension("store-shm"),
                url.deletingPathExtension().appendingPathExtension("store-wal")
            ]
            for file in related {
                try? FileManager.default.removeItem(at: file)
            }
            self.modelContainer = try! ModelContainer(for: schema, configurations: [config])
        }
    }
}
