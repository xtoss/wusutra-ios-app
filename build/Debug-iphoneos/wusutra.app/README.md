# wusutra - iOS Crowdsourcing Speech App

A production-ready iOS app for crowdsourcing speech and text pairs. Records audio clips and collects corresponding text/translations for upload.

## Features

- Record audio in .m4a format (16 kHz, mono, AAC)
- Required text/translation input for each recording
- Upload recordings with metadata via multipart/form-data
- Local persistence with retry capabilities
- Clean SwiftUI architecture

## Build Instructions

1. Open Xcode and create a new iOS app project named "wusutra"
2. Set minimum deployment target to iOS 16.0
3. Replace the default files with the provided source files
4. Add the Info.plist keys to your project's Info.plist:
   - NSMicrophoneUsageDescription
   - NSAppTransportSecurity (if testing with non-HTTPS endpoints)

## Configuration

- Default API endpoint: `https://example.com/upload`
- Change via Settings tab in the app
- Or modify the default in `wusutraApp.swift`: `@AppStorage("API_BASE_URL")`

## Project Structure

- `wusutraApp.swift` - App entry point
- `RecordingManager.swift` - Audio recording with AVFoundation
- `UploadManager.swift` - Network upload with retry logic
- `Models.swift` - Data models
- `NetworkingClient.swift` - Multipart upload implementation
- Views: RecordView, LibraryView, SettingsView, AboutView
- Supporting views: TranslationSheet, EditTextSheet

## Upload Format

POST multipart/form-data:
- `file`: .m4a audio binary
- `text`: user-entered text/translation
- `filename`: original filename
- `duration_sec`: float
- `sample_rate`: 16000
- `format`: "m4a"
- `app`: "wusutra"