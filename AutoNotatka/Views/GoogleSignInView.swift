import SwiftUI

struct GoogleSignInView: View {
    @EnvironmentObject var authManager: GoogleAuthManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App Icon/Title
            VStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("AutoNotatka")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            Spacer()

            // Description
            VStack(spacing: 12) {
                Text("Zaloguj się, aby zapisywać nagrania na Dysku Google")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }

            // Sign In Button
            Button {
                signInWithGoogle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                    Text("Zaloguj się przez Google")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 40)

            // Error Message
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
    }

    private func signInWithGoogle() {
        guard let rootViewController = authManager.getRootViewController() else {
            authManager.errorMessage = "Nie można znaleźć okna aplikacji"
            return
        }

        authManager.signIn(presenting: rootViewController)
    }
}

#Preview {
    GoogleSignInView()
        .environmentObject(GoogleAuthManager.shared)
}
