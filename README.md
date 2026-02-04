# AutoNotatka

> **Voice-to-text note-taking iOS app with real-time AI transcription and iCloud sync**

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat-square&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=flat-square&logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=flat-square&logo=swift&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

AutoNotatka is a minimalist iOS app for voice recording with instant transcription. Press record, speak, and your words appear as text in real-time. Notes automatically sync to iCloud Drive.

## AI Features

- **Real-time Speech Recognition** — Text appears as you speak using Apple's Speech Framework
- **On-device Processing** — No internet required for transcription (offline capable)
- **Natural Language Processing** — Automatic punctuation and formatting

## Features

- One-tap recording with large, accessible button
- Live transcription during recording
- Automatic save to iCloud Drive as `.txt` files
- Notes list with search and management
- Offline mode with local storage fallback
- Clean, minimal interface

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Views                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │Recording │  │NotesList │  │NoteDetail│  │Onboarding│ │
│  │  View    │  │  View    │  │  View    │  │  View   │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘ │
└───────┼─────────────┼─────────────┼─────────────┼───────┘
        │             │             │             │
┌───────▼─────────────▼─────────────▼─────────────▼───────┐
│                    ViewModels                            │
│         ┌────────────────┐  ┌────────────────┐          │
│         │  Recording     │  │    Notes       │          │
│         │  ViewModel     │  │   ViewModel    │          │
│         └───────┬────────┘  └───────┬────────┘          │
└─────────────────┼───────────────────┼───────────────────┘
                  │                   │
┌─────────────────▼───────────────────▼───────────────────┐
│                      Managers                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │  Audio   │  │  Speech  │  │  Cloud   │  │Permission│ │
│  │ Manager  │  │ Manager  │  │ Storage  │  │ Manager │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                      Models                              │
│                   ┌──────────┐                          │
│                   │   Note   │                          │
│                   └──────────┘                          │
└─────────────────────────────────────────────────────────┘
```

**Pattern:** MVVM (Model-View-ViewModel)

| Layer | Responsibility |
|-------|---------------|
| Views | SwiftUI views, user interaction |
| ViewModels | Business logic, state management |
| Managers | Audio session, speech recognition, storage |
| Models | Data structures |

## Tech Stack

| Component | Technology |
|-----------|------------|
| UI | SwiftUI |
| Architecture | MVVM |
| Speech Recognition | Apple Speech Framework |
| Storage | iCloud Drive / FileManager |
| Minimum iOS | 17.0 |

## Installation

### Prerequisites

- macOS with Xcode 15.0+
- Apple Developer account (for iCloud)
- Physical iPhone (Speech recognition works best on device)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/selter2001/AutoNotatka.git
   cd AutoNotatka
   ```

2. **Open in Xcode**
   ```bash
   open AutoNotatka.xcodeproj
   ```

3. **Configure signing**
   - Select your Team in Signing & Capabilities
   - Change Bundle Identifier to your own (e.g., `com.yourname.autonotatka`)

4. **Configure iCloud** (optional, for sync)
   - Update iCloud container identifier in Signing & Capabilities
   - Or disable iCloud to use local storage only

5. **Run on device**
   - Connect iPhone
   - Select device as target
   - Press `Cmd + R`

## Usage

### First Launch
1. Grant microphone permission when prompted
2. Grant speech recognition permission
3. Tap "Przyznaj uprawnienia" (Grant permissions)

### Recording
1. Go to "Nagrywaj" (Record) tab
2. Tap the red microphone button
3. Speak — text appears in real-time
4. Tap stop to finish
5. Note saves automatically

### Managing Notes
- View all notes in "Notatki" (Notes) tab
- Tap note to see full content
- Swipe left to delete
- Pull down to refresh

## File Locations

| Mode | Path |
|------|------|
| With iCloud | `iCloud Drive/AutoNotatka/AutoNotatka_YYYY-MM-DD_HH-mm-ss.txt` |
| Without iCloud | `Documents/AutoNotatka/AutoNotatka_YYYY-MM-DD_HH-mm-ss.txt` |

## Permissions

| Permission | Purpose |
|------------|---------|
| Microphone | Voice recording |
| Speech Recognition | Transcription |

## License

MIT License — see [LICENSE](LICENSE) file

## Author

**Wojciech Olszak**

Built with Swift and SwiftUI. AI transcription powered by Apple Speech Framework.
Created with assistance from Claude AI (Anthropic).

---

*AutoNotatka v1.0 | 2026*
