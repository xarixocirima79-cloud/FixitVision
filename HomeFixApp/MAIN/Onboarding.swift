import SwiftUI

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: imageName)
                .font(.system(size: 100, weight: .light))
                .foregroundColor(.accent)
                .padding(.bottom, 30)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}


struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var selection = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                OnboardingPageView(
                    imageName: "questionmark.diamond.fill",
                    title: "Feeling Lost?",
                    description: "A leaky faucet, a crack in the wall, a strange noise... Home problems can be overwhelming."
                )
                .tag(0)
                
                OnboardingPageView(
                    imageName: "camera.on.rectangle.fill",
                    title: "Snap a Photo",
                    description: "Just take a picture of the problem. Our app will instantly analyze it to understand what's wrong."
                )
                .tag(1)
                
                OnboardingPageView(
                    imageName: "list.bullet.clipboard.fill",
                    title: "Get a Clear Plan",
                    description: "Receive step-by-step instructions, a list of tools, and materials needed to fix it yourself."
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            Button(action: handleButtonTap) {
                Text(selection == 2 ? "Get Started" : "Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(Color.appBackground)
    }
    
    private func handleButtonTap() {
        if selection < 2 {
            withAnimation {
                selection += 1
            }
        } else {
            onComplete()
        }
    }
}
