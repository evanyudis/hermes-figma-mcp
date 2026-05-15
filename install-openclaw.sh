#!/bin/bash
# Figma MCP installer for OpenClaw
set -e

INSTALL_DIR="${OPENCLAW_HOME:-$HOME/.openclaw}/skills/figma-mcp"
REPO="https://raw.githubusercontent.com/evanyudis/hermes-figma-mcp/main"

echo "📦 Installing Figma MCP for OpenClaw..."

mkdir -p "$INSTALL_DIR"
curl -sSL "$REPO/server.py" -o "$INSTALL_DIR/server.py"
curl -sSL "$REPO/SKILL.md" -o "$INSTALL_DIR/SKILL.md"
curl -sSL "$REPO/requirements.txt" -o "$INSTALL_DIR/requirements.txt"

# Install deps
pip install -q -r "$INSTALL_DIR/requirements.txt" 2>/dev/null || pip3 install -q -r "$INSTALL_DIR/requirements.txt"

echo "✅ Installed to $INSTALL_DIR"
echo ""
echo "Next steps:"
echo "  1. Get a PAT from https://www.figma.com/developers/api#access-tokens"
echo "  2. Add to your MCP config:"
echo ""
echo '  {"mcpServers":{"figma":{"command":"python3","args":["'$INSTALL_DIR'/server.py"],"env":{"FIGMA_PAT":"figd_xxx"}}}}'
echo ""
echo "  3. Restart your agent"
