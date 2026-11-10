// Adversarial contract tests; no engine, asset scanner, or checkout mutation is used.
import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { readFixedFps, resolve } from './entries.mjs';
import { main } from './run.mjs';

const success = () => ({ status: 0, out: '', timedOut: false, durationMs: 1 });

async function fixture(kind, declarations, check) {
  const root = mkdtempSync(join(tmpdir(), 'gtai-devrun-break-'));
  try {
    const projectDir = join(root, 'project');
    const dev = join(projectDir, 'dev', 'nested');
    mkdirSync(dev, { recursive: true });
    writeFileSync(join(dev, 'capture.gd'),
      `extends ${kind === 'scene' ? 'Node' : 'SceneTree'}\n`
      + 'const KNOWN_FLAGS: PackedStringArray = ["--out"]\n'
      + declarations + '\n');
    if (kind === 'scene') {
      writeFileSync(join(dev, 'capture.tscn'), '[gd_scene load_steps=2 format=3]\n'
        + '[ext_resource type="Script" path="res://dev/nested/capture.gd" id="1_root"]\n'
        + '[node name="Capture" type="Node"]\nscript = ExtResource("1_root")\n');
    }
    await check({ projectDir, logDir: join(root, 'logs'),
      path: `res://dev/nested/capture.${kind === 'scene' ? 'tscn' : 'gd'}` });
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
}

function harness(f, counts = [0], importResult = success()) {
  const events = [];
  const errors = [];
  let scans = 0;
  const opts = {
    projectDir: f.projectDir, logDir: f.logDir,
    out: () => {}, err: (line) => errors.push(line),
    assets: (project) => {
      assert.equal(project, f.projectDir, 'scan only the fixture project');
      events.push('assets');
      return { count: counts[Math.min(scans++, counts.length - 1)], sample: ['res://changed.png'] };
    },
    touch: (project) => {
      assert.equal(project, f.projectDir, 'touch only the fixture project');
      events.push('touch');
    },
    runner: async (args) => {
      if (args.includes('--import')) {
        assert.deepEqual(args, ['--import'], 'import must not also launch the entry');
        events.push('import');
        return importResult;
      }
      events.push('launch');
      assert.ok(args.includes(f.path), 'launch the fixture entry');
      return success();
    },
  };
  return { events, errors, opts };
}

const actions = (h) => h.events.filter((event) => event !== 'assets');

for (const kind of ['scene', 'script']) {
  test(`${kind}: stale assets require exactly one touch then import then fresh check before launch`, async () => {
    await fixture(kind, '', async (f) => {
      // count exceeds the sample size: count, rather than sample length, is authoritative.
      const h = harness(f, [7, 0]);
      assert.equal(await main(['capture'], h.opts), 0);
      assert.deepEqual(actions(h), ['touch', 'import', 'launch']);
      assert.ok(h.events.slice(h.events.indexOf('import') + 1, h.events.indexOf('launch'))
        .includes('assets'), 'freshness must be checked after import and before launch');
    });
  });

  test(`${kind}: initially fresh assets launch without touching or importing`, async () => {
    await fixture(kind, '', async (f) => {
      const h = harness(f);
      assert.equal(await main(['capture'], h.opts), 0);
      assert.deepEqual(actions(h), ['launch']);
    });
  });

  for (const [label, result] of [
    ['nonzero status', { ...success(), status: 9 }],
    ['negative status', { ...success(), status: -1 }],
    ['null status', { ...success(), status: null }],
    ['timeout despite zero status', { ...success(), timedOut: true }],
  ]) {
    test(`${kind}: import ${label} returns 1 and never launches even if a later scan would be fresh`, async () => {
      await fixture(kind, '', async (f) => {
        const h = harness(f, [1, 0], result);
        assert.equal(await main(['capture'], h.opts), 1);
        assert.deepEqual(actions(h), ['touch', 'import']);
      });
    });
  }

  test(`${kind}: assets still stale after successful import return 3 and UNVERIFIABLE without launch`, async () => {
    await fixture(kind, '', async (f) => {
      const h = harness(f, [2, 1]);
      assert.equal(await main(['capture'], h.opts), 3);
      assert.deepEqual(actions(h), ['touch', 'import']);
      assert.match(h.errors.join('\n'), /UNVERIFIABLE/);
    });
  });

  test(`${kind}: dry-run never calls assets, touch, or runner even for an import-needing fixture`, async () => {
    await fixture(kind, 'const FIXED_FPS: int = 24', async (f) => {
      const h = harness(f, [1, 0]);
      assert.equal(await main(['capture', '--dry-run'], h.opts), 0);
      assert.deepEqual(h.events, []);
    });
  });

  test(`${kind}: a refused flag returns 2 before any asset work or launch`, async () => {
    await fixture(kind, '', async (f) => {
      const h = harness(f, [1, 0]);
      assert.equal(await main(['capture', '--not-declared'], h.opts), 2);
      assert.deepEqual(h.events, []);
    });
  });
}

test('pending import must settle before rechecking assets or launching the entry', async () => {
  await fixture('script', '', async (f) => {
    const h = harness(f, [1, 0]);
    let finishImport;
    let signalStarted;
    const started = new Promise((done) => { signalStarted = done; });
    const pendingImport = new Promise((done) => { finishImport = done; });
    const baseRunner = h.opts.runner;
    h.opts.runner = async (args, opts) => {
      const result = await baseRunner(args, opts);
      if (!args.includes('--import')) return result;
      signalStarted();
      await pendingImport;
      return result;
    };
    const running = main(['capture'], h.opts);
    try {
      await started;
      // Give an implementation that forgot to await the import a turn to proceed.
      await new Promise((done) => setImmediate(done));
      assert.deepEqual(actions(h), ['touch', 'import']);
      assert.deepEqual(h.events.slice(h.events.indexOf('import') + 1), [],
        'no freshness check or launch while import is pending');
    } finally {
      finishImport();
      await running;
    }
    assert.equal(await running, 0);
    assert.deepEqual(actions(h), ['touch', 'import', 'launch']);
  });
});

for (const [label, text, expected] of [
  ['positive literal', 'const FIXED_FPS: int = 37', '37'],
  ['one is positive', 'const FIXED_FPS: int = 1\n', '1'],
  ['trailing comment', 'const FIXED_FPS: int = 24 # 60 is not the value\n', '24'],
  ['CRLF line', 'extends Node\r\nconst FIXED_FPS: int = 48\r\n', '48'],
  ['horizontal whitespace', 'const\tFIXED_FPS :\tint\t=\t25\t# capture\n', '25'],
  ['absent declaration', 'extends Node\n', null],
  ['zero', 'const FIXED_FPS: int = 0\n', null],
  ['negative integer', 'const FIXED_FPS: int = -30\n', null],
  ['expression', 'const FIXED_FPS: int = 30 * 2\n', null],
  ['named expression', 'const FIXED_FPS: int = SimClock.TICK_RATE\n', null],
  ['float', 'const FIXED_FPS: int = 30.0\n', null],
  ['commented declaration', '# const FIXED_FPS: int = 30\n', null],
  ['tab-indented declaration', '\tconst FIXED_FPS: int = 30\n', null],
  ['space-indented declaration', ' const FIXED_FPS: int = 30\n', null],
  ['similarly named constant', 'const FIXED_FPS_EXTRA: int = 30\n', null],
  ['newline after const', 'const\n\tFIXED_FPS: int = 30\n', null],
  ['newline before colon', 'const FIXED_FPS\n: int = 30\n', null],
  ['newline after colon', 'const FIXED_FPS:\n\tint = 30\n', null],
  ['newline before equals', 'const FIXED_FPS: int\n= 30\n', null],
  ['newline before value', 'const FIXED_FPS: int =\n\t30\n', null],
]) {
  test(`readFixedFps accepts only a positive top-level single-line literal: ${label}`, () => {
    assert.equal(readFixedFps(text), expected);
  });
}

function engineOption(args, flag, expected) {
  assert.equal(args.filter((arg) => arg === flag).length, expected === null ? 0 : 1,
    `${flag} must occur ${expected === null ? 'zero times' : 'exactly once'}: ${args.join(' ')}`);
  if (expected !== null) assert.equal(args[args.indexOf(flag) + 1], expected);
}

for (const kind of ['scene', 'script']) {
  for (const both of [false, true]) {
    for (const override of [false, true]) {
      test(`${kind}: FIXED_FPS ${override ? 'is replaced once by caller' : 'sets engine FPS'} and ${both ? 'RUN_TICKS supplies quit-after' : 'alone never adds quit-after'}`, async () => {
        const declarations = 'const FIXED_FPS: int = 24 # every frame\n'
          + (both ? 'const RUN_TICKS: int = 137\n' : '');
        await fixture(kind, declarations, async (f) => {
          const r = resolve('capture', [...(override ? ['--fixed-fps=91'] : []), '--out=frames'],
            { projectDir: f.projectDir });
          assert.equal(r.ok, true, r.error);
          assert.deepEqual(r.problems, []);
          const args = r.godotArgs;
          engineOption(args, '--fixed-fps', override ? '91' : '24');
          engineOption(args, '--quit-after', both ? '137' : null);
          const fps = args.indexOf('--fixed-fps');
          const target = args.indexOf(f.path);
          assert.ok(target >= 0);
          if (kind === 'scene') assert.ok(fps + 1 < target, 'engine FPS precedes the scene');
          else {
            assert.equal(args[target - 1], '-s');
            assert.ok(fps > target, 'engine FPS follows -s <script>');
          }
          assert.ok(fps + 1 < args.indexOf('--'), 'FPS must be an engine option, not an entry flag');
          assert.deepEqual(args.slice(args.indexOf('--') + 1), ['--out=frames']);
        });
      });
    }
  }

  for (const [label, declaration] of [
    ['zero', 'const FIXED_FPS: int = 0'],
    ['negative', 'const FIXED_FPS: int = -24'],
    ['expression', 'const FIXED_FPS: int = 12 * 2'],
    ['float', 'const FIXED_FPS: int = 24.0'],
    ['comment', '# const FIXED_FPS: int = 24'],
    ['indentation', '\tconst FIXED_FPS: int = 24'],
  ]) {
    test(`${kind}: invalid FIXED_FPS ${label} must not synthesize engine FPS or quit-after`, async () => {
      await fixture(kind, declaration, async (f) => {
        const r = resolve('capture', [], { projectDir: f.projectDir });
        assert.equal(r.ok, true, r.error);
        engineOption(r.godotArgs, '--fixed-fps', null);
        engineOption(r.godotArgs, '--quit-after', null);
      });
    });
  }
}
