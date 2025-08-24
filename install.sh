#!/usr/bin/env bash

# Nova CLI Installation Script
# 
# This script installs Nova CLI globally on your system.
# Usage: ./install.sh (run from the nova-cli repository directory)

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
BIN_DIR="$HOME/.nova/bin"

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
        warn "Git not found. Some features may be limited."
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

# Download and install Nova
install_nova() {
    log "Installing Nova CLI..."
    
    # Check if we're already in the nova-cli repository
    if [ -f "codex-cli/package.json" ] && [ -f "codex-cli/bin/nova.js" ]; then
        log "Running from nova-cli repository directory"
        REPO_DIR="$(pwd)"
    else
        error "Please run this script from the nova-cli repository directory"
        error "First run: git clone https://github.com/$GITHUB_REPO.git && cd nova-cli"
        exit 1
    fi
    
    # Copy files to installation directory
    mkdir -p "$INSTALL_DIR" "$BIN_DIR"
    cp -r "$REPO_DIR/codex-cli/"* "$INSTALL_DIR/"
    
    # Make sure the binary is executable
    if [ -f "$INSTALL_DIR/bin/nova-$PLATFORM" ]; then
        chmod +x "$INSTALL_DIR/bin/nova-$PLATFORM"
    else
        # Try to build from source if binary not available
        warn "Pre-built binary not found for $PLATFORM. Building from source..."
        build_from_source
    fi
    
    # Create global symlink
    if command -v npm &> /dev/null; then
        log "Installing Nova CLI globally via npm..."
        cd "$INSTALL_DIR"
        npm install -g .
    else
        # Manual installation
        warn "npm not found. Installing manually..."
        ln -sf "$INSTALL_DIR/bin/nova.js" "$BIN_DIR/nova"
        chmod +x "$BIN_DIR/nova"
        
        # Add to PATH if not already there
        add_to_path
    fi
    
    success "Nova CLI installed successfully!"
}

# Build from source if needed
build_from_source() {
    log "Building Nova CLI from source..."
    
    # Check for Rust
    if ! command -v cargo &> /dev/null; then
        error "Rust is required to build from source."
        error "Please install Rust from https://rustup.rs/"
        exit 1
    fi
    
    cd "$REPO_DIR/codex-rs"
    cargo build --release --bin codex-tui
    
    # Copy the built binary
    local binary_name="codex-tui"
    if [ "$(uname -s)" = "Windows_NT" ]; then
        binary_name="codex-tui.exe"
    fi
    
    cp "target/release/$binary_name" "$INSTALL_DIR/bin/nova-$PLATFORM"
    chmod +x "$INSTALL_DIR/bin/nova-$PLATFORM"
    
    success "Build completed!"
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
        error "Installation verification failed. Nova command not found."
        error "Please check your PATH or restart your terminal."
        exit 1
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
}

# Run the installer
main "$@"
