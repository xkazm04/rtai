// A film side: a worktree as it stands, or a commit in a throwaway snapshot with this kit's probe
// injected and the native guard. Shared by compare.mjs and film.mjs --rev; kept apart from both
// because compare imports film (a dynamic import of compare from film's top-level await deadlocks).
import { spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { ensureSnapshot, revParse } from '../lib/snapshot.mjs';

const PROBE = 'project/dev/frames/film_probe.gd';
const PROBE_FILES = [PROBE, 'project/dev/frames/film_card.gd', 'project/dev/frames/film_trigger.gd'];
const INJECTED = '.gtai-film-injected';
const HOOK = /^(\s*)FightFrames\.attach\(self, args, session\.world\).*$/m;

/** Puts this kit's probe in a snapshot older than the kit (a throwaway tree). Every run copies it
 *  again, because a cached snapshot must not film with last week's probe. */
function injectProbe(path) {
  const mark = join(path, INJECTED);
  if (PROBE_FILES.every((rel) => existsSync(join(path, rel))) && !existsSync(mark)) return false;
  const game = join(path, 'project/dev/arena/arena_game.gd');
  const text = readFileSync(game, 'utf8');
  if (!text.includes('FilmProbe.attach')) {
    if (!HOOK.test(text)) throw new Error(`compare: ${game} has no FightFrames.attach line to hook the probe on`);
    writeFileSync(game, text.replace(HOOK, (line, indent) => `${line}\n${indent}FilmProbe.attach(self, args)`));
  }
  for (const rel of PROBE_FILES) copyFileSync(join(ROOT, rel), join(path, rel));
  writeFileSync(mark, 'probe injected by tools/film/compare.mjs\n');
  return true;
}

/** True when `native/` at `sha` is not `native/` at the root's HEAD (git diff exits 1). */
export function nativeDiffers(root, sha) {
  const r = spawnSync('git', ['-C', root, 'diff', '--quiet', sha, 'HEAD', '--', 'native'], { encoding: 'utf8', windowsHide: true });
  return r.status === 1;
}

/** A commit side runs in a snapshot that gets the DLLs of THIS tree (built from its HEAD's native/), so
 *  when the sim's C++ differs at that commit the side is not that commit's sim: refused, unless the change
 *  under test is view-only and the caller says so with --native=donor (n15 t-4 film: the before would
 *  have run the after's car routing). The fix is a worktree at the commit with its own DLLs as the side. */
export function nativeRefusal(value, sha, differs, native) {
  if (!differs || native === 'donor') return null;
  return `compare: native/ at ${value} (${sha.slice(0, 8)}) differs from this tree's HEAD, but its snapshot would run this tree's DLLs, `
    + `so it would not be ${value}'s sim. Film a worktree at ${value} that has its own DLLs (tools/dev/wt_init.mjs, then just native) `
    + 'as that side, or pass --native=donor when the change under test is not in the sim.';
}

/** Resolves a side to a runnable tree: {tree, label, snapshot, injected} or {error}. */
export function resolveSide(value, { root = ROOT, ensure = ensureSnapshot, native, differs = nativeDiffers, rev = revParse } = {}) {
  const dir = resolve(value);
  if (existsSync(join(dir, 'project', 'project.godot'))) return { tree: dir, label: basename(dir), snapshot: false, injected: false };
  const sha = rev(root, value);
  if (!sha) return { error: `compare: ${value} is neither a worktree nor a commit git knows` };
  const refusal = nativeRefusal(value, sha, differs(root, sha), native);
  if (refusal) return { error: refusal };
  const snap = ensure({ root, rev: value, kind: 'film' });
  return { tree: snap.path, label: sha.slice(0, 8), snapshot: true, injected: injectProbe(snap.path) };
}
