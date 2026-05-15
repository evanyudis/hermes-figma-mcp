#!/usr/bin/env python3
"""Figma MCP Server - PAT-based Figma access for Hermes/OpenClaw agents.

A stdio MCP server that wraps Figma's REST API using a Personal Access Token.
No OAuth, no browser, no desktop app required.
"""

import json
import os
import sys
from typing import Any

import httpx
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import TextContent, Tool

FIGMA_API = "https://api.figma.com/v1"

server = Server("figma-mcp")


def _get_pat() -> str | None:
    return os.environ.get("FIGMA_PAT") or os.environ.get("FIGMA_PERSONAL_ACCESS_TOKEN")


def _headers() -> dict[str, str]:
    pat = _get_pat()
    if not pat:
        raise ValueError("FIGMA_PAT not set")
    return {"X-Figma-Token": pat}


def _api(path: str, params: dict | None = None) -> dict[str, Any]:
    r = httpx.get(f"{FIGMA_API}{path}", headers=_headers(), params=params, timeout=30)
    r.raise_for_status()
    return r.json()


def _error(msg: str) -> list[TextContent]:
    return [TextContent(type="text", text=json.dumps({"error": msg}))]


def _ok(data: Any) -> list[TextContent]:
    return [TextContent(type="text", text=json.dumps(data, default=str))]


# --- Tools ---

@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="figma_auth_status",
            description="Check if Figma PAT is configured and valid. Returns user info or error.",
            inputSchema={"type": "object", "properties": {}, "required": []},
        ),
        Tool(
            name="figma_get_file",
            description="Get a Figma file's structure (document tree, components, styles). Use file_key from the Figma URL: figma.com/design/<file_key>/...",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_key": {"type": "string", "description": "Figma file key from URL"},
                    "depth": {"type": "integer", "description": "Max depth of node tree to return (optional, reduces payload)"},
                },
                "required": ["file_key"],
            },
        ),
        Tool(
            name="figma_get_node",
            description="Get a specific node (frame, component, etc.) from a Figma file by node ID.",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_key": {"type": "string", "description": "Figma file key"},
                    "node_id": {"type": "string", "description": "Node ID (e.g. '1:2' or '123:456')"},
                },
                "required": ["file_key", "node_id"],
            },
        ),
        Tool(
            name="figma_get_components",
            description="List all published components in a Figma file.",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_key": {"type": "string", "description": "Figma file key"},
                },
                "required": ["file_key"],
            },
        ),
        Tool(
            name="figma_get_styles",
            description="List all published styles (colors, text, effects, grids) in a Figma file.",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_key": {"type": "string", "description": "Figma file key"},
                },
                "required": ["file_key"],
            },
        ),
        Tool(
            name="figma_get_variables",
            description="Get local variables (design tokens) from a Figma file. Requires the file to have variables defined.",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_key": {"type": "string", "description": "Figma file key"},
                },
                "required": ["file_key"],
            },
        ),
        Tool(
            name="figma_export_images",
            description="Export nodes as images (PNG, SVG, JPG, PDF). Returns download URLs.",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_key": {"type": "string", "description": "Figma file key"},
                    "node_ids": {"type": "array", "items": {"type": "string"}, "description": "List of node IDs to export"},
                    "format": {"type": "string", "enum": ["png", "svg", "jpg", "pdf"], "description": "Export format (default: png)"},
                    "scale": {"type": "number", "description": "Export scale (default: 2)"},
                },
                "required": ["file_key", "node_ids"],
            },
        ),
        Tool(
            name="figma_get_comments",
            description="Get comments on a Figma file.",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_key": {"type": "string", "description": "Figma file key"},
                },
                "required": ["file_key"],
            },
        ),
        Tool(
            name="figma_list_projects",
            description="List projects in a Figma team.",
            inputSchema={
                "type": "object",
                "properties": {
                    "team_id": {"type": "string", "description": "Figma team ID"},
                },
                "required": ["team_id"],
            },
        ),
        Tool(
            name="figma_list_files",
            description="List files in a Figma project.",
            inputSchema={
                "type": "object",
                "properties": {
                    "project_id": {"type": "string", "description": "Figma project ID"},
                },
                "required": ["project_id"],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict[str, Any]) -> list[TextContent]:
    try:
        pat = _get_pat()
        if not pat and name != "figma_auth_status":
            return _error("FIGMA_PAT not configured. Ask user to provide their Figma Personal Access Token.")

        if name == "figma_auth_status":
            if not pat:
                return _error("NOT_CONFIGURED: No FIGMA_PAT found in environment. User needs to provide a Personal Access Token.")
            try:
                user = _api("/me")
                return _ok({"status": "valid", "user": user})
            except httpx.HTTPStatusError as e:
                if e.response.status_code in (401, 403):
                    return _error("EXPIRED_OR_INVALID: PAT is invalid or expired (max 90 days). User needs to generate a new one at https://www.figma.com/developers/api#access-tokens")
                raise

        elif name == "figma_get_file":
            params = {}
            if "depth" in arguments:
                params["depth"] = arguments["depth"]
            data = _api(f"/files/{arguments['file_key']}", params=params)
            return _ok(data)

        elif name == "figma_get_node":
            node_id = arguments["node_id"]
            data = _api(f"/files/{arguments['file_key']}/nodes", params={"ids": node_id})
            return _ok(data)

        elif name == "figma_get_components":
            data = _api(f"/files/{arguments['file_key']}/components")
            return _ok(data)

        elif name == "figma_get_styles":
            data = _api(f"/files/{arguments['file_key']}/styles")
            return _ok(data)

        elif name == "figma_get_variables":
            data = _api(f"/files/{arguments['file_key']}/variables/local")
            return _ok(data)

        elif name == "figma_export_images":
            fmt = arguments.get("format", "png")
            scale = arguments.get("scale", 2)
            ids = ",".join(arguments["node_ids"])
            data = _api(f"/images/{arguments['file_key']}", params={"ids": ids, "format": fmt, "scale": scale})
            return _ok(data)

        elif name == "figma_get_comments":
            data = _api(f"/files/{arguments['file_key']}/comments")
            return _ok(data)

        elif name == "figma_list_projects":
            data = _api(f"/teams/{arguments['team_id']}/projects")
            return _ok(data)

        elif name == "figma_list_files":
            data = _api(f"/projects/{arguments['project_id']}/files")
            return _ok(data)

        else:
            return _error(f"Unknown tool: {name}")

    except httpx.HTTPStatusError as e:
        return _error(f"Figma API error {e.response.status_code}: {e.response.text[:200]}")
    except ValueError as e:
        return _error(str(e))
    except Exception as e:
        return _error(f"Error: {type(e).__name__}: {e}")


async def main():
    async with stdio_server() as (read, write):
        await server.run(read, write, server.create_initialization_options())


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
