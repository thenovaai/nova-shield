#!/usr/bin/env bash

# Nova CLI macOS DMG Builder
# Creates a professional DMG installer for Nova CLI

set -euo pipefail

# Configuration
APP_NAME="Nova CLI"
VERSION="0.1.0"
DMG_NAME="Nova-CLI-${VERSION}"
BUNDLE_ID="com.ceobitch.nova-cli"

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
DMG_DIR="$BUILD_DIR/dmg-contents"
INSTALLER_DIR="$DMG_DIR/Nova CLI Installer.app"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[DMG Builder]${NC} $1"
}

success() {
    echo -e "${GREEN}[DMG Builder]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[DMG Builder]${NC} $1"
}

error() {
    echo -e "${RED}[DMG Builder]${NC} $1" >&2
}

# Clean and create build directory
prepare_build() {
    log "Preparing build environment..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$DMG_DIR"
    mkdir -p "$INSTALLER_DIR/Contents/MacOS"
    mkdir -p "$INSTALLER_DIR/Contents/Resources"
}

# Create the installer app bundle
create_installer_app() {
    log "Creating installer app bundle..."
    
    # Create Info.plist
    cat > "$INSTALLER_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>install-nova</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}.installer</string>
    <key>CFBundleName</key>
    <string>Nova CLI Installer</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

    # Create the installer script
    cat > "$INSTALLER_DIR/Contents/MacOS/install-nova" << 'EOF'
#!/usr/bin/env bash

set -euo pipefail

# Nova CLI macOS Installer
# This script installs Nova CLI on macOS systems

# Configuration
INSTALL_DIR="/usr/local/bin"
NOVA_DIR="$HOME/.nova"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[Nova Installer]${NC} $1"
}

success() {
    echo -e "${GREEN}[Nova Installer]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[Nova Installer]${NC} $1"
}

error() {
    echo -e "${RED}[Nova Installer]${NC} $1" >&2
}

# Show welcome dialog
show_welcome() {
    osascript << 'APPLESCRIPT'
display dialog "Welcome to Nova CLI Installer!

Nova CLI is an enhanced coding agent that runs locally on your computer.

This installer will:
• Install Nova CLI to /usr/local/bin
• Set up configuration directory
• Make Nova available system-wide

Click OK to continue or Cancel to exit." with title "Nova CLI Installer" buttons {"Cancel", "Install"} default button "Install" with icon note

if button returned of result is "Cancel" then
    error number -128
end if
APPLESCRIPT
}

# Check prerequisites
check_prerequisites() {
    log "Checking system requirements..."
    
    # Check macOS version
    local macos_version
    macos_version=$(sw_vers -productVersion)
    log "macOS version: $macos_version"
    
    # Check for Node.js
    if ! command -v node &> /dev/null; then
        osascript << 'APPLESCRIPT'
display dialog "Node.js 20+ is required but not installed.

Please install Node.js from https://nodejs.org/ and run this installer again." with title "Nova CLI Installer" buttons {"OK"} default button "OK" with icon stop
APPLESCRIPT
        exit 1
    fi
    
    # Check Node.js version
    local node_version
    node_version=$(node --version | sed 's/v//')
    local major_version
    major_version=$(echo "$node_version" | cut -d. -f1)
    
    if [ "$major_version" -lt 20 ]; then
        osascript << APPLESCRIPT
display dialog "Node.js 20+ is required. Current version: $node_version

Please update Node.js from https://nodejs.org/ and run this installer again." with title "Nova CLI Installer" buttons {"OK"} default button "OK" with icon stop
APPLESCRIPT
        exit 1
    fi
    
    success "Prerequisites check passed!"
}

# Install Nova CLI
install_nova() {
    log "Installing Nova CLI..."
    
    # Get the directory containing this installer
    local installer_dir
    installer_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    
    # Check if nova-cli directory exists in the DMG
    if [ ! -d "$installer_dir/nova-cli" ]; then
        error "Nova CLI files not found in installer package"
        exit 1
    fi
    
    # Create Nova directory
    mkdir -p "$NOVA_DIR"
    
    # Copy Nova CLI files
    cp -r "$installer_dir/nova-cli/codex-cli/"* "$NOVA_DIR/"
    
    # Install globally via npm
    cd "$NOVA_DIR"
    if npm install -g . 2>/dev/null; then
        success "Nova CLI installed successfully!"
    else
        # Fallback: create symlink manually (requires admin privileges)
        warn "Global npm install failed. Attempting manual installation..."
        
        # Request admin privileges
        osascript << 'APPLESCRIPT'
do shell script "mkdir -p /usr/local/bin" with administrator privileges
APPLESCRIPT
        
        # Create symlink
        osascript << APPLESCRIPT
do shell script "ln -sf '$NOVA_DIR/bin/nova.js' '$INSTALL_DIR/nova'" with administrator privileges
APPLESCRIPT
        
        osascript << APPLESCRIPT
do shell script "chmod +x '$INSTALL_DIR/nova'" with administrator privileges
APPLESCRIPT
        
        success "Nova CLI installed to $INSTALL_DIR/nova"
    fi
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    if command -v nova &> /dev/null; then
        local version
        version=$(nova --version 2>/dev/null || echo "installed")
        success "Nova CLI is ready! Version: $version"
        
        # Show success dialog
        osascript << APPLESCRIPT
display dialog "Nova CLI has been successfully installed!

You can now use Nova CLI from Terminal:
• nova --help (show help)
• nova (start interactive mode)
• nova \"your prompt here\"

Thank you for installing Nova CLI!" with title "Installation Complete" buttons {"Open Terminal", "Done"} default button "Done" with icon note

if button returned of result is "Open Terminal" then
    do shell script "open -a Terminal"
end if
APPLESCRIPT
    else
        error "Installation verification failed"
        osascript << 'APPLESCRIPT'
display dialog "Installation failed. Please try again or install manually using the instructions in the README file." with title "Installation Failed" buttons {"OK"} default button "OK" with icon stop
APPLESCRIPT
        exit 1
    fi
}

# Main installation process
main() {
    show_welcome
    check_prerequisites
    install_nova
    verify_installation
}

# Run installer
main "$@"
EOF

    chmod +x "$INSTALLER_DIR/Contents/MacOS/install-nova"
}

# Copy Nova CLI files to DMG
copy_nova_files() {
    log "Copying Nova CLI files..."
    cp -r "$PROJECT_ROOT" "$DMG_DIR/nova-cli"
    
    # Remove unnecessary files from the copy
    rm -rf "$DMG_DIR/nova-cli/.git"
    rm -rf "$DMG_DIR/nova-cli/macos-installer/build"
    rm -rf "$DMG_DIR/nova-cli/codex-rs/target"
}

# Create additional DMG contents
create_dmg_contents() {
    log "Creating DMG contents..."
    
    # Create README for the DMG
    cat > "$DMG_DIR/README.txt" << EOF
Nova CLI - Enhanced Coding Agent

Installation Options:

1. EASY INSTALL (Recommended):
   Double-click "Nova CLI Installer.app" and follow the prompts.

2. MANUAL INSTALL:
   Open Terminal and run:
   cd "nova-cli/codex-cli"
   npm install -g .

3. COMMAND LINE INSTALL:
   curl -sSL https://gist.githubusercontent.com/ceobitch/YOUR_GIST_ID/raw/install-nova.sh | bash

Requirements:
- macOS 10.15 or later
- Node.js 20 or later

For more information, visit:
https://github.com/ceobitch/nova-cli

Version: ${VERSION}
EOF

    # Create an alias to Applications folder (optional)
    # ln -s /Applications "$DMG_DIR/Applications"
}

# Build the DMG
build_dmg() {
    log "Building DMG..."
    
    # Check if create-dmg is available
    if ! command -v create-dmg &> /dev/null; then
        warn "create-dmg not found. Installing via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install create-dmg
        else
            error "Homebrew not found. Please install create-dmg manually:"
            error "brew install create-dmg"
            exit 1
        fi
    fi
    
    # Create the DMG
    create-dmg \
        --volname "$APP_NAME $VERSION" \
        --volicon "$SCRIPT_DIR/nova-icon.icns" \
        --window-pos 200 120 \
        --window-size 800 600 \
        --icon-size 100 \
        --icon "Nova CLI Installer.app" 200 190 \
        --hide-extension "Nova CLI Installer.app" \
        --app-drop-link 600 185 \
        --background "$SCRIPT_DIR/dmg-background.png" \
        "$BUILD_DIR/${DMG_NAME}.dmg" \
        "$DMG_DIR" || {
        
        # Fallback: use hdiutil if create-dmg fails
        warn "create-dmg failed. Using hdiutil as fallback..."
        
        hdiutil create -volname "$APP_NAME $VERSION" \
            -srcfolder "$DMG_DIR" \
            -ov -format UDZO \
            "$BUILD_DIR/${DMG_NAME}.dmg"
    }
    
    success "DMG created: $BUILD_DIR/${DMG_NAME}.dmg"
}

# Main build process
main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║        Nova CLI DMG Builder           ║"
    echo "║     Creating macOS Installer         ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    
    prepare_build
    create_installer_app
    copy_nova_files
    create_dmg_contents
    build_dmg
    
    success "DMG build complete! 🎉"
    echo ""
    echo "📦 DMG Location: $BUILD_DIR/${DMG_NAME}.dmg"
    echo "📝 Users can now:"
    echo "   1. Download and mount the DMG"
    echo "   2. Double-click 'Nova CLI Installer.app'"
    echo "   3. Follow the guided installation"
    echo ""
}

# Run the build
main "$@"
