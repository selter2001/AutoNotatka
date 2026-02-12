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
            .navigationTitle("Nagrania")
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
            .alert("Zmień nazwę", isPresented: $viewModel.showRenameAlert) {
                TextField("Nazwa", text: $viewModel.renameText)
                Button("Zapisz") {
                    viewModel.confirmRename()
                }
                Button("Anuluj", role: .cancel) {}
            } message: {
                Text("Podaj nową nazwę nagrania")
            }
        }
    }

    private var notesList: some View {
        List {
            ForEach(viewModel.notes) { note in
                NoteRowView(note: note)
                    .contextMenu {
                        Button {
                            viewModel.startRename(note: note)
                        } label: {
                            Label("Zmień nazwę", systemImage: "pencil")
                        }

                        if note.uploadStatus == .failed {
                            Button {
                                viewModel.retryUpload(note: note)
                            } label: {
                                Label("Ponów wysyłanie", systemImage: "arrow.clockwise")
                            }
                        }

                        Button(role: .destructive) {
                            viewModel.deleteNote(note)
                        } label: {
                            Label("Usuń", systemImage: "trash")
                        }
                    }
            }
            .onDelete(perform: viewModel.deleteNotes)
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Brak nagrań",
            systemImage: "mic.slash",
            description: Text("Nagraj swoje pierwsze nagranie w zakładce Nagrywaj")
        )
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
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(note.displayName)
                    .font(.body)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(note.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if note.duration > 0 {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(note.formattedDuration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Upload status indicator
            if let status = note.uploadStatus {
                uploadStatusIcon(status)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func uploadStatusIcon(_ status: UploadStatus) -> some View {
        switch status {
        case .pending:
            Image(systemName: "clock")
                .foregroundStyle(.orange)
                .font(.caption)
        case .uploading:
            ProgressView()
                .scaleEffect(0.7)
        case .done:
            Image(systemName: "checkmark.icloud.fill")
                .foregroundStyle(.green)
                .font(.caption)
        case .failed:
            Image(systemName: "exclamationmark.icloud.fill")
                .foregroundStyle(.red)
                .font(.caption)
        }
    }
}

#Preview {
    NotesListView()
}
