import XCTest
@testable import AutoNotatka

final class CloudStorageManagerTests: XCTestCase {

    var storageManager: CloudStorageManager!

    override func setUp() {
        super.setUp()
        storageManager = CloudStorageManager.shared
    }

    func testStorageManagerExists() {
        XCTAssertNotNil(storageManager)
    }

    func testICloudAvailabilityCheck() {
        // This test verifies the property exists and returns a boolean
        let isAvailable = storageManager.isICloudAvailable
        XCTAssertNotNil(isAvailable)
    }

    func testEnsureDirectoryExists() {
        // Should not throw when creating directory
        XCTAssertNoThrow(try storageManager.ensureDirectoryExists())
    }

    func testSaveAndLoadNote() throws {
        // Create a test note
        let testNote = Note(
            id: UUID(),
            content: "Test note for storage",
            createdAt: Date(),
            duration: 15
        )

        // Save should not throw
        XCTAssertNoThrow(try storageManager.saveNote(testNote))

        // Load notes and verify our note is there
        let notes = try storageManager.loadAllNotes()
        let foundNote = notes.first { $0.content == testNote.content }

        XCTAssertNotNil(foundNote, "Saved note should be found in loaded notes")

        // Cleanup - delete the test note
        if let noteToDelete = foundNote {
            try? storageManager.deleteNote(noteToDelete)
        }
    }

    func testDeleteNote() throws {
        // Create and save a note
        let testNote = Note(
            id: UUID(),
            content: "Note to delete - \(UUID().uuidString)",
            createdAt: Date(),
            duration: 5
        )

        try storageManager.saveNote(testNote)

        // Load to get the actual saved note
        let notesBefore = try storageManager.loadAllNotes()
        let savedNote = notesBefore.first { $0.content == testNote.content }

        XCTAssertNotNil(savedNote)

        // Delete should not throw
        if let noteToDelete = savedNote {
            XCTAssertNoThrow(try storageManager.deleteNote(noteToDelete))
        }

        // Verify deletion
        let notesAfter = try storageManager.loadAllNotes()
        let deletedNote = notesAfter.first { $0.content == testNote.content }

        XCTAssertNil(deletedNote, "Deleted note should not be found")
    }

    func testLoadEmptyNotes() throws {
        // Should return empty array, not throw
        let notes = try storageManager.loadAllNotes()
        XCTAssertNotNil(notes)
    }
}
