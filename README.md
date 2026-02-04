# AutoNotatka

Minimalistyczna aplikacja iOS do nagrywania głosowego z natychmiastową transkrypcją i automatycznym zapisem do iCloud Drive.

## Funkcje

- **Jedno-przyciskowe nagrywanie** - duży, wyraźny przycisk nagrywania
- **Transkrypcja w czasie rzeczywistym** - tekst pojawia się podczas mówienia
- **Automatyczny zapis do iCloud** - notatki zapisywane jako pliki .txt
- **Lista notatek** - przeglądanie i zarządzanie zapisanymi notatkami
- **Tryb offline** - lokalna transkrypcja i zapis gdy iCloud niedostępne

## Wymagania

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Konto Apple Developer (do iCloud)

## Instalacja

1. Sklonuj repozytorium:
   ```bash
   git clone <repository-url>
   cd AutoNotatka
   ```

2. Otwórz projekt w Xcode:
   ```bash
   open AutoNotatka.xcodeproj
   ```

3. Skonfiguruj podpisywanie:
   - Wybierz swój Team w zakładce Signing & Capabilities
   - Zmień Bundle Identifier na unikalny (np. `com.twojnick.autonotatka`)

4. Skonfiguruj iCloud:
   - W Signing & Capabilities, zmodyfikuj iCloud container identifier
   - Zmień `iCloud.com.autonotatka.notes` na własny identyfikator

5. Uruchom na urządzeniu:
   - Podłącz iPhone'a
   - Wybierz urządzenie jako target
   - Naciśnij ⌘R

## Użytkowanie

### Pierwsze uruchomienie

1. Przy pierwszym uruchomieniu pojawi się ekran wprowadzający
2. Przyznaj uprawnienia do mikrofonu i rozpoznawania mowy
3. Naciśnij "Przyznaj uprawnienia"

### Nagrywanie notatki

1. Przejdź do zakładki "Nagrywaj"
2. Naciśnij czerwony przycisk mikrofonu
3. Mów - tekst pojawia się w czasie rzeczywistym
4. Naciśnij przycisk stop aby zakończyć
5. Notatka zostanie automatycznie zapisana

### Przeglądanie notatek

1. Przejdź do zakładki "Notatki"
2. Lista pokazuje wszystkie zapisane notatki
3. Dotknij notatkę aby zobaczyć pełną treść
4. Przesuń w lewo aby usunąć
5. Pociągnij w dół aby odświeżyć

### Szczegóły notatki

- Pełna treść z możliwością zaznaczania tekstu
- Data i czas nagrania
- Czas trwania nagrania
- Przycisk kopiowania do schowka

## Struktura projektu

```
AutoNotatka/
├── App/
│   └── AutoNotatkaApp.swift      # Punkt wejścia aplikacji
├── Views/
│   ├── ContentView.swift         # Główny widok z zakładkami
│   ├── OnboardingView.swift      # Ekran wprowadzający
│   ├── RecordingView.swift       # Widok nagrywania
│   ├── NotesListView.swift       # Lista notatek
│   └── NoteDetailView.swift      # Szczegóły notatki
├── ViewModels/
│   ├── RecordingViewModel.swift  # Logika nagrywania
│   └── NotesViewModel.swift      # Zarządzanie notatkami
├── Managers/
│   ├── AudioManager.swift        # Obsługa sesji audio
│   ├── SpeechManager.swift       # Rozpoznawanie mowy
│   ├── CloudStorageManager.swift # Operacje iCloud/lokalne
│   └── PermissionManager.swift   # Zarządzanie uprawnieniami
├── Models/
│   └── Note.swift                # Model danych notatki
└── Resources/
    └── Assets.xcassets/          # Zasoby graficzne
```

## Technologie

| Komponent | Technologia |
|-----------|-------------|
| UI | SwiftUI |
| Architektura | MVVM |
| Rozpoznawanie mowy | Speech Framework |
| Przechowywanie | iCloud Drive / FileManager |
| Minimum iOS | 17.0 |

## Uprawnienia

Aplikacja wymaga następujących uprawnień:

| Uprawnienie | Cel |
|-------------|-----|
| Mikrofon | Nagrywanie głosu |
| Rozpoznawanie mowy | Transkrypcja na tekst |

## Gdzie zapisywane są notatki?

- **Z iCloud**: `iCloud Drive > AutoNotatka > AutoNotatka_RRRR-MM-DD_GG-mm-ss.txt`
- **Bez iCloud**: `Documents > AutoNotatka > AutoNotatka_RRRR-MM-DD_GG-mm-ss.txt`

## Testowanie

```bash
# Uruchom testy jednostkowe
xcodebuild test -scheme AutoNotatka -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Licencja

MIT License - zobacz plik LICENSE

## Autor

**Wojciech Olszak**

Stworzone z pomocą Claude AI (Anthropic).

---

*AutoNotatka v1.0 | 2026 | Wojciech Olszak*
