#!/usr/bin/env python3
"""
Local WebSocket server that mimics AWS API Gateway WebSocket + Lambda behavior.
Replaces: API Gateway + connect-handler + message-handler + DynamoDB
Uses in-memory storage — no AWS required.
"""

import asyncio
import json
import time
import uuid
import websockets
from websockets.server import WebSocketServerProtocol

# In-memory "DynamoDB" tables
connections: dict[str, WebSocketServerProtocol] = {}
history: list[dict] = []

MAX_HISTORY = 20


async def broadcast(data: dict, exclude_id: str = None):
    """Send a message to all connected clients."""
    message = json.dumps(data)
    dead = []
    for cid, ws in connections.items():
        if cid == exclude_id:
            continue
        try:
            await ws.send(message)
        except Exception:
            dead.append(cid)
    for cid in dead:
        connections.pop(cid, None)


async def handle(websocket: WebSocketServerProtocol):
    connection_id = str(uuid.uuid4())[:8]
    connections[connection_id] = websocket
    print(f"[+] Connected: {connection_id} (total: {len(connections)})")

    try:
        async for raw in websocket:
            try:
                body = json.loads(raw)
            except json.JSONDecodeError:
                await websocket.send(json.dumps({"error": "Invalid JSON"}))
                continue

            action = body.get("action")
            print(f"[→] {connection_id} sent action: {action}")

            # ── get_history ──────────────────────────────────────────────────
            if action == "get_history":
                await websocket.send(json.dumps({
                    "action": "history",
                    "data": history[-MAX_HISTORY:]
                }))

            # ── manual_trigger ───────────────────────────────────────────────
            elif action == "manual_trigger":
                event = {
                    "id": str(uuid.uuid4())[:4],
                    "type": body.get("event_type", "System Update"),
                    "timestamp": time.strftime("%H:%M:%S"),
                    "unix_time": int(time.time())
                }
                history.append(event)
                # Keep only last MAX_HISTORY entries
                if len(history) > MAX_HISTORY:
                    history.pop(0)
                # Broadcast live event to ALL clients
                await broadcast(event)

            # ── clear_history ────────────────────────────────────────────────
            elif action == "clear_history":
                history.clear()
                await broadcast({"action": "ui_clear_requested"})

            else:
                await websocket.send(json.dumps({"error": f"Unknown action: {action}"}))

    except websockets.exceptions.ConnectionClosedOK:
        pass
    except websockets.exceptions.ConnectionClosedError as e:
        print(f"[!] Connection error for {connection_id}: {e}")
    finally:
        connections.pop(connection_id, None)
        print(f"[-] Disconnected: {connection_id} (total: {len(connections)})")


async def main():
    host = "0.0.0.0"
    port = 3001
    print(f"[*] WebSocket server listening on ws://{host}:{port}")
    async with websockets.serve(handle, host, port):
        await asyncio.Future()  # run forever


if __name__ == "__main__":
    asyncio.run(main())
