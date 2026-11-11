// node --test "tools/dev/*.test.mjs"
import assert from 'node:assert/strict';
import { mkdtempSync, readdirSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { main } from './run.mjs';

const FIX = fileURLToPath(new URL('./fixtures', import.meta.url));
const made = [];
after(() => { for (const d of made) rmSync(d, { recursive: true, force: true }); });

function harness(result = { status: 0, out: '', timedOut: false, durationMs: 5 }) {
  const calls = [];
  const lines = { out: [], err: [] };
  const logDir = mkdtempSync(join(tmpdir(), 'gtai-dev-run-'));
  made.push(logDir);
  const opts = {
    runner: async (args, o) => { calls.push({ args, o }); return result; },
    out: (l) => lines.out.push(l), err: (l) => lines.err.push(l), logDir,
    assets: () => ({ count: 0, sample: [] }), touch: () => {},
  };
  return { calls, lines, opts, logDir };
}

test('arena (no declared spec) launches; the verdict says its flags met the project literals', async () => {
  const h = harness();
  const code = await main(['arena', '--bot=pit'], h.opts);
  assert.equal(code, 0, h.lines.err.join('\n'));
  assert.equal(h.calls.length, 1);
  assert.ok(h.calls[0].args.includes('res://dev/arena/arena.tscn'));
  assert.equal(h.calls[0].o.headless, true);
  const last = h.lines.out.at(-1);
  assert.match(last, /^ok exit 0/);
  assert.match(last, /project's flag literals \(no declared spec\): 1/);
  assert.equal(readdirSync(h.logDir).length, 1);
});

test('no declared spec: a flag no literal reads is refused, nothing spawned; --any-flag launches it', async () => {
  const h = harness();
  assert.equal(await main(['arena', '--bto=pit'], h.opts), 2);
  assert.equal(h.calls.length, 0);
  const err = h.lines.err.join('\n');
  assert.match(err, /unknown flag --bto .*did you mean --bot\?/);
  assert.match(err, /--any-flag launches it unchecked/);
  const k = harness();
  assert.equal(await main(['arena', '--any-flag', '--bto=pit'], k.opts), 0, k.lines.err.join('\n'));
  assert.ok(!k.calls[0].args.includes('--any-flag'));
  assert.match(k.lines.out.at(-1), /flags unchecked: no declared spec/);
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

const staleThen = (...counts) => () => ({ count: counts.length > 1 ? counts.shift() : counts[0], sample: ['res://a.png'] });

test('a changed asset is re-imported before the run, and the run then launches', async () => {
  const h = harness();
  let touched = 0;
  const code = await main(['arena'], { ...h.opts, assets: staleThen(1, 0), touch: () => { touched += 1; } });
  assert.equal(code, 0, h.lines.err.join('\n'));
  assert.deepEqual(h.calls.map((c) => c.args[0]), ['--import', h.calls[1].args[0]]);
  assert.equal(touched, 1);
  assert.match(h.lines.err.join('\n'), /1 asset\(s\) changed since the last import \(res:\/\/a\.png\)/);
});

test('an asset still stale after --import is UNVERIFIABLE (exit 3) and nothing is launched', async () => {
  const h = harness();
  const code = await main(['arena'], { ...h.opts, assets: staleThen(1) });
  assert.equal(code, 3);
  assert.equal(h.calls.length, 1, 'only the import ran');
  assert.match(h.lines.err.join('\n'), /UNVERIFIABLE/);
});

test('a failed --import fails the run before launch', async () => {
  const h = harness({ status: 1, out: 'boom', timedOut: false, durationMs: 5 });
  const code = await main(['arena'], { ...h.opts, assets: staleThen(1, 0) });
  assert.equal(code, 1);
  assert.equal(h.calls.length, 1);
  assert.match(h.lines.err.join('\n'), /--import failed/);
});
