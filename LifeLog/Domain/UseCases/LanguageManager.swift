import Foundation
import SwiftUI

@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private static let languageKey = "app_language"
    private static let appearanceKey = "app_appearance"

    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.languageKey)
        }
    }

    var currentAppearance: AppAppearance {
        didSet {
            UserDefaults.standard.set(currentAppearance.rawValue, forKey: Self.appearanceKey)
        }
    }

    var locale: Locale {
        Locale(identifier: currentLanguage.localeIdentifier)
    }

    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Self.languageKey),
           let language = AppLanguage(rawValue: saved) {
            currentLanguage = language
        } else {
            let systemCode = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = AppLanguage(rawValue: systemCode) ?? .english
        }

        if let saved = UserDefaults.standard.string(forKey: Self.appearanceKey),
           let appearance = AppAppearance(rawValue: saved) {
            currentAppearance = appearance
        } else {
            currentAppearance = .system
        }
    }

    func localizedString(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    func displayName(using lang: LanguageManager) -> String {
        lang.localizedString("settings.appearance.\(rawValue)")
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .english: return "en-US"
        case .russian: return "ru-RU"
        }
    }
}
