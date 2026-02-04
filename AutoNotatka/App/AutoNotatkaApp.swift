import SwiftUI

@main
struct AutoNotatkaApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(isComplete: $hasCompletedOnboarding)
            }
        }
    }
}
