#!/usr/bin/env bash

# Nova CLI Universal Launcher
# Double-click this file to install or run Nova CLI
# Compatible with macOS, Linux, and Windows (Git Bash/WSL)

set -euo pipefail

# Colors for cross-platform compatibility
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    NC=''
fi

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

info() {
    echo -e "${CYAN}[Nova]${NC} $1"
}

# Show Nova ASCII art
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    _   ______ _    _____         _____ __  ______________    ____ 
   / | / / __ \ |  / /   |       / ___// / / / ____/ ____/   / __ \
  /  |/ / / / / | / / /| |       \__ \/ / / / __/ / __/     / / / /
 / /|  / /_/ /| |/ / ___ |      ___/ / /_/ / /___/ /___    / /_/ / 
/_/ |_/\____/ |___/_/  |_|     /____/\____/_____/_____/   /_____/  
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Enhanced Coding Agent - Your AI Programming Assistant${NC}"
    echo ""
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macOS"
            PLATFORM="darwin"
            ;;
        Linux*)
            OS="Linux"
            PLATFORM="linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS="Windows"
            PLATFORM="windows"
            ;;
        *)
            OS="Unknown"
            PLATFORM="unknown"
            ;;
    esac
    
    info "Detected: $OS"
}

# Check if Nova is already installed
check_nova_installed() {
    if command -v nova &> /dev/null; then
        NOVA_VERSION=$(nova --version 2>/dev/null | head -n1 || echo "unknown")
        return 0
    else
        return 1
    fi
}

# Check prerequisites
check_prerequisites() {
    log "Checking system requirements..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        error "Node.js 20+ is required but not installed."
        echo ""
        echo "📥 Please install Node.js from: https://nodejs.org/"
        echo ""
        case "$PLATFORM" in
            "darwin")
                echo "💡 On macOS: brew install node"
                ;;
            "linux")
                echo "💡 On Ubuntu/Debian: sudo apt install nodejs npm"
                echo "💡 On CentOS/RHEL: sudo yum install nodejs npm"
                ;;
            "windows")
                echo "💡 On Windows: Download from nodejs.org or use chocolatey"
                ;;
        esac
        echo ""
        read -p "Press Enter to exit..."
        exit 1
    fi
    
    # Check Node.js version
    local node_version
    node_version=$(node --version | sed 's/v//')
    local major_version
    major_version=$(echo "$node_version" | cut -d. -f1)
    
    if [ "$major_version" -lt 20 ]; then
        error "Node.js 20+ is required. Current version: v$node_version"
        echo ""
        echo "📥 Please update Node.js from: https://nodejs.org/"
        echo ""
        read -p "Press Enter to exit..."
        exit 1
    fi
    
    success "Node.js v$node_version ✓"
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        error "npm is required but not found."
        echo ""
        read -p "Press Enter to exit..."
        exit 1
    fi
    
    success "npm $(npm --version) ✓"
    
    # Check git
    if ! command -v git &> /dev/null; then
        warn "Git not found - some features may be limited"
    else
        success "Git $(git --version | cut -d' ' -f3) ✓"
    fi
}

# Install Nova CLI
install_nova() {
    log "Installing Nova CLI..."
    echo ""
    
    # Get script directory
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Check if we have the codex-cli directory
    if [ -d "$script_dir/codex-cli" ]; then
        info "Installing from local files..."
        cd "$script_dir/codex-cli"
        
        if npm install -g . 2>/dev/null; then
            success "Nova CLI installed successfully! 🎉"
        else
            warn "Global install failed. Trying with sudo..."
            if sudo npm install -g . 2>/dev/null; then
                success "Nova CLI installed successfully with sudo! 🎉"
            else
                error "Installation failed. Please try manual installation:"
                echo "cd codex-cli && npm install -g ."
                echo ""
                read -p "Press Enter to exit..."
                exit 1
            fi
        fi
    else
        info "Downloading Nova CLI from GitHub..."
        
        # Create temp directory
        local temp_dir
        temp_dir=$(mktemp -d)
        trap "rm -rf $temp_dir" EXIT
        
        # Clone repository
        if git clone https://github.com/ceobitch/nova-cli.git "$temp_dir/nova-cli" --depth 1; then
            cd "$temp_dir/nova-cli/codex-cli"
            
            if npm install -g . 2>/dev/null; then
                success "Nova CLI installed successfully! 🎉"
            else
                warn "Global install failed. Trying with sudo..."
                if sudo npm install -g . 2>/dev/null; then
                    success "Nova CLI installed successfully with sudo! 🎉"
                else
                    error "Installation failed."
                    echo ""
                    read -p "Press Enter to exit..."
                    exit 1
                fi
            fi
        else
            error "Failed to download Nova CLI from GitHub."
            error "Please check your internet connection and try again."
            echo ""
            read -p "Press Enter to exit..."
            exit 1
        fi
    fi
    
    echo ""
    success "Installation complete!"
}

# Run Nova CLI
run_nova() {
    echo ""
    info "Starting Nova CLI..."
    echo ""
    echo "🚀 Nova CLI is ready! Here are some commands to try:"
    echo ""
    echo "  nova --help                    # Show all options"
    echo "  nova                          # Start interactive mode"
    echo "  nova \"explain this code\"      # Direct prompt"
    echo "  nova \"write a Python script\" # Generate code"
    echo ""
    
    # Ask user what they want to do
    echo "What would you like to do?"
    echo ""
    echo "1) Start interactive Nova session"
    echo "2) Show Nova help"
    echo "3) Run custom prompt"
    echo "4) Exit"
    echo ""
    
    while true; do
        read -p "Choose an option (1-4): " choice
        case $choice in
            1)
                echo ""
                info "Starting Nova in interactive mode..."
                echo ""
                nova
                break
                ;;
            2)
                echo ""
                nova --help
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                echo ""
                read -p "Enter your prompt: " user_prompt
                if [ -n "$user_prompt" ]; then
                    echo ""
                    nova "$user_prompt"
                else
                    warn "No prompt entered."
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                echo ""
                success "Thanks for using Nova CLI! 👋"
                break
                ;;
            *)
                warn "Invalid option. Please choose 1-4."
                ;;
        esac
    done
}

# Main menu for installed Nova
show_main_menu() {
    while true; do
        clear
        show_banner
        success "Nova CLI is installed! Version: $NOVA_VERSION"
        echo ""
        echo "🎯 What would you like to do?"
        echo ""
        echo "1) Run Nova CLI"
        echo "2) Update Nova CLI"
        echo "3) Uninstall Nova CLI"
        echo "4) Show system info"
        echo "5) Exit"
        echo ""
        
        read -p "Choose an option (1-5): " choice
        case $choice in
            1)
                run_nova
                ;;
            2)
                echo ""
                log "Updating Nova CLI..."
                install_nova
                NOVA_VERSION=$(nova --version 2>/dev/null | head -n1 || echo "unknown")
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                echo ""
                warn "Uninstalling Nova CLI..."
                if npm uninstall -g nova-cli 2>/dev/null || sudo npm uninstall -g nova-cli 2>/dev/null; then
                    success "Nova CLI uninstalled successfully."
                else
                    error "Failed to uninstall. You may need to remove manually."
                fi
                echo ""
                read -p "Press Enter to exit..."
                exit 0
                ;;
            4)
                echo ""
                info "System Information:"
                echo "OS: $OS"
                echo "Node.js: $(node --version)"
                echo "npm: $(npm --version)"
                echo "Nova: $NOVA_VERSION"
                if command -v git &> /dev/null; then
                    echo "Git: $(git --version | cut -d' ' -f3)"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                echo ""
                success "Thanks for using Nova CLI! 👋"
                exit 0
                ;;
            *)
                warn "Invalid option. Please choose 1-5."
                sleep 1
                ;;
        esac
    done
}

# Main execution
main() {
    # Clear screen for better presentation
    clear
    
    show_banner
    detect_os
    
    echo ""
    
    # Check if Nova is already installed
    if check_nova_installed; then
        show_main_menu
    else
        log "Nova CLI is not installed. Let's install it!"
        echo ""
        
        check_prerequisites
        echo ""
        
        read -p "Press Enter to install Nova CLI..."
        echo ""
        
        install_nova
        
        # Verify installation
        if check_nova_installed; then
            echo ""
            success "🎉 Nova CLI is now ready to use!"
            echo ""
            read -p "Press Enter to start using Nova..."
            show_main_menu
        else
            error "Installation verification failed."
            echo ""
            read -p "Press Enter to exit..."
            exit 1
        fi
    fi
}

# Handle script being double-clicked vs run from terminal
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Script is being executed directly (double-clicked)
    main "$@"
    
    # Keep window open on exit
    echo ""
    read -p "Press Enter to close..."
fi
