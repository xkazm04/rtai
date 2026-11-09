#!/usr/bin/env node
// Makes a fresh git worktree able to run the game: the git-ignored things a checkout lacks (native
// DLLs, the baked city, the import cache, godot-cpp) come from a sibling worktree, never overwriting
// what is already there (FRICTION: empty godot-cpp, no DLL, no bake, a 300 s cold import, 12+ lanes).
//   node tools/dev/wt_init.mjs [<worktree>] [--donor=<worktree>] [--dry-run]
// Exit: 0 ready, 2 usage (not a worktree, nothing touched), 3 unverifiable (no donor has something it needs).
// A copied DLL or bake can be from different code than this branch: the run says so, by comparing
// the git objects each came from, rather than letting a stale artifact look like this tree's.
import { execFileSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { donorsOf } from '../lib/snapshot.mjs';

export const EXIT = { pass: 0, usage: 2, unverifiable: 3 };
const USAGE = 'usage: node tools/dev/wt_init.mjs [<worktree>] [--donor=<worktree>] [--dry-run]';
const DLLS = ['template_debug', 'template_release'].map((t) => `gtai_sim.windows.${t}.x86_64.dll`);

const realGit = (cwd, ...args) => {
  try {
    return execFileSync('git', ['-C', cwd, ...args], { encoding: 'utf8', windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] }).trim();
  } catch { return null; }
};

/** How many chunks the tree's golden list expects, or null when it has no list. */
function chunksExpected(tree) {
  const list = join(tree, 'project/data/generated/city_chunks.sha256');
  return existsSync(list) ? readFileSync(list, 'utf8').split('\n').filter((l) => l && !l.startsWith('#')).length : null;
}

const chunksIn = (dir) => (existsSync(dir) ? readdirSync(dir).filter((n) => /\.(gtch|bin|chunk)$/i.test(n) || !n.includes('.')).length : 0);

/** What a working tree needs. `has` is true when `tree` is usable for it; `built` names the source
 *  whose git object says whether a donor's copy is this code's. */
export const ITEMS = [
  { id: 'native DLLs', rel: 'project/native/bin', built: 'native', fix: 'run `just native` (scons) to rebuild them',
    has: (t) => DLLS.every((d) => existsSync(join(t, 'project/native/bin', d))) },
  { id: 'baked city', rel: 'project/data/generated/city', built: 'project/data/generated/city_chunks.sha256', fix: 'run `just bake`',
    has: (t) => { const dir = join(t, 'project/data/generated/city'); const want = chunksExpected(t); return existsSync(dir) && (want === null || chunksIn(dir) >= want); } },
  { id: 'import cache', rel: 'project/.godot', built: null, fix: 'the first Godot run imports (about 5 min on this machine)',
    has: (t) => existsSync(join(t, 'project/.godot/global_script_class_cache.cfg')) },
  { id: 'godot-cpp', rel: 'native/godot-cpp', built: null, fix: 'run `git submodule update --init native/godot-cpp` (needs the network)',
    has: (t) => existsSync(join(t, 'native/godot-cpp/SConstruct')) },
];

/** One entry per item: {id, state: 'ok'|'copy'|'missing', from?, stale?, fix}. Reads, copies nothing. */
export function plan(tree, donors, { git = realGit } = {}) {
  return ITEMS.map((item) => {
    if (item.has(tree)) return { ...item, state: 'ok' };
    const donor = donors.find((d) => resolve(d) !== resolve(tree) && item.has(d));
    if (!donor) return { ...item, state: 'missing' };
    const stale = Boolean(item.built) && git(tree, 'rev-parse', `HEAD:${item.built}`) !== git(donor, 'rev-parse', `HEAD:${item.built}`);
    return { ...item, state: 'copy', from: donor, stale };
  });
}

/** Copies what `plan` said to copy; never replaces anything already at the destination. */
export function apply(tree, entries, { copy = cpSync } = {}) {
  for (const e of entries) {
    if (e.state !== 'copy') continue;
    const to = join(tree, e.rel);
    if (existsSync(to) && readdirSync(to).length) throw new Error(`${e.rel} is not empty in ${tree}: it would be overwritten`);
    mkdirSync(dirname(to), { recursive: true });
    copy(join(e.from, e.rel), to, { recursive: true });
  }
}

/** {tree, flags} or {error}. */
export function parseArgv(argv) {
  const flags = {};
  let tree = null;
  for (const a of argv) {
    const m = /^--(donor|dry-run)(?:=(.+))?$/.exec(a);
    if (m && m[1] === 'dry-run' && m[2] === undefined) flags.dryRun = true;
    else if (m && m[1] === 'donor' && m[2]) flags.donor = m[2];
    else if (!a.startsWith('-') && tree === null) tree = a;
    else return { error: `wt_init: bad argument ${a}` };
  }
  return { tree: tree ?? process.cwd(), flags };
}

export function main(argv, { out = console.log, err = console.error, git = realGit, copy = cpSync } = {}) {
  const parsed = parseArgv(argv);
  if (parsed.error) { err(`${parsed.error}\n${USAGE}`); return EXIT.usage; }
  const tree = resolve(parsed.tree);
  if (git(tree, 'rev-parse', '--is-inside-work-tree') !== 'true' || !existsSync(join(tree, 'project/project.godot'))) {
    err(`wt_init: ${tree} is not a checkout of this game\n${USAGE}`);
    return EXIT.usage;
  }
  if (parsed.flags.donor && !existsSync(parsed.flags.donor)) { err(`wt_init: no such donor ${parsed.flags.donor}\n${USAGE}`); return EXIT.usage; }
  const donors = parsed.flags.donor ? [resolve(parsed.flags.donor)] : donorsOf(tree);
  const entries = plan(tree, donors, { git });
  for (const e of entries) {
    if (e.state === 'ok') out(`wt_init: ok      ${e.id}`);
    else if (e.state === 'copy') out(`wt_init: ${parsed.flags.dryRun ? 'would copy' : 'copy'}    ${e.id} from ${e.from}${e.stale ? ` (built from different code: ${e.fix})` : ''}`);
    else out(`wt_init: MISSING ${e.id}: no donor has it; ${e.fix}`);
  }
  if (parsed.flags.dryRun) return entries.some((e) => e.state === 'missing') ? EXIT.unverifiable : EXIT.pass;
  apply(tree, entries, { copy });
  if (git(tree, 'config', 'core.hooksPath') !== '.githooks') { git(tree, 'config', 'core.hooksPath', '.githooks'); out('wt_init: set core.hooksPath to .githooks'); }
  const missing = entries.filter((e) => e.state === 'missing');
  out(`wt_init: ${missing.length ? `UNVERIFIABLE: nothing to copy for ${missing.map((e) => e.id).join(', ')}` : 'ready'}`);
  return missing.length ? EXIT.unverifiable : EXIT.pass;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main(process.argv.slice(2)));
}
