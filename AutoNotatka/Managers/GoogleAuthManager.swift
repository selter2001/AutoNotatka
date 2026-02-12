import Foundation
import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Drive

@MainActor
class GoogleAuthManager: ObservableObject {
    static let shared = GoogleAuthManager()

    @Published var isSignedIn: Bool = false
    @Published var user: GIDGoogleUser? = nil
    @Published var errorMessage: String? = nil

    private init() {}

    // MARK: - Session Restoration

    private let requiredScope = "https://www.googleapis.com/auth/drive"

    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let error = error {
                    print("Failed to restore previous sign-in: \(error.localizedDescription)")
                    self.isSignedIn = false
                    self.user = nil
                    return
                }

                guard let user = user else {
                    self.isSignedIn = false
                    return
                }

                // Check if the restored session has the required Drive scope
                let grantedScopes = user.grantedScopes ?? []
                print("[Auth] Restored session scopes: \(grantedScopes)")

                if grantedScopes.contains(self.requiredScope) {
                    self.user = user
                    self.isSignedIn = true
                    self.errorMessage = nil
                    GoogleDriveManager.shared.configure(with: user)
                    print("Restored previous sign-in for user: \(user.profile?.email ?? "unknown")")
                } else {
                    // Token has old/insufficient scope - force re-login
                    print("[Auth] Restored session missing 'drive' scope, signing out to force re-auth")
                    GIDSignIn.sharedInstance.signOut()
                    self.isSignedIn = false
                    self.user = nil
                }
            }
        }
    }

    // MARK: - Sign In

    func signIn(presenting viewController: UIViewController) {
        let config = GIDConfiguration(clientID: GIDSignIn.sharedInstance.configuration?.clientID ?? "")
        GIDSignIn.sharedInstance.configuration = config

        // Request full Drive scope for folder listing and file upload
        let additionalScopes = [requiredScope]

        GIDSignIn.sharedInstance.signIn(
            withPresenting: viewController,
            hint: nil,
            additionalScopes: additionalScopes
        ) { [weak self] result, error in
            Task { @MainActor in
                if let error = error {
                    self?.errorMessage = "Błąd logowania: \(error.localizedDescription)"
                    self?.isSignedIn = false
                    print("Sign-in error: \(error.localizedDescription)")
                    return
                }

                guard let user = result?.user else {
                    self?.errorMessage = "Nie udało się pobrać danych użytkownika"
                    self?.isSignedIn = false
                    return
                }

                self?.user = user
                self?.isSignedIn = true
                self?.errorMessage = nil
                GoogleDriveManager.shared.configure(with: user)
                print("Sign-in successful for user: \(user.profile?.email ?? "unknown")")
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
        user = nil
        errorMessage = nil
        print("User signed out")
    }

    // MARK: - Helper Methods

    func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }

        // Navigate to the presented view controller if exists
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }

        return topController
    }
}
