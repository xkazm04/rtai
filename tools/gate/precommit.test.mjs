import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { decide, main, sameTreeAsHead, stagedPaths } from './precommit.mjs';
import { withoutGitEnv } from '../lint/lint.mjs';

// Never the hook's GIT_DIR / GIT_INDEX_FILE: with them this test committed into the real repo.
const env = withoutGitEnv();

test('only a commit of inert paths skips lint', () => {
  assert.equal(decide(['JOURNAL.md', 'REPORT.md', 'docs/day/x/JOURNAL.md', 'evidence/a.png', 'ASSETS-REPLIES.md']).skip, true);
  assert.equal(decide(['JOURNAL.md', 'project/a.gd']).skip, false);
  assert.equal(decide(['AGENTS.md']).skip, false, 'root markdown is code: debt metrics read AGENTS.md');
  assert.equal(decide(['project/README.md']).skip, false);
  assert.equal(decide(['tools/debt/baseline.json']).skip, false);
  assert.equal(decide(['journal.md']).skip, false, 'a case variant is not the inert file');
  assert.equal(decide([]).skip, false, 'nothing listed is never a reason to skip');
});

test('the skip says why; a failure to list runs lint', () => {
  assert.match(decide(['JOURNAL.md']).line, /1 staged path\(s\), all inert .*lint skipped/);
  let linted = 0;
  const lint = () => { linted += 1; return { status: 7 }; };
  const lines = [];
  const code = main({ git: () => ({ status: 128, stdout: '' }), lint, err: (l) => lines.push(l) });
  assert.equal(code, 7);
  assert.equal(linted, 1);
  assert.match(lines[0], /could not list the staged paths, running lint/);
  assert.equal(main({ git: () => ({ status: 0, stdout: 'JOURNAL.md\0' }), lint, err: () => {} }), 0);
  assert.equal(linted, 1, 'an inert-only commit never starts lint');
  assert.equal(main({ git: () => ({ status: 0, stdout: 'JOURNAL.md\0tools/x.mjs\0' }), lint, err: () => {} }), 7);
  assert.equal(main({ git: () => ({ status: 0, stdout: 'JOURNAL.md\0' }), lint: () => ({ status: null }), err: () => {} }), 0);
  assert.equal(main({ git: () => ({ status: 0, stdout: 'a.gd\0' }), lint: () => ({ status: null, signal: 'SIGKILL' }), err: () => {} }), 1);
});

test('a staged rename from code into docs lists the code side too (real git)', () => {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-precommit-'));
  const git = (...a) => execFileSync('git', ['-C', dir, ...a], { encoding: 'utf8', windowsHide: true, env });
  try {
    git('init', '-q');
    mkdirSync(join(dir, 'tools'));
    writeFileSync(join(dir, 'tools', 'x.mjs'), 'export const x = 1;\n'.repeat(20));
    git('add', 'tools/x.mjs');
    git('-c', 'user.email=t@t', '-c', 'user.name=t', 'commit', '-q', '-m', 'x', '--no-verify');
    mkdirSync(join(dir, 'docs'));
    git('mv', 'tools/x.mjs', 'docs/x.mjs');
    const paths = stagedPaths(dir, (c, a, o) => spawnSync(c, a, { ...o, env }));
    assert.deepEqual(paths.sort(), ['docs/x.mjs', 'tools/x.mjs']);
    assert.equal(decide(paths).skip, false);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test('withoutGitEnv drops every GIT_ variable and keeps the rest', () => {
  const clean = withoutGitEnv({ GIT_DIR: 'x', GIT_INDEX_FILE: 'y', git_work_tree: 'z', PATH: 'p', GODOT_BIN: 'g' });
  assert.deepEqual(clean, { PATH: 'p', GODOT_BIN: 'g' });
});

test('an empty commit skips lint only when git says the index tree is the HEAD tree (real git)', () => {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-precommit-'));
  const run = (c, a, o) => spawnSync(c, a, { ...o, env });
  const git = (...a) => execFileSync('git', ['-C', dir, ...a], { encoding: 'utf8', windowsHide: true, env });
  try {
    git('init', '-q');
    mkdirSync(join(dir, 'project'));
    writeFileSync(join(dir, 'project', 'a.gd'), 'var a: int = 1\n');
    assert.equal(sameTreeAsHead(dir, run), false, 'no HEAD yet');
    git('add', 'project/a.gd');
    git('-c', 'user.email=t@t', '-c', 'user.name=t', 'commit', '-q', '-m', 'x', '--no-verify');
    assert.equal(sameTreeAsHead(dir, run), true);
    let linted = 0;
    const lines = [];
    assert.equal(main({ cwd: dir, git: run, lint: () => { linted += 1; return { status: 3 }; }, err: (l) => lines.push(l) }), 0);
    assert.equal(linted, 0);
    assert.match(lines.at(-1), /nothing staged, the index tree is the HEAD tree: lint skipped/);
    writeFileSync(join(dir, 'project', 'a.gd'), 'var a: int = 2\n');
    git('add', 'project/a.gd');
    assert.equal(sameTreeAsHead(dir, run), false, 'a staged edit is not an empty commit');
  } finally { rmSync(dir, { recursive: true, force: true }); }
  assert.equal(sameTreeAsHead('.', () => ({ status: 0, stdout: '' })), false, 'two empty answers are not a match');
  assert.equal(sameTreeAsHead('.', () => ({ status: 0, stdout: 'abc\n' })), false, 'not a tree id');
});

test('lint gets the staged list as --scope, and the scope file is gone after', () => {
  let seen = null;
  const lint = (exe, args) => {
    const arg = args.find((a) => a.startsWith('--scope='));
    seen = { arg, text: readFileSync(arg.slice(8), 'utf8') };
    return { status: 0 };
  };
  const git = (c, a) => (a[0] === 'diff' && a[1] === '--cached' ? { status: 0, stdout: 'project/a.gd\0JOURNAL.md\0' } : { status: 0, stdout: '' });
  assert.equal(main({ git, lint, err: () => {} }), 0);
  assert.equal(seen.text, 'project/a.gd\nJOURNAL.md\n');
  assert.throws(() => readFileSync(seen.arg.slice(8)), /ENOENT/);
});
