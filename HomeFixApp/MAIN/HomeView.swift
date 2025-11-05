import SwiftUI
import PhotosUI
import RealmSwift

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var showImageSourceDialog = false
    @State private var showPhotoLibrary = false
    @State private var showCamera = false
    @State private var inputImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView
                    
                    analyzeButton
                    
                    statisticsSection
                    
                    if let tip = viewModel.dailyTip {
                        dailyTipView(tip: tip)
                    }
                    
                    if !viewModel.recentProjects.isEmpty {
                        recentProjectsSection
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            // ... (rest of the view modifiers are unchanged)
            .overlay(processingOverlay)
            .fullScreenCover(item: $viewModel.analysisResult) { project in
                AnalysisResultView(project: project)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            })
            .confirmationDialog("Choose a source", isPresented: $showImageSourceDialog) {
                Button("Camera") { showCamera = true }
                Button("Photo Library") { showPhotoLibrary = true }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(selectedImage: $inputImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .photosPicker(isPresented: $showPhotoLibrary, selection: $viewModel.selectedPhotoItem, matching: .images)
            .onChange(of: inputImage) { newImage in
                guard let newImage else { return }
                viewModel.processImage(newImage)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        // ... (unchanged)
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome Back!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text("Ready to tackle your next home project?")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
    }
    
    private var analyzeButton: some View {
        // ... (unchanged)
        Button(action: { showImageSourceDialog = true }) {
            HStack {
                Image(systemName: "camera.viewfinder")
                    .font(.title2)
                Text("Analyze a Problem")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accent)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading) {
            Label("Your Progress", systemImage: "chart.bar.xaxis")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            HStack(spacing: 12) {
                StatisticCard(title: "To Do", value: viewModel.toDoCount, color: .blue)
                StatisticCard(title: "In Progress", value: viewModel.inProgressCount, color: .orange)
                StatisticCard(title: "Completed", value: viewModel.completedCount, color: .green)
            }
        }
    }
    
    private func dailyTipView(tip: DailyTip) -> some View {
        // ... (unchanged)
        VStack(alignment: .leading) {
            Label("Tip of the Day", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(tip.title)
                    .fontWeight(.bold)
                Text(tip.description)
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.elementBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
    }
    
    private var recentProjectsSection: some View {
        // ... (unchanged)
        VStack(alignment: .leading) {
            Text("Recent Projects")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recentProjects) { project in
                        NavigationLink(value: project.id) {
                            ProjectCardView(project: project)
                        }
                    }
                }
            }
            .navigationDestination(for: ObjectId.self) { projectId in
                ProjectDetailView(projectId: projectId)
            }
        }
    }
    
    @ViewBuilder
    private var processingOverlay: some View {
        // ... (unchanged)
        if viewModel.isProcessing {
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack {
                    ProgressView()
                        .scaleEffect(2)
                        .padding()
                    Text("AI is analyzing...")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
        }
    }
}

// MARK: - Helper Views for HomeView

private struct StatisticCard: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.elementBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}


struct ProjectCardView: View {
    // ... (unchanged)
    let project: RepairProject
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if let photoData = project.originalPhoto, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 100)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.1))
                        .frame(width: 150, height: 100)
                        .overlay(Image(systemName: "photo").foregroundColor(.secondary))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                    .lineLimit(2)
                
                Text(project.status.title)
                    .font(.caption2)
                    .foregroundColor(.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accent.opacity(0.15))
                    .cornerRadius(6)
            }
            .padding(8)
        }
        .frame(width: 150)
        .background(Color.elementBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview {
    HomeView()
}
