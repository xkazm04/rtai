import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { EXIT, ITEMS, main, parseArgv, plan } from './wt_init.mjs';

const GOT = {
  'project/project.godot': '',
  'project/native/bin/gtai_sim.windows.template_debug.x86_64.dll': 'd',
  'project/native/bin/gtai_sim.windows.template_release.x86_64.dll': 'r',
  'project/data/generated/city_chunks.sha256': '# DO NOT EDIT. Generated\na  0.gtch\nb  1.gtch\n',
  'project/data/generated/city/0.gtch': 'x',
  'project/data/generated/city/1.gtch': 'y',
  'project/.godot/global_script_class_cache.cfg': 'c',
  'native/godot-cpp/SConstruct': 's',
};
const FRESH = ['project/project.godot', 'project/data/generated/city_chunks.sha256'];

function tree(t, files, name = 'wt') {
  const root = mkdtempSync(join(tmpdir(), `wtinit-${name}-`));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  for (const f of files) {
    mkdirSync(dirname(join(root, f)), { recursive: true });
    writeFileSync(join(root, f), GOT[f] ?? '');
  }
  return root;
}
const allFiles = Object.keys(GOT);
function fakeGit(objects = {}, hooks = '.githooks') {
  const set = [];
  const fn = (cwd, ...args) => {
    if (args[0] === 'rev-parse' && args[1] === '--is-inside-work-tree') return 'true';
    if (args[0] === 'rev-parse') return objects[`${cwd}|${args[1]}`] ?? `same-${args[1]}`;
    if (args[0] === 'config' && args.length === 2) return hooks;
    if (args[0] === 'config') { set.push(args); return ''; }
    return null;
  };
  fn.set = set;
  return fn;
}
const logger = () => { const lines = []; return { lines, out: (s) => lines.push(s), err: (s) => lines.push(s) }; };

test('a fresh worktree gets everything it lacks from the donor, and is then ready', (t) => {
  const fresh = tree(t, FRESH);
  const donor = tree(t, allFiles, 'donor');
  const log = logger();
  assert.equal(main([fresh, `--donor=${donor}`], { ...log, git: fakeGit() }), EXIT.pass);
  for (const item of ITEMS) assert.ok(item.has(fresh), item.id);
  assert.match(log.lines.at(-1), /ready/);
});

test('a copied submodule leaves its .git behind: it names a gitdir relative to the donor and broke git add', (t) => {
  const fresh = tree(t, FRESH);
  const donor = tree(t, allFiles, 'donor');
  writeFileSync(join(donor, 'native/godot-cpp/.git'), 'gitdir: ../../.git/modules/native/godot-cpp');
  assert.equal(main([fresh, `--donor=${donor}`], { ...logger(), git: fakeGit() }), EXIT.pass);
  assert.ok(existsSync(join(fresh, 'native/godot-cpp/SConstruct')));
  assert.equal(existsSync(join(fresh, 'native/godot-cpp/.git')), false);
});

test('it never touches what is already there, and a complete tree needs no donor', (t) => {
  const complete = tree(t, allFiles);
  const donor = tree(t, allFiles, 'donor');
  writeFileSync(join(donor, 'project/.godot/global_script_class_cache.cfg'), 'other');
  const log = logger();
  assert.equal(main([complete, `--donor=${donor}`], { ...log, git: fakeGit() }), EXIT.pass);
  assert.equal(readFileSync(join(complete, 'project/.godot/global_script_class_cache.cfg'), 'utf8'), 'c');
  assert.ok(log.lines.filter((l) => l.startsWith('wt_init: ok')).length === ITEMS.length);
});

test('a partly copied dir is not treated as present: a bake short of its chunks is incomplete', (t) => {
  const part = tree(t, [...FRESH, 'project/data/generated/city/0.gtch']);
  const entries = plan(part, [], { git: fakeGit() });
  assert.equal(entries.find((e) => e.id === 'baked city').state, 'missing');
});

test('an artifact built from different code says so instead of looking current', (t) => {
  const fresh = tree(t, FRESH);
  const donor = tree(t, allFiles, 'donor');
  const git = fakeGit({ [`${fresh}|HEAD:native`]: 'a', [`${donor}|HEAD:native`]: 'b', [`${fresh}|HEAD:project/data/generated/city_chunks.sha256`]: 'same', [`${donor}|HEAD:project/data/generated/city_chunks.sha256`]: 'same' });
  const log = logger();
  assert.equal(main([fresh, `--donor=${donor}`], { ...log, git }), EXIT.pass);
  assert.ok(log.lines.some((l) => /native DLLs.*different code.*native/.test(l)));
  assert.ok(!log.lines.some((l) => /baked city.*different code/.test(l)));
});

test('nothing to copy from is unverifiable and copies nothing', (t) => {
  const fresh = tree(t, FRESH);
  const donor = tree(t, FRESH, 'donor');
  const log = logger();
  assert.equal(main([fresh, `--donor=${donor}`], { ...log, git: fakeGit() }), EXIT.unverifiable);
  assert.ok(log.lines.some((l) => /MISSING.*godot-cpp/.test(l)));
  assert.match(log.lines.at(-1), /UNVERIFIABLE/);
});

test('--dry-run copies nothing and changes no git config', (t) => {
  const fresh = tree(t, FRESH);
  const donor = tree(t, allFiles, 'donor');
  const git = fakeGit({}, '');
  const log = logger();
  assert.equal(main([fresh, `--donor=${donor}`, '--dry-run'], { ...log, git }), EXIT.pass);
  assert.equal(existsSync(join(fresh, 'project/.godot')), false);
  assert.deepEqual(git.set, []);
  assert.ok(log.lines.some((l) => /would copy/.test(l)));
});

test('the hooks path is set when missing', (t) => {
  const complete = tree(t, allFiles);
  const git = fakeGit({}, '');
  assert.equal(main([complete, `--donor=${complete}`], { ...logger(), git }), EXIT.pass);
  assert.deepEqual(git.set, [['config', 'core.hooksPath', '.githooks']]);
});

test('bad input is usage and nothing runs: not a checkout, a donor that is gone, an unknown flag', (t) => {
  const notGame = tree(t, []);
  const fresh = tree(t, FRESH);
  assert.equal(main([notGame], { ...logger(), git: fakeGit() }), EXIT.usage);
  assert.equal(main([fresh, '--donor=C:/no/such/tree'], { ...logger(), git: fakeGit() }), EXIT.usage);
  assert.ok(parseArgv(['--bogus']).error);
  assert.ok(parseArgv(['a', 'b']).error);
  assert.ok(parseArgv(['--dry-run=1']).error);
});
