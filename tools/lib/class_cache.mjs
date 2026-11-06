// Class-cache freshness: is project/.godot/global_script_class_cache.cfg still in step with the
// `class_name` declarations under project/? Every runner except run_unit used to run on whatever
// cache existed, so after a merge lanes saw hundreds of parse errors until someone ran --import.
//
// The cache is ConfigFile text: `list=[{ "base": &"X", "class": &"Y", ..., "path": "res://a.gd" }, ...]`.
// It is parsed as text here (no ConfigFile). Stale means: the cache is missing, a declared class is
// absent from it, a cached path no longer exists, a class moved file or changed its simple
// `extends` base. A body edit of a class file is NOT stale (the cache only holds the class list).
// Cost on the real tree (~1,100 .gd files, ~660 class files) is a stat scan plus reading only files
// the cache does not already vouch for; measured in class_cache.test.mjs's sibling probe (< 1 s).
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

export const CACHE_REL = join('.godot', 'global_script_class_cache.cfg');
const DECL = /^(?:@\w+(?:\([^)\n]*\))?[ \t]+)*class_name[ \t]+(\w+)([^\n]*)/m;
const EXTENDS = /^(?:@\w+(?:\([^)\n]*\))?[ \t]+)*(?:class_name[ \t]+\w+[ \t]+)?extends[ \t]+(\w+)[ \t]*(?:#.*)?$/m;

/** Parses the cache text into [{name, base, path}] (res:// paths). */
export function parseCache(text) {
  const out = [];
  for (const m of text.matchAll(/\{([^{}]*)\}/g)) {
    const field = (k) => new RegExp(`"${k}":[ \\t]*&?"([^"]*)"`).exec(m[1])?.[1];
    const name = field('class');
    if (name) out.push({ name, base: field('base') ?? '', path: field('path') ?? '' });
  }
  return out;
}

/** Every .gd under `dir` as res:// paths (skips .godot and any folder holding a .gdignore). */
function scanGd(dir, prefix, out) {
  let entries;
  try { entries = readdirSync(dir, { withFileTypes: true }); } catch { return out; }
  if (entries.some((e) => e.name === '.gdignore')) return out;
  for (const e of entries) {
    if (e.isDirectory()) {
      if (e.name !== '.godot' && e.name !== '.git') scanGd(join(dir, e.name), `${prefix}${e.name}/`, out);
    } else if (e.name.endsWith('.gd')) {
      out.push(`${prefix}${e.name}`);
    }
  }
  return out;
}

/** The class_name a script declares (and its simple extends base), or null. */
export function declaredClass(source) {
  const m = DECL.exec(source);
  if (!m) return null;
  const rest = /extends[ \t]+(\w+)[ \t]*(?:#.*)?$/.exec(m[2]);
  const base = rest ? rest[1] : (EXTENDS.exec(source)?.[1] ?? null);
  return { name: m[1], base };
}

/** {stale, reason, ms}. `reason` names the first difference found. */
export function isStale(projectDir) {
  const t0 = Date.now();
  const done = (stale, reason) => ({ stale, reason, ms: Date.now() - t0 });
  const cacheFile = join(projectDir, CACHE_REL);
  if (!existsSync(cacheFile)) return done(true, `${CACHE_REL} is missing`);
  const entries = parseCache(readFileSync(cacheFile, 'utf8'));
  const byPath = new Map(entries.map((e) => [e.path, e]));
  for (const e of entries) {
    if (e.path.startsWith('res://') && !existsSync(join(projectDir, e.path.slice(6)))) {
      return done(true, `class ${e.name} points at ${e.path}, which no longer exists`);
    }
  }
  const cacheMtime = statSync(cacheFile).mtimeMs;
  for (const res of scanGd(projectDir, 'res://', [])) {
    const cached = byPath.get(res);
    const file = join(projectDir, res.slice(6));
    // an older file the cache already lists cannot have gained a class_name since
    if (cached && statSync(file).mtimeMs <= cacheMtime) continue;
    const decl = declaredClass(readFileSync(file, 'utf8'));
    if (!decl) {
      if (cached) return done(true, `${res} no longer declares class ${cached.name}`);
      continue;
    }
    if (!cached) return done(true, `class ${decl.name} (${res}) is not in the cache`);
    if (cached.name !== decl.name) return done(true, `${res} declares ${decl.name}, the cache has ${cached.name}`);
    if (decl.base && cached.base && decl.base !== cached.base && !cached.base.includes('.')) {
      return done(true, `class ${decl.name} extends ${decl.base}, the cache has ${cached.base}`);
    }
  }
  return done(false, 'class cache is fresh');
}
