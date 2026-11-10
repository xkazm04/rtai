#!/usr/bin/env node
// The lint job (TST-04 job 1): every check runs; exit 1 if any fails.
//   node tools/lint/lint.mjs [--json] [--scope=<file of staged paths>]   (--scope: tools/lint/scope.mjs)
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, dirname, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { PROJECT, ROOT, ownGdFiles, readJson, rel, run, walk } from '../lib/repo.mjs';
import { checkAll as styleChecks } from '../style/check_gd.mjs';
import { check as constantsCheck } from '../gen_constants/gen.mjs';
import { validate } from '../lib/mini_schema.mjs';
import { check as layersCheck } from './layers.mjs';
import { check as debtCheck } from '../debt/debt.mjs';
import { narrow, readScope, toolTestInputs } from './scope.mjs';

// Windows caps a command line at 32767 chars and the gdtoolkit launchers fail silently past it
// (exit 1, no output: 810 files were 32633 chars), so file lists go in batches of FILE_BATCH.
const FILE_BATCH = 200;
/** Issue lines a check prints before the rest go to a file (failing test names are never capped). */
export const SHOWN = 40;

/** Every failing test of a `node --test` run, as `<file:line:col> <name>`, from the spec reporter's
 *  closing "failing tests:" section. On 2026-11-10 a 40-line cap hid which tool test failed on CI. */
export function failingTests(out) {
  const lines = String(out).split(/\r?\n/);
  const start = lines.findIndex((l) => /^✖ failing tests:/.test(l));
  if (start < 0) return [];
  const names = [];
  for (let i = start + 1; i < lines.length - 1; i++) {
    const at = /^test at (.+)$/.exec(lines[i]);
    const nm = at && /^✖ (.+?)(?: \([\d.]+m?s\))?$/.exec(lines[i + 1]);
    if (nm) names.push(`${at[1]} ${nm[1]}`);
  }
  return names;
}

/** The lines lint prints for one check: every failing test name, then at most SHOWN issue lines;
 *  past that, `spill(check)` writes them all to a file and the last line names it with the count. */
export function report(c, spill) {
  const lines = [];
  if (c.failing?.length) lines.push(`${c.failing.length} failing test(s):`, ...c.failing.map((f) => `  FAILED ${f}`));
  lines.push(...c.issues.slice(0, SHOWN));
  if (c.issues.length > SHOWN) lines.push(`... ${c.issues.length - SHOWN} more not shown: all ${c.issues.length} lines in ${spill(c)}`);
  return lines;
}

const spillFile = (c) => {
  const dir = join(ROOT, 'build', 'lint');
  mkdirSync(dir, { recursive: true });
  const file = join(dir, `${c.name}.txt`);
  writeFileSync(file, `${[...(c.failing ?? []).map((f) => `FAILED ${f}`), ...c.issues].join('\n')}\n`, 'utf8');
  return rel(file);
};

const tool = (name, cmd, flags, files = null, env = null) => {
  const batches = [];
  for (let i = 0; files && i < files.length; i += FILE_BATCH) batches.push(files.slice(i, i + FILE_BATCH));
  const issues = [];
  const failing = [];
  let ok = true;
  for (const batch of files ? batches : [[]]) {
    const res = run(cmd, [...flags, ...batch], { cwd: ROOT, ...(env ? { env } : {}) });
    if (res.status === 0) continue;
    ok = false;
    const out = res.out.split('\n').filter((l) => l.trim());
    issues.push(...(out.length ? out : [`${cmd} exit ${res.status} with no output`]));
    failing.push(...failingTests(res.out));
  }
  return { name, ok, issues, ...(failing.length ? { failing } : {}) };
};

function jsonCanonical() {
  const files = [
    ...walk(join(PROJECT, 'data'), (n) => n.endsWith('.json')),
    ...walk(join(ROOT, 'steam'), (n) => n.endsWith('.json')),
    join(PROJECT, '.gutconfig.json'),
  ];
  const issues = [];
  for (const f of files) {
    const text = readFileSync(f, 'utf8');
    try {
      if (canonicalJson(JSON.parse(text)) !== text) issues.push(`${rel(f)}: not canonical (sorted keys, 2-space, LF)`);
    } catch (e) {
      issues.push(`${rel(f)}: ${e.message}`);
    }
  }
  return { name: 'json-canonical', ok: !issues.length, issues };
}

/** `signal name(a: int, b: StringName)` -> {name: 'a:int,b:StringName'} from events.gd. */
export function declaredSignals(src) {
  const out = {};
  for (const m of src.matchAll(/^signal\s+(\w+)\s*(?:\(([^)]*)\))?/gm)) {
    const params = (m[2] ?? '').split(',').map((p) => p.trim()).filter(Boolean);
    out[m[1]] = params.map((p) => p.replace(/\s+/g, '')).join(',');
  }
  return out;
}

function eventsRegistry() {
  const reg = readJson(join(PROJECT, 'data', 'schemas', 'events.json'));
  const declared = declaredSignals(readFileSync(join(PROJECT, 'core', 'events', 'events.gd'), 'utf8'));
  const issues = [];
  for (const s of Object.keys(declared)) {
    if (!reg.signals.some((r) => r.name === s)) issues.push(`signal ${s} missing from events.json`);
  }
  for (const sig of reg.signals) {
    const listed = sig.params.map((p) => `${p.name}:${p.type}`).join(',');
    if (!(sig.name in declared)) issues.push(`events.json lists ${sig.name}, not declared in Events`);
    else if (declared[sig.name] !== listed) {
      issues.push(`${sig.name}: Events declares (${declared[sig.name]}), events.json says (${listed})`);
    }
    if (!sig.emitter || !sig.doc || typeof sig.wired !== 'boolean') {
      issues.push(`${sig.name}: needs emitter, doc and a boolean wired (ARC-06)`);
    }
  }
  const count = Object.keys(declared).length;
  if (count > reg.cap) issues.push(`${count} signals > cap ${reg.cap} (ARC-06)`);
  return { name: 'events-registry', ok: !issues.length, issues };
}

/** Per-lane registration dirs under data/tables -> the schema every file in them obeys. */
const LANE_TABLE_DIRS = { arena_stations: 'arena_station', card_sets: 'card_set' };

/** DAT-03: every data/tables/<name>.json has data/schemas/<name>.schema.json and passes it. */
function dataTables() {
  const issues = [];
  for (const table of walk(join(PROJECT, 'data', 'tables'), (n) => n.endsWith('.json'))) {
    // <dir>/<lane>.json: one file per lane, all under the dir's one schema (LANE_TABLE_DIRS)
    const base = LANE_TABLE_DIRS[basename(dirname(table))] ?? basename(table, '.json');
    const schemaPath = join(PROJECT, 'data', 'schemas', `${base}.schema.json`);
    let schema;
    try {
      schema = readJson(schemaPath);
    } catch {
      issues.push(`${rel(table)}: no schema at ${rel(schemaPath)}`);
      continue;
    }
    for (const e of validate(schema, readJson(table))) issues.push(`${rel(table)}: ${e}`);
  }
  return { name: 'data-tables', ok: !issues.length, issues };
}

/** ARC-02: at most seven autoloads; an eighth needs a decisions.md line and this cap raised. */
export const AUTOLOAD_CAP = 7;
function autoloadBudget() {
  const text = readFileSync(join(PROJECT, 'project.godot'), 'utf8');
  const section = /^\[autoload\]\n([\s\S]*?)(?=^\[|(?![\s\S]))/m.exec(text)?.[1] ?? '';
  const names = section.split('\n').filter((l) => /^\w+=/.test(l)).map((l) => l.split('=')[0]);
  const ok = names.length <= AUTOLOAD_CAP;
  const issues = ok ? [] : [`${names.length} autoloads (${names.join(', ')}) > ${AUTOLOAD_CAP} (ARC-02)`];
  return { name: 'autoload-budget', ok, issues };
}

/** The Node tools no other gate runs: about 300 tests in a second, so they cannot rot unseen. */
/** The environment without git's own variables. Inside the pre-commit hook git sets GIT_DIR and
 *  GIT_INDEX_FILE, so a tool test running `git -C <tmp>` would commit into THIS repo and re-init its
 *  shared config (it did, n11 tools 01:39: core.bare=true broke the main checkout). */
export const withoutGitEnv = (env = process.env) => Object.fromEntries(Object.entries(env).filter(([k]) => !/^GIT_/i.test(k)));

const TOOL_TEST_GLOBS = ['tools/film/*.test.mjs', 'tools/merge/*.test.mjs', 'tools/codex/*.test.mjs', 'tools/gate/*.test.mjs'];

/** The scope a `--scope=<file>` names (null: the full lint), with a line saying which. */
export function scopeOf(argv) {
  const arg = argv.find((a) => a.startsWith('--scope='));
  if (!arg) return { scope: null, line: null };
  const staged = readScope(arg.slice('--scope='.length));
  if (!staged) return { scope: null, line: `lint: scope file ${arg.slice(8)} unreadable: full lint` };
  const testFiles = TOOL_TEST_GLOBS.map((g) => dirname(g)).flatMap((d) => walk(join(ROOT, d), (n) => n.endsWith('.test.mjs'), []));
  const scope = narrow(staged, ownGdFiles().map(rel), toolTestInputs(testFiles.map((f) => readFileSync(f, 'utf8'))));
  return { scope, line: scope ? scope.line : 'lint: the commit stages a path outside project/: full lint' };
}

export function runLint(scope = null) {
  const all = ownGdFiles().map(rel);
  const gd = scope ? scope.gd : all;
  const node = process.execPath;
  const gen = join('tools', 'achievements', 'gen.mjs');
  const checks = [
    tool('gdformat', 'gdformat', ['--check', '--line-length', '100'], gd),
    tool('gdlint', 'gdlint', [], gd),
    ...styleChecks(),
    jsonCanonical(),
    eventsRegistry(),
    autoloadBudget(),
    dataTables(),
    constantsCheck(),
    layersCheck(),
    debtCheck(),
    tool('achievements-validate', node, [gen, 'validate']),
    tool('achievements-drift', node, [gen, '--check']),
    ...(scope && !scope.toolTests ? [] : [tool('tool-tests', node, ['--test', '--test-reporter=spec', ...TOOL_TEST_GLOBS], null, withoutGitEnv())]),
  ];
  const failed = checks.filter((c) => !c.ok);
  const summary = failed.length
    ? `lint: ${failed.length} of ${checks.length} checks failed (${failed.map((c) => c.name).join(', ')})`
    : `lint: all ${checks.length} checks pass over ${scope ? `${gd.length} staged of ${all.length}` : gd.length} GDScript files`;
  return { ok: !failed.length, checks, summary, fileCount: gd.length };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const { scope, line } = scopeOf(process.argv);
  if (line) console.log(line);
  const result = runLint(scope);
  if (process.argv.includes('--json')) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    for (const c of result.checks) {
      console.log(`${c.ok ? 'ok  ' : 'FAIL'} ${c.name}`);
      for (const i of report(c, spillFile)) console.log(`     ${i}`);
    }
    console.log(result.summary);
  }
  process.exit(result.ok ? 0 : 1);
}
