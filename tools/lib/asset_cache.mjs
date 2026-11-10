// Is the import cache still in step with the assets on disk? Godot only re-imports when something
// asks it to, so a film or test after a PNG swap draws the old texture and looks like a real result
// (FRICTION, 5 journals). Godot's own test is the source's MD5 against the one recorded at import.
// Hashing every asset is about 15 s, so a stamp list in .godot remembers the (mtime, size, recorded
// hash) each source last matched at; anything different is hashed again. "Newer than the import" is
// not a usable shortcut: a Windows or `cp -p` copy keeps the file's old date with new bytes.
import { createHash } from 'node:crypto';
import { closeSync, existsSync, openSync, readFileSync, readSync, readdirSync, statSync, utimesSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const ASSET = /\.(png|jpe?g|webp|svg|ogg|wav|mp3|ttf|otf)$/i;
const SKIP = new Set(['.godot', '.git']);
const STAMPS = '.godot/gtai_asset_stamps.json';

const resPath = (project, res) => join(project, res.replace(/^res:\/\//, ''));
const md5 = (file) => createHash('md5').update(readFileSync(file)).digest('hex');

function walk(dir, found) {
  let entries;
  try { entries = readdirSync(dir, { withFileTypes: true }); } catch { return found; }
  if (entries.some((e) => e.name === '.gdignore')) return found;
  for (const e of entries) {
    if (e.isDirectory()) { if (!SKIP.has(e.name)) walk(join(dir, e.name), found); }
    else if (e.name.endsWith('.import') || ASSET.test(e.name)) found.push(join(dir, e.name));
  }
  return found;
}

/** Every res:// path on the .import file's dest_files line; empty when it has none. */
const destsOf = (text) => [...(/^dest_files=\[(.*)\]/m.exec(text)?.[1] ?? '').matchAll(/"([^"]+)"/g)].map((m) => m[1]);

function readStamps(project) {
  try { return JSON.parse(readFileSync(join(project, STAMPS), 'utf8')); } catch { return {}; }
}

/** Whether one asset needs importing, given the text of its .import file. `known` is what the stamp
 *  list said last time and `seen` collects what this run proved. */
function isStale(project, importText, known, seen) {
  if (/^importer="(keep|skip)"/m.test(importText)) return false;
  const src = /^source_file="([^"]+)"/m.exec(importText)?.[1];
  if (!src) return false;
  const srcFile = resPath(project, src);
  if (!existsSync(srcFile)) return false;
  const dests = destsOf(importText).map((d) => resPath(project, d));
  if (!dests.length || !dests.every(existsSync)) return true;
  // `x.png-<hash>.ctex` and `x.png-<hash>.bptc.ctex` both record their hash in `x.png-<hash>.md5`.
  const record = dests[0].replace(/(-[0-9a-f]{32})(\.[^./\\]+)+$/, '$1.md5');
  if (!existsSync(record)) return true;
  const was = /source_md5="([0-9a-f]+)"/.exec(readFileSync(record, 'utf8'))?.[1];
  if (!was) return true;
  const { mtimeMs, size } = statSync(srcFile);
  const stamp = `${mtimeMs}:${size}:${was}`;
  if (known[src] !== stamp && was !== md5(srcFile)) return true;
  seen[src] = stamp;
  return false;
}

const LFS_POINTER = 'version https://git-lfs';

/** True when `file` starts with a Git LFS pointer header (`git show HEAD:<png> > <png>` writes one). */
export function isLfsPointer(file) {
  try {
    const fd = openSync(file, 'r');
    const b = Buffer.alloc(LFS_POINTER.length);
    try { readSync(fd, b, 0, b.length, 0); } finally { closeSync(fd); }
    return b.toString('latin1') === LFS_POINTER;
  } catch { return false; }
}

/** {count, sample: [up to 5 res:// paths], pointers: [res:// paths that are LFS pointers]}: assets whose import no longer matches the source, plus
 *  assets with no .import at all. A tree with no import cache is not stale here: that is what
 *  ensureImport's own class-cache check is for. */
export function staleAssets(project, opts = {}) {
  const stale = staleFiles(project, opts);
  const res = (f) => `res://${f.slice(project.length + 1).split(/[\\/]/).join('/')}`;
  return { count: stale.length, sample: stale.slice(0, 5).map(res), pointers: stale.filter(isLfsPointer).map(res) };
}

/** Gives every stale source a new date. Godot's --import trusts the date, so without this a copy that
 *  kept an old one is skipped and the film goes on drawing the old pixels. */
export function touchStale(project) {
  const now = new Date();
  for (const f of staleFiles(project)) if (existsSync(f)) utimesSync(f, now, now);
}

function staleFiles(project, { onFirstScan = () => {} } = {}) {
  if (!existsSync(join(project, '.godot', 'imported'))) return [];
  const files = walk(project, []);
  const imports = new Set(files.filter((f) => f.endsWith('.import')));
  const stale = [];
  if (!existsSync(join(project, STAMPS))) onFirstScan();
  const known = readStamps(project);
  const seen = {};
  for (const f of files) {
    if (f.endsWith('.import')) { if (isStale(project, readFileSync(f, 'utf8'), known, seen)) stale.push(f.replace(/\.import$/, '')); }
    else if (!imports.has(`${f}.import`)) stale.push(f);
  }
  // A cache that cannot be written only costs the next run a re-hash.
  try { writeFileSync(join(project, STAMPS), JSON.stringify(seen)); } catch { /* the next run hashes */ }
  return stale;
}

