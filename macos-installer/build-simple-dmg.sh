#!/usr/bin/env bash

# Simple Nova CLI macOS DMG Builder
# Creates a basic DMG installer without custom assets

set -euo pipefail

# Configuration
APP_NAME="Nova CLI"
VERSION="0.1.0"
DMG_NAME="Nova-CLI-${VERSION}"

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
DMG_DIR="$BUILD_DIR/dmg-contents"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[DMG Builder]${NC} $1"
}

success() {
    echo -e "${GREEN}[DMG Builder]${NC} $1"
}

# Clean and create build directory
prepare_build() {
    log "Preparing build environment..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$DMG_DIR"
}

# Copy Nova CLI files to DMG
copy_nova_files() {
    log "Copying Nova CLI files..."
    cp -r "$PROJECT_ROOT" "$DMG_DIR/Nova-CLI"
    
    # Remove unnecessary files
    rm -rf "$DMG_DIR/Nova-CLI/.git"
    rm -rf "$DMG_DIR/Nova-CLI/macos-installer/build"
    rm -rf "$DMG_DIR/Nova-CLI/codex-rs/target"
}

# Create installation script
create_install_script() {
    log "Creating installation script..."
    
    cat > "$DMG_DIR/Install Nova CLI.command" << 'EOF'
#!/usr/bin/env bash

# Nova CLI Installer Script
# Double-click this file to install Nova CLI

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[Nova Installer]${NC} $1"
}

success() {
    echo -e "${GREEN}[Nova Installer]${NC} $1"
}

error() {
    echo -e "${RED}[Nova Installer]${NC} $1" >&2
}

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║        Nova CLI Installer             ║"
echo "║     Enhanced Coding Agent             ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Check prerequisites
log "Checking prerequisites..."

if ! command -v node &> /dev/null; then
    error "Node.js 20+ is required but not installed."
    error "Please install Node.js from https://nodejs.org/"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

node_version=$(node --version | sed 's/v//')
major_version=$(echo "$node_version" | cut -d. -f1)

if [ "$major_version" -lt 20 ]; then
    error "Node.js 20+ is required. Current version: $node_version"
    error "Please update Node.js from https://nodejs.org/"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

success "Prerequisites check passed!"

# Install Nova CLI
log "Installing Nova CLI..."

# Get the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$SCRIPT_DIR/Nova-CLI/codex-cli" ]; then
    error "Nova CLI files not found!"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

cd "$SCRIPT_DIR/Nova-CLI/codex-cli"

if npm install -g . 2>/dev/null; then
    success "Nova CLI installed successfully!"
else
    error "Installation failed. You may need to run with sudo:"
    echo "sudo npm install -g ."
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Verify installation
if command -v nova &> /dev/null; then
    version=$(nova --version 2>/dev/null || echo "installed")
    success "Nova CLI is ready! Version: $version"
    echo ""
    echo "🚀 You can now use Nova CLI:"
    echo "   nova --help"
    echo "   nova"
    echo "   nova \"your prompt here\""
    echo ""
else
    error "Installation verification failed"
    echo ""
fi

echo "Installation complete! 🎉"
echo ""
read -p "Press Enter to close..."
EOF

    chmod +x "$DMG_DIR/Install Nova CLI.command"
}

# Create README for DMG
create_readme() {
    log "Creating README..."
    
    cat > "$DMG_DIR/README.txt" << EOF
Nova CLI - Enhanced Coding Agent
================================

Installation Instructions:
1. Double-click "Install Nova CLI.command"
2. Follow the prompts in Terminal
3. Start using: nova --help

Manual Installation:
1. Open Terminal
2. cd Nova-CLI/codex-cli
3. npm install -g .

Requirements:
- macOS 10.15 or later
- Node.js 20 or later

For more information:
https://github.com/ceobitch/nova-cli

Version: ${VERSION}
EOF
}

# Build the DMG using hdiutil (built into macOS)
build_dmg() {
    log "Building DMG using hdiutil..."
    
    # Create the DMG
    hdiutil create -volname "$APP_NAME $VERSION" \
        -srcfolder "$DMG_DIR" \
        -ov -format UDZO \
        "$BUILD_DIR/${DMG_NAME}.dmg"
    
    success "DMG created: $BUILD_DIR/${DMG_NAME}.dmg"
}

# Main build process
main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║     Nova CLI Simple DMG Builder       ║"
    echo "║      Creating macOS Installer        ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    
    prepare_build
    copy_nova_files
    create_install_script
    create_readme
    build_dmg
    
    success "DMG build complete! 🎉"
    echo ""
    echo "📦 DMG Location: $BUILD_DIR/${DMG_NAME}.dmg"
    echo ""
    echo "📝 Users can now:"
    echo "   1. Download and mount the DMG"
    echo "   2. Double-click 'Install Nova CLI.command'"
    echo "   3. Follow the installation prompts"
    echo ""
    echo "💡 The DMG contains:"
    echo "   • Install Nova CLI.command (installer script)"
    echo "   • Nova-CLI/ (complete source code)"
    echo "   • README.txt (installation instructions)"
    echo ""
}

# Run the build
main "$@"
