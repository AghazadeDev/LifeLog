import Foundation
import SwiftData

@Model
final class NoteEntry {
    var text: String
    var createdAt: Date
    var audioURL: URL?
    var dayEntry: DayEntry?
    var mood: String?
    @Attribute(.externalStorage) var photoData: Data?
    var tags: [String]
    var aiTags: [String]
    var isPinned: Bool

    init(text: String, createdAt: Date = .now, audioURL: URL? = nil,
         mood: String? = nil, photoData: Data? = nil,
         tags: [String] = [], isPinned: Bool = false) {
        self.text = text
        self.createdAt = createdAt
        self.audioURL = audioURL
        self.mood = mood
        self.photoData = photoData
        self.tags = tags
        self.aiTags = []
        self.isPinned = isPinned
    }
}
