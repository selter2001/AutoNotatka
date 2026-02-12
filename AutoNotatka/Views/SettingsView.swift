import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: GoogleAuthManager
    @EnvironmentObject var drivePreferences: DrivePreferences
    @AppStorage("deleteLocalAfterUpload") private var deleteLocalAfterUpload = true
    @State private var showingSignOutAlert = false
    @State private var showingFolderPicker = false

    var body: some View {
        NavigationStack {
            List {
                // Google account section
                Section("Konto Google") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(authManager.user?.profile?.email ?? "Zalogowany")
                                .font(.subheadline)
                        }
                    }

                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        Label("Wyloguj się", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                // Drive folder section
                Section("Google Drive") {
                    Button {
                        showingFolderPicker = true
                    } label: {
                        HStack {
                            Label("Folder docelowy", systemImage: "folder.fill")
                            Spacer()
                            Text(drivePreferences.hasSelectedFolder ? drivePreferences.selectedFolderName : "Nie wybrano")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    Toggle(isOn: $deleteLocalAfterUpload) {
                        VStack(alignment: .leading) {
                            Text("Kasuj lokalne po wysłaniu")
                            Text("Usuwa plik audio z urządzenia po udanym uploadzie")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // App info
                Section("Informacje") {
                    HStack {
                        Text("Wersja")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Autor")
                        Spacer()
                        Text("Wojciech Olszak")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Ustawienia")
        }
        .alert("Wyloguj się", isPresented: $showingSignOutAlert) {
            Button("Anuluj", role: .cancel) {}
            Button("Wyloguj", role: .destructive) {
                authManager.signOut()
                drivePreferences.clearSelection()
            }
        } message: {
            Text("Czy na pewno chcesz się wylogować?")
        }
        .sheet(isPresented: $showingFolderPicker) {
            DriveFolderPickerView { folderId, folderName in
                drivePreferences.selectFolder(id: folderId, name: folderName)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GoogleAuthManager.shared)
        .environmentObject(DrivePreferences())
}
