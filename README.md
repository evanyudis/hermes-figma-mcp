# Figma MCP for Hermes & OpenClaw

A lightweight MCP server that connects your AI agent to Figma using a Personal Access Token (PAT). No OAuth, no browser, no desktop app required.

Works on any machine — local, VPS, headless server.

## What it does

- Read Figma file structures, components, styles, and variables
- Export frames/nodes as PNG, SVG, JPG, or PDF
- Get design tokens for design-to-code workflows
- Get comments from design files
- List team projects and files

## Quick Start

### 1. Get a Figma PAT

1. Go to [figma.com/developers/api#access-tokens](https://www.figma.com/developers/api#access-tokens)
2. Click **Generate new token**
3. Name it (e.g. "Hermes Agent"), set expiration (max 90 days)
4. Copy the token

### 2. Install

```bash
git clone https://github.com/evanyudis/hermes-figma-mcp.git
cd hermes-figma-mcp
pip install -r requirements.txt
```

### 3. Set your PAT

```bash
export FIGMA_PAT=figd_your_token_here
```

Or add to your `.env` file:
```
FIGMA_PAT=figd_your_token_here
```

### 4. Test it works

```bash
python server.py
```

The server runs on stdio (MCP protocol). It will wait for JSON-RPC input.

---

## Install for Hermes Agent

### Option A: Add as MCP server in config.yaml

Add to your `~/.hermes/config.yaml` (or profile config):

```yaml
mcp_servers:
  figma:
    command: python3
    args: ["/path/to/figma-mcp-hermes/server.py"]
    env:
      FIGMA_PAT: ${FIGMA_PAT}
```

Make sure `FIGMA_PAT` is in your `~/.hermes/.env`:
```
FIGMA_PAT=figd_your_token_here
```

### Option B: Install as a skill

```bash
cp SKILL.md ~/.hermes/skills/figma-mcp/SKILL.md
```

Then add the MCP server config as shown in Option A.

### Restart gateway

```bash
hermes gateway restart
```

The agent will now have `figma_*` tools available.

---

## Install for OpenClaw

### Option A: MCP server config

Add to your OpenClaw MCP configuration:

```json
{
  "mcpServers": {
    "figma": {
      "command": "python3",
      "args": ["/path/to/figma-mcp-hermes/server.py"],
      "env": {
        "FIGMA_PAT": "figd_your_token_here"
      }
    }
  }
}
```

### Option B: Install as a skill

Copy `SKILL.md` to your OpenClaw skills directory. Then add the MCP server config above.

---

## Available Tools

| Tool | Description |
|------|-------------|
| `figma_auth_status` | Check if PAT is valid, get user info |
| `figma_get_file` | Get file structure (use `depth` param for large files) |
| `figma_get_node` | Get a specific node by ID |
| `figma_get_components` | List published components |
| `figma_get_styles` | List styles (colors, text, effects, grids) |
| `figma_get_variables` | Get design tokens / local variables |
| `figma_export_images` | Export nodes as PNG/SVG/JPG/PDF |
| `figma_get_comments` | Get file comments |
| `figma_list_projects` | List projects in a team |
| `figma_list_files` | List files in a project |

## File Keys

Get the file key from any Figma URL:
```
https://www.figma.com/design/ABC123xyz/My-File-Name
                              ^^^^^^^^^^
                              this is the file_key
```

## PAT Expiration

Figma PATs expire after max 90 days. When your token expires, the `figma_auth_status` tool will report it. Generate a new one and update your `.env`.

## Requirements

- Python 3.10+
- `mcp` (MCP SDK)
- `httpx` (HTTP client)

## License

MIT
