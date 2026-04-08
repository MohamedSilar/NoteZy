import Foundation
import SwiftUI

enum TodoPriority: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .gray
        }
    }
}

struct Todo: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: TodoPriority = .medium
    var category: String = "General"
    var dueDate: Date?
    var createdAt = Date()
}
