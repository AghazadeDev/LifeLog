import SwiftUI

struct SettingsView: View {
    @Bindable private var lang = LanguageManager.shared

    var body: some View {
        NavigationStack {
            Form {
                Section(footer: Text(lang.localizedString("settings.language.footer"))) {
                    Picker(lang.localizedString("settings.language"), selection: $lang.currentLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }

                Section {
                    Picker(lang.localizedString("settings.appearance"), selection: $lang.currentAppearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.displayName(using: lang)).tag(appearance)
                        }
                    }
                }
            }
            .navigationTitle(lang.localizedString("tab.settings"))
        }
    }
}
