#!/bin/bash
# Nova CLI Bootstrap Installer - Minimal one-liner
set -e

echo "🚀 Installing Nova CLI..."

# Check Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "❌ Node.js 20+ required. Install from https://nodejs.org/"
    exit 1
fi

# Check Git
if ! command -v git >/dev/null 2>&1; then
    echo "❌ Git required. Install from https://git-scm.com/"
    exit 1
fi

# Clone and install
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "📥 Downloading Nova CLI..."
git clone https://github.com/ceobitch/nova-cli.git "$TEMP_DIR/nova-cli" --depth 1

echo "⚙️  Installing globally..."
cd "$TEMP_DIR/nova-cli/codex-cli"
npm install -g .

echo "✅ Nova CLI installed! Try: nova --help"
