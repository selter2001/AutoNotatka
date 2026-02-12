import SwiftUI
import GoogleSignIn

@main
struct AutoNotatkaApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var authManager = GoogleAuthManager.shared

    init() {
        UserDefaults.standard.register(defaults: ["deleteLocalAfterUpload": true])
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    if authManager.isSignedIn {
                        ContentView()
                    } else {
                        GoogleSignInView()
                    }
                } else {
                    OnboardingView(isComplete: $hasCompletedOnboarding)
                }
            }
            .environmentObject(authManager)
            .onAppear {
                authManager.restorePreviousSignIn()
                // Process any pending uploads from previous session
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UploadQueueManager.shared.processPendingUploads()
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
