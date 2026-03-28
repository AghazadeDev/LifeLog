import SwiftUI

struct LockScreenView: View {
    @Bindable var biometricService: BiometricService
    @State private var passcode = ""
    @State private var showError = false
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

            if biometricService.usesBiometric {
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
            } else {
                PasscodeInputView(passcode: $passcode, showError: $showError) {
                    if biometricService.unlockWithPasscode(passcode) {
                        passcode = ""
                        showError = false
                    } else {
                        showError = true
                        passcode = ""
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            if biometricService.usesBiometric {
                Task {
                    await biometricService.authenticate()
                }
            }
        }
    }
}

struct PasscodeInputView: View {
    @Binding var passcode: String
    @Binding var showError: Bool
    var onSubmit: () -> Void
    var lang = LanguageManager.shared

    let codeLength = 4

    var body: some View {
        VStack(spacing: 24) {
            Text(lang.localizedString("lock.enterPasscode"))
                .font(.headline)

            HStack(spacing: 16) {
                ForEach(0..<codeLength, id: \.self) { index in
                    Circle()
                        .fill(index < passcode.count ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 16, height: 16)
                }
            }
            .modifier(ShakeEffect(shakes: showError ? 2 : 0))
            .animation(.default, value: showError)

            if showError {
                Text(lang.localizedString("lock.wrongPasscode"))
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(75)), count: 3), spacing: 16) {
                ForEach(1...9, id: \.self) { num in
                    PasscodeButton(title: "\(num)") {
                        appendDigit("\(num)")
                    }
                }
                Color.clear.frame(width: 75, height: 75)
                PasscodeButton(title: "0") {
                    appendDigit("0")
                }
                PasscodeButton(systemImage: "delete.left") {
                    if !passcode.isEmpty {
                        passcode.removeLast()
                        showError = false
                    }
                }
            }
        }
        .padding(.horizontal, 40)
    }

    private func appendDigit(_ digit: String) {
        guard passcode.count < codeLength else { return }
        passcode += digit
        showError = false
        if passcode.count == codeLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onSubmit()
            }
        }
    }
}

struct PasscodeButton: View {
    var title: String?
    var systemImage: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 75, height: 75)
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * 2), y: 0)
        )
    }
}
