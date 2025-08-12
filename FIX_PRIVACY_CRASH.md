# Fix Privacy Crash - Microphone Permission

The app is crashing because it's trying to access the microphone without the required permission in Info.plist.

## Quick Fix:

### 1. Add Microphone Permission in Xcode
1. In Xcode, click on your **project** (blue icon at top)
2. Select the **"wusutra" target**
3. Go to the **"Info"** tab
4. Look for **"Custom iOS Target Properties"**
5. Click the **+** button to add a new row
6. For the key, type: `Privacy - Microphone Usage Description`
   - Or select from dropdown: "Privacy - Microphone Usage Description"
7. For the value, enter: `wusutra needs access to your microphone to record audio for crowdsourcing dialect speech samples.`

### 2. Clean and Run Again
1. **Product → Clean Build Folder** (Shift+Cmd+K)
2. **Run** the app again (Cmd+R)

### 3. When the App Launches
- You'll see a permission dialog asking for microphone access
- Tap "OK" to grant permission
- The app should now work without crashing

## Alternative Method:
If the above doesn't work, you can also:
1. Stop the app
2. In Simulator: Settings → Privacy & Security → Microphone → Toggle on for wusutra
3. Run the app again

## Why This Happened
The app tries to check microphone permission on launch, but without the Info.plist entry, iOS immediately crashes the app for privacy violation. This is iOS's way of enforcing privacy requirements.