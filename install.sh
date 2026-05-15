#!/bin/bash
# Figma MCP installer for Hermes Agent
set -e

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
INSTALL_DIR="$HERMES_HOME/skills/figma-mcp"
CONFIG="$HERMES_HOME/config.yaml"
REPO="https://raw.githubusercontent.com/evanyudis/hermes-figma-mcp/main"

echo "📦 Installing Figma MCP for Hermes..."

# Download files
mkdir -p "$INSTALL_DIR"
curl -sSL "$REPO/server.py" -o "$INSTALL_DIR/server.py"
curl -sSL "$REPO/SKILL.md" -o "$INSTALL_DIR/SKILL.md"
curl -sSL "$REPO/requirements.txt" -o "$INSTALL_DIR/requirements.txt"

# Install deps
pip install -q -r "$INSTALL_DIR/requirements.txt" 2>/dev/null || pip3 install -q -r "$INSTALL_DIR/requirements.txt" 2>/dev/null

# Auto-inject MCP server config
if [ -f "$CONFIG" ] && ! grep -q "figma-mcp/server.py" "$CONFIG"; then
  # Check if mcp_servers key exists
  if grep -q "^mcp_servers:" "$CONFIG"; then
    # Append under existing mcp_servers
    sed -i '/^mcp_servers:/a\  figma:\n    command: python3\n    args: ["'"$INSTALL_DIR"'/server.py"]\n    env:\n      FIGMA_PAT: ${FIGMA_PAT}' "$CONFIG"
  else
    # Add mcp_servers section
    echo "" >> "$CONFIG"
    echo "mcp_servers:" >> "$CONFIG"
    echo "  figma:" >> "$CONFIG"
    echo "    command: python3" >> "$CONFIG"
    echo "    args: [\"$INSTALL_DIR/server.py\"]" >> "$CONFIG"
    echo "    env:" >> "$CONFIG"
    echo "      FIGMA_PAT: \${FIGMA_PAT}" >> "$CONFIG"
  fi
  echo "✅ Added figma MCP server to $CONFIG"
fi

echo "✅ Installed!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Now paste this message to your Hermes agent:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Connect my Figma account. Run figma_auth_status to check"
echo "  if I have a valid PAT configured, and guide me through"
echo "  setup if needed."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
