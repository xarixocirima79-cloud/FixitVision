import Foundation
import RealmSwift
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var completedCount: Int = 0
    @Published var inProgressCount: Int = 0
    @Published var toDoCount: Int = 0
    
    private var projectsToken: NotificationToken?
    private let projects: Results<RepairProject>

    init() {
        let realm = try! Realm()
        projects = realm.objects(RepairProject.self)
        setupObserver()
        updateCounts()
    }

    private func setupObserver() {
        projectsToken = projects.observe { [weak self] _ in
            self?.updateCounts()
        }
    }

    private func updateCounts() {
        completedCount = projects.where { $0.status == .done }.count
        inProgressCount = projects.where { $0.status == .inProgress }.count
        toDoCount = projects.where { $0.status == .toDo }.count
    }
    
    deinit {
        projectsToken?.invalidate()
    }
}
