import SwiftUI

struct NotesListView: View {
    @StateObject private var viewModel = NotesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Wczytywanie...")
                } else if viewModel.isEmpty {
                    emptyState
                } else {
                    notesList
                }
            }
            .navigationTitle("Notatki")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    storageIndicator
                }
            }
            .refreshable {
                viewModel.loadNotes()
            }
            .onAppear {
                viewModel.loadNotes()
            }
            .alert("Błąd", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Nieznany błąd")
            }
        }
    }

    private var notesList: some View {
        List {
            ForEach(viewModel.notes) { note in
                NavigationLink(destination: NoteDetailView(note: note)) {
                    NoteRowView(note: note)
                }
            }
            .onDelete(perform: viewModel.deleteNotes)
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Brak notatek",
            systemImage: "doc.text",
            description: Text("Nagraj swoją pierwszą notatkę w zakładce Nagrywaj")
        )
    }

    private var storageIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.iCloudStatus == "iCloud" ? "icloud.fill" : "internaldrive.fill")
                .font(.caption)
            Text(viewModel.iCloudStatus)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }
}

// MARK: - App Info
extension NotesListView {
    static let appAuthor = "Wojciech Olszak"
    static let appVersion = "1.0"
}

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.preview)
                .font(.body)
                .lineLimit(2)

            HStack {
                Text(note.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if note.duration > 0 {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(formatDuration(note.duration))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
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
    NotesListView()
}
