// The Codex test factory's ledger: one JSON line per event, append only. What the owner has never had
// measured is the Claude saving, so this keeps measured and estimated numbers apart by name: Codex
// time and machine grades are measured, and the Claude cost of a review session is measured but
// sharing one session across the tasks it reviewed is an estimate, and is labelled so.
import { appendFileSync, existsSync, mkdirSync, readFileSync } from 'node:fs';
import { dirname } from 'node:path';

export function append(file, event) {
  mkdirSync(dirname(file), { recursive: true });
  appendFileSync(file, `${JSON.stringify(event)}\n`);
}

export const read = (file) => (existsSync(file) ? readFileSync(file, 'utf8').split('\n').filter(Boolean).map((l) => JSON.parse(l)) : []);

/** Folds events into one row per task id, in the order tasks were first seen. */
export function rows(events) {
  const byId = new Map();
  for (const e of events) {
    const row = byId.get(e.id) ?? { id: e.id, task: null, review: null };
    if (e.type === 'task') row.task = e;
    else if (e.type === 'review') row.review = e;
    byId.set(e.id, row);
  }
  return [...byId.values()];
}

/** The tasks waiting for Claude: passed the machine, not reviewed. Failures are never queued. */
export const queue = (allRows) => allRows.filter((r) => r.task?.machine?.pass && !r.review);

const usdOf = (state, n) => state?.iterations?.find((i) => i.n === n)?.costUsd ?? null;

/** Totals for the report. `state` is a runner state.json. reviewUsd is measured per session; the
 *  share per task divides a session by the tasks it reviewed, which is an estimate. */
export function totals(allRows, state = null) {
  const tasks = allRows.filter((r) => r.task);
  const reviewed = allRows.filter((r) => r.review);
  const sessions = new Set(reviewed.map((r) => r.review.iteration).filter((n) => n !== null && n !== undefined));
  const known = [...sessions].map((n) => usdOf(state, n));
  const reviewUsd = known.some((u) => u === null) ? null : known.reduce((a, b) => a + b, 0);
  const counts = (v) => reviewed.filter((r) => r.review.verdict === v).length;
  return {
    measured: {
      tasks: tasks.length,
      refused_by_meter: tasks.filter((r) => r.task.refused).length,
      machine_pass: tasks.filter((r) => r.task.machine?.pass).length,
      machine_fail: tasks.filter((r) => r.task.machine && !r.task.machine.pass && !r.task.refused).length,
      codex_secs: tasks.reduce((a, r) => a + (r.task.codex_secs ?? 0), 0),
      awaiting_review: queue(allRows).length,
      accepted: counts('accepted'),
      accepted_after_revision: counts('accepted-after-revision'),
      rejected: counts('rejected'),
      review_lines_changed: reviewed.reduce((a, r) => a + (r.review.changed_lines ?? 0), 0),
      review_sessions: sessions.size,
      review_sessions_usd: reviewUsd,
    },
    estimated: {
      note: 'one session reviews many tasks, so a task\'s share of it is an even split, not a measurement',
      review_usd_per_task: reviewUsd !== null && reviewed.length ? reviewUsd / reviewed.length : null,
    },
    unmeasured: ['the Claude cost of writing the same tests without Codex: there is no control run, so no saving can be stated as measured'],
  };
}
