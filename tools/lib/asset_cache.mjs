// Is the import cache still in step with the assets on disk? Godot only re-imports when something
// asks it to, so a film or test after a PNG swap draws the old texture and looks like a real result
// (FRICTION, 5 journals). Godot's own test is the source's MD5 against the one recorded at import;
// an mtime check first keeps this to a stat scan unless something was really touched.
import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

const ASSET = /\.(png|jpe?g|webp|svg|ogg|wav|mp3|ttf|otf)$/i;
const SKIP = new Set(['.godot', '.git']);

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

/** Whether one asset needs importing, given the text of its .import file. */
function isStale(project, importText) {
  const src = /^source_file="([^"]+)"/m.exec(importText)?.[1];
  const dest = /^dest_files=\["([^"]+)"/m.exec(importText)?.[1];
  if (!src || !dest) return false;
  const srcFile = resPath(project, src);
  if (!existsSync(srcFile)) return false;
  const destFile = resPath(project, dest);
  // `x.png-<hash>.ctex` and `x.png-<hash>.bptc.ctex` both record their hash in `x.png-<hash>.md5`.
  const record = destFile.replace(/(-[0-9a-f]{32})(\.[^./\\]+)+$/, '$1.md5');
  if (!existsSync(destFile) || !existsSync(record)) return true;
  if (statSync(srcFile).mtimeMs <= statSync(destFile).mtimeMs + 2000) return false;
  const was = /source_md5="([0-9a-f]+)"/.exec(readFileSync(record, 'utf8'))?.[1];
  return was !== md5(srcFile);
}

/** {count, sample: [up to 5 res:// paths]}: assets whose import no longer matches the source, plus
 *  assets with no .import at all. A tree with no import cache is not stale here: that is what
 *  ensureImport's own class-cache check is for. */
export function staleAssets(project) {
  if (!existsSync(join(project, '.godot', 'imported'))) return { count: 0, sample: [] };
  const files = walk(project, []);
  const imports = new Set(files.filter((f) => f.endsWith('.import')));
  const stale = [];
  for (const f of files) {
    if (f.endsWith('.import')) { if (isStale(project, readFileSync(f, 'utf8'))) stale.push(f.replace(/\.import$/, '')); }
    else if (!imports.has(`${f}.import`)) stale.push(f);
  }
  const res = (f) => `res://${f.slice(project.length + 1).split(/[\\/]/).join('/')}`;
  return { count: stale.length, sample: stale.slice(0, 5).map(res) };
}

