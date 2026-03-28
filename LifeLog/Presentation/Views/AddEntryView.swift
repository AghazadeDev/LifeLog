import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddEntryViewModel
    private var lang = LanguageManager.shared

    init(viewModel: AddEntryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextEditor(text: $viewModel.entryText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(minHeight: 150)

                if viewModel.speechRecognizer.isRecording {
                    liveTranscript
                }

                if let error = viewModel.speechRecognizer.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                micButton

                Spacer()
            }
            .padding()
            .navigationTitle(lang.localizedString("addEntry.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localizedString("addEntry.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.localizedString("addEntry.save")) {
                        viewModel.saveEntry()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }

    private var liveTranscript: some View {
        HStack {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
            Text(viewModel.speechRecognizer.transcript.isEmpty
                 ? lang.localizedString("addEntry.listening")
                 : viewModel.speechRecognizer.transcript)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(.horizontal)
    }

    private var micButton: some View {
        Button {
            viewModel.toggleRecording()
        } label: {
            Image(systemName: viewModel.speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                .font(.system(size: 56))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(viewModel.speechRecognizer.isRecording ? .red : .blue)
        }
    }
}
