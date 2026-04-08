import Foundation

struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var category: String
    var isBookmarked: Bool
    var createdAt: Date
    var eventDate: Date?
    var reminderIDs: [String]

    enum CodingKeys: String, CodingKey {
        case id, title, content, text, category, isBookmarked, createdAt, eventDate, reminderIDs
    }

    init(id: UUID = UUID(), title: String, content: String, category: String = "Daily", isBookmarked: Bool = false, createdAt: Date = Date(), eventDate: Date? = nil, reminderIDs: [String] = []) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.isBookmarked = isBookmarked
        self.createdAt = createdAt
        self.eventDate = eventDate
        self.reminderIDs = reminderIDs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        content = try container.decodeIfPresent(String.self, forKey: .content) ?? 
                  (try container.decodeIfPresent(String.self, forKey: .text) ?? "")
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "Daily"
        isBookmarked = try container.decodeIfPresent(Bool.self, forKey: .isBookmarked) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        eventDate = try container.decodeIfPresent(Date.self, forKey: .eventDate)
        reminderIDs = try container.decodeIfPresent([String].self, forKey: .reminderIDs) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(category, forKey: .category)
        try container.encode(isBookmarked, forKey: .isBookmarked)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(eventDate, forKey: .eventDate)
        try container.encode(reminderIDs, forKey: .reminderIDs)
    }
}
