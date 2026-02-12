import SwiftUI

struct OnboardingView: View {
    @StateObject private var permissionManager = PermissionManager.shared
    @Binding var isComplete: Bool
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "mic.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.red)
            }

            // Title
            VStack(spacing: 8) {
                Text("AutoNotatka")
                    .font(.largeTitle.bold())

                Text("Nagrywaj notatki głosowe")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Permissions
            VStack(spacing: 16) {
                PermissionRow(
                    icon: "mic.fill",
                    title: "Mikrofon",
                    description: "Wymagany do nagrywania głosu",
                    isGranted: permissionManager.isMicrophoneGranted
                )
            }
            .padding(.horizontal)

            Spacer()

            // Button
            Button {
                Task {
                    isRequesting = true
                    await permissionManager.requestAllPermissions()
                    isRequesting = false

                    if permissionManager.allPermissionsGranted {
                        withAnimation {
                            isComplete = true
                        }
                    }
                }
            } label: {
                HStack {
                    if isRequesting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(permissionManager.allPermissionsGranted ? "Rozpocznij" : "Przyznaj uprawnienia")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundStyle(.white)
                .font(.headline)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(isRequesting)
            .padding(.horizontal, 24)

            // Skip if permissions denied
            if !permissionManager.needsPermissions && !permissionManager.allPermissionsGranted {
                Button("Otwórz Ustawienia") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            // Author credit
            Text("Stworzone przez Wojciecha Olszaka")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 20)
        }
        .onAppear {
            permissionManager.refreshStatus()
            if permissionManager.allPermissionsGranted {
                isComplete = true
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isGranted ? .green : .red)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: isGranted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isGranted ? .green : .secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    OnboardingView(isComplete: .constant(false))
}
