import Foundation
import RealmSwift

// MARK: - ChecklistItem
class ChecklistItem: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var id = UUID()
    @Persisted var name: String = ""
    @Persisted var isCompleted: Bool = false
}

// MARK: - InstructionStep
class InstructionStep: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var id = UUID()
    @Persisted var title: String = ""
    @Persisted var descriptionText: String = ""
    @Persisted var isCompleted: Bool = false
}

class RepairProject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = "New Project"
    @Persisted var creationDate: Date = Date()
    @Persisted var originalPhoto: Data?
    
    @Persisted var status: ProjectStatus = .toDo
    @Persisted var difficulty: DifficultyLevel = .easy
    @Persisted var category: ProjectCategory = .other
    
    @Persisted var safetyWarning: String?
    @Persisted var recommendation: String?
    
    @Persisted var materials = List<ChecklistItem>()
    @Persisted var tools = List<ChecklistItem>()
    @Persisted var steps = List<InstructionStep>()
}


class UserTool: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var location: String?
    @Persisted var photo: Data?
}
