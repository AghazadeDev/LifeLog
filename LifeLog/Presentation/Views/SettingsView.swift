import SwiftUI

struct SettingsView: View {
    @Bindable private var lang = LanguageManager.shared
    @State private var biometricEnabled = BiometricService.isEnabled

    var body: some View {
        NavigationStack {
            Form {
                // Language
                Section(footer: Text(lang.localizedString("settings.language.footer"))) {
                    Picker(lang.localizedString("settings.language"), selection: $lang.currentLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }

                // Appearance
                Section {
                    Picker(lang.localizedString("settings.appearance"), selection: $lang.currentAppearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.displayName(using: lang)).tag(appearance)
                        }
                    }
                }

                // Security
                if BiometricService.isBiometricAvailable {
                    Section(footer: Text(lang.localizedString("settings.biometric.footer"))) {
                        Toggle(isOn: $biometricEnabled) {
                            let service = BiometricService()
                            Label(
                                String(format: lang.localizedString("settings.biometric.toggle"), service.biometricName),
                                systemImage: service.biometricIcon
                            )
                        }
                        .onChange(of: biometricEnabled) { _, newValue in
                            BiometricService.isEnabled = newValue
                        }
                    }
                }

                // iCloud
                Section {
                    HStack {
                        Label(lang.localizedString("settings.icloud"), systemImage: "icloud")
                        Spacer()
                        Text(lang.localizedString("settings.icloud.enabled"))
                            .foregroundStyle(.secondary)
                    }
                }

                // AI Features
                Section(footer: Text(lang.localizedString("settings.ai.footer"))) {
                    HStack {
                        Label(lang.localizedString("settings.ai"), systemImage: "sparkles")
                        Spacer()
                        if #available(iOS 26.0, *) {
                            Text(lang.localizedString("settings.ai.available"))
                                .foregroundStyle(.green)
                        } else {
                            Text(lang.localizedString("settings.ai.unavailable"))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // About
                Section {
                    HStack {
                        Text(lang.localizedString("settings.version"))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(lang.localizedString("tab.settings"))
        }
    }
}
