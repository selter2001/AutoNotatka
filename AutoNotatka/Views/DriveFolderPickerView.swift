import SwiftUI
import GoogleAPIClientForREST_Drive

struct DriveFolderPickerView: View {
    @StateObject private var viewModel = DriveFolderPickerViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showNewFolderAlert = false
    @State private var newFolderName = ""

    var onFolderSelected: (String, String) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    // Navigate up button
                    if viewModel.canNavigateUp {
                        Button {
                            viewModel.navigateUp()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up")
                                    .foregroundColor(.blue)
                                Text("Folder nadrzędny")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }

                    // My Drive folders
                    if !viewModel.folders.isEmpty {
                        Section(viewModel.isAtRoot ? "Mój Dysk" : "Foldery") {
                            ForEach(viewModel.folders, id: \.identifier) { folder in
                                Button {
                                    viewModel.navigateInto(folder: folder)
                                } label: {
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.blue)
                                        Text(folder.name ?? "Untitled")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }

                    // Shared with me folders (only at root)
                    if viewModel.isAtRoot && !viewModel.sharedDrives.isEmpty {
                        Section("Udostępnione mi") {
                            ForEach(viewModel.sharedDrives, id: \.identifier) { drive in
                                Button {
                                    viewModel.navigateInto(folder: drive)
                                } label: {
                                    HStack {
                                        Image(systemName: "folder.fill.badge.person.crop")
                                            .foregroundColor(.orange)
                                        Text(drive.name ?? "Untitled")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }

                    // Empty state
                    if !viewModel.isLoading && viewModel.folders.isEmpty && viewModel.sharedDrives.isEmpty && viewModel.errorMessage == nil {
                        Text("Brak folderów")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }

                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .navigationTitle(viewModel.currentFolderName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        newFolderName = ""
                        showNewFolderAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "folder.badge.plus")
                            Text("Nowy folder")
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Wybierz") {
                        selectCurrentFolder()
                    }
                }
            }
            .alert("Nowy folder", isPresented: $showNewFolderAlert) {
                TextField("Nazwa folderu", text: $newFolderName)
                Button("Utwórz") {
                    let name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !name.isEmpty {
                        viewModel.createFolder(name: name)
                    }
                }
                Button("Anuluj", role: .cancel) {}
            } message: {
                Text("Podaj nazwę nowego folderu")
            }
            .alert("Błąd", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Spróbuj ponownie") {
                    viewModel.errorMessage = nil
                    viewModel.loadFolders()
                }
                Button("Anuluj", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    private func selectCurrentFolder() {
        let folderId = viewModel.currentFolderId ?? "root"
        let folderName = viewModel.currentFolderName

        onFolderSelected(folderId, folderName)
        dismiss()
    }
}

#Preview {
    DriveFolderPickerView { id, name in
        print("Selected folder: \(name) (ID: \(id))")
    }
}
