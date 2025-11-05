import Foundation
import RealmSwift
import SwiftUI

// MARK: - ProjectStatus
enum ProjectStatus: String, PersistableEnum, CaseIterable {
    case toDo = "To Do"
    case inProgress = "In Progress"
    case done = "Done"
    
    var title: String {
        return self.rawValue
    }
}

// MARK: - DifficultyLevel
enum DifficultyLevel: String, PersistableEnum, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case professional = "Professional Required"
    
    var title: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .easy:
            return .green
        case .medium:
            return .yellow
        case .hard:
            return .orange
        case .professional:
            return .destructive
        }
    }
}

// MARK: - ProjectCategory
enum ProjectCategory: String, PersistableEnum, CaseIterable {
    case electrical = "Electrical"
    case plumbing = "Plumbing"
    case walls = "Walls & Paint"
    case furniture = "Furniture"
    case other = "Other"
    
    var title: String {
        return self.rawValue
    }
}
