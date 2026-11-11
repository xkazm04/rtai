// A flag matched inside a dispatch helper that its caller never routes there can never fire. CastFlags
// splits apply() into helpers (`_walk(arg)`, `_ghost(arg)`, `_windup(arg)`) behind a guard such as
// `elif arg.begins_with("--rivet-walk=") or arg.begins_with("--rivet-bob"):`; c8d71e34a moved
// `--rivet-walk-armed=off` and `--rivet-stride=off` into `_walk` without widening the guard, and both
// did nothing for two nights while befores were filmed with them (n15 tools, 2026-11-11).
// For each `func _name(<v>: String)` in a file, every `"--..."` literal in its body must pass the guard
// of some `_name(<v>)` call in the same file: the `if`/`elif` condition right above the call, made of
// `<v>.begins_with("P")`, `<v> == "L"` and `<v> in CONST` (a same-file string list) joined by `or`.
// A guard with anything else (`and`, `not`, a call) is not judged: no false alarm, no claim.
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import { ownGdFiles, rel } from '../lib/repo.mjs';

export const NAME = 'flag-routes';

const indentOf = (line) => /^\t*/.exec(line)[0].length;
const code = (line) => line.replace(/#.*$/, '');

/** Same-file `const NAME ... = [ "a", "b" ]` string lists. */
export function constLists(src) {
  const lists = new Map();
  for (const m of src.matchAll(/^const\s+([A-Z][A-Z0-9_]*)\b[^=\n]*=\s*\[([\s\S]*?)\]/gm)) {
    lists.set(m[1], [...code(m[2]).matchAll(/"([^"]*)"/g)].map((x) => x[1]));
  }
  return lists;
}

/** `s` without parentheses that wrap all of it (`(a) or (b)` keeps its own). */
function unwrap(s) {
  let t = s.trim();
  while (t.startsWith('(') && t.endsWith(')')) {
    let depth = 0;
    for (let i = 0; i < t.length - 1; i++) {
      depth += t[i] === '(' ? 1 : t[i] === ')' ? -1 : 0;
      if (depth === 0) return t;
    }
    t = t.slice(1, -1).trim();
  }
  return t;
}

/** The terms of an `or`-only guard on `v`, or null when it holds anything else. */
export function guardTerms(cond, v, lists) {
  const terms = [];
  const parts = unwrap(cond).split(/\s+or\s+/);
  for (const raw of parts) {
    const p = unwrap(raw);
    let m;
    if ((m = new RegExp(`^${v}\\.begins_with\\("([^"]*)"\\)$`).exec(p))) terms.push((f) => f.startsWith(m[1]));
    else if ((m = new RegExp(`^${v}\\s*==\\s*"([^"]*)"$`).exec(p))) terms.push((f) => f === m[1]);
    else if ((m = new RegExp(`^${v}\\s+in\\s+([A-Z][A-Z0-9_]*)$`).exec(p)) && lists.has(m[1])) {
      const list = lists.get(m[1]);
      terms.push((f) => list.includes(f));
    } else return null;
  }
  return { parts: parts.map((p) => p.trim()), test: (f) => terms.some((t) => t(f)) };
}

/** The condition of the if/elif branch that holds line `at` (it may span lines in parentheses). */
function branchCondition(lines, at) {
  const ind = indentOf(lines[at]);
  for (let i = at - 1; i >= 0; i--) {
    const t = code(lines[i]);
    if (!t.trim()) continue;
    if (indentOf(lines[i]) >= ind) continue;
    let open = i;
    if (/^\s*\)\s*:\s*$/.test(t)) { // the `):` closing a condition that spans lines: find its `elif (`
      while (open > 0 && !(indentOf(lines[open]) === indentOf(lines[i]) && /^\s*(el)?if\b/.test(code(lines[open])))) open--;
    }
    if (!/^\s*(el)?if\b/.test(code(lines[open]))) return null;
    const parts = [code(lines[open]).replace(/^\s*(el)?if\s*/, '')];
    for (let j = open + 1; j < at && !/:\s*$/.test(parts.at(-1)); j++) parts.push(code(lines[j]).trim());
    return parts.join(' ').replace(/:\s*$/, '').replace(/\s+/g, ' ').replace(/\(\s+/g, '(').replace(/\s+\)/g, ')');
  }
  return null;
}

/** Issues for one file's source. */
export function unroutedFlags(path, src) {
  const lines = src.split('\n');
  const lists = constLists(src);
  const issues = [];
  lines.forEach((line, i) => {
    const h = /^(?:static\s+)?func\s+(_\w+)\(\s*(\w+)\s*:\s*String\s*\)/.exec(line);
    if (!h) return;
    const [, name] = h;
    const guards = [];
    lines.forEach((l, k) => {
      const call = new RegExp(`(?<![\\w.])${name}\\((\\w+)\\)`).exec(code(l));
      if (!call || k === i) return;
      const cond = branchCondition(lines, k);
      guards.push(cond === null ? null : guardTerms(cond, call[1], lists));
    });
    if (!guards.length || guards.some((g) => g === null)) return;
    for (let k = i + 1; k < lines.length && (!lines[k].trim() || /^[\t#]/.test(lines[k])); k++) {
      for (const m of code(lines[k]).matchAll(/"(--[^"]+)"/g)) {
        if (guards.some((g) => g.test(m[1]))) continue;
        issues.push(`${path}:${k + 1}: "${m[1]}" is matched in ${name}() but no caller routes it there `
          + `(guard: ${guards.map((g) => g.parts.join(' or ')).join(' | ')}): it can never fire`);
      }
    }
  });
  return issues;
}

export function flagRoutesCheck(read = () => ownGdFiles().map((f) => ({ path: rel(f), src: readFileSync(f, 'utf8') }))) {
  const issues = read().filter((f) => !f.path.startsWith('project/tests/')).flatMap((f) => unroutedFlags(f.path, f.src.replace(/\r\n/g, '\n')));
  return { name: NAME, ok: !issues.length, issues };
}

// `node tools/style/flag_routes.mjs <file.gd>...`: the same check on the files named (paths as given, so a
// lane without this check can run this copy on its own tree). Exit 0 clean, 1 issues, 2 usage.
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const files = process.argv.slice(2);
  if (!files.length) { console.error('usage: node tools/style/flag_routes.mjs <file.gd>...'); process.exit(2); }
  const issues = files.flatMap((f) => unroutedFlags(f, readFileSync(f, 'utf8').replace(/\r\n/g, '\n')));
  for (const i of issues) console.log(i);
  console.log(`flag-routes: ${issues.length} unrouted flag(s) in ${files.length} file(s)`);
  process.exit(issues.length ? 1 : 0);
}
