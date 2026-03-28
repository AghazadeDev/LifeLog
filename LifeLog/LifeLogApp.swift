import SwiftUI
import SwiftData

@main
struct LifeLogApp: App {
    private let store = SwiftDataStore()
    private var settings = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settings.currentAppearance.colorScheme)
        }
        .modelContainer(store.modelContainer)
    }

    init() {
        NotificationUseCase().requestAndSchedule()
    }
}
