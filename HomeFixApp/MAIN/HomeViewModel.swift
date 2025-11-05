import Foundation
import SwiftUI
import PhotosUI
import RealmSwift

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var analysisResult: RepairProject?
    @Published var errorMessage: String?
    
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            if let selectedPhotoItem {
                processPhotoItem(item: selectedPhotoItem)
            }
        }
    }
    
    // MARK: - Dashboard Properties
    @Published var dailyTip: DailyTip?
    @Published var recentProjects: [RepairProject] = []
    
    // Statistics Properties
    @Published var completedCount: Int = 0
    @Published var inProgressCount: Int = 0
    @Published var toDoCount: Int = 0
    
    private var projectsToken: NotificationToken?
    private let geminiService = GeminiService()

    init() {
        loadDailyTip()
        setupProjectsObserver()
    }
    
    private func setupProjectsObserver() {
        let realm = try! Realm()
        let projects = realm.objects(RepairProject.self).sorted(byKeyPath: "creationDate", ascending: false)
        
        projectsToken = projects.observe { [weak self] _ in
            // This single observer now updates BOTH recent projects and statistics
            self?.updateRecentProjects(from: projects)
            self?.updateStatistics(from: projects)
        }
    }
    
    private func loadDailyTip() {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let tipIndex = dayOfYear % DailyTip.allTips.count
        dailyTip = DailyTip.allTips[tipIndex]
    }
    
    private func updateRecentProjects(from projects: Results<RepairProject>) {
        self.recentProjects = Array(projects.prefix(3))
    }
    
    private func updateStatistics(from projects: Results<RepairProject>) {
        completedCount = projects.where { $0.status == .done }.count
        inProgressCount = projects.where { $0.status == .inProgress }.count
        toDoCount = projects.where { $0.status == .toDo }.count
    }
    
    func processImage(_ image: UIImage) {
        Task {
            isProcessing = true
            analysisResult = nil
            errorMessage = nil
            
            do {
                let dto = try await geminiService.analyse(image: image)
                
                let newProject = RepairProject()
                // ... (rest of the processImage function is unchanged)
                newProject.title = dto.title
                newProject.category = ProjectCategory(rawValue: dto.category) ?? .other
                newProject.difficulty = DifficultyLevel(rawValue:dto.difficulty) ?? .easy
                newProject.safetyWarning = dto.safetyWarning
                newProject.recommendation = dto.recommendation
                newProject.originalPhoto = image.jpegData(compressionQuality: 0.7)
                
                dto.materials.forEach {
                    let item = ChecklistItem()
                    item.name = $0.name
                    newProject.materials.append(item)
                }
                
                dto.tools.forEach {
                    let item = ChecklistItem()
                    item.name = $0.name
                    newProject.tools.append(item)
                }
                
                dto.steps.forEach {
                    let item = InstructionStep()
                    item.title = $0.title
                    item.descriptionText = $0.descriptionText
                    newProject.steps.append(item)
                }
                
                analysisResult = newProject
                
            } catch {
                print("--- Gemini Service Error ---")
                print(error.localizedDescription)
                errorMessage = "An error occurred. Please check your connection and try again."
            }
            
            isProcessing = false
        }
    }
    
    private func processPhotoItem(item: PhotosPickerItem) {
        // ... (this function is unchanged)
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    errorMessage = "Failed to load image data."
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    errorMessage = "Failed to convert data to image."
                    return
                }
                
                processImage(image)
                
            } catch {
                errorMessage = "An error occurred while selecting the photo."
            }
        }
    }
    
    deinit {
        projectsToken?.invalidate()
    }
}
