import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { decide, main, stagedPaths } from './precommit.mjs';
import { isInert } from '../evidence/scope.mjs';
import { withoutGitEnv } from '../lint/lint.mjs';
import { judge, parseArgv, plan } from '../film/film.mjs';
import { checkVictim, godotArgs, parseShot, victimKinds, victimSaid } from '../film/shots.mjs';

function temporary(t, prefix) {
  const dir = mkdtempSync(join(tmpdir(), prefix));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  return dir;
}

function put(dir, path, text = 'content\n') {
  const file = join(dir, path);
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, text);
}

function front(result, lintResult = { status: 29 }) {
  let calls = 0;
  const code = main({
    git: () => result,
    lint: () => { calls += 1; return lintResult; },
    err: () => {},
  });
  return { code, calls };
}

const inert = ['docs/day/note.md', 'evidence/frame.png', 'JOURNAL.md', 'REPORT.md', 'ASSETS-REPLIES.md'];
const active = [
  'AGENTS.md', 'project/README.md', 'project/a.gd.uid', 'docs_extra/a.md', 'docs.md',
  'evidence_extra/a.png', 'tools/JOURNAL.md', 'project/REPORT.md', 'tools/ASSETS-REPLIES.md',
  'docs\\note.md', 'evidence\\frame.png', 'tools/space name.mjs', 'tools/line\nbreak.mjs',
  'tools/žluťoučký.mjs', '"docs/note.md"', '"JOURNAL.md"', 'Docs/note.md', 'journal.md',
];

test('precommit skips lint only for a nonempty list entirely inert by isInert', () => {
  for (const paths of [inert, ...inert.map((p) => [p])]) {
    assert.ok(paths.every(isInert));
    assert.equal(decide(paths).skip, true);
    assert.deepEqual(front({ status: 0, stdout: `${paths.join('\0')}\0` }), { code: 0, calls: 0 });
  }
  assert.equal(decide([]).skip, false);
});

for (const path of active) {
  test(`precommit must run lint for active path ${JSON.stringify(path)} even beside inert paths`, () => {
    assert.equal(isInert(path), false);
    for (const paths of [[path], [...inert, path], [path, ...inert]]) {
      assert.equal(decide(paths).skip, false);
      assert.deepEqual(front({ status: 0, stdout: `${paths.join('\0')}\0` }), { code: 29, calls: 1 });
    }
  });
}

for (const [name, result] of [
  ['empty successful output', { status: 0, stdout: '' }],
  ['NUL-only output', { status: 0, stdout: '\0' }],
  ['git failure with inert-looking output', { status: 128, stdout: 'docs/note.md\0' }],
  ['git killed by signal', { status: null, signal: 'SIGTERM', stdout: 'JOURNAL.md\0' }],
  ['git spawn error', { status: null, error: new Error('spawn failed') }],
  ['git missing stdout', { status: 0 }],
]) {
  test(`precommit must run lint when git supplies ${name}`, () => {
    assert.deepEqual(front(result), { code: 29, calls: 1 });
  });
}

test('stagedPaths requests cached name-only no-renames NUL output and preserves every path byte', () => {
  const paths = ['docs/note with spaces.md', 'tools/line\nbreak.mjs', 'tools/é.mjs', '"docs/x"', 'docs\\x'];
  const cwd = join(tmpdir(), 'unused-break-cwd');
  const actual = stagedPaths(cwd, (command, args, options) => {
    assert.equal(command, 'git');
    assert.deepEqual(args, ['diff', '--cached', '--name-only', '--no-renames', '-z']);
    assert.equal(options.cwd, cwd);
    assert.equal(options.encoding, 'utf8');
    return { status: 0, stdout: `${paths.join('\0')}\0` };
  });
  assert.deepEqual(actual, paths);
});

test('main returns every lint exit code and returns one for a lint terminated by signal', () => {
  for (const status of [0, 1, 2, 17, 255]) {
    assert.deepEqual(front({ status: 0, stdout: 'tools/x.mjs\0' }, { status }), { code: status, calls: 1 });
  }
  assert.deepEqual(front({ status: 0, stdout: 'tools/x.mjs\0' }, { status: null, signal: 'SIGKILL' }), { code: 1, calls: 1 });
});

// All real git calls use -C and a scrubbed env; stagedPaths' injected adapter also enforces this.
function repository(t) {
  const dir = temporary(t, 'gtai-break-git-');
  const env = withoutGitEnv();
  const run = (args, index) => {
    const result = spawnSync('git', ['-C', dir, ...args], {
      encoding: 'utf8', windowsHide: true,
      env: index ? { ...env, GIT_INDEX_FILE: index } : env,
    });
    assert.equal(result.status, 0, result.stderr || String(result.error));
    return result;
  };
  run(['init', '-q']);
  const commit = () => run(['-c', 'user.email=t@t', '-c', 'user.name=t', 'commit', '--no-verify', '-q', '-m', 'fixture']);
  const adapter = (index) => (command, args, options) => {
    assert.equal(command, 'git');
    assert.equal(options.cwd, dir);
    return run(args, index);
  };
  const paths = (index) => stagedPaths(dir, adapter(index));
  const lintRequired = (index) => {
    let calls = 0;
    const code = main({ cwd: dir, git: adapter(index), err: () => {}, lint: () => { calls += 1; return { status: 23 }; } });
    assert.equal(code, 23);
    assert.equal(calls, 1);
  };
  const lintSkipped = (index) => {
    const code = main({ cwd: dir, git: adapter(index), err: () => {}, lint: () => assert.fail('inert commit launched lint') });
    assert.equal(code, 0);
  };
  return { dir, run, commit, paths, lintRequired, lintSkipped };
}

test('real staged deletion of code beside a JOURNAL edit must run lint', (t) => {
  const r = repository(t);
  put(r.dir, 'tools/code.mjs');
  put(r.dir, 'JOURNAL.md');
  r.run(['add', '--', 'tools/code.mjs', 'JOURNAL.md']);
  r.commit();
  r.run(['rm', '--', 'tools/code.mjs']);
  put(r.dir, 'JOURNAL.md', 'edited\n');
  r.run(['add', '--', 'JOURNAL.md']);
  assert.deepEqual(new Set(r.paths()), new Set(['tools/code.mjs', 'JOURNAL.md']));
  r.lintRequired();
});

test('real staged rename from tools into docs must count both sides and run lint', (t) => {
  const r = repository(t);
  put(r.dir, 'tools/code.mjs', 'export const value = 1;\n'.repeat(20));
  r.run(['add', '--', 'tools/code.mjs']);
  r.commit();
  mkdirSync(join(r.dir, 'docs'));
  r.run(['mv', '--', 'tools/code.mjs', 'docs/code.mjs']);
  assert.deepEqual(new Set(r.paths()), new Set(['tools/code.mjs', 'docs/code.mjs']));
  r.lintRequired();
});

test('real staged paths with spaces remain whole and only inert space paths skip lint', (t) => {
  const r = repository(t);
  put(r.dir, 'docs/space note.md');
  r.run(['add', '--', 'docs/space note.md']);
  assert.deepEqual(r.paths(), ['docs/space note.md']);
  assert.equal(decide(r.paths()).skip, true);
  r.lintSkipped();
  put(r.dir, 'tools/space code.mjs');
  r.run(['add', '--', 'tools/space code.mjs']);
  assert.deepEqual(new Set(r.paths()), new Set(['docs/space note.md', 'tools/space code.mjs']));
  r.lintRequired();
});

test('real temporary commit index controls lint independently of the default index', (t) => {
  const r = repository(t);
  put(r.dir, 'tools/code.mjs');
  put(r.dir, 'JOURNAL.md');
  r.run(['add', '--', 'tools/code.mjs', 'JOURNAL.md']);
  r.commit();
  put(r.dir, 'JOURNAL.md', 'new note\n');
  r.run(['add', '--', 'JOURNAL.md']);
  const index = join(r.dir, 'commit-index');
  r.run(['read-tree', 'HEAD'], index);
  put(r.dir, 'tools/code.mjs', 'changed code\n');
  r.run(['add', '--', 'tools/code.mjs'], index);
  assert.deepEqual(r.paths(), ['JOURNAL.md']);
  assert.equal(decide(r.paths()).skip, true);
  assert.deepEqual(r.paths(index), ['tools/code.mjs']);
  r.lintRequired(index);
  // Reverse the trap: a path-limited commit of the note must ignore default-index code.
  r.run(['add', '--', 'tools/code.mjs']);
  r.run(['read-tree', 'HEAD'], index);
  r.run(['add', '--', 'JOURNAL.md'], index);
  assert.deepEqual(r.paths(index), ['JOURNAL.md']);
  r.lintRequired();
  r.lintSkipped(index);
});

test('withoutGitEnv drops every case permutation of GIT_ and preserves all other names and values', () => {
  const source = { PATH: 'p', GODOT_BIN: 'g', GIT: 'keep', GITISH: 'keep', XGIT_DIR: 'keep', _GIT_DIR: 'keep', ' GIT_DIR': 'keep', git_dirish: 'drop' };
  for (const g of ['g', 'G']) for (const i of ['i', 'I']) for (const t of ['t', 'T']) {
    for (const suffix of ['', 'DIR', 'INDEX_FILE', 'unknown_future_variable']) source[`${g}${i}${t}_${suffix}`] = suffix;
  }
  assert.deepEqual(withoutGitEnv(source), { PATH: 'p', GODOT_BIN: 'g', GIT: 'keep', GITISH: 'keep', XGIT_DIR: 'keep', _GIT_DIR: 'keep', ' GIT_DIR': 'keep' });
});

const tablePath = 'project/features/characters/street_dead_plan.gd';
const table = 'const CLASS_OF: Dictionary[String, String] = {\n  "thug": "thug",\n  # "retired": "old",\n  "cop/head_swat": "swat",\n}\n';

function filmTree(t, text = table, hook = 'var victim = args.text("--victim")\n') {
  const root = temporary(t, 'gtai-break-film-');
  for (const [path, content] of Object.entries({
    'project/project.godot': '', 'project/dev/frames/film_probe.gd': '',
    'project/data/tables/weapons.json': '{"weapons":[{"id":"pistol"}]}',
    'project/data/tables/view.json': '{"views":[{"id":"combo"}]}',
    'project/dev/showcase/reel_chapters.gd': 'var c = Chapter.new(&"intro")\n',
    'project/features/hook.gd': hook, [tablePath]: text,
  })) put(root, path, content);
  return root;
}

function planned(root, shot = 'weapon:pistol', victim = 'thug', extra = []) {
  return plan({ ...parseArgv([]).flags, tree: root, out: join(root, 'out'), victim, stills: '2' }, shot, extra);
}

test('victimKinds uses only live CLASS_OF keys in the filmed tree and ignores other dictionaries and commented rows', (t) => {
  const root = filmTree(t, 'const OTHER = {\n "before": "x",\n}\n' + table + 'const BY_KIND = {\n "after": "x",\n}\n');
  assert.deepEqual(new Set(victimKinds(root)), new Set(['thug', 'cop/head_swat']));
  const other = filmTree(t, 'const CLASS_OF = {\n "other_tree": "x",\n}\n');
  assert.deepEqual(victimKinds(other), ['other_tree']);
});

for (const [name, text] of [
  ['commented-out CLASS_OF declaration', '# const CLASS_OF = {\n# "retired": "x",\n# }\n' + table],
  ['another dictionary whose name starts with CLASS_OF', 'const CLASS_OF_OLD = {\n "obsolete": "x",\n}\n' + table],
  ['multiple keys on one valid dictionary line', 'const CLASS_OF = {"thug": "thug", "cop/head_swat": "swat"}\n'],
  ['closing brace inside a row comment', table.replace('"thug": "thug",', '"thug": "thug", # old shape }')],
]) {
  test(`victimKinds must return exactly live CLASS_OF keys despite ${name}`, (t) => {
    const root = filmTree(t, text);
    assert.deepEqual(new Set(victimKinds(root)), new Set(['thug', 'cop/head_swat']));
  });
}

test('checkVictim and plan reject a victim for every non-weapon shot', (t) => {
  const root = filmTree(t);
  for (const shot of ['arena', 'city', 'chapter:intro', 'quest1']) {
    assert.ok(checkVictim('thug', parseShot(shot), root));
    assert.ok(planned(root, shot).error, shot);
  }
});

test('checkVictim and plan reject unknown kinds with a nearest-kind suggestion', (t) => {
  const root = filmTree(t);
  for (const error of [checkVictim('cop/head_swot', parseShot('weapon:pistol'), root), planned(root, 'weapon:pistol', 'cop/head_swot').error]) {
    assert.match(error, /did.you.mean/i);
    assert.ok(error.includes('cop/head_swat'));
  }
});

test('checkVictim and plan refuse a tree where only comments mention --victim', (t) => {
  const root = filmTree(t, table, '# var victim = args.text("--victim")\n');
  assert.ok(checkVictim('thug', parseShot('weapon:pistol'), root));
  assert.ok(planned(root).error);
});

test('plan refuses --victim after the separator even if the same valid victim was supplied before it', (t) => {
  const root = filmTree(t);
  for (const extra of [['--victim=thug'], ['--victim', 'thug'], ['--victim=unknown']]) {
    for (const before of [[], ['--victim=thug']]) {
      const parsed = parseArgv(['weapon:pistol', `--tree=${root}`, `--out=${join(root, 'out')}`, ...before, '--', ...extra]);
      assert.ok(plan(parsed.flags, parsed.shotText, parsed.extra).error);
    }
  }
});

test('plan accepts a live weapon victim and forwards exactly that kind to the game', (t) => {
  const root = filmTree(t);
  const p = planned(root, 'weapon:pistol', 'cop/head_swat');
  assert.equal(p.error, undefined);
  assert.equal(p.opts.victim, 'cop/head_swat');
  assert.ok(godotArgs(p.shot, p.opts).includes('--victim=cop/head_swat'));
});

function judged(t, out, victim) {
  const dir = temporary(t, 'gtai-break-judge-');
  put(dir, 'probe.json', JSON.stringify({ rows: [{ tick: 1, fighters: [] }], stills: [], view: [10, 10] }));
  return judge({ status: 0, out, timedOut: false }, { dir, stills: [], res: '10x10', ticks: 10, victim }, 0);
}

for (const [name, output, said] of [
  ['no output', '', null],
  ['a kill line without victim confirmation', '[INFO] gunplay: lone kill 1', null],
  ['another kind', '[INFO] gunplay: lone victim cop/head_swat\n', 'cop/head_swat'],
  ['a prefix of the asked kind', '[INFO] gunplay: lone victim thu\n', 'thu'],
  ['an extension of the asked kind', '[INFO] gunplay: lone victim thug_elite\n', 'thug_elite'],
]) {
  test(`judge must be unverifiable for a requested victim with ${name}`, (t) => {
    assert.equal(victimSaid(output), said);
    assert.equal(judged(t, output, 'thug').outcome, 'unverifiable');
  });
}

test('judge passes the otherwise valid control only when the run confirms the exact requested victim', (t) => {
  const output = '[INFO] gunplay: lone victim thug\r\n';
  assert.equal(victimSaid(output), 'thug');
  assert.equal(judged(t, output, 'thug').outcome, 'pass');
  assert.equal(judged(t, '', null).outcome, 'pass');
});
