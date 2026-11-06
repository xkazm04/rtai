// Layer-boundary lint (STANDARDS LAY-01, LAY-02, LAY-05, ARC-02 spirit): what ships must not
// depend on what does not ship, and core stays engine-agnostic infrastructure.
//
// Rules (each issue names the file:line):
//   1. project/boot, core and features may not name a `class_name` declared under project/dev or
//      project/tests (as a type, `is`, `as`, `.new()`, static call ...). A release export drops
//      dev/ and tests/ (export_presets exclude_filter), so such a script does not compile there.
//   2. The same three folders may not hold a string literal that is a bare res://dev/... or
//      res://tests/... path (no whitespace in it: prose messages that merely mention a path are
//      not references) outside a debug guard. GUARD HEURISTIC, deliberately simple: an earlier
//      line of the SAME function (or file scope) mentions `OS.is_debug_build()` or
//      `OS.has_feature("devtools")`/`("debug")`. The reference is then a run-time, debug-only load.
//   3. project/core may not name a `class_name` declared under project/features (core is
//      engine-agnostic infrastructure that features build on, never the reverse).
//   4. LAY-02: every directory and source/data file under project/ is snake_case lowercase.
//      Existing offenders are listed in NAMING_ALLOWLIST below with a reason (visible, not
//      renamed here because other lanes use the paths); a NEW offender fails.
//
// Comments and string contents are blanked before type names are matched, so prose such as a
// doc comment naming ArenaRigs never trips rule 1/3.
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join, relative, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { PROJECT } from '../lib/repo.mjs';

/** Project-relative path prefixes exempt from LAY-02, each with the reason. Shrink, never grow. */
export const NAMING_ALLOWLIST = [
  { prefix: 'dev/ghost-forms', why: 'kebab-case dev lane folder, referenced by other lanes; rename pending' },
  { prefix: 'dev/ghost-powers', why: 'kebab-case dev lane folder, referenced by other lanes; rename pending' },
  { prefix: 'quests/collect-call', why: 'kebab-case quest folder, referenced by the quest 1 data; rename pending' },
  { prefix: 'data/tables/arena_stations/', why: 'station tables are named after their hyphenated lane ids' },
  { prefix: 'assets/audio/voice/', why: 'voice clips are named speaker-line after the script ids' },
  { prefix: 'tests/golden/look/', why: 'golden look images are named after the look id and px/m (d4-48ppm)' },
];

/** Known core -> features dependencies (rule 3), each with a reason. Shrink, never grow. */
export const CORE_FEATURE_ALLOWLIST = [
  { file: 'core/render/print_stage.gd', name: 'SimConst', why: 'codegen constants (sim_constants.gd) live in features/city/sim; moving them under core/ is pending' },
];

/** Doc/legal file names that are conventionally upper case. */
const UPPER_OK = new Set(['README.md', 'VENDORS.md', 'LICENSE.md', 'CHANGELOG.md']);
const SKIP_DIRS = new Set(['.godot', 'addons', '.git', 'bin']);
const NAMED_EXT = /\.(gd|tscn|tres|res|json|po|gdshader|gdextension|cfg|png|ogg|wav|svg|uid|import)$/;
const SNAKE = /^[a-z0-9_]+$/;
const GUARD = /OS\.is_debug_build\(\)|OS\.has_feature\(\s*["'](?:devtools|debug)["']\s*\)/;

/**
 * Blanks comments and string contents (keeping quotes and line structure). Returns the code lines
 * and the string literals found, each with its 1-based line.
 */
export function scan(source) {
  const code = [];
  const strings = [];
  let line = '';
  let lineNo = 1;
  let i = 0;
  const n = source.length;
  const endLine = () => {
    code.push(line);
    line = '';
    lineNo += 1;
  };
  while (i < n) {
    const c = source[i];
    if (c === '\n') {
      endLine();
      i += 1;
    } else if (c === '#') {
      while (i < n && source[i] !== '\n') i += 1;
    } else if (c === '"' || c === "'") {
      const triple = source.startsWith(c.repeat(3), i);
      const q = triple ? c.repeat(3) : c;
      const startLine = lineNo;
      let text = '';
      line += q;
      i += q.length;
      while (i < n && !source.startsWith(q, i)) {
        if (source[i] === '\\' && i + 1 < n) {
          text += source[i] + source[i + 1];
          i += 2;
          continue;
        }
        if (source[i] === '\n') {
          if (!triple) break;
          endLine();
        }
        text += source[i];
        i += source[i] === '\n' ? 1 : 1;
      }
      if (source.startsWith(q, i)) i += q.length;
      line += q;
      strings.push({ line: startLine, text });
    } else {
      line += c;
      i += 1;
    }
  }
  code.push(line);
  return { code, strings };
}

const declared = (code) => {
  for (const l of code) {
    const m = /^class_name\s+([A-Za-z_]\w*)/.exec(l);
    if (m) return m[1];
  }
  return null;
};

const listFiles = (dir, base = dir, out = []) => {
  if (!existsSync(dir)) return out;
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    const abs = join(dir, e.name);
    if (e.isDirectory()) {
      if (!SKIP_DIRS.has(e.name)) listFiles(abs, base, out);
    } else out.push(relative(base, abs).split(sep).join('/'));
  }
  return out;
};

const layerOf = (relPath) => relPath.split('/')[0];

/** Index of class_name -> {layer, file} plus the scanned code of every .gd file. */
export function buildIndex(project) {
  const files = new Map();
  const classes = new Map();
  for (const f of listFiles(project).filter((p) => p.endsWith('.gd'))) {
    const s = scan(readFileSync(join(project, f), 'utf8'));
    files.set(f, s);
    const cn = declared(s.code);
    if (cn) classes.set(cn, { layer: layerOf(f), file: f });
  }
  return { files, classes };
}

const namesRegex = (names) =>
  names.length ? new RegExp(`(?<![\\w.$%&^@])(?:${names.join('|')})(?!\\w)`, 'g') : null;

/** Lines of `code` that name one of `re`'s classes: [{line, name}]. */
function mentions(code, re) {
  const out = [];
  if (!re) return out;
  code.forEach((text, idx) => {
    for (const m of text.matchAll(re)) out.push({ line: idx + 1, name: m[0] });
  });
  return out;
}

/** True when an earlier line of the same function (or the file scope) holds a debug guard. */
export function guarded(code, lineNo) {
  for (let i = lineNo - 1; i >= 0; i -= 1) {
    if (GUARD.test(code[i])) return true;
    if (/^(?:static\s+)?func\s/.test(code[i])) return false;
  }
  return false;
}

function namingIssues(project) {
  const issues = [];
  const seen = new Set();
  for (const f of listFiles(project)) {
    const parts = f.split('/');
    for (let k = 0; k < parts.length; k += 1) {
      const p = parts.slice(0, k + 1).join('/');
      if (seen.has(p)) continue;
      seen.add(p);
      const name = parts[k];
      const isFile = k === parts.length - 1;
      if (isFile && (UPPER_OK.has(name) || !NAMED_EXT.test(name))) continue;
      const stem = isFile ? name.split('.')[0] : name;
      if (name.startsWith('.') || SNAKE.test(stem)) continue;
      if (NAMING_ALLOWLIST.some((a) => (p + (isFile ? '' : '/')).startsWith(a.prefix))) continue;
      issues.push(`project/${p}: not snake_case lowercase (LAY-02); rename it or allowlist with a reason`);
    }
  }
  return issues;
}

export function check(project = PROJECT) {
  const { files, classes } = buildIndex(project);
  const byLayer = (...layers) =>
    [...classes].filter(([, v]) => layers.includes(v.layer)).map(([k]) => k);
  const shippedBad = namesRegex(byLayer('dev', 'tests'));
  const coreBad = namesRegex(byLayer('features'));
  const issues = [];
  for (const [f, { code, strings }] of files) {
    const layer = layerOf(f);
    if (!['boot', 'core', 'features'].includes(layer)) continue;
    for (const m of mentions(code, shippedBad)) {
      const where = classes.get(m.name);
      issues.push(`project/${f}:${m.line}: names ${m.name} (declared in project/${where.file}); a release export drops ${where.layer}/`);
    }
    if (layer === 'core') {
      for (const m of mentions(code, coreBad)) {
        if (CORE_FEATURE_ALLOWLIST.some((a) => a.file === f && a.name === m.name)) continue;
        issues.push(`project/${f}:${m.line}: core names ${m.name} (project/${classes.get(m.name).file}); core must not depend on features (LAY-05)`);
      }
    }
    for (const s of strings) {
      if (!/^res:\/\/(?:dev|tests)\/\S*$/.test(s.text) || guarded(code, s.line)) continue;
      issues.push(`project/${f}:${s.line}: unguarded "${s.text}" (dev/tests are not in release exports); wrap it in an OS.is_debug_build() check`);
    }
  }
  issues.push(...namingIssues(project));
  return { name: 'layers', ok: issues.length === 0, issues };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const r = check();
  for (const i of r.issues) console.error(i);
  console.log(`layers: ${r.ok ? 'ok' : `${r.issues.length} issue(s)`}`);
  process.exit(r.ok ? 0 : 1);
}
