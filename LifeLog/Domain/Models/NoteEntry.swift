import Foundation
import SwiftData

@Model
final class NoteEntry {
    var text: String
    var createdAt: Date
    var audioURL: URL?
    var dayEntry: DayEntry?

    init(text: String, createdAt: Date = .now, audioURL: URL? = nil) {
        self.text = text
        self.createdAt = createdAt
        self.audioURL = audioURL
    }
}
