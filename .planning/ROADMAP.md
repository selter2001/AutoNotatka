# AutoNotatka - Development Roadmap

## Overview

This roadmap follows the **MVP-first** approach with **atomic commits** after each logical component.

---

## Phase 1: Project Setup
**Goal**: Xcode project with proper structure and capabilities

| Step | Task | Commit Message |
|------|------|----------------|
| 1.1 | Create Xcode project (SwiftUI, iOS 17+) | `init: create AutoNotatka Xcode project` |
| 1.2 | Set up folder structure (Views, ViewModels, Managers, Models) | `chore: set up project folder structure` |
| 1.3 | Configure iCloud capability and entitlements | `config: add iCloud capability and entitlements` |
| 1.4 | Add Info.plist permission descriptions | `config: add microphone and speech recognition permissions` |

---

## Phase 2: Core Managers
**Goal**: Build reusable service layer

| Step | Task | Commit Message |
|------|------|----------------|
| 2.1 | Create `AudioManager` - audio session setup | `feat: add AudioManager for audio session handling` |
| 2.2 | Create `SpeechManager` - speech recognition wrapper | `feat: add SpeechManager for speech-to-text` |
| 2.3 | Create `CloudStorageManager` - iCloud read/write | `feat: add CloudStorageManager for iCloud Drive` |
| 2.4 | Create `Note` model | `feat: add Note data model` |

---

## Phase 3: Recording Feature
**Goal**: Working voice recording with live transcription

| Step | Task | Commit Message |
|------|------|----------------|
| 3.1 | Create `RecordingViewModel` with state management | `feat: add RecordingViewModel` |
| 3.2 | Create `RecordingView` with big record button | `feat: add RecordingView with record button UI` |
| 3.3 | Add pulsing animation for recording state | `feat: add recording button animation` |
| 3.4 | Connect speech recognition to live display | `feat: connect live transcription to RecordingView` |
| 3.5 | Auto-save note on recording stop | `feat: auto-save transcription to iCloud on stop` |

---

## Phase 4: Notes Management
**Goal**: View and manage saved notes

| Step | Task | Commit Message |
|------|------|----------------|
| 4.1 | Create `NotesViewModel` - load notes from iCloud | `feat: add NotesViewModel for notes management` |
| 4.2 | Create `NotesListView` - display all notes | `feat: add NotesListView` |
| 4.3 | Create `NoteDetailView` - view full note | `feat: add NoteDetailView` |
| 4.4 | Add swipe-to-delete functionality | `feat: add delete note functionality` |

---

## Phase 5: Navigation & Polish
**Goal**: Complete app flow and error handling

| Step | Task | Commit Message |
|------|------|----------------|
| 5.1 | Set up `ContentView` with tab navigation | `feat: add tab navigation (Record/Notes)` |
| 5.2 | Add permission request flows | `feat: add permission request handling` |
| 5.3 | Add error alerts and fallback states | `feat: add error handling and alerts` |
| 5.4 | Add app icon and launch screen | `chore: add app icon and launch screen` |

---

## Phase 6: Testing & Release
**Goal**: Quality assurance and App Store preparation

| Step | Task | Commit Message |
|------|------|----------------|
| 6.1 | Write unit tests for managers | `test: add unit tests for managers` |
| 6.2 | Manual testing on physical device | *(no commit)* |
| 6.3 | Fix bugs found during testing | `fix: [description]` |
| 6.4 | Update README with usage instructions | `docs: add README` |

---

## Milestones

| Milestone | Phases | Definition of Done |
|-----------|--------|-------------------|
| **M1: Foundation** | 1-2 | Project compiles, managers work in isolation |
| **M2: Recording Works** | 3 | Can record and see live transcription |
| **M3: MVP Complete** | 4-5 | Full app flow works end-to-end |
| **M4: Release Ready** | 6 | Tested, documented, ready for TestFlight |

---

## Dependencies Between Steps

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Managers) ──────────────────┐
    │                                │
    ▼                                ▼
Phase 3 (Recording)            Phase 4 (Notes)
    │                                │
    └────────────┬───────────────────┘
                 ▼
           Phase 5 (Polish)
                 │
                 ▼
           Phase 6 (Release)
```

---

## Current Status

- [x] **Phase 1**: Project Setup (commit: fe0a5c6)
- [x] **Phase 2**: Core Managers (commits: 5310492, 808dd73, 77a51a0, e8dfd41)
- [x] **Phase 3**: Recording Feature (commits: cee0895, f9d2396)
- [x] **Phase 4**: Notes Management (commits: ede2482, 0df066a, e35b66f)
- [x] **Phase 5**: Navigation & Polish (commits: 18ad263, 1cd8231, 7236940)
- [x] **Phase 6**: Testing & Release (commits: 9fb150c, 3b2bc5a)

---

*Last Updated: 2026-02-04*
