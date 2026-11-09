import assert from 'node:assert/strict';
import { cpSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, sep } from 'node:path';
import test from 'node:test';
import { EXIT, ITEMS, main } from './wt_init.mjs';

const GOLDEN = 'project/data/generated/city_chunks.sha256';
const CITY = 'project/data/generated/city';
const DLL = 'project/native/bin/gtai_sim.windows.template_debug.x86_64.dll';
const FILES = {
  'project/project.godot': '[application]\n',
  [GOLDEN]: '# generated\na  0.gtch\nb  1.gtch\n',
  [DLL]: 'debug',
  'project/native/bin/gtai_sim.windows.template_release.x86_64.dll': 'release',
  [`${CITY}/0.gtch`]: 'zero',
  [`${CITY}/1.gtch`]: 'one',
  'project/.godot/global_script_class_cache.cfg': 'cache',
  'native/godot-cpp/SConstruct': 'scons',
};

function write(root, rel, bytes) {
  mkdirSync(dirname(join(root, rel)), { recursive: true });
  writeFileSync(join(root, rel), bytes);
}

function tree(t, complete = false) {
  const root = mkdtempSync(join(tmpdir(), 'wt-init-break-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  for (const rel of complete ? Object.keys(FILES) : ['project/project.godot', GOLDEN]) {
    write(root, rel, FILES[rel]);
  }
  return root;
}

// Record directories as well as bytes: a dry-run must not even create empty parents.
function snapshot(root) {
  return readdirSync(root).sort().map((name) => {
    const file = join(root, name);
    const stat = lstatSync(file);
    return [name, stat.isSymbolicLink() ? 'link' : stat.isDirectory() ? snapshot(file) : readFileSync(file).toString('hex')];
  });
}

function harness({ checkout = true, different = false } = {}) {
  const calls = [];
  const lines = [];
  const git = (cwd, ...args) => {
    calls.push([cwd, ...args]);
    if (args[0] === 'rev-parse' && args[1] === '--is-inside-work-tree') return String(checkout);
    if (args[0] === 'rev-parse') return different ? `${cwd}:${args[1]}` : args[1];
    if (args[0] === 'config') return '';
    assert.fail(`unexpected git operation: ${args.join(' ')}`);
  };
  return { git, calls, lines, out: (s) => lines.push(s), err: (s) => lines.push(s) };
}

function run(target, donor, h, flags = [], copy = cpSync) {
  return main([target, `--donor=${donor}`, ...flags], { ...h, copy });
}

test('never replaces existing destination bytes in a partly filled DLL directory', (t) => {
  const target = tree(t);
  const donor = tree(t, true);
  write(target, DLL, 'irreplaceable local build');
  const before = snapshot(target);
  // Refusal by exception or exit is fine; the promise here is preservation.
  try { run(target, donor, harness()); } catch (error) { assert.ok(error instanceof Error); }
  assert.deepEqual(snapshot(target), before);
});

test('never replaces bytes behind a junctioned destination directory', (t) => {
  const target = tree(t);
  const donor = tree(t, true);
  const outside = tree(t);
  write(outside, 'keep.dll', 'external bytes');
  mkdirSync(join(target, 'project/native'), { recursive: true });
  symlinkSync(outside, join(target, 'project/native/bin'), process.platform === 'win32' ? 'junction' : 'dir');
  const before = snapshot(outside);
  try { run(target, donor, harness()); } catch (error) { assert.ok(error instanceof Error); }
  assert.deepEqual(snapshot(outside), before);
  assert.ok(lstatSync(join(target, 'project/native/bin')).isSymbolicLink());
});

test('a non-checkout is usage with no files, copy calls, or config changes', (t) => {
  const target = tree(t, true);
  const donor = tree(t, true);
  const before = snapshot(target);
  const h = harness({ checkout: false });
  let copies = 0;
  assert.equal(run(target, donor, h, [], () => { copies += 1; }), EXIT.usage);
  assert.equal(copies, 0);
  assert.deepEqual(snapshot(target), before);
  assert.equal(h.calls.some((c) => c[1] === 'config'), false);
});

test('a donor that is a file cannot make missing prerequisites ready', (t) => {
  const target = tree(t);
  const donor = join(tree(t), 'not-a-directory');
  writeFileSync(donor, 'not a checkout');
  let copies = 0;
  const status = run(target, donor, harness(), [], () => { copies += 1; });
  assert.ok([EXIT.usage, EXIT.unverifiable].includes(status));
  assert.equal(copies, 0);
  assert.equal(readFileSync(donor, 'utf8'), 'not a checkout');
});

for (const spelling of ['trailing slash', 'parent traversal', 'case']) {
  test(`a missing prerequisite stays unverifiable when donor equals target via ${spelling}`, (t) => {
    const target = tree(t);
    const donor = spelling === 'trailing slash' ? `${target}${sep}`
      : spelling === 'parent traversal' ? `${target}${sep}project${sep}..` : target.toUpperCase();
    if (spelling === 'case' && process.platform !== 'win32') {
      t.skip('case alias requires a case-insensitive filesystem');
      return;
    }
    let copies = 0;
    assert.equal(run(target, donor, harness(), [], () => { copies += 1; }), EXIT.unverifiable);
    assert.equal(copies, 0);
  });
}

test('--dry-run writes nothing and changes no config through a junctioned target with spaces', (t) => {
  const target = tree(t);
  const donor = tree(t, true);
  const alias = join(tree(t), 'checkout alias with spaces');
  symlinkSync(target, alias, process.platform === 'win32' ? 'junction' : 'dir');
  const beforeTarget = snapshot(target);
  const beforeDonor = snapshot(donor);
  const h = harness();
  assert.equal(run(alias, donor, h, ['--dry-run'], () => assert.fail('dry-run copied')), EXIT.pass);
  assert.deepEqual(snapshot(target), beforeTarget);
  assert.deepEqual(snapshot(donor), beforeDonor);
  assert.equal(h.calls.some((c) => c[1] === 'config'), false);
});

test('a copy that leaves every required item absent is unverifiable, never ready', (t) => {
  const target = tree(t);
  const donor = tree(t, true);
  assert.ok(ITEMS.every((item) => item.has(donor) && !item.has(target)));
  let copies = 0;
  const status = run(target, donor, harness(), [], () => { copies += 1; });
  assert.equal(copies, ITEMS.length);
  assert.ok(ITEMS.every((item) => !item.has(target)));
  assert.equal(status, EXIT.unverifiable);
});

test('a donor bake short by one required chunk is unverifiable, never ready', (t) => {
  const target = tree(t, true);
  const donor = tree(t, true);
  rmSync(join(target, CITY), { recursive: true });
  rmSync(join(donor, CITY, '1.gtch'));
  assert.equal(run(target, donor, harness()), EXIT.unverifiable);
});

test('a donor bake complete for different code cannot make an incomplete target bake ready', (t) => {
  const target = tree(t, true);
  const donor = tree(t, true);
  rmSync(join(target, CITY), { recursive: true });
  write(donor, GOLDEN, 'a  0.gtch\n');
  rmSync(join(donor, CITY, '1.gtch'));
  const status = run(target, donor, harness({ different: true }));
  assert.equal(ITEMS.find((item) => item.id === 'baked city').has(target), false);
  assert.equal(status, EXIT.unverifiable);
});

test('a complete bake with CRLF golden comments and blank lines is not called missing', (t) => {
  const target = tree(t, true);
  write(target, GOLDEN, '# generated\r\n\r\na  0.gtch\r\nb  1.gtch\r\n');
  assert.equal(run(target, target, harness()), EXIT.pass);
});

test('a comments-only donor golden list cannot prove a target bake with required chunks ready', (t) => {
  const target = tree(t, true);
  const donor = tree(t, true);
  rmSync(join(target, CITY), { recursive: true });
  write(donor, GOLDEN, '# no chunk records\n# still no records\n');
  rmSync(join(donor, CITY), { recursive: true });
  mkdirSync(join(donor, CITY));
  assert.equal(run(target, donor, harness({ different: true })), EXIT.unverifiable);
});

for (const id of ['native DLLs', 'baked city']) {
  test(`a copied ${id} built from different code discloses its provenance`, (t) => {
    const target = tree(t, true);
    const donor = tree(t, true);
    const item = ITEMS.find((entry) => entry.id === id);
    rmSync(join(target, item.rel), { recursive: true });
    const h = harness({ different: true });
    assert.equal(run(target, donor, h), EXIT.pass);
    assert.ok(item.has(target));
    assert.ok(h.lines.some((line) => line.includes(id) && /different code/i.test(line)), 'copied item must be identified as built from different code');
  });
}
