import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecordingView()
                .tabItem {
                    Label("Nagrywaj", systemImage: "mic.fill")
                }

            NotesListView()
                .tabItem {
                    Label("Notatki", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
