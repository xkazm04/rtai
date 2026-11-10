import test from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import {
  existsSync, mkdirSync, mkdtempSync, rmSync, statSync, utimesSync, writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { exportChecked, FS_SLACK_MS, outPath, written } from './export_checked.mjs';
import { bakedIn, STEP_RUNNERS } from '../merge/morning.mjs';

// Every filesystem fixture is isolated, including when the assertion intentionally fails.
async function inTree(body) {
  const root = mkdtempSync(join(tmpdir(), 'gtai-proof-break-'));
  try { return await body(root); }
  finally { rmSync(root, { recursive: true, force: true }); }
}

const goodBake = () => ({ ok: true, expected: 3, missing: [], mismatched: [] });
const output = '../build/export/nested/RTAI.exe';
const hash = (bytes) => createHash('sha256').update(bytes).digest('hex');

function put(file, bytes) {
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, bytes);
}

function manifest(root, rows) {
  const generated = join(root, 'project/data/generated');
  mkdirSync(join(generated, 'city'), { recursive: true });
  put(join(generated, 'city_chunks.sha256'), `${rows.join('\n')}\n`);
  return join(generated, 'city');
}

function bakeContext(cwd, overrides = {}) {
  return {
    cwd,
    run: () => ({ status: 0, out: '', log: 'fake-bake.log' }),
    git: (args) => {
      assert.deepEqual(args, ['status', '--porcelain']);
      return { ok: true, stdout: '', out: '' };
    },
    checkBaked: goodBake,
    ...overrides,
  };
}

const advice = (result) => {
  assert.equal(result.ok, false);
  assert.ok(Array.isArray(result.advice) && result.advice.length > 0);
  return result.advice.join('\n');
};

for (const [label, value] of [
  ['undefined', undefined], ['null', null], ['false', false], ['true', true],
  ['zero', 0], ['string', 'ok'], ['NaN', NaN], ['array without ok', []],
  ['missing ok', {}], ['false ok', { ok: false }], ['numeric ok', { ok: 1 }],
  ['string ok', { ok: 'true' }], ['boxed boolean ok', { ok: new Boolean(true) }],
]) {
  test(`export requires check ok exactly true: ${label} never runs the export`, async () => {
    await inTree(async (root) => {
      let calls = 0;
      const result = await exportChecked({ root, out: output, check: async () => value,
        run: () => { calls += 1; return 0; } });
      assert.equal(calls, 0);
      assert.equal(result.ok, false);
      assert.equal(existsSync(join(root, 'build')), false);
    });
  });
}

// Review (05:3x): a test that a function carrying ok: true is refused was thrown away. The task's
// "non-object" wording overreached; the only checker (check_baked) returns a plain object, and
// `ok === true` is the guard that matters (tested above).

for (const asynchronous of [false, true]) {
  test(`export never runs after a ${asynchronous ? 'rejected' : 'throwing'} check`, async () => {
    await inTree(async (root) => {
      let calls = 0;
      const fail = () => { throw new Error('checker unavailable'); };
      const result = await exportChecked({ root, out: output,
        check: asynchronous ? async () => fail() : fail,
        run: () => { calls += 1; return 0; } });
      assert.equal(calls, 0);
      assert.equal(result.ok, false);
    });
  });
}

for (const [label, code] of [
  ['positive exit', 1], ['negative exit', -1], ['string zero', '0'], ['null', null],
  ['undefined', undefined], ['NaN', NaN], ['false', false], ['boxed zero', new Number(0)],
]) {
  test(`export requires numeric exit zero even with a fresh executable: ${label}`, async () => {
    await inTree(async (root) => {
      const result = await exportChecked({ root, out: output, check: goodBake,
        run: async () => { put(outPath(output, root), 'MZ'); return code; } });
      assert.equal(result.ok, false);
    });
  });
}

for (const asynchronous of [false, true]) {
  test(`export returns ok false when run ${asynchronous ? 'rejects' : 'throws'} after writing`, async () => {
    await inTree(async (root) => {
      const fail = () => { put(outPath(output, root), 'MZ'); throw new Error('runner failed'); };
      const result = await exportChecked({ root, out: output, check: goodBake,
        run: asynchronous ? async () => fail() : fail });
      assert.equal(result.ok, false);
    });
  });
}

for (const kind of ['missing', 'empty', 'directory', 'stale', 'wrong location', 'fresh']) {
  test(`export exit zero still checks the resolved artifact: ${kind}`, async () => {
    await inTree(async (root) => {
      const file = outPath(output, root);
      assert.equal(file, join(root, 'build/export/nested/RTAI.exe'));
      const result = await exportChecked({ root, out: output, check: goodBake, run: () => {
        assert.ok(statSync(dirname(file)).isDirectory());
        if (kind === 'directory') mkdirSync(file);
        if (kind === 'empty') writeFileSync(file, '');
        if (kind === 'fresh' || kind === 'stale') writeFileSync(file, 'MZ');
        if (kind === 'stale') utimesSync(file, 1, 1);
        if (kind === 'wrong location') put(join(root, 'RTAI.exe'), 'MZ');
        return 0;
      } });
      assert.equal(result.ok, kind === 'fresh');
      if (kind === 'missing' || kind === 'wrong location') assert.match(result.reason, /wrote no/i);
      if (kind === 'empty' || kind === 'directory') assert.match(result.reason, /empty|not a file/i);
      if (kind === 'stale') assert.match(result.reason, /did not rewrite/i);
    });
  });
}

test('export measures freshness at run invocation, after check and before run completion', async (t) => {
  await inTree(async (root) => {
    const beforeCheck = 1_700_000_000_000;
    const invocation = beforeCheck + 60_000;
    let now = beforeCheck;
    t.mock.method(Date, 'now', () => now);
    for (const stale of [true, false]) {
      now = beforeCheck;
      const result = await exportChecked({ root, out: output,
        check: async () => { now = invocation; return goodBake(); },
        run: async () => {
          const file = outPath(output, root);
          put(file, 'MZ');
          const timestamp = stale ? beforeCheck : invocation;
          utimesSync(file, timestamp / 1000, timestamp / 1000);
          now = invocation + 60_000;
          return 0;
        } });
      assert.equal(result.ok, !stale);
      if (stale) assert.match(result.reason, /did not rewrite/i);
    }
  });
});

for (const offset of [-FS_SLACK_MS - 1, -FS_SLACK_MS, -FS_SLACK_MS + 1, 0, 1000]) {
  test(`written enforces the inclusive FS_SLACK_MS boundary at offset ${offset}`, () => {
    const started = 1_700_000_000_000;
    let calls = 0;
    const result = written('injected.exe', started, (file) => {
      calls += 1;
      assert.equal(file, 'injected.exe');
      return { isFile: () => true, size: 1, mtimeMs: started + offset };
    });
    assert.equal(calls, 1);
    assert.equal(result.ok, offset >= -FS_SLACK_MS);
    if (!result.ok) assert.match(result.reason, /did not rewrite/i);
  });
}

for (const [kind, stat, reason] of [
  ['stat failure', () => { throw new Error('unreadable'); }, /wrote no/i],
  ['empty file', () => ({ isFile: () => true, size: 0, mtimeMs: 10000 }), /empty/i],
  ['non-file', () => ({ isFile: () => false, size: 512, mtimeMs: 10000 }), /not a file|empty/i],
]) {
  test(`written independently refuses ${kind} even without exportChecked`, () => {
    const result = written('injected.exe', 10000, stat);
    assert.equal(result.ok, false);
    assert.match(result.reason, reason);
  });
}

for (const [label, status] of [
  ['nonzero', 7], ['string zero', '0'], ['null', null], ['NaN', NaN], ['undefined', undefined],
]) {
  test(`bake requires status exactly zero before checking git or chunks: ${label}`, () => {
    const result = STEP_RUNNERS.bake(bakeContext('unused', {
      run: () => ({ status, log: 'fake-bake.log' }),
      git: () => assert.fail('a failed bake must stop'),
      checkBaked: () => assert.fail('a failed bake must stop'),
    }));
    assert.match(advice(result), /bake.*fail|fail.*bake/i);
  });
}

for (const dirty of [' M project/data/generated/city_chunks.sha256', '?? unexpected.bin', 'UU conflict.bin']) {
  test(`bake refuses nonempty porcelain even when chunks would pass: ${dirty}`, () => {
    const result = STEP_RUNNERS.bake(bakeContext('unused', {
      git: (args) => {
        assert.deepEqual(args, ['status', '--porcelain']);
        return { ok: true, stdout: dirty, out: dirty };
      },
      checkBaked: () => assert.fail('dirty bake must stop before chunk verification'),
    }));
    const text = advice(result);
    assert.ok(text.includes(dirty));
    assert.match(text, /chang|dirty|clean|tracked/i);
  });
}

for (const ok of [false, undefined, null, 0, 1, 'false', 'true', new Boolean(false)]) {
  test(`bake requires chunk ok exactly true, rejecting ${String(ok)} (${typeof ok})`, () => {
    const result = STEP_RUNNERS.bake(bakeContext('injected-cwd', {
      checkBaked: (cwd) => {
        assert.equal(cwd, 'injected-cwd');
        return { ok, expected: 9, missing: ['absent.bin'], mismatched: ['corrupt.bin'] };
      },
    }));
    assert.match(advice(result), /chunk|bake/i);
  });
}

for (const [missing, mismatched] of [
  [['a.bin', 'b.bin'], ['c.bin', 'd.bin', 'e.bin']],
  [[], ['c.bin', 'd.bin', 'e.bin']], [['a.bin', 'b.bin'], []],
]) {
  test(`bake chunk failure advice reports counts and a first bad chunk: ${missing.length} missing, ${mismatched.length} mismatched`, () => {
    const text = advice(STEP_RUNNERS.bake(bakeContext('unused', {
      checkBaked: () => ({ ok: false, expected: 17, missing, mismatched }),
    })));
    assert.match(text, new RegExp(`\\b${missing.length}\\s+missing\\b`, 'i'));
    assert.match(text, new RegExp(`\\b${mismatched.length}\\s+mismatched\\b`, 'i'));
    assert.match(text, /\b17\b/);
    // No ordering between the two failure categories is required.
    assert.ok([missing[0], mismatched[0]].filter(Boolean).some((name) => text.includes(name)));
  });
}

for (const kind of ['valid', 'missing manifest', 'empty manifest', 'comments only',
  'missing city', 'city is a file', 'missing chunk', 'wrong hash', 'directory chunk',
  'malformed row', 'parent traversal', 'absolute path']) {
  test(`bakedIn and default bake verify the supplied cwd tree: ${kind}`, async () => {
    await inTree(async (root) => {
      const rows = ['a.bin', 'b.bin', 'c.bin'].map((name) => `${hash(name)}  ${name}`);
      const city = manifest(root, rows);
      for (const name of ['a.bin', 'b.bin', 'c.bin']) put(join(city, name), name);
      const list = join(dirname(city), 'city_chunks.sha256');
      if (kind === 'missing manifest') rmSync(list);
      if (kind === 'empty manifest') writeFileSync(list, '');
      if (kind === 'comments only') writeFileSync(list, '# no chunks\n  \n');
      if (kind === 'missing city' || kind === 'city is a file') rmSync(city, { recursive: true });
      if (kind === 'city is a file') writeFileSync(city, 'not a directory');
      if (kind === 'missing chunk') rmSync(join(city, 'b.bin'));
      if (kind === 'wrong hash') writeFileSync(join(city, 'b.bin'), 'corrupt');
      if (kind === 'directory chunk') { rmSync(join(city, 'b.bin')); mkdirSync(join(city, 'b.bin')); }
      if (kind === 'malformed row') writeFileSync(list, [...rows, 'not a hash row'].join('\n'));
      if (kind === 'parent traversal' || kind === 'absolute path') {
        const outside = join(dirname(city), 'outside.bin');
        put(outside, 'outside');
        const path = kind === 'parent traversal' ? '../outside.bin' : outside;
        writeFileSync(list, [...rows, `${hash('outside')}  ${path}`].join('\n'));
      }
      const checked = bakedIn(root);
      assert.equal(checked.ok, kind === 'valid');
      if (kind === 'missing chunk') assert.ok(checked.missing.includes('b.bin'));
      if (kind === 'wrong hash') assert.ok(checked.mismatched.includes('b.bin'));
      const ctx = bakeContext(root);
      delete ctx.checkBaked;
      const result = STEP_RUNNERS.bake(ctx);
      assert.equal(result.ok, kind === 'valid');
      if (!result.ok) assert.match(advice(result), /chunk|bake/i);
    });
  });
}

test('bakedIn accepts comment and CRLF rows while detecting missing and mismatched chunks together', async () => {
  await inTree(async (root) => {
    const city = manifest(root, [
      '# fixture', '', `${hash('good')}  a.bin\r`,
      `${hash('missing')}  b.bin\r`, `${hash('expected')}  c.bin\r`,
    ]);
    put(join(city, 'a.bin'), 'good');
    put(join(city, 'c.bin'), 'wrong');
    const result = bakedIn(root);
    assert.equal(result.ok, false);
    assert.equal(result.expected, 3);
    assert.deepEqual(new Set(result.missing), new Set(['b.bin']));
    assert.deepEqual(new Set(result.mismatched), new Set(['c.bin']));
    const ctx = bakeContext(root);
    delete ctx.checkBaked;
    const text = advice(STEP_RUNNERS.bake(ctx));
    assert.match(text, /\b1\s+missing\b/i);
    assert.match(text, /\b1\s+mismatched\b/i);
    assert.match(text, /\b3\b/);
    assert.ok(['b.bin', 'c.bin'].some((name) => text.includes(name)));
    put(join(city, 'b.bin'), 'missing');
    put(join(city, 'c.bin'), 'expected');
    assert.equal(bakedIn(root).ok, true);
    assert.equal(STEP_RUNNERS.bake(ctx).ok, true);
  });
});
