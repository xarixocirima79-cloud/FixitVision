import SwiftUI

struct MainTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        TabView {
            if #available(iOS 16.0, *) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
            } else {
                // Fallback on earlier versions
            }
            
            if #available(iOS 16.0, *) {
                ProjectsView()
                    .tabItem {
                        Label("Projects", systemImage: "list.bullet.clipboard.fill")
                    }
            } else {
                // Fallback on earlier versions
            }
            
            if #available(iOS 16.0, *) {
                MyStuffView()
                    .tabItem {
                        Label("My Stuff", systemImage: "wrench.and.screwdriver.fill")
                    }
            } else {
                // Fallback on earlier versions
            }
            
            if #available(iOS 16.0, *) {
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            } else {
                // Fallback on earlier versions
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
