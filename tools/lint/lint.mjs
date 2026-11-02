#!/usr/bin/env node
// The lint job (TST-04 job 1): every check runs; exit 1 if any fails.
//   node tools/lint/lint.mjs [--json]
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { PROJECT, ROOT, ownGdFiles, readJson, rel, run, walk } from '../lib/repo.mjs';
import { checkAll as styleChecks } from '../style/check_gd.mjs';

const tool = (name, cmd, args) => {
  const res = run(cmd, args, { cwd: ROOT });
  const issues = res.status === 0 ? [] : res.out.split('\n').filter((l) => l.trim()).slice(0, 40);
  return { name, ok: res.status === 0, issues };
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

function eventsRegistry() {
  const reg = readJson(join(PROJECT, 'data', 'schemas', 'events.json'));
  const src = readFileSync(join(PROJECT, 'core', 'events', 'events.gd'), 'utf8');
  const declared = [...src.matchAll(/^signal\s+(\w+)/gm)].map((m) => m[1]).sort();
  const listed = reg.signals.map((s) => s.name).sort();
  const issues = [];
  for (const s of declared) if (!listed.includes(s)) issues.push(`signal ${s} missing from events.json`);
  for (const s of listed) if (!declared.includes(s)) issues.push(`events.json lists ${s}, not declared in Events`);
  if (declared.length > reg.cap) issues.push(`${declared.length} signals > cap ${reg.cap} (ARC-06)`);
  return { name: 'events-registry', ok: !issues.length, issues };
}

export function runLint() {
  const gd = ownGdFiles().map(rel);
  const node = process.execPath;
  const gen = join('tools', 'achievements', 'gen.mjs');
  const checks = [
    tool('gdformat', 'gdformat', ['--check', '--line-length', '100', ...gd]),
    tool('gdlint', 'gdlint', gd),
    ...styleChecks(),
    jsonCanonical(),
    eventsRegistry(),
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
