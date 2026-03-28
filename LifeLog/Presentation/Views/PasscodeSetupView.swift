import SwiftUI

struct PasscodeSetupView: View {
    @Environment(\.dismiss) var dismiss
    var lang = LanguageManager.shared

    var isChange: Bool = false
    var onComplete: (Bool) -> Void

    @State private var step: SetupStep = .enter
    @State private var firstEntry = ""
    @State private var confirmEntry = ""
    @State private var showError = false

    private let codeLength = 4

    enum SetupStep {
        case enter
        case confirm
    }

    private var currentPasscode: Binding<String> {
        switch step {
        case .enter: return $firstEntry
        case .confirm: return $confirmEntry
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)

                Text(stepTitle)
                    .font(.headline)

                HStack(spacing: 16) {
                    ForEach(0..<codeLength, id: \.self) { index in
                        Circle()
                            .fill(index < currentPasscode.wrappedValue.count ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 16, height: 16)
                    }
                }
                .modifier(ShakeEffect(shakes: showError ? 2 : 0))
                .animation(.default, value: showError)

                if showError {
                    Text(lang.localizedString("passcode.mismatch"))
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
                        deleteDigit()
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localizedString("addEntry.cancel")) {
                        onComplete(false)
                        dismiss()
                    }
                }
            }
        }
    }

    private var stepTitle: String {
        switch step {
        case .enter: return lang.localizedString("passcode.set")
        case .confirm: return lang.localizedString("passcode.confirm")
        }
    }

    private func appendDigit(_ digit: String) {
        showError = false
        switch step {
        case .enter:
            guard firstEntry.count < codeLength else { return }
            firstEntry += digit
            if firstEntry.count == codeLength {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    step = .confirm
                }
            }
        case .confirm:
            guard confirmEntry.count < codeLength else { return }
            confirmEntry += digit
            if confirmEntry.count == codeLength {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if confirmEntry == firstEntry {
                        PasscodeService.setPasscode(confirmEntry)
                        onComplete(true)
                        dismiss()
                    } else {
                        showError = true
                        confirmEntry = ""
                    }
                }
            }
        }
    }

    private func deleteDigit() {
        showError = false
        switch step {
        case .enter:
            if !firstEntry.isEmpty { firstEntry.removeLast() }
        case .confirm:
            if !confirmEntry.isEmpty { confirmEntry.removeLast() }
        }
    }
}
