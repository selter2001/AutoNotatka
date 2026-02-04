# AutoNotatka - Technical Specification

## Overview

**AutoNotatka** is a minimalist iOS app for voice recording with instant transcription and automatic saving to iCloud Drive.

**Core Philosophy**: One-tap recording, zero friction, automatic cloud backup.

---

## Technical Stack

| Component | Technology |
|-----------|------------|
| **Platform** | iOS 17+ |
| **Language** | Swift 5.9+ |
| **UI Framework** | SwiftUI |
| **Speech Recognition** | Speech Framework (SFSpeechRecognizer) |
| **Cloud Storage** | iCloud Drive (FileManager + UIDocument) |
| **Architecture** | MVVM |

---

## Features

### MVP (v1.0)

1. **One-Button Recording**
   - Large, prominent record button (center screen)
   - Visual feedback: pulsing animation while recording
   - Tap to start, tap to stop

2. **Real-Time Transcription**
   - Live speech-to-text using Apple's Speech Framework
   - Support for Polish language (pl-PL) as primary
   - Display transcribed text in real-time during recording

3. **Automatic Save to iCloud**
   - Save as `.txt` file upon recording completion
   - Filename format: `AutoNotatka_YYYY-MM-DD_HH-mm-ss.txt`
   - Location: iCloud Drive > AutoNotatka folder
   - Fallback to local Documents if iCloud unavailable

4. **Notes List**
   - Simple list view of all saved notes
   - Tap to view full transcription
   - Swipe to delete

---

## Architecture

```
AutoNotatka/
├── App/
│   └── AutoNotatkaApp.swift          # App entry point
├── Views/
│   ├── ContentView.swift             # Main tab container
│   ├── RecordingView.swift           # Recording screen with big button
│   └── NotesListView.swift           # List of saved notes
├── ViewModels/
│   ├── RecordingViewModel.swift      # Recording logic & state
│   └── NotesViewModel.swift          # Notes management
├── Managers/
│   ├── SpeechManager.swift           # Speech recognition wrapper
│   ├── AudioManager.swift            # Audio session handling
│   └── CloudStorageManager.swift     # iCloud Drive operations
├── Models/
│   └── Note.swift                    # Note data model
└── Resources/
    └── Assets.xcassets               # App icons, colors
```

---

## Permissions Required

| Permission | Usage Description (Info.plist) |
|------------|-------------------------------|
| `NSSpeechRecognitionUsageDescription` | "AutoNotatka uses speech recognition to transcribe your voice recordings." |
| `NSMicrophoneUsageDescription` | "AutoNotatka needs microphone access to record your voice." |

---

## iCloud Configuration

- Enable **iCloud** capability in Xcode
- Enable **iCloud Documents** container
- Container identifier: `iCloud.com.autonotatka.notes`

---

## UI Design

### Recording Screen
```
┌─────────────────────────────┐
│                             │
│   ┌─────────────────────┐   │
│   │                     │   │
│   │  Live transcription │   │
│   │  appears here...    │   │
│   │                     │   │
│   └─────────────────────┘   │
│                             │
│         ┌───────┐           │
│         │       │           │
│         │  ●    │  ← Big red│
│         │ REC   │    button │
│         │       │           │
│         └───────┘           │
│                             │
└─────────────────────────────┘
```

### Color Palette
- **Primary**: Red (#FF3B30) - Recording indicator
- **Background**: System background (light/dark mode)
- **Text**: System label colors

---

## Data Model

```swift
struct Note: Identifiable, Codable {
    let id: UUID
    let content: String
    let createdAt: Date
    let duration: TimeInterval
    var fileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "AutoNotatka_\(formatter.string(from: createdAt)).txt"
    }
}
```

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Microphone denied | Show alert with Settings link |
| Speech recognition denied | Show alert with Settings link |
| Speech recognition unavailable | Show error, disable recording |
| iCloud unavailable | Save locally, show warning badge |
| Network offline | Use on-device recognition if available |

---

## Testing Strategy

- **Unit Tests**: SpeechManager, CloudStorageManager
- **UI Tests**: Recording flow, notes list navigation
- **Manual Testing**: Real device required for Speech Framework

---

## Future Enhancements (v2.0+)

- [ ] Audio playback of original recording
- [ ] Multiple language support
- [ ] Share/export functionality
- [ ] Folders/tags organization
- [ ] Widget for quick recording
- [ ] Apple Watch companion app

---

## Acceptance Criteria (MVP)

- [x] User can tap button to start/stop recording
- [x] Transcription appears in real-time during recording
- [x] Note is automatically saved to iCloud Drive on stop
- [x] User can view list of all notes
- [x] User can tap note to view full content
- [x] User can delete notes
- [x] App handles permission requests gracefully
- [x] Works offline with local fallback

**MVP Status: COMPLETE** (2026-02-04)

---

*Document Version: 1.0*
*Created: 2026-02-04*
