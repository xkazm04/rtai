import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import {
  copyFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync,
  realpathSync, rmSync, writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, dirname, join, relative, sep } from 'node:path';
import test from 'node:test';
import { isInert } from '../evidence/scope.mjs';
import { withoutGitEnv } from '../lint/lint.mjs';
import { lintTarget, main } from './precommit.mjs';
import { driftPaths, exportIndex, PREFIX, removeExport, wanted } from './staged_tree.mjs';

const ok = (stdout = '') => ({ status: 0, stdout });
const inert = ['docs/nested/a.gd', 'evidence/a.json', 'JOURNAL.md', 'REPORT.md', 'ASSETS-REPLIES.md'];
const erase = (dir) => rmSync(dir, { recursive: true, force: true });
function put(dir, path, bytes = 'index\n') {
  mkdirSync(dirname(join(dir, path)), { recursive: true });
  writeFileSync(join(dir, path), bytes);
}

// Every real git call is confined to this newly created repo, even under hook GIT_* pollution.
// No commits or config writes are needed: the index alone is the subject of these tests.
function inRepo(body) {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-break-repo-'));
  try {
    const git = (args, extra = {}) => spawnSync('git', [
      '-C', dir, '-c', 'core.autocrlf=false', ...args,
    ], { encoding: 'utf8', windowsHide: true, env: { ...withoutGitEnv(), ...extra } });
    const run = (...args) => {
      const r = git(args);
      assert.equal(r.status, 0, `fixture git ${args[0]}: ${r.stderr || r.error || ''}`);
      return r.stdout;
    };
    const adapter = (extra = {}) => (cmd, args, options) => {
      assert.equal(cmd, 'git');
      assert.equal(options.cwd, dir, 'git must stay inside this test repo');
      return spawnSync('git', ['-C', dir, '-c', 'core.autocrlf=false', ...args], {
        ...options, env: { ...withoutGitEnv(), ...extra },
      });
    };
    run('init', '-q');
    put(dir, '.gitattributes', '* -text\n');
    run('add', '--', '.gitattributes');
    body({ dir, run, git, adapter });
  } finally { erase(dir); }
}

test('driftPaths lists edits, deletions, binary drift and nested untracked Unicode/spaced paths, excluding inert and ignored', () => {
  inRepo(({ dir, run, adapter }) => {
    const tracked = ['project/edit.gd', 'project/delete.gd', 'project/image.png', ...inert];
    for (const p of tracked) put(dir, p);
    put(dir, '.gitignore', 'ignored/\n*.ignored\n');
    run('add', '--', '.gitignore', ...tracked);
    for (const p of tracked) put(dir, p, 'different working bytes\n');
    rmSync(join(dir, 'project/delete.gd'));
    const untracked = ['new directory/deep/žluťoučký file.gd', 'loose file.mjs', 'AGENTS.md'];
    for (const p of [...untracked, 'ignored/deep/x.gd', 'x.ignored', 'docs/new.gd', 'evidence/new.json']) put(dir, p);
    assert.deepEqual(new Set(driftPaths(dir, adapter())), new Set([...tracked.filter((p) => !isInert(p)), ...untracked]));
  });
});

test('driftPaths returns an empty list for index-equal code despite inert and ignored working changes', () => {
  inRepo(({ dir, run, adapter }) => {
    put(dir, 'project/clean.gd');
    put(dir, '.gitignore', 'ignored/\n');
    run('add', '--', 'project/clean.gd', '.gitignore');
    for (const p of [...inert, 'ignored/untracked.gd']) put(dir, p);
    assert.deepEqual(driftPaths(dir, adapter()), []);
  });
});

for (const which of ['diff', 'ls-files']) {
  for (const failure of [{ status: 128, stdout: '' }, { status: null, error: new Error('spawn failed') }, { status: 0, stdout: null }]) {
    test(`driftPaths returns null rather than clean when ${which} fails with status ${failure.status} and stdout ${typeof failure.stdout}`, () => {
      const git = (_cmd, args) => args[0] === which ? failure : ok();
      assert.equal(driftPaths('/fake', git), null);
    });
  }
}

for (const flag of ['--assume-unchanged', '--skip-worktree']) {
  test(`driftPaths never claims index equality for changed content hidden by ${flag}`, () => {
    inRepo(({ dir, run, adapter }) => {
      put(dir, 'project/hidden.gd');
      run('add', '--', 'project/hidden.gd');
      run('update-index', flag, '--', 'project/hidden.gd');
      put(dir, 'project/hidden.gd', 'broken unstaged content\n');
      assert.deepEqual(driftPaths(dir, adapter()), ['project/hidden.gd']);
    });
  });
}

test('exportIndex exports all wanted staged bytes including Unicode, spaces and nested paths, omitting deleted, binary, inert and untracked files', () => {
  inRepo(({ dir, run, adapter }) => {
    const keep = ['nested dir/žába file.gd', 'tools/deep/test.mjs', 'project/image.png.import', 'AGENTS.md'];
    const binary = [
      'png', 'jpg', 'jpeg', 'WEBP', 'exr', 'hdr', 'wav', 'ogg', 'mp3', 'glb', 'gltf',
      'blend', 'ttf', 'otf', 'dll', 'so', 'dylib', 'exe', 'pck', 'zip', 'mp4', 'log',
    ].map((ext) => `project/image.${ext}`);
    const tracked = [...keep, ...binary, ...inert, 'project/deleted.gd'];
    for (const p of tracked) put(dir, p, `staged ${p}\n`);
    run('add', '--', ...tracked);
    run('rm', '--cached', '--', 'project/deleted.gd');
    for (const p of keep) put(dir, p, 'unstaged replacement\n');
    put(dir, 'untracked/new.gd');
    let out;
    try {
      out = exportIndex(dir, adapter());
      assert.equal(realpathSync(dirname(out.dir)), realpathSync(tmpdir()));
      assert.ok(basename(out.dir).startsWith(PREFIX));
      assert.equal(out.count, keep.length + 1); // also .gitattributes
      for (const p of keep) {
        assert.equal(wanted(p), true);
        assert.equal(readFileSync(join(out.dir, p), 'utf8'), `staged ${p}\n`);
      }
      for (const p of [...binary, ...inert, 'project/deleted.gd', 'untracked/new.gd']) {
        assert.equal(existsSync(join(out.dir, p)), false, `${p} must be absent`);
      }
    } finally { if (out) erase(out.dir); }
  });
});

test('exportIndex follows GIT_INDEX_FILE rather than either the ordinary index or working bytes', () => {
  inRepo(({ dir, run, git, adapter }) => {
    put(dir, 'project/a.gd', 'ordinary index\n');
    run('add', '--', 'project/a.gd');
    const alt = join(dir, '.git', 'test-index');
    copyFileSync(join(dir, '.git', 'index'), alt);
    put(dir, 'project/a.gd', 'alternate staged bytes\n');
    put(dir, 'alternate only/číslo.gd', 'alternate new file\n');
    const r = git(['add', '--', 'project/a.gd', 'alternate only/číslo.gd'], { GIT_INDEX_FILE: alt });
    assert.equal(r.status, 0, r.stderr);
    put(dir, 'project/a.gd', 'working tree\n');
    let out;
    try {
      out = exportIndex(dir, adapter({ GIT_INDEX_FILE: alt }));
      assert.equal(readFileSync(join(out.dir, 'project/a.gd'), 'utf8'), 'alternate staged bytes\n');
      assert.equal(readFileSync(join(out.dir, 'alternate only/číslo.gd'), 'utf8'), 'alternate new file\n');
    } finally { if (out) erase(out.dir); }
  });
});

// (A test that the export ignores the commit's eol attributes was thrown away in review: the export
// is a checkout of the commit, and lint must see what any checkout of it gives.)

// A private base makes leak detection independent of concurrent pre-commit exports.
for (const phase of ['list status', 'checkout status', 'checkout throw']) {
  test(`exportIndex throws and leaves no export directory after a git ${phase} failure`, () => {
    const base = mkdtempSync(join(tmpdir(), 'gtai-break-base-'));
    try {
      const failure = new Error('git spawn threw');
      const git = (_cmd, args) => {
        if (args[0] === 'ls-files') return phase === 'list status' ? { status: 128 } : ok('project/a.gd\0');
        const prefix = args.find((a) => a.startsWith('--prefix=')).slice('--prefix='.length);
        put(prefix, 'project/partial.gd');
        if (phase === 'checkout throw') throw failure;
        return { status: null, signal: 'SIGKILL', stderr: 'checkout failed' };
      };
      assert.throws(() => exportIndex('/fake', git, base));
      assert.deepEqual(readdirSync(base), [], 'a failed export must not leak even partially written files');
    } finally { erase(base); }
  });
}

test('exportIndex can export an index whose every entry is unwanted as an empty snapshot', () => {
  inRepo(({ dir, run, adapter }) => {
    run('rm', '--cached', '--', '.gitattributes');
    put(dir, 'docs/only.md');
    run('add', '--', 'docs/only.md');
    let out;
    try {
      out = exportIndex(dir, adapter());
      assert.equal(out.count, 0);
      assert.deepEqual(readdirSync(out.dir), []);
    } finally { if (out) erase(out.dir); }
  });
});

for (const kind of ['nested', 'look-alike sibling', 'base itself', 'relative', 'dot-dot outside']) {
  test(`removeExport refuses a ${kind} path and deletes nothing`, () => {
    const root = mkdtempSync(join(tmpdir(), 'gtai-break-remove-'));
    try {
      const base = join(root, 'temp');
      const valid = join(base, `${PREFIX}owned`);
      const outside = join(root, `${PREFIX}outside`);
      const lookalike = join(base, 'gtai-precommit_lookalike');
      const nested = join(valid, `${PREFIX}nested`);
      for (const dir of [base, valid, outside, lookalike, nested]) put(dir, 'sentinel', 'keep');
      const paths = {
        nested, 'look-alike sibling': lookalike, 'base itself': base,
        relative: relative(process.cwd(), valid),
        'dot-dot outside': `${base}${sep}..${sep}${basename(outside)}`,
      };
      assert.throws(() => removeExport(paths[kind], base));
      for (const dir of [base, valid, outside, lookalike, nested]) {
        assert.equal(readFileSync(join(dir, 'sentinel'), 'utf8'), 'keep');
      }
    } finally { erase(root); }
  });
}

test('removeExport removes a test-owned direct prefixed child of the actual temp directory', () => {
  const dir = mkdtempSync(join(tmpdir(), PREFIX));
  try {
    put(dir, 'nested/sentinel');
    removeExport(dir);
    assert.equal(existsSync(dir), false);
  } finally { erase(dir); }
});

// These fakes distinguish staged listing, unstaged diff and untracked listing without real git.
const fakeGit = (drift = '', unknown = false) => (_cmd, args) => {
  if (args.includes('--cached')) return ok('tools/changed.mjs\0');
  if (unknown) return { status: 128, stdout: '' };
  return ok(args[0] === 'diff' ? drift : '');
};
const forbidden = () => assert.fail('unexpected export/removal');

test('driftPaths reports a path once even if git lists it more than once, without dropping inert-looking code', () => {
  const code = ['project/JOURNAL.md', 'docs_like/a.gd', 'journal.md'];
  const git = () => ok([...code, ...code, ...inert].join('\0') + '\0');
  const drift = driftPaths('/fake', git);
  assert.equal(drift.length, code.length);
  assert.deepEqual(new Set(drift), new Set(code));
});

for (const mode of ['clean', 'drift', 'unknown', 'export throws']) {
  test(`lintTarget chooses the promised directory and truthful diagnostic for ${mode}`, () => {
    let exports = 0;
    const removed = [];
    const cwd = '/fake/tree';
    const snapshot = '/fake/snapshot';
    const t = lintTarget(cwd, {
      git: fakeGit(mode === 'clean' ? 'docs/inert.md\0' : 'project/a.gd\0', mode === 'unknown'),
      exporter: () => {
        exports += 1;
        if (mode === 'export throws') throw new Error('disk full');
        return { dir: snapshot, count: 2 };
      },
      remover: (dir) => removed.push(dir),
    });
    assert.equal(exports, ['clean', 'unknown'].includes(mode) ? 0 : 1);
    assert.equal(t.dir, mode === 'drift' ? snapshot : cwd);
    if (mode === 'clean') assert.equal(t.line, null);
    else if (mode === 'drift') assert.ok(t.line.includes(snapshot));
    else {
      assert.match(t.line, /working tree/i);
      assert.match(t.line, /not .*commit/i);
      assert.equal(t.line.includes(snapshot), false);
    }
    t.cleanup();
    assert.deepEqual(removed, mode === 'drift' ? [snapshot] : []);
  });
}

for (const mode of ['clean', 'drift', 'unknown', 'export throws']) {
  test(`main preserves lint cwd, environment, exit status and cleanup when target is ${mode}`, () => {
    const saved = process.env.GIT_BREAK_SENTINEL;
    const savedLower = process.env.git_break_lower_sentinel;
    process.env.GIT_BREAK_SENTINEL = 'must not reach an export';
    process.env.git_break_lower_sentinel = 'mixed case must also be stripped';
    try {
      for (const result of [{ status: 0 }, { status: 23 }, { status: null, signal: 'SIGTERM' }]) {
        let calls = 0;
        const removed = [];
        const cwd = '/fake/tree';
        const snapshot = '/fake/snapshot';
        const code = main({
          cwd, git: fakeGit(mode === 'clean' ? '' : 'x.gd\0', mode === 'unknown'), err: () => {},
          exporter: mode === 'clean' || mode === 'unknown' ? forbidden : () => {
            if (mode === 'export throws') throw new Error('export failed');
            return { dir: snapshot, count: 1 };
          },
          remover: (dir) => { removed.push(dir); throw new Error('cleanup failed'); },
          lint: (cmd, args, options) => {
            calls += 1;
            const expected = mode === 'drift' ? snapshot : cwd;
            assert.equal(cmd, process.execPath);
            assert.equal(args[0], join(expected, 'tools', 'lint', 'lint.mjs'));
            assert.ok(args.length <= 2 && args.slice(1).every((a) => a.startsWith('--scope=')), 'only the staged-list scope is added');
            assert.equal(options.cwd, expected);
            if (mode === 'drift') {
              assert.equal(Object.keys(options.env).some((k) => /^GIT_/i.test(k)), false);
              assert.deepEqual(options.env, withoutGitEnv());
            } else assert.equal(options.env, process.env);
            return result;
          },
        });
        assert.equal(calls, 1);
        assert.equal(code, result.status ?? 1);
        assert.deepEqual(removed, mode === 'drift' ? [snapshot] : []);
      }
    } finally {
      if (saved === undefined) delete process.env.GIT_BREAK_SENTINEL;
      else process.env.GIT_BREAK_SENTINEL = saved;
      if (savedLower === undefined) delete process.env.git_break_lower_sentinel;
      else process.env.git_break_lower_sentinel = savedLower;
    }
  });
}

for (const cleanupThrows of [false, true]) {
  test(`main always cleans up after lint throws and preserves its exception when cleanupThrows=${cleanupThrows}`, () => {
    const lintError = new Error('lint crashed');
    const removed = [];
    assert.throws(() => main({
      cwd: '/fake/tree', git: fakeGit('x.gd\0'), err: () => {},
      exporter: () => ({ dir: '/fake/snapshot', count: 1 }),
      remover: (dir) => {
        removed.push(dir);
        if (cleanupThrows) throw new Error('cleanup crashed');
      },
      lint: () => { throw lintError; },
    }), (e) => e === lintError);
    assert.deepEqual(removed, ['/fake/snapshot']);
  });
}
