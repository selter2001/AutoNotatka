import SwiftUI

struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            transcriptionArea
            Spacer()
            recordingControls
            Spacer()
        }
        .padding()
        .task {
            await viewModel.requestPermissions()
        }
        .alert("Uwaga", isPresented: $viewModel.showPermissionAlert) {
            Button("Ustawienia") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.permissionAlertMessage)
        }
        .overlay(alignment: .top) {
            if viewModel.showSaveConfirmation {
                saveConfirmationBanner
            }
        }
    }

    private var transcriptionArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transkrypcja")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                if viewModel.isRecording {
                    Text(viewModel.formattedDuration)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.red)
                }
            }

            ScrollView {
                Text(viewModel.transcribedText.isEmpty ? "Naciśnij przycisk, aby rozpocząć nagrywanie..." : viewModel.transcribedText)
                    .font(.body)
                    .foregroundStyle(viewModel.transcribedText.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 300)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var recordingControls: some View {
        VStack(spacing: 20) {
            RecordButton(
                isRecording: viewModel.isRecording,
                action: viewModel.toggleRecording
            )

            Text(viewModel.isRecording ? "Nagrywanie..." : "Dotknij, aby nagrać")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var saveConfirmationBanner: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Notatka zapisana")
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: viewModel.showSaveConfirmation)
        .padding(.top, 8)
    }
}

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    @State private var isPulsing = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Pulsing circles (only when recording)
                if isRecording {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isPulsing ? 1.3 : 1.0)
                        .opacity(isPulsing ? 0 : 0.6)

                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isPulsing ? 1.5 : 1.0)
                        .opacity(isPulsing ? 0 : 0.4)
                }

                // Main button
                Circle()
                    .fill(isRecording ? Color.red : Color.red.opacity(0.9))
                    .frame(width: 100, height: 100)
                    .shadow(color: .red.opacity(0.4), radius: isRecording ? 15 : 8, x: 0, y: 4)

                // Icon
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }
}

#Preview {
    RecordingView()
}
