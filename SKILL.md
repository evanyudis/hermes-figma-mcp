---
name: Figma MCP
description: Connect to Figma via Personal Access Token. Read files, components, styles, variables, and export images from Figma designs.
version: 1.0.0
tags: [figma, design, mcp, design-system, components]
---

# Figma MCP Skill

You have access to Figma design files via MCP tools (prefixed `figma_`).

## PAT Onboarding Flow

Before using any Figma tool, ALWAYS call `figma_auth_status` first.

### If status is NOT_CONFIGURED:
Tell the user:
> To connect Figma, I need a Personal Access Token (PAT). Here's how:
> 1. Go to https://www.figma.com/developers/api#access-tokens
> 2. Click "Generate new token"
> 3. Give it a name (e.g. "Hermes Agent")
> 4. Set expiration (max 90 days)
> 5. Copy the token and paste it here

Once user provides the PAT, store it by running:
```bash
echo 'FIGMA_PAT=<token>' >> ~/.hermes/.env
```
Then tell user to restart the gateway or session for it to take effect.

### If status is EXPIRED_OR_INVALID:
Tell the user:
> Your Figma PAT has expired (they last max 90 days). Please generate a new one:
> 1. Go to https://www.figma.com/developers/api#access-tokens
> 2. Generate a new token
> 3. Paste it here

Update the token:
```bash
sed -i 's/^FIGMA_PAT=.*/FIGMA_PAT=<new_token>/' ~/.hermes/.env
```

### If status is valid:
Proceed with the user's request using the available tools.

## Available Tools

| Tool | Purpose |
|------|---------|
| `figma_auth_status` | Check PAT validity, get current user info |
| `figma_get_file` | Get file structure (document tree, pages, frames) |
| `figma_get_node` | Get a specific node by ID |
| `figma_get_components` | List published components |
| `figma_get_styles` | List published styles (colors, text, effects) |
| `figma_get_variables` | Get design tokens / variables |
| `figma_export_images` | Export nodes as PNG/SVG/JPG/PDF (returns URLs) |
| `figma_get_comments` | Get file comments |
| `figma_list_projects` | List projects in a team |
| `figma_list_files` | List files in a project |

## Getting File Keys

The file_key comes from Figma URLs:
- `figma.com/design/ABC123xyz/My-File` → file_key is `ABC123xyz`
- `figma.com/file/ABC123xyz/My-File` → file_key is `ABC123xyz`

## Tips

- Use `depth: 1` or `depth: 2` in `figma_get_file` for large files to avoid huge payloads
- Node IDs look like `1:2` or `123:456` - get them from `figma_get_file` response
- For design-to-code: get the node, extract layout/style properties, generate code
- For design tokens: use `figma_get_variables` to get colors, spacing, typography as tokens
