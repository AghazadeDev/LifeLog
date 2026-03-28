import Foundation
import LocalAuthentication

@Observable
final class BiometricService {
    var isUnlocked = false
    var biometricType: LABiometryType = .none

    private static let storageKey = "biometric_lock_enabled"

    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: storageKey) }
        set { UserDefaults.standard.set(newValue, forKey: storageKey) }
    }

    init() {
        checkBiometricAvailability()
        if !Self.isEnabled {
            isUnlocked = true
        }
    }

    func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
        }
    }

    var usesBiometric: Bool {
        biometricType != .none
    }

    var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Passcode"
        }
    }

    var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }

    var lockLabel: String {
        if usesBiometric {
            return biometricName
        } else {
            return "Passcode"
        }
    }

    var lockIcon: String {
        if usesBiometric {
            return biometricIcon
        } else {
            return "lock.fill"
        }
    }

    static var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func authenticate() async -> Bool {
        let context = LAContext()
        let lang = LanguageManager.shared
        let reason = lang.localizedString("biometric.reason")

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            await MainActor.run { isUnlocked = success }
            return success
        } catch {
            return false
        }
    }

    func unlockWithPasscode(_ code: String) -> Bool {
        if PasscodeService.verify(code) {
            isUnlocked = true
            return true
        }
        return false
    }

    func lock() {
        isUnlocked = false
    }
}
