#!/bin/bash
# Figma MCP installer for OpenClaw
set -e

OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
INSTALL_DIR="$OPENCLAW_HOME/skills/figma-mcp"
REPO="https://raw.githubusercontent.com/evanyudis/hermes-figma-mcp/main"

echo "📦 Installing Figma MCP for OpenClaw..."

# Download files
mkdir -p "$INSTALL_DIR"
curl -sSL "$REPO/server.py" -o "$INSTALL_DIR/server.py"
curl -sSL "$REPO/SKILL.md" -o "$INSTALL_DIR/SKILL.md"
curl -sSL "$REPO/requirements.txt" -o "$INSTALL_DIR/requirements.txt"

# Install deps
pip install -q -r "$INSTALL_DIR/requirements.txt" 2>/dev/null || pip3 install -q -r "$INSTALL_DIR/requirements.txt" 2>/dev/null

# Write MCP config snippet
MCP_CONFIG="$OPENCLAW_HOME/mcp.json"
if [ ! -f "$MCP_CONFIG" ] || ! grep -q "figma" "$MCP_CONFIG" 2>/dev/null; then
  cat > "$MCP_CONFIG.figma" <<EOF
{
  "figma": {
    "command": "python3",
    "args": ["$INSTALL_DIR/server.py"],
    "env": {
      "FIGMA_PAT": "\${FIGMA_PAT}"
    }
  }
}
EOF
  echo "✅ MCP config written to $MCP_CONFIG.figma"
  echo "   Merge it into your OpenClaw MCP configuration."
fi

echo "✅ Installed!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Now paste this message to your OpenClaw agent:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Connect my Figma account. Run figma_auth_status to check"
echo "  if I have a valid PAT configured, and guide me through"
echo "  setup if needed."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
