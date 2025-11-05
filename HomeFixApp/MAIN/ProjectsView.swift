import SwiftUI
import RealmSwift

struct ProjectsView: View {
    @StateObject private var viewModel = ProjectsViewModel()
    @State private var viewUpdater = UUID()
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter by status", selection: $viewModel.selectedStatusFilter) {
                    Text("All").tag(ProjectStatus?(nil))
                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                        Text(status.title).tag(ProjectStatus?(status))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if viewModel.filteredProjects.isEmpty {
                    emptyStateView
                } else {
                    List(viewModel.filteredProjects) { project in
                        NavigationLink(value: project.id) {
                            ProjectRowView(project: project)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteProject(project)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .id(viewUpdater)
            .navigationTitle("Projects")
            .navigationDestination(for: ObjectId.self) { projectId in
                ProjectDetailView(projectId: projectId)
            }
            .onAppear {
                viewUpdater = UUID()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText.opacity(0.5))
            Text("No Projects Yet")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 8)
            Text("Saved projects from the Home tab will appear here.")
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Spacer()
        }
    }
    
    private func deleteProject(_ project: RepairProject) {
        // We need to find a live version of the object to delete
        guard let realm = project.realm else { return }
        guard let projectToDelete = realm.resolve(ThreadSafeReference(to: project)) else { return }
        
        try? realm.write {
            realm.delete(projectToDelete)
        }
    }
}

#Preview {
    ProjectsView()
}
