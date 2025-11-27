import SwiftUI
import RealmSwift
import PhotosUI

@available(iOS 16.0, *)
struct AddToolView: View {
    @Environment(\.dismiss) var dismiss
    
    // We pass in the realm instance to write to
    @Environment(\.realm) var realm
    
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tool Details") {
                    TextField("Tool Name (e.g., Hammer)", text: $name)
                    TextField("Location (e.g., Garage, top drawer)", text: $location)
                }
                
                Section("Photo") {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Select a Photo", systemImage: "photo")
                    }
                }
            }
            .navigationTitle("Add New Tool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveTool)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    private func saveTool() {
        let newTool = UserTool()
        newTool.name = name.trimmingCharacters(in: .whitespaces)
        newTool.location = location.trimmingCharacters(in: .whitespaces).isEmpty ? nil : location
        newTool.photo = selectedImageData
        
        try? realm.write {
            realm.add(newTool)
        }
        
        dismiss()
    }
}
