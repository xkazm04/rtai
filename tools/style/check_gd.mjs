// In-house GDScript gates gdlint does not cover (GDS-03, GDS-08, SIM-02, SEC-02, STM-03, GIT-05).
// Pure: each check returns {name, ok, issues[]}. Comment text is stripped before matching.
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import { PROJECT, ownGdFiles, rel, walk } from '../lib/repo.mjs';

export const FILE_SOFT_LINES = 200;
export const FILE_HARD_LINES = 300;
export const FUNC_MAX_LINES = 40;

const STEAM_FILE = 'project/core/platform/backends/steam_backend.gd';
const LOG_FILE = 'project/core/log/log.gd';
const BANNED = [
  { re: /(^|[^.\w])(print|prints|printt|print_rich)\(/, why: 'bare print: use Log (GDS-08)', allow: [LOG_FILE] },
  { re: /(^|[^.\w])printerr\(/, why: 'printerr outside Log/test runners (GDS-08)', allow: [LOG_FILE, 'project/tests/'] },
  { re: /(^|[^.\w])(randf|randi|randf_range|randi_range|randfn|seed|randomize)\(/, why: 'global RNG: own a seeded RandomNumberGenerator (SIM-02)' },
  { re: /\b(str_to_var|bytes_to_var_with_objects|ConfigFile)\b|get_var\(\s*true|store_var\([^)]*,\s*true/, why: 'object-instantiating parser on data (SEC-02)' },
];

/** Drops `#` comments (outside string literals) so prose never trips a grep. */
export function stripComment(line) {
  let quote = null;
  for (let i = 0; i < line.length; i += 1) {
    const c = line[i];
    if (quote) {
      if (c === '\\') i += 1;
      else if (c === quote) quote = null;
    } else if (c === '"' || c === "'") quote = c;
    else if (c === '#') return line.slice(0, i);
  }
  return line;
}

/** Top-level functions longer than FUNC_MAX_LINES (signature to last non-blank body line). */
export function longFunctions(lines) {
  const out = [];
  let start = -1;
  let name = '';
  let last = -1;
  const close = () => {
    if (start >= 0 && last - start + 1 > FUNC_MAX_LINES) out.push({ name, lines: last - start + 1 });
  };
  lines.forEach((line, i) => {
    const m = /^(?:@\w+\s+)*(?:static\s+)?func\s+(\w+)/.exec(line);
    if (m) {
      close();
      [start, name, last] = [i, m[1], i];
    } else if (start >= 0 && line.trim() && !/^\s/.test(line) && !line.startsWith('#')) {
      close();
      start = -1;
    } else if (start >= 0 && line.trim()) {
      last = i;
    }
  });
  close();
  return out;
}

export function checkAll(files = ownGdFiles()) {
  const size = { name: 'gd-size', ok: true, issues: [], warnings: [] };
  const banned = { name: 'banned-api', ok: true, issues: [] };
  const steam = { name: 'steam-grep', ok: true, issues: [] };
  for (const abs of files) {
    const path = rel(abs);
    const lines = readFileSync(abs, 'utf8').split('\n');
    if (lines.at(-1) === '') lines.pop();
    if (lines.length > FILE_HARD_LINES) size.issues.push(`${path}: ${lines.length} lines > ${FILE_HARD_LINES}`);
    else if (lines.length > FILE_SOFT_LINES) size.warnings.push(`${path}: ${lines.length} lines > ${FILE_SOFT_LINES}`);
    for (const f of longFunctions(lines)) {
      size.issues.push(`${path}: func ${f.name} is ${f.lines} lines > ${FUNC_MAX_LINES}`);
    }
    lines.forEach((raw, i) => {
      const code = stripComment(raw);
      for (const b of BANNED) {
        if (b.re.test(code) && !(b.allow ?? []).some((a) => path.startsWith(a))) {
          banned.issues.push(`${path}:${i + 1}: ${b.why}`);
        }
      }
      if (/\bSteam\./.test(code) && path !== STEAM_FILE) {
        steam.issues.push(`${path}:${i + 1}: Steam. outside ${STEAM_FILE} (STM-03)`);
      }
    });
  }
  const binary = walk(PROJECT, (n) => /\.(scn|res)$/.test(n), ['.godot']);
  const gitFmt = { name: 'text-resources', ok: !binary.length, issues: binary.map((b) => `${rel(b)}: binary .scn/.res (GIT-05)`) };
  for (const c of [size, banned, steam]) c.ok = c.issues.length === 0;
  return [size, banned, steam, gitFmt];
}

if (import.meta.url === `file://${process.argv[1].replace(/\\/g, '/').replace(/^\/?/, '/')}`) {
  const checks = checkAll();
  for (const c of checks) {
    console.log(`${c.ok ? 'ok  ' : 'FAIL'} ${c.name}`);
    for (const i of [...c.issues, ...(c.warnings ?? [])]) console.log(`     ${i}`);
  }
  process.exit(checks.every((c) => c.ok) ? 0 : 1);
}
