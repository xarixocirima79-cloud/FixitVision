import SwiftUI

struct MainTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "list.bullet.clipboard.fill")
                }
            
            MyStuffView()
                .tabItem {
                    Label("My Stuff", systemImage: "wrench.and.screwdriver.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.accent)
        .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        }
    }
}

#Preview {
    MainTabView()
}
