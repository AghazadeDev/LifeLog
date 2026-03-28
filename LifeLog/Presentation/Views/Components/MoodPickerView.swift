import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: String?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Mood.allCases) { mood in
                Button {
                    if selectedMood == mood.emoji {
                        selectedMood = nil
                    } else {
                        selectedMood = mood.emoji
                    }
                } label: {
                    Text(mood.emoji)
                        .font(.title2)
                        .padding(8)
                        .background(
                            selectedMood == mood.emoji
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear
                        )
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(selectedMood == mood.emoji ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
