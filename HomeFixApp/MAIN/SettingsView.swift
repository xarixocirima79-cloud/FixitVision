import SwiftUI
import StoreKit
import RealmSwift

@available(iOS 16.0, *)
struct SettingsView: View {
    @State private var isShowingDeleteAlert = false

    // MARK: - Support & Legal Links
    private let developerEmail = "privacy@fixitvision.app" // <-- ЗАМЕНИ НА СВОЙ EMAIL
    private let privacyPolicyURL = "https://sites.google.com/view/fixit-vision/privacy-policy" // <-- ЗАМЕНИ НА СВОЮ ССЫЛКУ
    private let termsOfServiceURL = "https://sites.google.com/view/fixit-vision/home" // <-- ЗАМЕНИ НА СВОЮ ССЫЛКУ

    var body: some View {
        NavigationStack {
            List {
                Section("Actions") {
                    Button(action: requestAppReview) {
                        Label("Rate App", systemImage: "star.fill")
                            .foregroundColor(.accent)
                    }
                    
                    Button(action: shareApp) {
                        Label("Share App", systemImage: "square.and.arrow.up")
                            .foregroundColor(.accent)
                    }
                    
                    Button(role: .destructive, action: {
                        isShowingDeleteAlert = true
                    }) {
                        Label("Delete All Data", systemImage: "trash.fill")
                    }
                }
                
                Section("Support & Legal") {
                    Link(destination: URL(string: "mailto:\(developerEmail)")!) {
                        Label("Contact Developer", systemImage: "envelope.fill")
                    }
                    
                    Link(destination: URL(string: privacyPolicyURL)!) {
                        Label("Privacy Policy", systemImage: "lock.shield.fill")
                    }
                    
                    Link(destination: URL(string: termsOfServiceURL)!) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                }
                .foregroundColor(.accent)
                
                Section("About") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondaryText)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
                Button("Delete All", role: .destructive, action: deleteAllData)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your saved projects and tools. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func deleteAllData() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Error deleting all data from Realm: \(error)")
        }
    }
    
    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func shareApp() {
        guard let url = URL(string: "https://apps.apple.com/app/idY6754935917") else { return }
        let shareText = "Check out Fixit Vision, a great app for home repairs powered by AI!"
        
        let activityController = UIActivityViewController(activityItems: [shareText, url], applicationActivities: nil)
        
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
           windowScene.windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
        }
    }
}
