# Nova CLI macOS DMG Installer

This directory contains tools to create a professional macOS DMG installer for Nova CLI.

## Quick Build

```bash
cd macos-installer
./build-simple-dmg.sh
```

This creates: `build/Nova-CLI-0.1.0.dmg`

## What's in the DMG

When users download and mount the DMG, they'll see:

1. **Install Nova CLI.command** - Double-click installer script
2. **Nova-CLI/** - Complete source code 
3. **README.txt** - Installation instructions

## User Experience

1. **Download** the DMG file
2. **Double-click** to mount it
3. **Double-click** "Install Nova CLI.command"
4. **Follow prompts** in Terminal
5. **Start using:** `nova --help`

## Advanced Build (with custom assets)

For a more professional DMG with custom background and icon:

1. Install create-dmg: `brew install create-dmg`
2. Create custom assets:
   - `dmg-background.png` (800x600)
   - `nova-icon.icns` (1024x1024 icon converted to .icns)
3. Run: `./build-dmg.sh`

## Distribution

The generated DMG can be:
- Uploaded to GitHub Releases
- Hosted on your website
- Distributed via email/Slack
- Notarized for macOS Gatekeeper (optional)

## Benefits of DMG Distribution

✅ **Familiar** - Mac users know how to use DMG files
✅ **Professional** - Looks like commercial software
✅ **Self-contained** - Includes everything needed
✅ **Easy** - Double-click installation
✅ **Offline** - Works without internet after download
✅ **Trusted** - Can be code-signed and notarized

## File Sizes

- DMG file: ~16MB (includes complete Nova CLI source)
- Installation: ~50MB (after npm install)

## Requirements

- macOS 10.15 or later
- Node.js 20 or later
- npm (included with Node.js)
