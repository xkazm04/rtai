import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { lintTarget } from './precommit.mjs';
import { etaLine, parseArgs, reelSecs, REEL_VIEWS } from './run.mjs';

const ok = (stdout = '') => ({ status: 0, stdout });
const gitWithDrift = (paths) => (_command, args) =>
  ok(args[0] === 'diff' && paths.length ? `${paths.join('\0')}\0` : '');

function etaSandbox(t) {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-gate-timing-break-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  return dir;
}

function putGate(dir, name, body, mtimeMs) {
  const run = join(dir, name);
  mkdirSync(run);
  const file = join(run, 'gate.json');
  writeFileSync(file, typeof body === 'string' ? body : JSON.stringify(body));
  utimesSync(file, mtimeMs / 1000, mtimeMs / 1000);
}

test('parseArgs promise: plain --reels selects the full reel gate', () => {
  const parsed = parseArgs(['--reels']);
  assert.equal(parsed.error, undefined);
  assert.equal(parsed.reels, true);
  assert.equal(parsed.reelViews, null);
});

test('parseArgs promise: partial reel views deduplicate and return in REEL_VIEWS order', () => {
  const parsed = parseArgs(['--reels=combo,top,combo,tilt70,top']);
  assert.equal(parsed.error, undefined);
  assert.equal(parsed.reels, true);
  assert.equal(parsed.reelViews, null, 'naming every view, even with duplicates, is the full gate');
  assert.deepEqual(REEL_VIEWS, ['top', 'tilt70', 'combo'], 'the public gate order is stable');
  assert.deepEqual(parseArgs(['--reels=combo,top,combo']).reelViews, ['top', 'combo']);
});

test('parseArgs promise: empty and unknown reel view spellings are rejected and named', () => {
  assert.match(parseArgs(['--reels=']).error, /--reels=/);
  assert.ok(parseArgs(['--reels=combo,,top']).error, 'an empty member is not silently collapsed');
  assert.match(parseArgs(['--reels=COMBO']).error, /COMBO/, 'the invalid view itself is named');
});

test('parseArgs promise: repeated reel options use the last occurrence', () => {
  const fullLast = parseArgs(['--reels=top', '--reels']);
  assert.equal(fullLast.reels, true);
  assert.equal(fullLast.reelViews, null, 'a trailing plain option restores the full reel gate');
  assert.deepEqual(parseArgs(['--reels', '--reels=combo']).reelViews, ['combo']);
});

test('reelSecs promise: CRLF, FAIL verdicts, and decimal seconds are retained per view', () => {
  const log = [
    'unrelated line',
    'run_reels: [1/3] top OK, 12 s; log C:\\tmp\\top.log',
    'run_reels: [2/3] tilt70 FAIL, 7.5 s; log C:\\tmp\\tilt.log',
    'run_reels: [3/3] combo OK, 0.25 s; log C:\\tmp\\combo.log',
    '',
  ].join('\r\n');
  assert.deepEqual(reelSecs(log), { top: 12, tilt70: 7.5, combo: 0.25 });
});

test('etaLine promise: a missing directory or directory without timed gates returns null', (t) => {
  const dir = etaSandbox(t);
  assert.equal(etaLine(join(dir, 'missing')), null);
  putGate(dir, 'untimed', { sha: 'abc', outcome: 'pass' }, Date.now());
  assert.equal(etaLine(dir), null);
});

test('etaLine promise: newest timed gate wins while newer damaged and untimed files are skipped', (t) => {
  const dir = etaSandbox(t);
  const now = Date.now();
  putGate(dir, 'old', { sha: '111111111111', timing: { evidence_s: 60, reels: { top: 20 } } }, now - 4000);
  putGate(dir, 'new', { sha: 'abcdef123456', timing: { evidence_s: 150, reels: { top: 12, combo: 18 } } }, now - 3000);
  putGate(dir, 'untimed', { sha: '222222222222' }, now - 2000);
  putGate(dir, 'damaged', '{ definitely not JSON', now - 1000);
  assert.equal(etaLine(dir),
    'gate: the last gate here (abcdef12) took evidence 2.5 min + reels 0.5 min (top 12 s, combo 18 s)');
});

test('etaLine promise: equal mtimes do not let a damaged gate hide a valid timed gate', (t) => {
  const dir = etaSandbox(t);
  const same = Date.now() - 1000;
  putGate(dir, 'a-damaged', 'not json', same);
  putGate(dir, 'b-valid', { sha: 'short', timing: { evidence_s: 90 } }, same);
  assert.equal(etaLine(dir), 'gate: the last gate here (short) took evidence 1.5 min, no reels');
});

test('lintTarget promise: no drift lints in place and never calls the exporter', () => {
  let exports = 0;
  const cwd = 'C:/fake/tree';
  const target = lintTarget(cwd, {
    git: gitWithDrift([]),
    exporter: () => { exports += 1; throw new Error('must not export'); },
  });
  assert.equal(exports, 0);
  assert.equal(target.dir, cwd);
  assert.equal(target.line, null);
});

test('lintTarget promise: drift uses the export and names the drift in its diagnostic', () => {
  const removed = [];
  const target = lintTarget('C:/fake/tree', {
    git: gitWithDrift(['project/a.gd', 'tools/b.mjs']),
    exporter: () => ({ dir: 'C:/fake/export', count: 7 }),
    remover: (dir) => removed.push(dir),
  });
  assert.equal(target.dir, 'C:/fake/export');
  assert.match(target.line, /project\/a\.gd, tools\/b\.mjs/);
  target.cleanup();
  assert.deepEqual(removed, ['C:/fake/export']);
});

test('lintTarget promise: one export failure is retried once and successful retry is cleaned', () => {
  let exports = 0;
  const removed = [];
  const target = lintTarget('C:/fake/tree', {
    git: gitWithDrift(['project/a.gd']),
    exporter: () => {
      exports += 1;
      if (exports === 1) throw new Error('first EBUSY');
      return { dir: 'C:/fake/retry-export', count: 3 };
    },
    remover: (dir) => removed.push(dir),
  });
  assert.equal(exports, 2, 'there is exactly one retry');
  assert.equal(target.dir, 'C:/fake/retry-export');
  assert.match(target.line, /export retried after: first EBUSY/);
  assert.deepEqual(removed, [], 'the failed attempt leaves no caller cleanup');
  target.cleanup();
  assert.deepEqual(removed, ['C:/fake/retry-export']);
});

test('lintTarget promise: two export failures lint the tree and name all unstaged drift paths', () => {
  let exports = 0;
  const removed = [];
  const target = lintTarget('C:/fake/tree', {
    git: gitWithDrift(['project/a.gd', 'tools/b.mjs']),
    exporter: () => { exports += 1; throw new Error(`failure ${exports}`); },
    remover: (dir) => removed.push(dir),
  });
  assert.equal(exports, 2);
  assert.equal(target.dir, 'C:/fake/tree');
  assert.match(target.line, /linting the WORKING TREE/);
  assert.match(target.line,
    /it reads your unstaged project\/a\.gd, tools\/b\.mjs: a failure there is not in the commit$/);
  target.cleanup();
  assert.deepEqual(removed, []);
});

test('lintTarget promise: unknown drift never exports and invents no unstaged list', () => {
  let exports = 0;
  const target = lintTarget('C:/fake/tree', {
    git: () => ({ status: 128, stdout: '' }),
    exporter: () => { exports += 1; throw new Error('must not export'); },
  });
  assert.equal(exports, 0);
  assert.equal(target.dir, 'C:/fake/tree');
  assert.match(target.line, /linting the WORKING TREE/);
  assert.doesNotMatch(target.line, /it reads your unstaged/);
});
