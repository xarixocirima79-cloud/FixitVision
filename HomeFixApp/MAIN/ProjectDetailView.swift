import SwiftUI
import RealmSwift

struct ProjectDetailView: View {
    @ObservedRealmObject var project: RepairProject
    
    // The user's brilliant idea: A state variable to force UI updates.
    @State private var viewUpdater = UUID()
    
    private let projectId: ObjectId

    init(projectId: ObjectId) {
        self.projectId = projectId
        let realm = try! Realm()
        guard let projectToObserve = realm.object(ofType: RepairProject.self, forPrimaryKey: projectId) else {
            fatalError("Project with ID \(projectId) not found.")
        }
        _project = ObservedRealmObject(wrappedValue: projectToObserve)
    }

    var body: some View {
        List {
            
            
            Section("Overview") {
                if let photoData = project.originalPhoto, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding(.vertical, 8)
                }
                
                Picker("Status", selection: createStatusBinding()) {
                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                        Text(status.title).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .id(viewUpdater)
            }
            
            if let warning = project.safetyWarning, !warning.isEmpty {
                Section("⚠️ Safety Warning") {
                    Text(warning).foregroundColor(.destructive)
                }
            }
            
            createChecklistSection(title: "Required Materials", items: project.materials)
            createChecklistSection(title: "Required Tools", items: project.tools)
            
            Section("Step-by-Step Instructions") {
                ForEach(project.steps) { step in
                    Button(action: { toggleStepCompletion(for: step.id) }) {
                        HStack {
                            Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(step.isCompleted ? .accent : .secondaryText)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.title)
                                    .fontWeight(.bold)
                                    .strikethrough(step.isCompleted, color: .secondaryText)
                                Text(step.descriptionText)
                                    .font(.caption)
                                    .strikethrough(step.isCompleted, color: .secondaryText)
                            }
                        }
                        .foregroundColor(.primaryText)
                    }
                }
            }
        }
        
        .navigationTitle(project.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func createChecklistSection(title: String, items: RealmSwift.List<ChecklistItem>) -> some View {
        Section(title) {
            if items.isEmpty {
                Text("No items listed.").foregroundColor(.secondaryText)
            } else {
                ForEach(items) { item in
                    Button(action: { toggleItemCompletion(for: item.id) }) {
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .accent : .secondaryText)
                            Text(item.name)
                                .strikethrough(item.isCompleted, color: .secondaryText)
                        }
                        .foregroundColor(.primaryText)
                    }
                }
            }
        }
    }
    
    // MARK: - Write Actions
    
    private func createStatusBinding() -> Binding<ProjectStatus> {
        Binding<ProjectStatus>(
            get: { self.project.status },
            set: { newStatus in
                let realm = try! Realm()
                guard let liveProject = realm.object(ofType: RepairProject.self, forPrimaryKey: self.projectId) else { return }
                try! realm.write {
                    liveProject.status = newStatus
                }
                // Force UI to re-read the latest data
                self.viewUpdater = UUID()
            }
        )
    }
    
    private func toggleItemCompletion(for id: UUID) {
        let realm = try! Realm()
        guard let liveProject = realm.object(ofType: RepairProject.self, forPrimaryKey: self.projectId) else { return }
        
        if let item = liveProject.materials.first(where: { $0.id == id }) {
            try! realm.write {
                item.isCompleted.toggle()
            }
        } else if let item = liveProject.tools.first(where: { $0.id == id }) {
            try! realm.write {
                item.isCompleted.toggle()
            }
        }
        // Force UI to re-read the latest data
        viewUpdater = UUID()
    }
    
    private func toggleStepCompletion(for id: UUID) {
        let realm = try! Realm()
        guard let liveProject = realm.object(ofType: RepairProject.self, forPrimaryKey: self.projectId) else { return }
        
        if let step = liveProject.steps.first(where: { $0.id == id }) {
            try! realm.write {
                step.isCompleted.toggle()
            }
        }
        // Force UI to re-read the latest data
        viewUpdater = UUID()
    }
}
