# Nova CLI

**Nova CLI** is an enhanced coding agent that runs locally on your computer. This is a hard fork of OpenAI's Codex CLI with additional features and improvements.

## Features

- 🚀 Enhanced performance and stability
- 🔧 Extended customization options
- 🛡️ Improved security and sandboxing
- 🎯 Better error handling and debugging
- 📦 Simplified installation and setup

## Installation

### macOS DMG Installer (Easiest for Mac users)

1. Download `Nova-CLI-0.1.0.dmg` from releases
2. Double-click to mount the DMG
3. Double-click "Install Nova CLI.command"
4. Follow the prompts

### One-Line Install (Cross-platform)

```bash
curl -sSL https://gist.githubusercontent.com/ceobitch/YOUR_GIST_ID/raw/install-nova.sh | bash
```

> **Note:** Replace `YOUR_GIST_ID` with the actual gist ID after creating the public gist

### Alternative: Manual Install

**Option 1: Simple npm install**
```bash
git clone https://github.com/ceobitch/nova-cli.git
cd nova-cli/codex-cli
npm install -g .
```

**Option 2: Using the install script**
```bash
git clone https://github.com/ceobitch/nova-cli.git
cd nova-cli
chmod +x install.sh
./install.sh
```

**Option 3: From npm package**
```bash
git clone https://github.com/ceobitch/nova-cli.git
cd nova-cli/codex-cli
npm pack
npm install -g nova-cli-0.1.0.tgz
```

### Requirements
- **Node.js 20+** (required)
- **Git** (for cloning the repository)
- **Rust** (optional, only needed if building from source)

### From Source (Development)

```bash
# Clone the repository
git clone https://github.com/ceobitch/nova-cli.git
cd nova-cli

# Build the Rust components
cd codex-rs
cargo build --release

# Install the CLI globally
cd ../codex-cli
npm install -g .
```

## Quick Start

Once installed, simply run:

```bash
nova
```

Or with a direct prompt:

```bash
nova "explain this codebase to me"
```

## Configuration

Nova CLI supports rich configuration options. By default, it loads configuration from `~/.nova/config.toml`.

## System Requirements

- **Operating Systems:** macOS 12+, Ubuntu 20.04+/Debian 10+, or Windows 11 via WSL2
- **Git:** 2.23+ (optional, recommended)
- **RAM:** 4GB minimum (8GB recommended)
- **Node.js:** 20+ (for npm installation)
- **Rust:** Latest stable (for building from source)

## What's Different from Nova CLI

This fork includes:

- Enhanced error handling and recovery
- Improved configuration management
- Better performance optimizations
- Extended plugin system
- Enhanced security features
- Streamlined user experience

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the Apache-2.0 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This project is based on OpenAI's Codex CLI. We thank the original developers for their excellent work.