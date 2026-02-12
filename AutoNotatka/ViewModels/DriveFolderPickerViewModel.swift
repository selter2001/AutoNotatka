import Foundation
import SwiftUI
import GoogleAPIClientForREST_Drive

@MainActor
class DriveFolderPickerViewModel: ObservableObject {
    @Published var folders: [GTLRDrive_File] = []
    @Published var sharedDrives: [GTLRDrive_File] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Stack tracks navigation: (folderId, folderName, driveId)
    private var folderStack: [(id: String?, name: String, driveId: String?)] = []

    var currentFolderId: String? {
        folderStack.last?.id
    }

    var currentDriveId: String? {
        folderStack.last?.driveId
    }

    var currentFolderName: String {
        folderStack.last?.name ?? "Mój Dysk"
    }

    var canNavigateUp: Bool {
        !folderStack.isEmpty
    }

    var isAtRoot: Bool {
        folderStack.isEmpty
    }

    init() {
        loadFolders()
    }

    func loadFolders() {
        isLoading = true
        errorMessage = nil

        if isAtRoot {
            // At root: load both My Drive folders and shared drives
            let group = DispatchGroup()
            // Use nonisolated(unsafe) because both callbacks dispatch to main queue
            nonisolated(unsafe) var myDriveFolders: [GTLRDrive_File] = []
            nonisolated(unsafe) var sharedDrivesList: [GTLRDrive_File] = []

            group.enter()
            GoogleDriveManager.shared.listFolders(in: nil) { result in
                if case .success(let folders) = result {
                    myDriveFolders = folders
                }
                group.leave()
            }

            group.enter()
            GoogleDriveManager.shared.listSharedFolders { result in
                if case .success(let drives) = result {
                    sharedDrivesList = drives
                }
                group.leave()
            }

            group.notify(queue: .main) { [weak self] in
                self?.folders = myDriveFolders
                self?.sharedDrives = sharedDrivesList
                self?.isLoading = false
                print("[ViewModel] Root: \(myDriveFolders.count) folders, \(sharedDrivesList.count) shared drives")
            }
        } else {
            // Inside a folder: list subfolders
            sharedDrives = []
            GoogleDriveManager.shared.listFolders(in: currentFolderId, driveId: currentDriveId) { [weak self] result in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isLoading = false

                    switch result {
                    case .success(let folders):
                        self.folders = folders
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.folders = []
                    }
                }
            }
        }
    }

    func navigateInto(folder: GTLRDrive_File) {
        guard let folderId = folder.identifier,
              let folderName = folder.name else {
            return
        }

        folderStack.append((id: folderId, name: folderName, driveId: nil))
        loadFolders()
    }

    func navigateUp() {
        guard !folderStack.isEmpty else { return }
        folderStack.removeLast()
        loadFolders()
    }

    func createFolder(name: String) {
        isLoading = true
        GoogleDriveManager.shared.createFolder(name: name, parentId: currentFolderId) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                switch result {
                case .success(let folder):
                    // Navigate into the newly created folder
                    self.navigateInto(folder: folder)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
