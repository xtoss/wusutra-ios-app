# Wusutra iOS App

A dialect preservation app that helps users learn and practice local Chinese dialects through interactive exercises and speech recognition.

## Features

- **Recording & Practice**: Record yourself speaking dialect phrases
- **Library**: Browse and listen to dialect phrases with translations
- **Training**: View model training status and progress
- **Leaderboard**: Track your learning progress
- **Support**: Get help and submit feedback

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

## Important: API Configuration Required

**This app requires backend services to function.** No API endpoints are included in the source code.

### Required Configuration:

1. **API Base URL**: Must be configured in Settings before use
   - No default URL provided
   - You need to deploy your own backend services
   - Configure via Settings → API Base URL

2. **Inference URL**: For real-time transcription
   - Default: `http://localhost:8000`
   - Configure via Settings if using different endpoint

### Backend Requirements:

To use this app, you need to deploy:
- Audio upload service (AWS Lambda or similar)
- ML training pipeline (SageMaker or similar)
- Inference endpoint for transcription
- Database for storing recordings

## Setup

1. Clone the repository
2. Deploy required backend services (see wusutra-BE repository)
3. Open `wusutra.xcodeproj` in Xcode
4. Build and run the project
5. Configure API endpoints in Settings before first use

## Architecture

The app follows MVVM architecture with:
- SwiftUI for UI
- Combine for reactive programming
- URLSession for networking
- AVFoundation for audio recording

## API Integration

The app integrates with:
- Audio upload endpoints for recordings
- Training status endpoints
- Model inference endpoints
- Prompt management system

## Security Notes

- No hardcoded API keys or secrets
- Configurable endpoints via Settings
- Audio recordings are processed server-side

## Contributing

Please ensure all sensitive information is removed before committing.