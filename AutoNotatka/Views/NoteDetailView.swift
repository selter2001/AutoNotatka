import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss
    @State private var showCopyConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                metadata
                Divider()
                content
            }
            .padding()
        }
        .navigationTitle("Notatka")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    copyToClipboard()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showCopyConfirmation {
                copyConfirmationBanner
            }
        }
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(note.formattedDate)
            }
            .font(.subheadline)

            if note.duration > 0 {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                    Text(formatDuration(note.duration))
                }
                .font(.subheadline)
            }

            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(.secondary)
                Text("\(note.content.count) znaków")
            }
            .font(.subheadline)
        }
        .foregroundStyle(.secondary)
    }

    private var content: some View {
        Text(note.content)
            .font(.body)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var copyConfirmationBanner: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Skopiowano do schowka")
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: showCopyConfirmation)
        .padding(.bottom, 20)
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = note.content
        showCopyConfirmation = true

        Task {
            try? await Task.sleep(for: .seconds(2))
            showCopyConfirmation = false
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes) min \(seconds) sek"
        }
        return "\(seconds) sek"
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(note: Note(
            id: UUID(),
            content: "To jest przykładowa notatka z transkrypcją mowy. Zawiera tekst, który został rozpoznany przez system rozpoznawania mowy.",
            createdAt: Date(),
            duration: 45
        ))
    }
}
