#!/usr/bin/env node
// The lint job (TST-04 job 1): every check runs; exit 1 if any fails.
//   node tools/lint/lint.mjs [--json]
import { readFileSync } from 'node:fs';
import { basename, dirname, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { PROJECT, ROOT, ownGdFiles, readJson, rel, run, walk } from '../lib/repo.mjs';
import { checkAll as styleChecks } from '../style/check_gd.mjs';
import { check as constantsCheck } from '../gen_constants/gen.mjs';
import { validate } from '../lib/mini_schema.mjs';
import { check as layersCheck } from './layers.mjs';
import { check as debtCheck } from '../debt/debt.mjs';

// Windows caps a command line at 32767 chars and the gdtoolkit launchers fail silently past it
// (exit 1, no output: 810 files were 32633 chars), so file lists go in batches of FILE_BATCH.
const FILE_BATCH = 200;
const tool = (name, cmd, flags, files = null) => {
  const batches = [];
  for (let i = 0; files && i < files.length; i += FILE_BATCH) batches.push(files.slice(i, i + FILE_BATCH));
  const issues = [];
  let ok = true;
  for (const batch of files ? batches : [[]]) {
    const res = run(cmd, [...flags, ...batch], { cwd: ROOT });
    if (res.status === 0) continue;
    ok = false;
    const out = res.out.split('\n').filter((l) => l.trim());
    issues.push(...(out.length ? out : [`${cmd} exit ${res.status} with no output`]));
  }
  return { name, ok, issues: issues.slice(0, 40) };
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

/** DAT-03: every data/tables/<name>.json has data/schemas/<name>.schema.json and passes it. */
function dataTables() {
  const issues = [];
  for (const table of walk(join(PROJECT, 'data', 'tables'), (n) => n.endsWith('.json'))) {
    // arena_stations/<lane>.json: one file per lane, all under the one station schema
    const station = basename(dirname(table)) === 'arena_stations';
    const base = station ? 'arena_station' : basename(table, '.json');
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

export function runLint() {
  const gd = ownGdFiles().map(rel);
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
  ];
  const failed = checks.filter((c) => !c.ok);
  const summary = failed.length
    ? `lint: ${failed.length} of ${checks.length} checks failed (${failed.map((c) => c.name).join(', ')})`
    : `lint: all ${checks.length} checks pass over ${gd.length} GDScript files`;
  return { ok: !failed.length, checks, summary, fileCount: gd.length };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = runLint();
  if (process.argv.includes('--json')) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    for (const c of result.checks) {
      console.log(`${c.ok ? 'ok  ' : 'FAIL'} ${c.name}`);
      for (const i of c.issues) console.log(`     ${i}`);
    }
    console.log(result.summary);
  }
  process.exit(result.ok ? 0 : 1);
}
