import SwiftUI

struct LockScreenView: View {
    @Bindable var biometricService: BiometricService
    private var lang = LanguageManager.shared

    init(biometricService: BiometricService) {
        self.biometricService = biometricService
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("LifeLog")
                .font(.largeTitle.bold())

            Text(lang.localizedString("lock.subtitle"))
                .foregroundStyle(.secondary)

            Button {
                Task {
                    await biometricService.authenticate()
                }
            } label: {
                Label(
                    lang.localizedString("lock.unlock"),
                    systemImage: biometricService.biometricIcon
                )
                .font(.headline)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            Task {
                await biometricService.authenticate()
            }
        }
    }
}
