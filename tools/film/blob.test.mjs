import assert from 'node:assert/strict';
import test from 'node:test';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { LFS_HEADER, isPointer, main, parseArgs, readBlob } from './blob.mjs';
import { withoutGitEnv } from '../lint/lint.mjs';

const POINTER = Buffer.from(`${LFS_HEADER}\noid sha256:${'a'.repeat(64)}\nsize 4\n`);
const PNG = Buffer.from([0x89, 0x50, 0x4e, 0x47]);

test('parseArgs: rev:path, a default out under build/blob, and refusals', () => {
  assert.deepEqual(parseArgs(['HEAD~2:project/a b.png']),
    { rev: 'HEAD~2', path: 'project/a b.png', out: join('build', 'blob', 'HEAD_2', 'project/a b.png') });
  assert.equal(parseArgs(['abc:./x.png', '--out=o.png']).out, 'o.png');
  assert.equal(parseArgs(['abc:x\\y.png']).path, 'x/y.png');
  for (const bad of [[], ['HEAD'], ['HEAD:'], ['a:b', 'c:d'], ['a:b', '--outt=x']]) assert.throws(() => parseArgs(bad), bad.join(' '));
});

test('a pointer is smudged with its path; a plain blob is not; a pointer back is an error', () => {
  const calls = [];
  const run = (args, input) => { calls.push([args, input]); return args[0] === 'cat-file' ? POINTER : PNG; };
  assert.deepEqual(readBlob('r', 'p.png', { run }), { bytes: PNG, lfs: true });
  assert.deepEqual(calls[1][0], ['lfs', 'smudge', '--', 'p.png']);
  assert.equal(calls[1][1], POINTER);
  assert.deepEqual(readBlob('r', 'p.png', { run: () => PNG }), { bytes: PNG, lfs: false });
  assert.throws(() => readBlob('r', 'p.png', { run: () => POINTER }), /pointer again/);
  assert.ok(isPointer(POINTER) && !isPointer(PNG) && !isPointer(Buffer.alloc(0)));
});

test('main on a real throwaway repo: the old bytes of a changed file, exit 1 on a missing path', (t) => {
  const repo = mkdtempSync(join(tmpdir(), 'gtai-blob-'));
  t.after(() => rmSync(repo, { recursive: true, force: true }));
  const env = { ...withoutGitEnv(), GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: join(repo, 'none') };
  const git = (...a) => execFileSync('git', ['-c', 'user.name=t', '-c', 'user.email=t@t', ...a], { cwd: repo, env });
  git('init', '-q');
  writeFileSync(join(repo, 'f.bin'), PNG);
  git('add', 'f.bin');
  git('commit', '-qm', 'one');
  writeFileSync(join(repo, 'f.bin'), 'changed');
  const said = [];
  const run = (args, input) => execFileSync('git', args, { cwd: repo, env, input, stdio: ['pipe', 'pipe', 'pipe'] });
  assert.equal(main(['HEAD:f.bin', '--out=old.bin'], { cwd: repo, run, out: (l) => said.push(l), err: () => {} }), 0);
  assert.deepEqual(readFileSync(join(repo, 'old.bin')), PNG);
  assert.match(said[0], /4 bytes, plain blob/);
  const errs = [];
  assert.equal(main(['HEAD:gone.bin'], { cwd: repo, run, err: (l) => errs.push(l) }), 1);
  assert.match(errs[0], /HEAD:gone\.bin/);
  assert.equal(main(['nope'], { cwd: repo, run, err: () => {} }), 2);
});
