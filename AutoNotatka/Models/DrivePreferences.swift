import Foundation
import SwiftUI

class DrivePreferences: ObservableObject {
    @AppStorage("selectedDriveFolderId") var selectedFolderId: String = ""
    @AppStorage("selectedDriveFolderName") var selectedFolderName: String = ""

    var hasSelectedFolder: Bool {
        !selectedFolderId.isEmpty
    }

    func selectFolder(id: String, name: String) {
        selectedFolderId = id
        selectedFolderName = name
        print("Selected folder: \(name) (ID: \(id))")
    }

    func clearSelection() {
        selectedFolderId = ""
        selectedFolderName = ""
        print("Cleared folder selection")
    }
}
