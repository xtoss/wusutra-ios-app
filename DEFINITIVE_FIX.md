# DEFINITIVE FIX - Info.plist Double Processing

The error clearly shows:
- `has copy command from` - Info.plist is being COPIED
- `has process command with` - Info.plist is being PROCESSED

Both are happening, which causes the conflict.

## THE FIX:

### 1. Remove Info.plist from Copy Bundle Resources
1. In Xcode, click your **project name** (blue icon)
2. Select **"wusutra" target**
3. Go to **"Build Phases"** tab
4. Expand **"Copy Bundle Resources"**
5. **FIND Info.plist in this list**
6. **SELECT IT and CLICK THE MINUS (-) BUTTON**
7. Info.plist should NOT be in this list at all

### 2. Verify Info.plist is Only Processed
After removing it from Copy Bundle Resources:
- Info.plist should ONLY be processed automatically by Xcode
- It should NOT appear in any Build Phases lists

### 3. Clean and Build
1. **Product → Clean Build Folder** (Shift+Cmd+K)
2. **Product → Build** (Cmd+B)

## Why This Happens
When you manually add Info.plist to your project, Xcode sometimes incorrectly adds it to "Copy Bundle Resources". This causes it to be:
1. Processed automatically (correct)
2. Copied manually (incorrect)

Result: Two commands trying to create the same output file.

## If You Can't Find It
Sometimes the UI doesn't show it clearly. Try:
1. Right-click on your project file → "Show in Finder"
2. Right-click the .xcodeproj → "Show Package Contents"
3. Open project.pbxproj in a text editor
4. Search for "Info.plist"
5. Look for it in any "PBXCopyFilesBuildPhase" section and remove that reference