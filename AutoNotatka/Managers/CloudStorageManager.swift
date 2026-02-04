import Foundation

final class CloudStorageManager {
    static let shared = CloudStorageManager()

    private let fileManager = FileManager.default
    private let folderName = "AutoNotatka"

    private init() {}

    var iCloudContainerURL: URL? {
        fileManager.url(forUbiquityContainerIdentifier: "iCloud.com.autonotatka.notes")
    }

    var isICloudAvailable: Bool {
        iCloudContainerURL != nil
    }

    private var notesDirectoryURL: URL? {
        if let iCloudURL = iCloudContainerURL {
            return iCloudURL.appendingPathComponent("Documents").appendingPathComponent(folderName)
        }
        return localDocumentsURL
    }

    private var localDocumentsURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(folderName)
    }

    func ensureDirectoryExists() throws {
        guard let directoryURL = notesDirectoryURL else { return }

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }

    func saveNote(_ note: Note) throws {
        try ensureDirectoryExists()

        guard let directoryURL = notesDirectoryURL else {
            throw StorageError.directoryNotFound
        }

        let fileURL = directoryURL.appendingPathComponent(note.fileName)
        let content = note.content
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    func loadAllNotes() throws -> [Note] {
        guard let directoryURL = notesDirectoryURL,
              fileManager.fileExists(atPath: directoryURL.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        )

        return fileURLs
            .filter { $0.pathExtension == "txt" }
            .compactMap { fileURL -> Note? in
                guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
                      let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                      let creationDate = attributes[.creationDate] as? Date else {
                    return nil
                }

                return Note(
                    id: UUID(),
                    content: content,
                    createdAt: creationDate,
                    duration: 0
                )
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func deleteNote(_ note: Note) throws {
        guard let directoryURL = notesDirectoryURL else {
            throw StorageError.directoryNotFound
        }

        let fileURL = directoryURL.appendingPathComponent(note.fileName)

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    enum StorageError: LocalizedError {
        case directoryNotFound
        case saveFailed
        case loadFailed

        var errorDescription: String? {
            switch self {
            case .directoryNotFound:
                return "Nie znaleziono folderu"
            case .saveFailed:
                return "Nie udało się zapisać notatki"
            case .loadFailed:
                return "Nie udało się wczytać notatek"
            }
        }
    }
}
