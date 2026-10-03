#!/usr/bin/env node
// Development-only stand-in for the reactions API. Never built into dist.
//
//   npm run mock:reactions            (listens on http://localhost:8787)
//   MOCK_MODE=accept|invalid|unavailable npm run mock:reactions
//
// Switch modes while running: POST /__mode/accept, /__mode/invalid or /__mode/unavailable.
// GET /__log returns every accepted body in arrival order, numbered, so a test can prove each
// pending reaction arrived exactly once. CORS allows localhost origins only.
import http from 'node:http';
import { reactionProblems } from '../src/scripts/reaction-schema.ts';

const PORT = Number(process.env.MOCK_PORT ?? 8787);
const PATH = '/api/public/arrowspark/reactions';
const MODES = new Set(['accept', 'invalid', 'unavailable']);
let mode = MODES.has(process.env.MOCK_MODE) ? process.env.MOCK_MODE : 'accept';
const accepted = [];

const localOrigin = (origin) => typeof origin === 'string' && /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);

function send(res, status, origin, body) {
  const headers = { 'Cache-Control': 'no-store' };
  if (localOrigin(origin)) {
    headers['Access-Control-Allow-Origin'] = origin;
    headers['Access-Control-Allow-Methods'] = 'POST';
    headers['Access-Control-Allow-Headers'] = 'Content-Type';
    headers['Vary'] = 'Origin';
  }
  if (body !== undefined) headers['Content-Type'] = 'application/json';
  res.writeHead(status, headers);
  res.end(body === undefined ? undefined : JSON.stringify(body));
}

http
  .createServer((req, res) => {
    const origin = req.headers.origin;
    const url = new URL(req.url ?? '/', `http://localhost:${PORT}`);
    if (req.method === 'POST' && url.pathname.startsWith('/__mode/')) {
      const next = url.pathname.slice('/__mode/'.length);
      if (MODES.has(next)) mode = next;
      console.log(`mode: ${mode}`);
      return send(res, 200, origin, { mode });
    }
    if (req.method === 'GET' && url.pathname === '/__log') return send(res, 200, origin, { mode, accepted });
    if (url.pathname !== PATH) return send(res, 404, origin);
    if (req.method === 'OPTIONS') return send(res, 204, origin);
    if (req.method !== 'POST') return send(res, 405, origin);
    if (mode === 'unavailable') return send(res, 503, origin, { title: 'Service unavailable' });

    const chunks = [];
    let size = 0;
    req.on('data', (chunk) => {
      size += chunk.length;
      chunks.push(chunk);
    });
    req.on('end', () => {
      if (!String(req.headers['content-type'] ?? '').startsWith('application/json')) return send(res, 415, origin);
      if (size > 4096) return send(res, 413, origin);
      let body;
      try {
        body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      } catch {
        return send(res, 400, origin, { title: 'Malformed JSON' });
      }
      const problems = reactionProblems(body);
      if (mode === 'invalid' || problems.length > 0) {
        return send(res, 400, origin, { title: 'Validation failed', errors: problems.length ? problems : ['mock: invalid mode'] });
      }
      accepted.push({ n: accepted.length + 1, body });
      console.log(`accepted #${accepted.length}: ${JSON.stringify(body)}`);
      return send(res, 202, origin);
    });
  })
  .listen(PORT, () => console.log(`mock reactions API on http://localhost:${PORT}${PATH} (mode: ${mode})`));
