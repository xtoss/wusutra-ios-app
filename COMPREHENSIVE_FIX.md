# Comprehensive Fix for Info.plist Build Error

## The Problem
Xcode is trying to process Info.plist multiple times, creating a conflict. This usually happens when:
- Info.plist is added to the project incorrectly
- It exists in "Copy Bundle Resources" build phase
- Multiple Info.plist files exist

## Step-by-Step Solution

### 1. Check Build Phases (MOST IMPORTANT)
1. In Xcode, click on your **project name** (blue icon at top)
2. Select the **"wusutra" target**
3. Go to **"Build Phases"** tab
4. Expand **"Copy Bundle Resources"**
5. **LOOK FOR Info.plist** - if it's there, THIS IS YOUR PROBLEM
6. Select Info.plist and click the **minus (-)** button to remove it
   - Info.plist should NEVER be in Copy Bundle Resources

### 2. Check for Duplicate Info.plist Files
1. In the project navigator (left sidebar), look for all Info.plist files
2. You should have ONLY ONE Info.plist
3. If you see multiple:
   - Right-click extra ones → Delete → "Remove Reference"
   - Keep the one that Xcode created (usually in the main project folder)

### 3. Verify Info.plist Settings
1. With your target selected, go to **"Build Settings"** tab
2. Search for "info.plist"
3. Check that **"Info.plist File"** points to your single Info.plist
   - Should be something like: `wusutra/Info.plist`

### 4. Clean Everything
1. **Product → Clean Build Folder** (Shift+Cmd+K)
2. Close Xcode
3. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/wusutra-*
   ```
4. Reopen Xcode

### 5. Add Microphone Permission (Correctly)
1. Click on your single Info.plist file in the navigator
2. Add row with + button:
   - Key: `Privacy - Microphone Usage Description`
   - Value: `wusutra needs access to your microphone to record audio for crowdsourcing dialect speech samples.`
3. Do NOT add App Transport Security unless you need it

### 6. Build Again
- Command+B to build

## If Still Not Working
Check if you have:
- Multiple targets with the same name
- Custom build scripts that process Info.plist
- Info.plist in multiple groups/folders

## Quick Terminal Check
Run this to see all Info.plist references in your project:
```bash
cd /Users/jxu/Code\ Public/wusutra
find . -name "*.pbxproj" -exec grep -l "Info.plist" {} \;
```

The key is: Info.plist should be automatically processed by Xcode, never manually copied.