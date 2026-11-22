import { relative, sep } from 'node:path';
import { targets } from './death_score.mjs';
import { fmt } from './report_tables.mjs';

const row = (...cells) => '| ' + cells.map((v) => String(v).replaceAll('|', '\\|').replace(/[\r\n]+/g, ' ')).join(' | ') + ' |';
const range = (lo, hi) => fmt(lo) + '–' + fmt(hi);

function action(c) {
  if (c.revert_commit) return 'Reverted';
  if (!c.commit) return 'Skipped';
  return c.verdict === 'kept' ? 'Kept' : 'Awaiting revert';
}

function journalLine(branch, changes) {
  const prefix = 'cycle ' + branch.slice('n23-tune-'.length) + ': ';
  if (!changes.length) return prefix + 'no change';
  return prefix + changes.map((c) => action(c).toLowerCase() + ' ' + c.id + ' '
    + (c.members ? '1x -> ' + c.factor + 'x' : c.before + ' -> ' + c.after)).join(', ');
}

function deathTable(ledger) {
  const { before, after } = ledger.death_wave;
  const lines = ['## Death wave by profile', '',
    'Survivors at a stopping limit contribute their last reached wave as a lower bound. Spreads show P25–P75 and the full range.', '',
    row('Profile', 'Target', 'Before median', 'Before spread (range)', 'After median', 'After spread (range)',
      'Censored before → after', 'Null floor (pairs)', 'Profile verdict', 'Moved away beyond floor'),
    '|---|---:|---:|---|---:|---|---:|---:|---|---|'];
  const spread = (p) => range(p.p25, p.p75) + ' (' + range(p.min, p.max) + ')';
  for (const p of ledger.profiles) {
    const a = before.profiles.find((v) => v.profile === p.profile), b = after.profiles.find((v) => v.profile === p.profile);
    lines.push(row(p.profile, p.metric.target, fmt(a.median), spread(a), fmt(b.median), spread(b),
      a.censored + ' → ' + b.censored, fmt(p.floor) + ' (' + p.aa_pairs + ')', p.verdict,
      p.verdict === 'too few pairs' ? 'undetermined' : p.beyond_floor_away ? 'yes' : 'no'));
  }
  return lines;
}

function separationTable(ledger) {
  const { before, after } = ledger.death_wave;
  const profiles = new Set(ledger.profiles.map((p) => p.profile));
  if (profiles.size < 2) return [];
  const limits = targets.separation;
  const lines = ['', '## Profile separation', '', 'Target gap ' + limits.min_wave_gap + ' waves. Target later-death share '
    + fmt(limits.min_seed_share * 100) + '% of shared seeds. Censored pairs with an unknown order stay in the denominator.', '',
    row('Profiles', 'Before gap', 'Before later / shared', 'Before unresolved', 'Before verdict',
      'After gap', 'After later / shared', 'After unresolved', 'After verdict'), '|---|---:|---:|---:|---|---:|---:|---:|---|'];
  const share = (c) => c.later + '/' + c.shared + (c.shared ? ' (' + fmt(100 * c.later / c.shared) + '%)' : '');
  for (const a of before.comparisons.filter((c) => profiles.has(c.a) && profiles.has(c.b))) {
    const b = after.comparisons.find((v) => v.a === a.a && v.b === a.b);
    lines.push(row(a.a + ' → ' + a.b, fmt(a.observedGap), share(a), a.unknown, a.verdict,
      fmt(b.observedGap), share(b), b.unknown, b.verdict));
  }
  return lines;
}

function changeTable(changes) {
  if (!changes.length) return ['The plan contained no changes.'];
  const lines = ['## Change ledger', '',
    row('Action', 'Knob', 'Before', 'After', 'Baseline', 'Measured miss', 'Confirmed before → after (pairs)',
      'Improvement (CI95)', 'A/A floor (pairs)', 'Verdict', 'Apply SHA', 'Revert SHA'),
    '|---|---|---:|---:|---:|---|---:|---:|---:|---|---|---|'];
  for (const c of changes) {
    lines.push(row(action(c), c.id, c.members ? 1 : c.before, c.members ? c.factor : c.after, c.members ? 'per knob' : c.baseline,
      c.miss, fmt(c.measured_before) + ' → ' + fmt(c.measured_after) + ' (' + c.pairs + ')',
      fmt(c.improvement) + ' (' + c.ci95.map(fmt).join(' to ') + ')', fmt(c.floor) + ' (' + c.aa_pairs + ')',
      c.verdict, c.commit ?? '—', c.revert_commit ?? '—'));
  }
  for (const c of changes) {
    if (c.profiles) lines.push('', 'Intended profiles for ' + c.id + ' include ' + c.profiles.join(', ') + '.');
    if (c.members) {
      lines.push('', row('Group member', 'Baseline', 'Before', 'After'), '|---|---:|---:|---:|');
      for (const m of c.members) lines.push(row(m.id, m.baseline, m.before, m.after));
    }
  }
  return lines;
}

export function summary(job, branch, ledger) {
  const link = (role) => relative(job.dir, job.files[role]).split(sep).map(encodeURIComponent).join('/');
  const b = job.batch;
  const lines = [journalLine(branch, ledger.changes), '', '# Gauntlet night', '', branch + ', ' + b.profile + ', ' + b.pick
    + ', ' + b.controls + ', seeds ' + b.seed0 + ' through ' + (b.seed0 + b.seeds - 1) + '. Matched '
    + ledger.matched_runs + ' of ' + ledger.before_runs + ' before and ' + ledger.after_runs + ' after runs.', '',
    '[Before batch](' + link('before') + ') · [Null batch](' + link('null') + ') · [Before report](before/report.md) · '
    + '[Plan](plan.json) · [Confirm batch](' + link('after') + ') · [Confirm report](after/report.md) · '
    + '[Seed pairs and verdicts](after/tune-ledger.md)', ''];
  if (ledger.batch_wall_s) {
    const timings = Object.entries(ledger.batch_wall_s).filter(([, s]) => Number.isFinite(s));
    if (timings.length) lines.push('Batch wall time in seconds — ' + timings.map(([arm, s]) => arm + ' ' + fmt(s)
      + (job.inputs[arm] ? ' (reused)' : '')).join(', ') + '.', '');
  }
  if (ledger.profiles) lines.push(...deathTable(ledger), ...separationTable(ledger), '');
  return [...lines, ...changeTable(ledger.changes), ''].join('\n');
}
