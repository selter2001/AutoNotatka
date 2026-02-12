import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: GoogleAuthManager
    @StateObject private var drivePreferences = DrivePreferences()

    var body: some View {
        TabView {
            RecordingView()
                .tabItem {
                    Label("Nagrywaj", systemImage: "mic.fill")
                }

            NotesListView()
                .tabItem {
                    Label("Nagrania", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Ustawienia", systemImage: "gear")
                }
        }
        .environmentObject(drivePreferences)
    }
}

#Preview {
    ContentView()
        .environmentObject(GoogleAuthManager.shared)
}
