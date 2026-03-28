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
        self.modelContainer = try! ModelContainer(for: schema, configurations: [config])
    }
}
