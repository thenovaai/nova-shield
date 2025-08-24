#!/usr/bin/env bash

# Nova CLI One-Line Installer
# Usage: curl -sSL https://your-hosting-service.com/install-nova.sh | bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="ceobitch/nova-cli"
INSTALL_DIR="$HOME/.nova"
BIN_DIR="$HOME/.local/bin"

# Utility functions
log() {
    echo -e "${BLUE}[Nova]${NC} $1"
}

success() {
    echo -e "${GREEN}[Nova]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[Nova]${NC} $1"
}

error() {
    echo -e "${RED}[Nova]${NC} $1" >&2
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check for Node.js
    if ! command -v node &> /dev/null; then
        error "Node.js is required but not installed."
        error "Please install Node.js 20+ from https://nodejs.org/"
        exit 1
    fi
    
    # Check Node.js version
    local node_version
    node_version=$(node --version | sed 's/v//')
    local major_version
    major_version=$(echo "$node_version" | cut -d. -f1)
    
    if [ "$major_version" -lt 20 ]; then
        error "Node.js 20+ is required. Current version: $node_version"
        error "Please update Node.js from https://nodejs.org/"
        exit 1
    fi
    
    # Check for git
    if ! command -v git &> /dev/null; then
        error "Git is required for installation."
        error "Please install Git from https://git-scm.com/"
        exit 1
    fi
    
    # Check for npm
    if ! command -v npm &> /dev/null; then
        error "npm is required but not found."
        error "Please install Node.js with npm from https://nodejs.org/"
        exit 1
    fi
    
    success "Prerequisites check passed!"
}

# Detect platform
detect_platform() {
    local os
    local arch
    
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    
    case "$os" in
        darwin)
            case "$arch" in
                x86_64)
                    PLATFORM="x86_64-apple-darwin"
                    ;;
                arm64|aarch64)
                    PLATFORM="aarch64-apple-darwin"
                    ;;
                *)
                    error "Unsupported macOS architecture: $arch"
                    exit 1
                    ;;
            esac
            ;;
        linux)
            case "$arch" in
                x86_64)
                    PLATFORM="x86_64-unknown-linux-musl"
                    ;;
                aarch64|arm64)
                    PLATFORM="aarch64-unknown-linux-musl"
                    ;;
                *)
                    error "Unsupported Linux architecture: $arch"
                    exit 1
                    ;;
            esac
            ;;
        *)
            error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
    
    log "Detected platform: $PLATFORM"
}

# Install Nova CLI
install_nova() {
    log "Installing Nova CLI..."
    
    # Create temp directory
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT
    
    # Clone the repository
    log "Downloading Nova CLI from GitHub..."
    if ! git clone "https://github.com/$GITHUB_REPO.git" "$temp_dir/nova-cli" --depth 1; then
        error "Failed to clone Nova CLI repository."
        error "This might be because the repository is private."
        error "Please make sure you have access to https://github.com/$GITHUB_REPO"
        exit 1
    fi
    
    # Create installation directories
    mkdir -p "$INSTALL_DIR" "$BIN_DIR"
    
    # Copy nova-cli to install directory
    cp -r "$temp_dir/nova-cli/codex-cli/"* "$INSTALL_DIR/"
    
    # Install via npm
    log "Installing Nova CLI globally..."
    cd "$INSTALL_DIR"
    
    # Try global npm install first
    if npm install -g . 2>/dev/null; then
        success "Nova CLI installed globally via npm!"
    else
        # Fallback to local install with symlink
        warn "Global npm install failed. Installing locally..."
        npm install
        
        # Create symlink in user's local bin
        ln -sf "$INSTALL_DIR/bin/nova.js" "$BIN_DIR/nova"
        chmod +x "$BIN_DIR/nova"
        
        # Add to PATH if needed
        add_to_path
        
        success "Nova CLI installed locally!"
    fi
}

# Add Nova to PATH
add_to_path() {
    local shell_profile=""
    
    # Detect shell and profile file
    if [ -n "${ZSH_VERSION:-}" ]; then
        shell_profile="$HOME/.zshrc"
    elif [ -n "${BASH_VERSION:-}" ]; then
        if [ -f "$HOME/.bash_profile" ]; then
            shell_profile="$HOME/.bash_profile"
        else
            shell_profile="$HOME/.bashrc"
        fi
    fi
    
    if [ -n "$shell_profile" ]; then
        if ! grep -q "$BIN_DIR" "$shell_profile" 2>/dev/null; then
            echo "" >> "$shell_profile"
            echo "# Nova CLI" >> "$shell_profile"
            echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$shell_profile"
            success "Added Nova to PATH in $shell_profile"
            warn "Please restart your terminal or run: source $shell_profile"
        fi
    else
        warn "Could not detect shell profile. Please manually add $BIN_DIR to your PATH."
    fi
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Check if nova command is available
    if command -v nova &> /dev/null; then
        local version
        version=$(nova --version 2>/dev/null || echo "unknown")
        success "Nova CLI is ready! Version: $version"
        echo ""
        echo "🚀 Get started:"
        echo "   nova --help"
        echo "   nova \"explain this codebase\""
        echo ""
    else
        warn "Nova command not found in PATH."
        echo ""
        echo "📝 Manual steps to complete installation:"
        echo "   export PATH=\"\$PATH:$BIN_DIR\""
        echo "   nova --help"
        echo ""
        echo "Or restart your terminal and try again."
    fi
}

# Main installation flow
main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║           Nova CLI Installer          ║"
    echo "║      Enhanced Coding Agent            ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    
    check_prerequisites
    detect_platform
    install_nova
    verify_installation
    
    success "Installation complete! 🎉"
    echo ""
    echo "💡 If you encounter any issues, visit:"
    echo "   https://github.com/$GITHUB_REPO"
}

# Run the installer
main "$@"
