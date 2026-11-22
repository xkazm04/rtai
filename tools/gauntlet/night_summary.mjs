import { fmt } from './report_tables.mjs';

export function summary(job, branch, ledger) {
  const lines = ['# Gauntlet night', '', branch + ', ' + job.profile + ', ' + job.pick + ', ' + job.controls
    + ', seeds 1 through ' + job.seeds + '. Matched ' + ledger.matched_runs + ' of ' + ledger.before_runs
    + ' before and ' + ledger.after_runs + ' after runs.', '',
    '[Before batch](before/batch.json) · [Null batch](null/batch.json) · [Before report](before/report.md) · [Plan](plan.json) · '
    + '[Confirm batch](after/batch.json) · [Confirm report](after/report.md) · [Seed pairs and verdicts](after/tune-ledger.md)', ''];
  if (ledger.changes.length) {
    lines.push('| Action | Knob | Before | After | Baseline | Measured miss | Confirmed before → after (pairs) | Improvement (CI95) | A/A floor (pairs) | Verdict | Apply SHA | Revert SHA |',
      '|---|---|---:|---:|---:|---|---:|---:|---:|---|---|---|');
    for (const c of ledger.changes) {
      const action = c.revert_commit ? 'Reverted' : !c.commit ? 'Skipped' : c.verdict === 'kept' ? 'Kept' : 'Awaiting revert';
      const measured = fmt(c.measured_before) + ' → ' + fmt(c.measured_after) + ' (' + c.pairs + ')';
      const cells = [action, c.id, c.members ? 1 : c.before, c.members ? c.factor : c.after, c.members ? 'per knob' : c.baseline, c.miss, measured, fmt(c.improvement) + ' (' + c.ci95.map(fmt).join(' to ') + ')',
        fmt(c.floor) + ' (' + c.aa_pairs + ')', c.verdict, c.commit ?? '—', c.revert_commit ?? '—'];
      lines.push('| ' + cells.map((s) => String(s).replaceAll('|', '\\|').replace(/[\r\n]+/g, ' ')).join(' | ') + ' |');
    }
  } else lines.push('The plan contained no changes.');
  return lines.join('\n') + '\n';
}
