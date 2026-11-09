// node --test "tools/dev/*.test.mjs"
import assert from 'node:assert/strict';
import { mkdtempSync, readdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { main } from './run.mjs';

const FIX = fileURLToPath(new URL('./fixtures', import.meta.url));

function harness(result = { status: 0, out: '', timedOut: false, durationMs: 5 }) {
  const calls = [];
  const lines = { out: [], err: [] };
  const logDir = mkdtempSync(join(tmpdir(), 'gtai-dev-run-'));
  const opts = {
    runner: async (args, o) => { calls.push({ args, o }); return result; },
    out: (l) => lines.out.push(l), err: (l) => lines.err.push(l), logDir,
  };
  return { calls, lines, opts, logDir };
}

test('arena (no declared spec) launches and the verdict says flags unchecked', async () => {
  const h = harness();
  const code = await main(['arena', '--bot=pit'], h.opts);
  assert.equal(code, 0, h.lines.err.join('\n'));
  assert.equal(h.calls.length, 1);
  assert.ok(h.calls[0].args.includes('res://dev/arena/arena.tscn'));
  assert.equal(h.calls[0].o.headless, true);
  const last = h.lines.out.at(-1);
  assert.match(last, /^ok exit 0/);
  assert.match(last, /flags unchecked: no declared spec/);
  assert.equal(readdirSync(h.logDir).length, 1);
});

test('a declared spec refuses --bto with exit 2 and a did-you-mean; nothing is spawned', async () => {
  const h = harness();
  const code = await main(['arena_args.gd', '--bto=pit'], { ...h.opts, projectDir: FIX });
  assert.equal(code, 2);
  assert.equal(h.calls.length, 0);
  assert.match(h.lines.err.join('\n'), /unknown flag --bto .*did you mean --bot\?/);
});

test('--windowed and --timeout are runner options, not user args', async () => {
  const h = harness();
  await main(['reel.gd', '--windowed', '--timeout=30'], { ...h.opts, projectDir: FIX });
  assert.equal(h.calls[0].o.headless, false);
  assert.equal(h.calls[0].o.timeoutMs, 30000);
  assert.ok(!h.calls[0].args.includes('--windowed'));
});

test('a failed run exits non-zero with a FAIL verdict', async () => {
  const out = 'SCRIPT ERROR: boom\n   at: f (res://reel.gd:3)\n';
  const h = harness({ status: 1, out, timedOut: false, durationMs: 1 });
  const code = await main(['reel.gd'], { ...h.opts, projectDir: FIX });
  assert.equal(code, 1);
  assert.match(h.lines.out.at(-1), /^FAIL exit 1 \(fail\); SCRIPT ERROR 1 \(first res:\/\/reel.gd:3\)/);
});

test('an unknown entry exits 2 without spawning', async () => {
  const h = harness();
  assert.equal(await main(['no_such_entry_xyz'], h.opts), 2);
  assert.equal(await main([], h.opts), 2);
  assert.equal(h.calls.length, 0);
});

test('--dry-run prints the godot args and spawns nothing', async () => {
  const h = harness();
  const code = await main(['arena', '--bot=pit', '--dry-run'], h.opts);
  assert.equal(code, 0);
  assert.equal(h.calls.length, 0);
  assert.match(h.lines.out.join('\n'), /res:\/\/dev\/arena\/arena.tscn -- --bot=pit/);
});

test('the run stops at its first SCRIPT ERROR unless --keep-going, and a stopped run reads FAIL, not "never ran"', async () => {
  const { SCRIPT_ERROR } = await import('../lib/godot.mjs');
  const h = harness({ status: -1, out: 'SCRIPT ERROR: Parse Error\n   at: (res://reel.gd:3)\n', timedOut: false,
    stopped: 'SCRIPT ERROR: Parse Error', durationMs: 2100 });
  assert.equal(await main(['reel.gd'], { ...h.opts, projectDir: FIX }), 1);
  assert.equal(h.calls[0].o.stopOn, SCRIPT_ERROR);
  assert.match(h.lines.out.at(-1), /^FAIL stopped at the first script error after 2.1 s \(--keep-going to wait it out\); SCRIPT ERROR 1/);
  await main(['reel.gd', '--keep-going'], { ...h.opts, projectDir: FIX });
  assert.equal(h.calls[1].o.stopOn, null);
  assert.ok(!h.calls[1].args.includes('--keep-going'));
});
