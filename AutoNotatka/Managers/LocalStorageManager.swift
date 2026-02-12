import Foundation

final class LocalStorageManager {
    static let shared = LocalStorageManager()

    private let fileManager = FileManager.default
    private let folderName = "AutoNotatka"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.outputFormatting = .prettyPrinted
    }

    private var notesDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName)
    }

    private func ensureDirectoryExists() throws {
        if !fileManager.fileExists(atPath: notesDirectory.path) {
            try fileManager.createDirectory(at: notesDirectory, withIntermediateDirectories: true)
        }
    }

    func saveNote(_ note: Note) throws {
        try ensureDirectoryExists()

        let fileName = note.id.uuidString + ".json"
        let fileURL = notesDirectory.appendingPathComponent(fileName)

        let data = try encoder.encode(note)
        try data.write(to: fileURL, options: .atomic)
    }

    func updateNote(_ note: Note) throws {
        try saveNote(note)
    }

    func loadAllNotes() throws -> [Note] {
        guard fileManager.fileExists(atPath: notesDirectory.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: notesDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )

        var notes: [Note] = []

        for fileURL in fileURLs {
            if fileURL.pathExtension == "json" {
                // New JSON format
                if let data = try? Data(contentsOf: fileURL),
                   let note = try? decoder.decode(Note.self, from: data) {
                    notes.append(note)
                }
            } else if fileURL.pathExtension == "txt" {
                // Legacy .txt format - migrate
                if let content = try? String(contentsOf: fileURL, encoding: .utf8),
                   let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                   let creationDate = attributes[.creationDate] as? Date {
                    let note = Note(
                        id: UUID(),
                        content: content,
                        createdAt: creationDate,
                        duration: 0,
                        storedFileName: fileURL.lastPathComponent
                    )
                    notes.append(note)
                }
            }
        }

        return notes.sorted { $0.createdAt > $1.createdAt }
    }

    func deleteNote(_ note: Note) throws {
        // Try JSON file first
        let jsonURL = notesDirectory.appendingPathComponent(note.id.uuidString + ".json")
        if fileManager.fileExists(atPath: jsonURL.path) {
            try fileManager.removeItem(at: jsonURL)
            return
        }

        // Fallback: legacy .txt file
        let txtURL = notesDirectory.appendingPathComponent(note.fileName)
        if fileManager.fileExists(atPath: txtURL.path) {
            try fileManager.removeItem(at: txtURL)
        }
    }

    enum StorageError: LocalizedError {
        case directoryNotFound
        case saveFailed
        case loadFailed

        var errorDescription: String? {
            switch self {
            case .directoryNotFound:
                return "Nie znaleziono pliku"
            case .saveFailed:
                return "Nie udało się zapisać notatki"
            case .loadFailed:
                return "Nie udało się wczytać notatek"
            }
        }
    }
}
