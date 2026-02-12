import Foundation

enum UploadStatus: String, Codable, Equatable {
    case pending
    case uploading
    case done
    case failed
}

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    let createdAt: Date
    let duration: TimeInterval
    var storedFileName: String?
    var driveFileId: String?
    var uploadStatus: UploadStatus?
    var audioFileName: String?

    var fileName: String {
        if let stored = storedFileName {
            return stored
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "AutoNotatka_\(formatter.string(from: createdAt)).txt"
    }

    var displayName: String {
        if let audioName = audioFileName {
            return audioName
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return "Nagranie \(formatter.string(from: createdAt))"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes) min \(seconds) sek"
        }
        return "\(seconds) sek"
    }

    var preview: String {
        let maxLength = 100
        if content.count <= maxLength {
            return content
        }
        return String(content.prefix(maxLength)) + "..."
    }
}
