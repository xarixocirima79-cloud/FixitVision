import SwiftUI
import RealmSwift

@available(iOS 16.0, *)
struct AnalysisResultView: View {
    @Environment(\.dismiss) var dismiss
    let project: RepairProject

    var body: some View {
        NavigationStack {
            List {
                Section("Problem Overview") {
                    if let photoData = project.originalPhoto, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.vertical, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(project.title).font(.title2).fontWeight(.bold)
                        
                        HStack {
                            Text("Difficulty:")
                            Spacer()
                            Text(project.difficulty.title)
                                .fontWeight(.semibold)
                                .foregroundColor(project.difficulty.color)
                        }
                        
                        HStack {
                            Text("Category:")
                            Spacer()
                            Text(project.category.title)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                if let warning = project.safetyWarning, !warning.isEmpty {
                    Section("⚠️ Safety Warning") {
                        Text(warning)
                            .foregroundColor(.destructive)
                    }
                }
                
                if let recommendation = project.recommendation, !recommendation.isEmpty {
                    Section("💡 Recommendation") {
                        Text(recommendation)
                            .foregroundColor(.accent)
                    }
                }

                Section("Required Materials") {
                    ForEach(project.materials) { item in
                        Text(item.name)
                    }
                }
                
                Section("Required Tools") {
                    ForEach(project.tools) { item in
                        Text(item.name)
                    }
                }
                
                Section("Step-by-Step Instructions") {
                    ForEach(project.steps) { step in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.title).fontWeight(.bold)
                            Text(step.descriptionText).foregroundColor(.secondaryText)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Analysis Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Project") {
                        saveProject()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveProject() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(project)
            }
        } catch {
            print("Error saving project to Realm: \(error)")
        }
    }
}
