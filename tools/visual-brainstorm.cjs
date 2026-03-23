#!/usr/bin/env node

/**
 * Agent Q -- Visual Brainstorm Server
 *
 * Zero-dependency Node.js WebSocket server for visual brainstorming.
 * Serves an HTML page with mockup rendering, markdown preview, and
 * SVG diagramming -- all updated in real-time via WebSocket.
 *
 * Usage: node tools/visual-brainstorm.cjs
 *
 * Environment variables:
 *   AGENTQ_BRAINSTORM_PORT    -- port to bind (default: 3847)
 *   AGENTQ_BRAINSTORM_TIMEOUT -- idle timeout in minutes (default: 30)
 *
 * Safety:
 *   - Binds to 127.0.0.1 only (localhost)
 *   - Auto-terminates after idle timeout
 *   - Monitors parent PID -- shuts down if parent dies
 */

const http = require("http");
const crypto = require("crypto");

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const PORT = parseInt(process.env.AGENTQ_BRAINSTORM_PORT || "3847", 10);
const IDLE_TIMEOUT_MIN = parseInt(process.env.AGENTQ_BRAINSTORM_TIMEOUT || "30", 10);
const IDLE_TIMEOUT_MS = IDLE_TIMEOUT_MIN * 60 * 1000;
const PARENT_PID = process.ppid;
const PARENT_CHECK_INTERVAL_MS = 5000;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

let lastActivityTime = Date.now();
let wsClients = [];

// ---------------------------------------------------------------------------
// HTML page served to the browser
// ---------------------------------------------------------------------------

const HTML_PAGE = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agent Q -- Visual Brainstorm</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    background: #0d1117;
    color: #c9d1d9;
    height: 100vh;
    display: flex;
    flex-direction: column;
  }
  header {
    background: #161b22;
    border-bottom: 1px solid #30363d;
    padding: 12px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  header h1 { font-size: 16px; font-weight: 600; color: #58a6ff; }
  #status { font-size: 12px; color: #8b949e; }
  #status.connected { color: #3fb950; }
  #status.disconnected { color: #f85149; }
  main {
    flex: 1;
    display: flex;
    overflow: hidden;
  }
  .panel {
    flex: 1;
    overflow: auto;
    padding: 20px;
    border-right: 1px solid #30363d;
  }
  .panel:last-child { border-right: none; }
  .panel-header {
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #8b949e;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid #30363d;
  }
  #mockup-area { background: #0d1117; }
  #mockup-area svg { max-width: 100%; height: auto; }
  #markdown-area { background: #0d1117; }
  #markdown-content {
    line-height: 1.6;
    font-size: 14px;
  }
  #markdown-content h1 { font-size: 24px; font-weight: 600; margin: 16px 0 8px; color: #c9d1d9; }
  #markdown-content h2 { font-size: 20px; font-weight: 600; margin: 14px 0 6px; color: #c9d1d9; }
  #markdown-content h3 { font-size: 16px; font-weight: 600; margin: 12px 0 4px; color: #c9d1d9; }
  #markdown-content p { margin: 8px 0; }
  #markdown-content ul, #markdown-content ol { margin: 8px 0; padding-left: 24px; }
  #markdown-content li { margin: 4px 0; }
  #markdown-content code {
    background: #161b22;
    padding: 2px 6px;
    border-radius: 4px;
    font-family: "SF Mono", Consolas, monospace;
    font-size: 13px;
  }
  #markdown-content pre {
    background: #161b22;
    padding: 12px;
    border-radius: 6px;
    overflow-x: auto;
    margin: 8px 0;
  }
  #markdown-content pre code { background: none; padding: 0; }
  #markdown-content blockquote {
    border-left: 3px solid #30363d;
    padding-left: 12px;
    color: #8b949e;
    margin: 8px 0;
  }
  #markdown-content strong { color: #f0f6fc; }
  #markdown-content em { color: #c9d1d9; }
  #markdown-content hr { border: none; border-top: 1px solid #30363d; margin: 16px 0; }
  #diagram-area { background: #0d1117; }
  #diagram-area svg { max-width: 100%; height: auto; }
  .empty-state {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 200px;
    color: #484f58;
    font-size: 14px;
    font-style: italic;
  }
</style>
</head>
<body>
<header>
  <h1>Agent Q -- Visual Brainstorm</h1>
  <span id="status" class="disconnected">Disconnected</span>
</header>
<main>
  <div class="panel" id="mockup-area">
    <div class="panel-header">Mockup</div>
    <div id="mockup-content"><div class="empty-state">Waiting for mockup data...</div></div>
  </div>
  <div class="panel" id="markdown-area">
    <div class="panel-header">Markdown</div>
    <div id="markdown-content"><div class="empty-state">Waiting for markdown data...</div></div>
  </div>
  <div class="panel" id="diagram-area">
    <div class="panel-header">Diagram</div>
    <div id="diagram-content"><div class="empty-state">Waiting for diagram data...</div></div>
  </div>
</main>
<script>
(function() {
  var statusEl = document.getElementById("status");
  var mockupEl = document.getElementById("mockup-content");
  var markdownEl = document.getElementById("markdown-content");
  var diagramEl = document.getElementById("diagram-content");

  function renderMarkdown(md) {
    // Minimal markdown-to-HTML renderer (no dependencies)
    var html = md;
    // Escape HTML first
    html = html.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    // Code blocks (fenced)
    html = html.replace(/\`\`\`([\\s\\S]*?)\`\`\`/g, function(m, code) {
      return "<pre><code>" + code.trim() + "</code></pre>";
    });
    // Inline code
    html = html.replace(/\`([^\`]+)\`/g, "<code>$1</code>");
    // Headers
    html = html.replace(/^### (.+)$/gm, "<h3>$1</h3>");
    html = html.replace(/^## (.+)$/gm, "<h2>$1</h2>");
    html = html.replace(/^# (.+)$/gm, "<h1>$1</h1>");
    // Bold
    html = html.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
    // Italic
    html = html.replace(/\*([^*]+)\*/g, "<em>$1</em>");
    // Blockquote
    html = html.replace(/^&gt; (.+)$/gm, "<blockquote>$1</blockquote>");
    // Horizontal rule
    html = html.replace(/^---$/gm, "<hr>");
    // Unordered list items
    html = html.replace(/^- (.+)$/gm, "<li>$1</li>");
    html = html.replace(/(<li>.*<\\/li>\\n?)+/g, function(m) { return "<ul>" + m + "</ul>"; });
    // Paragraphs (lines not already wrapped in block elements)
    html = html.replace(/^(?!<[hupbol]|<li|<hr|<blockquote|<pre)(.+)$/gm, "<p>$1</p>");
    return html;
  }

  function connect() {
    var ws = new WebSocket("ws://" + location.host + "/ws");

    ws.onopen = function() {
      statusEl.textContent = "Connected";
      statusEl.className = "connected";
    };

    ws.onclose = function() {
      statusEl.textContent = "Disconnected";
      statusEl.className = "disconnected";
      // Reconnect after 2 seconds
      setTimeout(connect, 2000);
    };

    ws.onerror = function() {
      ws.close();
    };

    ws.onmessage = function(event) {
      try {
        var msg = JSON.parse(event.data);
        if (msg.type === "mockup") {
          mockupEl.innerHTML = msg.content;
        } else if (msg.type === "markdown") {
          markdownEl.innerHTML = renderMarkdown(msg.content);
        } else if (msg.type === "diagram") {
          diagramEl.innerHTML = msg.content;
        }
      } catch (e) {
        // Ignore malformed messages
      }
    };
  }

  connect();
})();
</script>
</body>
</html>`;

// ---------------------------------------------------------------------------
// WebSocket helpers (RFC 6455 — minimal implementation, no dependencies)
// ---------------------------------------------------------------------------

/**
 * Compute the Sec-WebSocket-Accept value for a given key.
 */
function computeAcceptKey(secKey) {
  const GUID = "258EAFA5-E914-47DA-95CA-5AB5DC85B11C";
  return crypto.createHash("sha1").update(secKey + GUID).digest("base64");
}

/**
 * Decode a WebSocket frame from a buffer.
 * Returns { opcode, payload } or null if incomplete.
 */
function decodeFrame(buffer) {
  if (buffer.length < 2) return null;

  const firstByte = buffer[0];
  const secondByte = buffer[1];
  const opcode = firstByte & 0x0f;
  const masked = (secondByte & 0x80) !== 0;
  let payloadLen = secondByte & 0x7f;
  let offset = 2;

  if (payloadLen === 126) {
    if (buffer.length < 4) return null;
    payloadLen = buffer.readUInt16BE(2);
    offset = 4;
  } else if (payloadLen === 127) {
    if (buffer.length < 10) return null;
    // For safety, only read the lower 32 bits
    payloadLen = buffer.readUInt32BE(6);
    offset = 10;
  }

  if (masked) {
    if (buffer.length < offset + 4 + payloadLen) return null;
    const maskKey = buffer.slice(offset, offset + 4);
    offset += 4;
    const payload = Buffer.alloc(payloadLen);
    for (let i = 0; i < payloadLen; i++) {
      payload[i] = buffer[offset + i] ^ maskKey[i % 4];
    }
    return { opcode, payload, totalLength: offset + payloadLen };
  }

  if (buffer.length < offset + payloadLen) return null;
  const payload = buffer.slice(offset, offset + payloadLen);
  return { opcode, payload, totalLength: offset + payloadLen };
}

/**
 * Encode a payload string into a WebSocket frame (server-to-client, unmasked).
 */
function encodeFrame(data) {
  const payload = Buffer.from(data, "utf8");
  const len = payload.length;
  let header;

  if (len < 126) {
    header = Buffer.alloc(2);
    header[0] = 0x81; // FIN + text opcode
    header[1] = len;
  } else if (len < 65536) {
    header = Buffer.alloc(4);
    header[0] = 0x81;
    header[1] = 126;
    header.writeUInt16BE(len, 2);
  } else {
    header = Buffer.alloc(10);
    header[0] = 0x81;
    header[1] = 127;
    header.writeUInt32BE(0, 2);
    header.writeUInt32BE(len, 6);
  }

  return Buffer.concat([header, payload]);
}

// ---------------------------------------------------------------------------
// HTTP + WebSocket Server
// ---------------------------------------------------------------------------

const server = http.createServer((req, res) => {
  touchActivity();

  if (req.url === "/" || req.url === "/index.html") {
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end(HTML_PAGE);
    return;
  }

  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", clients: wsClients.length }));
    return;
  }

  res.writeHead(404, { "Content-Type": "text/plain" });
  res.end("Not found");
});

server.on("upgrade", (req, socket, head) => {
  if (req.url !== "/ws") {
    socket.destroy();
    return;
  }

  const secKey = req.headers["sec-websocket-key"];
  if (!secKey) {
    socket.destroy();
    return;
  }

  const acceptKey = computeAcceptKey(secKey);
  const responseHeaders = [
    "HTTP/1.1 101 Switching Protocols",
    "Upgrade: websocket",
    "Connection: Upgrade",
    "Sec-WebSocket-Accept: " + acceptKey,
    "",
    "",
  ].join("\r\n");

  socket.write(responseHeaders);
  touchActivity();

  let recvBuffer = Buffer.alloc(0);

  const client = { socket, alive: true };
  wsClients.push(client);

  socket.on("data", (chunk) => {
    touchActivity();
    recvBuffer = Buffer.concat([recvBuffer, chunk]);

    while (true) {
      const frame = decodeFrame(recvBuffer);
      if (!frame) break;
      recvBuffer = recvBuffer.slice(frame.totalLength);

      if (frame.opcode === 0x08) {
        // Close frame
        socket.end();
        return;
      }
      if (frame.opcode === 0x09) {
        // Ping -- respond with pong
        const pong = Buffer.alloc(2);
        pong[0] = 0x8a; // FIN + pong
        pong[1] = 0;
        socket.write(pong);
        continue;
      }
      if (frame.opcode === 0x0a) {
        // Pong -- mark alive
        client.alive = true;
        continue;
      }

      // Text frame -- broadcast to all other clients and handle server-side
      if (frame.opcode === 0x01) {
        const text = frame.payload.toString("utf8");
        broadcast(text, client);
      }
    }
  });

  socket.on("close", () => {
    wsClients = wsClients.filter((c) => c !== client);
  });

  socket.on("error", () => {
    wsClients = wsClients.filter((c) => c !== client);
  });
});

/**
 * Broadcast a message to all connected WebSocket clients.
 * Optionally exclude a sender client.
 */
function broadcast(message, excludeClient) {
  const frame = encodeFrame(message);
  for (const client of wsClients) {
    if (client === excludeClient) continue;
    try {
      client.socket.write(frame);
    } catch {
      // Client disconnected, will be cleaned up
    }
  }
}

// ---------------------------------------------------------------------------
// stdin listener -- agent sends JSON messages via stdin
// ---------------------------------------------------------------------------

process.stdin.setEncoding("utf8");
let stdinBuffer = "";

process.stdin.on("data", (chunk) => {
  touchActivity();
  stdinBuffer += chunk;

  // Process complete lines
  const lines = stdinBuffer.split("\n");
  stdinBuffer = lines.pop() || ""; // Keep incomplete last line

  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;

    try {
      const msg = JSON.parse(trimmed);
      // Validate message shape
      if (msg.type && msg.content && ["mockup", "markdown", "diagram"].includes(msg.type)) {
        broadcast(JSON.stringify(msg));
      }
    } catch {
      // Ignore malformed JSON
    }
  }
});

process.stdin.on("end", () => {
  shutdown("stdin closed");
});

// ---------------------------------------------------------------------------
// Activity tracking and idle timeout
// ---------------------------------------------------------------------------

function touchActivity() {
  lastActivityTime = Date.now();
}

const idleTimer = setInterval(() => {
  if (Date.now() - lastActivityTime > IDLE_TIMEOUT_MS) {
    shutdown("idle timeout (" + IDLE_TIMEOUT_MIN + " min)");
  }
}, 60000); // Check every minute

// ---------------------------------------------------------------------------
// Parent PID monitoring -- shut down if parent process dies
// ---------------------------------------------------------------------------

const parentTimer = setInterval(() => {
  try {
    process.kill(PARENT_PID, 0); // Signal 0 = check existence
  } catch {
    shutdown("parent process (PID " + PARENT_PID + ") died");
  }
}, PARENT_CHECK_INTERVAL_MS);

// ---------------------------------------------------------------------------
// Graceful shutdown
// ---------------------------------------------------------------------------

function shutdown(reason) {
  process.stderr.write("[visual-brainstorm] Shutting down: " + reason + "\n");
  clearInterval(idleTimer);
  clearInterval(parentTimer);

  // Close all WebSocket connections
  for (const client of wsClients) {
    try {
      // Send close frame
      const closeFrame = Buffer.alloc(2);
      closeFrame[0] = 0x88; // FIN + close
      closeFrame[1] = 0;
      client.socket.write(closeFrame);
      client.socket.end();
    } catch {
      // Already closed
    }
  }
  wsClients = [];

  server.close(() => {
    process.exit(0);
  });

  // Force exit after 3 seconds if graceful close stalls
  setTimeout(() => process.exit(0), 3000).unref();
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));

// ---------------------------------------------------------------------------
// Start server
// ---------------------------------------------------------------------------

server.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    process.stderr.write(
      "[visual-brainstorm] Port " + PORT + " is already in use.\n" +
      "Set AGENTQ_BRAINSTORM_PORT to use a different port, e.g.:\n" +
      "  AGENTQ_BRAINSTORM_PORT=3848 node tools/visual-brainstorm.cjs\n"
    );
    process.exit(1);
  }
  throw err;
});

server.listen(PORT, "127.0.0.1", () => {
  process.stderr.write("[visual-brainstorm] Listening on http://127.0.0.1:" + PORT + "\n");
  process.stderr.write("[visual-brainstorm] Idle timeout: " + IDLE_TIMEOUT_MIN + " min\n");
  process.stderr.write("[visual-brainstorm] Parent PID: " + PARENT_PID + "\n");
});
