#!/usr/bin/env node
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, relative, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { readJson } from '../lib/repo.mjs';
import { MIN_AA_PAIRS, PROFILES } from './contract.mjs';
import { deathOverview } from './death_report.mjs';
import { deathChange, deathProfiles } from './death_cycle.mjs';
import { targets } from './death_score.mjs';
import { setArguments } from './plan_sets.mjs';
import { loadBatch } from './report.mjs';
import { fmt } from './report_tables.mjs';
import { confirmChange, pairNullRuns, pairRuns, verdictMode } from './tune_confirm.mjs';
import { floorMode } from './tune_floor.mjs';
import { floorReport, loadFloorBatch } from './tune_floor_report.mjs';
import { applyPlan, checkPlan, commitsFor, nightly, nightOf, ownBranch, planId, revertChanges, revertFor } from './tune_git.mjs';
import { PLAN_SCHEMA, propose } from './tune_propose.mjs';
import { atomicWrite, BASELINE, digest, ensureBaseline, git, inventory, withLock } from './tune_state.mjs';

const hashFile = (file) => digest(readFileSync(file));
const LEDGER = 'gtai.gauntlet-tune-ledger/1';

function options(argv, required, optional, flags = []) {
  const strings = [...required, ...optional].map((key) => [key, { type: 'string' }]);
  const booleans = flags.map((key) => [key, { type: 'boolean' }]);
  const { values } = parseArgs({ args: argv, options: Object.fromEntries([...strings, ...booleans]) });
  for (const key of required) if (!values[key]) throw new Error('--' + key + ' is required');
  return values;
}

export function artifact(root, file) {
  const name = relative(root, resolve(file)).replaceAll('\\', '/').toLowerCase();
  if (name === BASELINE) throw new Error('tuner baseline is write-once');
  if (/^(project|tools|\.git|\.githooks)\//.test(name)) throw new Error('choose an artifact output outside ' + name.split('/')[0]);
}

// Only a night with a dedicated plan.json can own its untracked before/after output.
function nightOutput(root, v) {
  if (!v['night-output']) return null;
  const dir = resolve(v['night-output']);
  if (dir === resolve(root) || resolve(v.plan) !== join(dir, 'plan.json'))
    throw new Error('--night-output must be the dedicated directory containing plan.json');
  artifact(root, v.plan);
  return dir;
}

function writePlan(root, v) {
  const target = Number(v['target-s'] ?? targets.wave_seconds.average), profile = v.profile ?? 'all';
  const max = Number(v.max ?? 6), killerShare = Number(v['killer-share'] ?? 0.5);
  const minN = Number(v['min-n'] ?? 3);
  if (!Number.isSafeInteger(minN) || minN < 1) throw new Error('--min-n must be a positive integer');
  if (!(target > 0 && Number.isFinite(target))) throw new Error('--target-s must be positive');
  if (![...PROFILES, 'human', 'all'].includes(profile)) throw new Error('unknown profile ' + profile);
  if (!Number.isSafeInteger(max) || max < 0) throw new Error('--max must be a nonnegative integer');
  if (!(killerShare > 0 && killerShare < 1)) throw new Error('--killer-share must be between 0 and 1');
  artifact(root, v.out);
  if (!v.out.toLowerCase().endsWith('.json')) throw new Error('--out must name a JSON file');
  if (existsSync(v.out) && readJson(v.out).schema !== PLAN_SCHEMA) throw new Error('refusing to replace a non-plan: ' + v.out);
  const batch = loadBatch(v.batch);
  const state = inventory(root);
  const baseline = ensureBaseline(root, state.entries);
  const plan = propose(batch, state, baseline, { target, profile, max, killerShare, minN, batchHash: hashFile(v.batch),
    metric: v.metric, night: nightOf(), used: new Set(nightly(root).keys()) });
  atomicWrite(v.out, canonicalJson(plan));
  for (const m of plan.misses) console.log(m.miss + ': ' + m.reason);
  console.log(plan.changes.length + ' changes from ' + plan.misses.length + ' measured misses in ' + v.out);
  return plan;
}

const cell = (s) => String(s).replaceAll('|', '\\|').replace(/[\r\n]+/g, ' ');
function markdown(ledger) {
  const lines = ['# Gauntlet tune ledger', '', 'Plan ' + ledger.plan_sha256 + '. Matched ' + ledger.matched_runs + ' of '
    + ledger.before_runs + ' before and ' + ledger.after_runs + ' after runs. The ' + ledger.floor_mode
    + ' floor decides each verdict.' + (ledger.null_sha256 ? ' Matched ' + ledger.matched_null_runs + ' null runs.' : ''), '',
    'Positive improvement means the measured miss shrank. An empty apply SHA means this branch has no commit for that edit. A revert SHA records an executed undo.', '',
    '| Knob | Before → after | Baseline | Measured miss | Target | Confirmation before → after | Pairs | Improvement (CI95) | Null-salt floor (pairs) | Cross-seed floor (pairs) | Deciding mode | Verdict | Deciding rule | Point | Strict | Apply / revert SHA |',
    '|---|---:|---:|---|---:|---:|---:|---:|---:|---:|---|---|---|---|---|---|'];
  const floorCell = (f) => {
    if (!f) return 'not measured';
    const value = Number.isFinite(f.estimate) && !Number.isFinite(f.floor) ? fmt(f.estimate) + '*' : fmt(f.floor);
    return value + ' (' + f.aa_pairs + ')';
  };
  for (const c of ledger.changes) {
    const unit = { death: 'waves', wave: 's', spread: 'waves', killer: 'death share', offer: c.metric.outcome === 'seconds' ? 's' : 'waves' }[c.metric.type];
    lines.push('| ' + [c.id, c.members ? '× ' + c.factor + ' (' + c.members.length + ' knobs)' : c.before + ' → ' + c.after, c.members ? 'per knob' : c.baseline, c.miss, c.metric.target,
      fmt(c.measured_before) + ' → ' + fmt(c.measured_after) + ' ' + unit
        + (c.metric.type === 'death' ? ' (' + c.censored_before + ' → ' + c.censored_after + ' censored, median uses lower bounds)' : ''), c.pairs,
      fmt(c.improvement) + ' (' + c.ci95.map(fmt).join(' to ') + ')',
      floorCell(c.floors['null-salt']), floorCell(c.floors['cross-seed']), c.floor_mode,
      c.verdict, c.verdict_mode, c.verdicts.point, c.verdicts.strict, [c.commit, c.revert_commit].filter(Boolean).join(' / ') || '—'].map(cell).join(' | ') + ' |');
  }
  if (!ledger.changes.length) lines.push('', 'The plan contained no changes.');
  else {
    lines.push('', '## A/A seed pairs', '',
      'Null-salt pairs each before seed with its null run. Cross-seed pairs adjacent before seeds in each group. '
      + 'The floor is the larger absolute CI95 endpoint for right minus left, with at least ' + MIN_AA_PAIRS
      + ' pairs. An asterisk marks an estimate below that minimum. Offer entries show take/decline seed pairs.', '',
      '| Knob | Floor mode | Group | Left seeds | Right seeds |', '|---|---|---|---|---|');
    const seedList = (side) => side.map((s) => Array.isArray(s) ? s.join('/') : s).join(', ');
    for (const c of ledger.changes) for (const [mode, floor] of Object.entries(c.floors))
      for (const group of floor?.aa_groups ?? [])
        lines.push('| ' + [c.id, mode, group.stratum, seedList(group.left), seedList(group.right)].map(cell).join(' | ') + ' |');
  }
  return lines.join('\n') + '\n';
}

function confirmation(root, v) {
  if (v.revert) ownBranch(root);
  const mode = floorMode(v['floor-mode']);
  const verdict = verdictMode(v.verdict);
  if (mode === 'null-salt' && !v.null) throw new Error('--null=<batch.json> is required for null-salt');
  const plan = readJson(v.plan);
  checkPlan(plan);
  const beforeHash = hashFile(v.before);
  if (plan.batch_sha256 !== beforeHash) throw new Error('before batch does not match the plan');
  const before = loadBatch(v.before), after = loadBatch(v.after);
  if ((before.args.salt ?? 0) !== (after.args.salt ?? 0)) throw new Error('before and after need the same bot salt');
  const neutral = v.null ? loadBatch(v.null) : null;
  const nullRows = neutral ? pairNullRuns(before, neutral) : null;
  const rows = pairRuns(before, after);
  const beforeRows = pairRuns(before, before);
  const settings = { beforeRows, nullRows, mode, verdict };
  const profiles = plan.metric === 'death' ? deathProfiles(rows, plan.profile, settings) : null;
  const receipts = commitsFor(root, plan);
  const ledger = { schema: LEDGER, plan_sha256: planId(plan), before_sha256: beforeHash, after_sha256: hashFile(v.after),
    floor_mode: mode, verdict_mode: verdict, null_sha256: v.null ? hashFile(v.null) : null, matched_null_runs: nullRows?.length ?? 0,
    before_runs: before.results.length, after_runs: after.results.length, matched_runs: rows.length,
    ...(profiles && { profiles, death_wave: { before: deathOverview(before), after: deathOverview(after) },
      batch_wall_s: { before: before.speed?.wall_s, null: neutral?.speed?.wall_s, after: after.speed?.wall_s } }),
    changes: plan.changes.map((c) => {
      const commit = receipts.get(c.id) ?? null;
      const result = profiles ? deathChange(c, profiles, verdict) : confirmChange(rows, c, settings);
      return { ...result, commit, revert_commit: revertFor(root, commit) };
    }) };
  const stem = join(resolve(v['ledger-dir'] ?? dirname(resolve(v.after))), 'tune-ledger');
  artifact(root, stem);
  if (existsSync(stem + '.json') && readJson(stem + '.json').schema !== LEDGER)
    throw new Error('ledger path already holds a different artifact');
  const save = () => {
    atomicWrite(stem + '.json', canonicalJson(ledger));
    atomicWrite(stem + '.md', markdown(ledger));
  };
  if (v.revert && plan.changes.length && !rows.length) {
    save();
    throw new Error('no matching seeds, profiles, controls and pick modes to confirm');
  }
  if (v.revert) revertChanges(root, ledger, save, [v.before, v.after, v.null, v.plan, stem + '.json', stem + '.md'].filter(Boolean), nightOutput(root, v));
  else save();
  for (const c of ledger.changes) console.log(c.id + ' ' + c.verdict + ', improvement ' + fmt(c.improvement)
    + ', CI95 ' + c.ci95.map(fmt).join(' to ') + ', ' + mode + ' floor ' + fmt(c.floor));
  console.log('wrote ' + stem + '.json and .md');
  return ledger;
}

export function main([command, ...argv]) {
  const root = git(process.cwd(), 'rev-parse', '--show-toplevel').trim();
  if (command === 'sets') {
    const v = options(argv, ['plan'], []);
    const args = setArguments(readJson(v.plan));
    for (const arg of args) console.log(arg);
    return args;
  }
  if (command === 'floor') {
    const v = options(argv, ['before', 'null'], ['out']);
    const report = floorReport(loadFloorBatch(v.before), loadFloorBatch(v.null));
    if (v.out) {
      artifact(root, v.out);
      if (!v.out.toLowerCase().endsWith('.md')) throw new Error('--out must name a Markdown file');
      atomicWrite(v.out, report);
    }
    process.stdout.write(report);
    return report;
  }
  if (command === 'propose') {
    if (argv.includes('--overwrite-baseline')) throw new Error('tuner baseline is write-once');
    const v = options(argv, ['batch', 'out'], ['target-s', 'profile', 'max', 'killer-share', 'min-n', 'metric']);
    return withLock(root, () => writePlan(root, v));
  }
  if (command === 'apply') {
    ownBranch(root);
    const v = options(argv, ['plan'], ['night-output']);
    return withLock(root, () => {
      const receipts = applyPlan(root, readJson(v.plan), nightOutput(root, v));
      for (const [id, sha] of receipts) console.log(id + ' ' + sha);
      return receipts;
    });
  }
  if (command === 'confirm') {
    const v = options(argv, ['before', 'after', 'plan'], ['night-output', 'floor-mode', 'verdict', 'null', 'ledger-dir'], ['revert']);
    return withLock(root, () => confirmation(root, v));
  }
  throw new Error('usage: tune.mjs propose|sets|apply|confirm|floor [options]');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { main(process.argv.slice(2)); }
  catch (err) { console.error(err.message); process.exitCode = 1; }
}
