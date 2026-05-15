#!/bin/bash
# Figma MCP installer for Hermes Agent
set -e

INSTALL_DIR="${HERMES_HOME:-$HOME/.hermes}/skills/figma-mcp"
REPO="https://raw.githubusercontent.com/evanyudis/hermes-figma-mcp/main"

echo "📦 Installing Figma MCP for Hermes..."

mkdir -p "$INSTALL_DIR"
curl -sSL "$REPO/server.py" -o "$INSTALL_DIR/server.py"
curl -sSL "$REPO/SKILL.md" -o "$INSTALL_DIR/SKILL.md"
curl -sSL "$REPO/requirements.txt" -o "$INSTALL_DIR/requirements.txt"

# Install deps
pip install -q -r "$INSTALL_DIR/requirements.txt" 2>/dev/null || pip3 install -q -r "$INSTALL_DIR/requirements.txt"

# Add MCP server config if not already present
CONFIG="${HERMES_HOME:-$HOME/.hermes}/config.yaml"
if [ -f "$CONFIG" ] && ! grep -q "figma-mcp/server.py" "$CONFIG"; then
  echo ""
  echo "📝 Add this to your $CONFIG under mcp_servers:"
  echo ""
  echo "mcp_servers:"
  echo "  figma:"
  echo "    command: python3"
  echo "    args: [\"$INSTALL_DIR/server.py\"]"
  echo "    env:"
  echo "      FIGMA_PAT: \${FIGMA_PAT}"
  echo ""
fi

echo "✅ Installed to $INSTALL_DIR"
echo ""
echo "Next steps:"
echo "  1. Get a PAT from https://www.figma.com/developers/api#access-tokens"
echo "  2. Add to your .env:  echo 'FIGMA_PAT=figd_xxx' >> ~/.hermes/.env"
echo "  3. Add the mcp_servers config shown above to your config.yaml"
echo "  4. Restart: hermes gateway restart"
