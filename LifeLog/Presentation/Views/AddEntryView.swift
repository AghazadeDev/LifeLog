import SwiftUI
import PhotosUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddEntryViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @FocusState private var isTextFocused: Bool
    private var lang = LanguageManager.shared

    init(viewModel: AddEntryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Mood Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lang.localizedString("addEntry.mood"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        MoodPickerView(selectedMood: $viewModel.selectedMood)
                    }

                    // Text Editor
                    TextEditor(text: $viewModel.entryText)
                        .focused($isTextFocused)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(minHeight: 150)

                    // Photo
                    photoSection

                    // Tags
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lang.localizedString("addEntry.tags"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TagInputView(selectedTags: $viewModel.selectedTags)
                    }

                    // Pin toggle
                    Toggle(lang.localizedString("addEntry.pin"), isOn: $viewModel.isPinned)

                    if let error = viewModel.speechRecognizer.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    if viewModel.speechRecognizer.isRecording {
                        liveTranscript
                    }
                }
                .padding()
            }
            .onTapGesture {
                isTextFocused = false
            }
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
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Button {
                            viewModel.toggleRecording()
                        } label: {
                            Image(systemName: viewModel.speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title2)
                                .foregroundStyle(viewModel.speechRecognizer.isRecording ? .red : .blue)
                        }
                        Spacer()
                        Button {
                            isTextFocused = false
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .font(.title3)
                        }
                    }
                }
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lang.localizedString("addEntry.photo"))
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(lang.localizedString("addEntry.addPhoto"), systemImage: "photo.badge.plus")
                        .font(.subheadline)
                }
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            viewModel.selectedPhotoData = data
                        }
                    }
                }

                if viewModel.selectedPhotoData != nil {
                    Button {
                        viewModel.selectedPhotoData = nil
                        selectedPhoto = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }

            if let photoData = viewModel.selectedPhotoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
}
