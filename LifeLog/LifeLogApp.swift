import SwiftUI
import SwiftData

@main
struct LifeLogApp: App {
    private let store = SwiftDataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(store.modelContainer)
    }

    init() {
        NotificationUseCase().requestAndSchedule()
    }
}
