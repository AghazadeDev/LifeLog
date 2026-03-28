import SwiftUI
import SwiftData

@main
struct LifeLogApp: App {
    private let store = SwiftDataStore()
    private var settings = LanguageManager.shared
    @State private var biometricService = BiometricService()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .preferredColorScheme(settings.currentAppearance.colorScheme)

                if BiometricService.isEnabled && !biometricService.isUnlocked {
                    LockScreenView(biometricService: biometricService)
                        .transition(.opacity)
                }
            }
            .animation(.default, value: biometricService.isUnlocked)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background && BiometricService.isEnabled {
                    biometricService.lock()
                }
            }
        }
        .modelContainer(store.modelContainer)
    }

    init() {
        NotificationUseCase().requestAndSchedule()
    }
}
