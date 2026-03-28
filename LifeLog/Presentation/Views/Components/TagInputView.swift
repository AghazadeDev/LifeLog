import SwiftUI

public struct TagInputView: View {
    @Binding var selectedTags: [String]
    @State var newTagText = ""
    @State var showSuggestions = false
    var lang = LanguageManager.shared

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(selectedTags, id: \.self) { tag in
                        tagChip(tag) {
                            selectedTags.removeAll { $0 == tag }
                        }
                    }
                    Button {
                        showSuggestions.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if showSuggestions {
                suggestionGrid
            }
        }
    }

    private var suggestionGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 6) {
            ForEach(JournalTag.allCases) { tag in
                let tagName = tag.rawValue
                let isSelected = selectedTags.contains(tagName)
                Button {
                    if isSelected {
                        selectedTags.removeAll { $0 == tagName }
                    } else {
                        selectedTags.append(tagName)
                    }
                } label: {
                    Label(lang.localizedString(tag.localizedKey), systemImage: tag.icon)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray5))
                        .clipShape(Capsule())
                        .foregroundStyle(isSelected ? .primary : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func tagChip(_ tag: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            if let predefined = JournalTag(rawValue: tag) {
                Image(systemName: predefined.icon)
                    .font(.caption2)
            }
            Text(lang.localizedString("tag.\(tag)"))
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.15))
        .clipShape(Capsule())
    }
}
