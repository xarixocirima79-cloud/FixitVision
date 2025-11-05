import Foundation
import RealmSwift

@MainActor
class ProjectsViewModel: ObservableObject {
    @Published var selectedStatusFilter: ProjectStatus? = nil
    
    private var allProjects: Results<RepairProject>
    
    var filteredProjects: [RepairProject] {
        if let filter = selectedStatusFilter {
            return allProjects.where { $0.status == filter }.map { $0 }
        } else {
            return allProjects.map { $0 }
        }
    }
    
    init() {
        let realm = try! Realm()
        self.allProjects = realm.objects(RepairProject.self).sorted(byKeyPath: "creationDate", ascending: false)
    }
}
