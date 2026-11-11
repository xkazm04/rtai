// Adversarial coverage for the filmed-root and shared-snapshot runtime promises (n16). Written by Codex
// (n16t-break-film-root, gpt-5.6-sol); review flipped the subdirectory case (the cwd's ancestors count).
import assert from 'node:assert/strict';
import {
  existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import test from 'node:test';
import { plan, parseArgv } from './film.mjs';
import { filmedRoot, resolveSide } from './side.mjs';
import { copyRuntime } from '../lib/snapshot.mjs';
import { ROOT } from '../lib/repo.mjs';

const SHA = '1234567890abcdef1234567890abcdef12345678';

function tempTree(prefix = 'gtai-film-break-') {
  return mkdtempSync(join(tmpdir(), prefix));
}

function write(root, rel, text = '') {
  const file = join(root, rel);
  mkdirSync(join(file, '..'), { recursive: true });
  writeFileSync(file, text);
}

function gameTree(root) {
  write(root, 'project/project.godot');
  write(root, 'project/dev/frames/film_probe.gd');
  write(root, 'project/data/tables/view.json', '{"views":[{"id":"combo"}]}');
}

function injectableSnapshot(root) {
  for (const rel of [
    'project/dev/frames/film_probe.gd',
    'project/dev/frames/film_card.gd',
    'project/dev/frames/film_trigger.gd',
  ]) write(root, rel);
}

test('filmedRoot: a cwd below a game root films that game tree, not the kit', () => {
  const lane = tempTree();
  try {
    gameTree(lane);
    const child = join(lane, 'project', 'features');
    mkdirSync(child, { recursive: true });
    assert.equal(filmedRoot(lane), resolve(lane), 'the cwd itself holds project/project.godot');
    assert.equal(filmedRoot(child), resolve(lane), 'review: from project/features the lane still films its own tree');
    assert.equal(filmedRoot(tmpdir()), ROOT, 'no game tree above: the kit');
  } finally {
    rmSync(lane, { recursive: true, force: true });
  }
});

test('resolveSide: default git, native, and snapshot roots come from the current cwd game tree', () => {
  const lane = tempTree();
  const snapshot = tempTree('gtai-film-snapshot-break-');
  const previous = process.cwd();
  try {
    gameTree(lane);
    injectableSnapshot(snapshot);
    const calls = [];
    process.chdir(lane);
    const side = resolveSide('HEAD~1', {
      rev: (root, value) => { calls.push(['rev', root, value]); return SHA; },
      differs: (root, sha) => { calls.push(['differs', root, sha]); return false; },
      ensure: (options) => { calls.push(['ensure', options.root, options.rev]); return { path: snapshot }; },
    });
    assert.equal(side.tree, snapshot);
    assert.deepEqual(calls, [
      ['rev', lane, 'HEAD~1'],
      ['differs', lane, SHA],
      ['ensure', lane, 'HEAD~1'],
    ]);
  } finally {
    process.chdir(previous);
    rmSync(lane, { recursive: true, force: true });
    rmSync(snapshot, { recursive: true, force: true });
  }
});

test('resolveSide: a directory holding a game is a worktree without git, native, or snapshot calls', () => {
  const lane = tempTree();
  try {
    gameTree(lane);
    let calls = 0;
    const fail = () => { calls += 1; throw new Error('must not be called'); };
    const side = resolveSide(lane, { rev: fail, differs: fail, ensure: fail });
    assert.deepEqual(side, {
      tree: resolve(lane), label: lane.split(/[\\/]/).pop(), snapshot: false, injected: false,
    });
    assert.equal(calls, 0);
  } finally {
    rmSync(lane, { recursive: true, force: true });
  }
});

test('plan: without --tree or --rev the filmed tree is filmedRoot of the current cwd', () => {
  const lane = tempTree();
  const previous = process.cwd();
  try {
    gameTree(lane);
    process.chdir(lane);
    const flags = { ...parseArgv([]).flags, out: join(lane, 'out') };
    const result = plan(flags, 'arena', []);
    assert.equal(result.error, undefined);
    assert.equal(result.opts.tree, resolve(lane));
  } finally {
    process.chdir(previous);
    rmSync(lane, { recursive: true, force: true });
  }
});

test('copyRuntime: a donor native/bin extra file forces a byte-for-byte refresh report', () => {
  const donor = tempTree();
  const snapshot = tempTree();
  try {
    write(donor, 'project/native/bin/same.dll', 'same');
    write(donor, 'project/native/bin/extra.dll', 'donor extra');
    write(snapshot, 'project/native/bin/same.dll', 'same');
    assert.deepEqual(copyRuntime([donor], snapshot), ['project/native/bin']);
    assert.equal(readFileSync(join(snapshot, 'project/native/bin/extra.dll'), 'utf8'), 'donor extra');
  } finally {
    rmSync(donor, { recursive: true, force: true });
    rmSync(snapshot, { recursive: true, force: true });
  }
});

test('copyRuntime: an empty donor native/bin is copied when absent and is identical when present', () => {
  const donor = tempTree();
  const snapshot = tempTree();
  try {
    mkdirSync(join(donor, 'project/native/bin'), { recursive: true });
    assert.deepEqual(copyRuntime(donor, snapshot), ['project/native/bin']);
    assert.equal(existsSync(join(snapshot, 'project/native/bin')), true);
    assert.deepEqual(copyRuntime(donor, snapshot), []);
  } finally {
    rmSync(donor, { recursive: true, force: true });
    rmSync(snapshot, { recursive: true, force: true });
  }
});

test('copyRuntime: a stale snapshot-only DLL does not refresh identical donor files', () => {
  const donor = tempTree();
  const snapshot = tempTree();
  try {
    write(donor, 'project/native/bin/current.dll', 'same bytes');
    write(snapshot, 'project/native/bin/current.dll', 'same bytes');
    write(snapshot, 'project/native/bin/stale.dll', 'old lane');
    assert.deepEqual(copyRuntime(donor, snapshot), [], 'every donor file is already byte-identical');
    assert.equal(readFileSync(join(snapshot, 'project/native/bin/stale.dll'), 'utf8'), 'old lane');
  } finally {
    rmSync(donor, { recursive: true, force: true });
    rmSync(snapshot, { recursive: true, force: true });
  }
});

test('copyRuntime: a single donor string supplies runtime and first-donor-only override.cfg', () => {
  const donor = tempTree();
  const snapshot = tempTree();
  try {
    write(donor, 'project/data/generated/city/chunk.gtch', 'city');
    write(donor, 'project/override.cfg', 'donor config');
    assert.deepEqual(copyRuntime(donor, snapshot), [
      'project/data/generated/city', 'project/override.cfg',
    ]);
    assert.equal(readFileSync(join(snapshot, 'project/override.cfg'), 'utf8'), 'donor config');
  } finally {
    rmSync(donor, { recursive: true, force: true });
    rmSync(snapshot, { recursive: true, force: true });
  }
});

test('copyRuntime: each runtime dir comes from the first donor that has that dir', () => {
  const first = tempTree();
  const second = tempTree();
  const snapshot = tempTree();
  try {
    write(first, 'project/native/bin/game.dll', 'first native');
    write(second, 'project/native/bin/game.dll', 'second native');
    write(second, 'project/data/generated/city/chunk.gtch', 'second city');
    write(second, 'project/.godot/cache.bin', 'second cache');
    write(second, 'project/override.cfg', 'second config');
    assert.deepEqual(copyRuntime([first, second], snapshot), [
      'project/native/bin', 'project/data/generated/city', 'project/.godot',
    ]);
    assert.equal(readFileSync(join(snapshot, 'project/native/bin/game.dll'), 'utf8'), 'first native');
    assert.equal(readFileSync(join(snapshot, 'project/data/generated/city/chunk.gtch'), 'utf8'), 'second city');
    assert.equal(existsSync(join(snapshot, 'project/override.cfg')), false, 'override only comes from donor zero');
  } finally {
    rmSync(first, { recursive: true, force: true });
    rmSync(second, { recursive: true, force: true });
    rmSync(snapshot, { recursive: true, force: true });
  }
});

test('copyRuntime: existing bake, import cache, and override are never overwritten', () => {
  const donor = tempTree();
  const snapshot = tempTree();
  try {
    for (const [rel, text] of [
      ['project/data/generated/city/chunk.gtch', 'donor city'],
      ['project/.godot/cache.bin', 'donor cache'],
      ['project/override.cfg', 'donor config'],
    ]) write(donor, rel, text);
    for (const [rel, text] of [
      ['project/data/generated/city/chunk.gtch', 'snapshot city'],
      ['project/.godot/cache.bin', 'snapshot cache'],
      ['project/override.cfg', 'snapshot config'],
    ]) write(snapshot, rel, text);
    assert.deepEqual(copyRuntime([donor], snapshot), []);
    assert.equal(readFileSync(join(snapshot, 'project/data/generated/city/chunk.gtch'), 'utf8'), 'snapshot city');
    assert.equal(readFileSync(join(snapshot, 'project/.godot/cache.bin'), 'utf8'), 'snapshot cache');
    assert.equal(readFileSync(join(snapshot, 'project/override.cfg'), 'utf8'), 'snapshot config');
  } finally {
    rmSync(donor, { recursive: true, force: true });
    rmSync(snapshot, { recursive: true, force: true });
  }
});
