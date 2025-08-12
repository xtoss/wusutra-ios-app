# Fix ContentView Redeclaration Error

## The Problem
You have ContentView declared in multiple places:
1. In the default ContentView.swift that Xcode created
2. In wusutraApp.swift (where I originally put it)

## Solution:

### Option 1: Use the Fixed Version
1. In Xcode, **delete** these files from your project:
   - `ContentView.swift` (Xcode's default)
   - `wusutraApp.swift` (the original with ContentView)

2. **Add** the fixed version:
   - Right-click on your project folder
   - "Add Files to wusutra..."
   - Select `wusutraApp_Fixed.swift`
   - After adding, right-click it and "Rename" to `wusutraApp.swift`

### Option 2: Keep Xcode's Structure
1. Keep the default `ContentView.swift`
2. Edit `wusutraApp.swift` to remove the ContentView definition
3. Move the ContentView code to the separate ContentView.swift file

## Quick Fix for Option 2:
Replace your `wusutraApp.swift` with just this:
```swift
import SwiftUI

@main
struct wusutraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Then update ContentView.swift with the TabView code.

## Recommendation
Use Option 1 - it's cleaner to use the fixed version I provided that uses MainView instead of ContentView.