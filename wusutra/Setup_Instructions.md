# Quick Setup Instructions for wusutra iOS App

## Step-by-Step Setup in Xcode:

1. **Create New Project**
   - Open Xcode
   - File → New → Project
   - Choose "iOS" → "App"
   - Click "Next"

2. **Configure Project**
   - Product Name: `wusutra`
   - Team: (Select your team or personal account)
   - Organization Identifier: `com.yourname` (or your actual identifier)
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Use Core Data: `NO` (unchecked)
   - Include Tests: `NO` (unchecked for now)
   - Click "Next" and save the project

3. **Replace Default Files**
   - In Xcode's file navigator (left panel):
   - Delete the default `ContentView.swift`
   - Right-click on the project folder → "Add Files to 'wusutra'"
   - Add all the Swift files I created (excluding README.md)

4. **Configure Info.plist**
   - Click on your project name in navigator
   - Select the "wusutra" target
   - Go to "Info" tab
   - Add these keys:
     - Privacy - Microphone Usage Description: "wusutra needs access to your microphone to record audio for crowdsourcing dialect speech samples."
     - App Transport Security Settings → Allow Arbitrary Loads: YES (only for testing)

5. **Build and Run**
   - Select a simulator or your device
   - Press Cmd+R or click the Play button

That's it! Xcode will create the .xcodeproj automatically when you create the new project.