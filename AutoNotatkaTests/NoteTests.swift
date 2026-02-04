import XCTest
@testable import AutoNotatka

final class NoteTests: XCTestCase {

    func testNoteCreation() {
        let note = Note(
            id: UUID(),
            content: "Test content",
            createdAt: Date(),
            duration: 30
        )

        XCTAssertEqual(note.content, "Test content")
        XCTAssertEqual(note.duration, 30)
    }

    func testNoteFileName() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

        let testDate = Date()
        let note = Note(
            id: UUID(),
            content: "Test",
            createdAt: testDate,
            duration: 0
        )

        let expectedFileName = "AutoNotatka_\(dateFormatter.string(from: testDate)).txt"
        XCTAssertEqual(note.fileName, expectedFileName)
    }

    func testNotePreviewShortContent() {
        let note = Note(
            id: UUID(),
            content: "Short content",
            createdAt: Date(),
            duration: 0
        )

        XCTAssertEqual(note.preview, "Short content")
    }

    func testNotePreviewLongContent() {
        let longContent = String(repeating: "a", count: 150)
        let note = Note(
            id: UUID(),
            content: longContent,
            createdAt: Date(),
            duration: 0
        )

        XCTAssertTrue(note.preview.hasSuffix("..."))
        XCTAssertEqual(note.preview.count, 103) // 100 chars + "..."
    }

    func testNoteEquatable() {
        let id = UUID()
        let note1 = Note(id: id, content: "Test", createdAt: Date(), duration: 10)
        let note2 = Note(id: id, content: "Test", createdAt: note1.createdAt, duration: 10)

        XCTAssertEqual(note1, note2)
    }

    func testNoteCodable() throws {
        let note = Note(
            id: UUID(),
            content: "Test content",
            createdAt: Date(),
            duration: 45
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(note)

        let decoder = JSONDecoder()
        let decodedNote = try decoder.decode(Note.self, from: data)

        XCTAssertEqual(note.id, decodedNote.id)
        XCTAssertEqual(note.content, decodedNote.content)
        XCTAssertEqual(note.duration, decodedNote.duration)
    }
}
