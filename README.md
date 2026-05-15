# Figma MCP for Hermes & OpenClaw

Connect your AI agent to Figma in 30 seconds. PAT-based, no OAuth, no browser needed.

## Install

### Paste to your agent (easiest)

Just send this message to your Hermes or OpenClaw agent:

> Install the Figma MCP skill from https://github.com/evanyudis/hermes-figma-mcp and connect my Figma account.

The agent will:
1. Download and install the skill
2. Configure the MCP server
3. Ask you for your Figma PAT
4. Validate the connection

That's it.

---

### Or use the terminal one-liner

**Hermes:**
```bash
curl -sSL https://raw.githubusercontent.com/evanyudis/hermes-figma-mcp/main/install.sh | bash
```

**OpenClaw:**
```bash
curl -sSL https://raw.githubusercontent.com/evanyudis/hermes-figma-mcp/main/install-openclaw.sh | bash
```

Then paste to your agent:
> Connect my Figma account. Run figma_auth_status and guide me through setup if needed.

---

## Get Your Figma PAT

1. Go to [figma.com/developers/api#access-tokens](https://www.figma.com/developers/api#access-tokens)
2. Click **Generate new token**
3. Name it (e.g. "Hermes Agent")
4. Set expiration (max 90 days)
5. Copy the token (starts with `figd_`)

> **Note:** PATs expire after max 90 days. The agent will tell you when it's expired and guide you to regenerate.

---

## What You Get

Once installed, your agent has these Figma tools:

| Tool | What it does |
|------|-------------|
| `figma_auth_status` | Check if PAT is valid |
| `figma_get_file` | Get file structure |
| `figma_get_node` | Get a specific frame/component |
| `figma_get_components` | List published components |
| `figma_get_styles` | List styles (colors, text, effects) |
| `figma_get_variables` | Get design tokens |
| `figma_export_images` | Export as PNG/SVG/JPG/PDF |
| `figma_get_comments` | Get file comments |
| `figma_list_projects` | List team projects |
| `figma_list_files` | List project files |

## Manual Install

If you prefer not to use the install script:

```bash
git clone https://github.com/evanyudis/hermes-figma-mcp.git ~/.hermes/skills/figma-mcp
pip install -r ~/.hermes/skills/figma-mcp/requirements.txt
```

Then add to `~/.hermes/config.yaml`:
```yaml
mcp_servers:
  figma:
    command: python3
    args: ["~/.hermes/skills/figma-mcp/server.py"]
    env:
      FIGMA_PAT: ${FIGMA_PAT}
```

## License

MIT
