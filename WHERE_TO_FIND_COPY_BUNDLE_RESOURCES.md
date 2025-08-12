# Where to Find Copy Bundle Resources

## Step-by-Step with Visual Guide:

1. **Click on your PROJECT** (the blue icon at the very top of the file navigator)
   - It's labeled "wusutra" with a blue app icon

2. **In the main editor, you'll see two items in the sidebar:**
   - PROJECT: wusutra
   - TARGETS: wusutra ← **CLICK THIS ONE**

3. **Once you click the TARGET, you'll see tabs across the top:**
   - General
   - Signing & Capabilities
   - Resource Tags
   - Info
   - **Build Settings**
   - **Build Phases** ← **CLICK THIS TAB**

4. **In Build Phases, you'll see several sections (click to expand):**
   - Target Dependencies
   - Compile Sources
   - Link Binary With Libraries
   - **Copy Bundle Resources** ← **THIS IS IT!**

5. **Click the triangle next to "Copy Bundle Resources" to expand it**

6. **Look for Info.plist in this list**
   - If it's there, select it
   - Click the minus (-) button at the bottom of that section to remove it

## Visual Path:
Project Navigator → Project (blue icon) → TARGETS: wusutra → Build Phases tab → Copy Bundle Resources section

## Can't see Build Phases tab?
- Make sure you clicked on the TARGET (not the PROJECT)
- The tabs only appear when you select the target