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
    const row = byId.get(e.id) ?? { id: e.id, started: null, task: null, review: null };
    if (e.type === 'started') row.started = e;
    else if (e.type === 'control') row.control = e;
    else if (e.type === 'task') row.task = e;
    else if (e.type === 'review') row.review = e;
    byId.set(e.id, row);
  }
  return [...byId.values()];
}

/** The tasks waiting for Claude: passed the machine, not reviewed. Failures are never queued. */
export const queue = (allRows) => allRows.filter((r) => r.task?.machine?.pass && !r.review);

const usdOf = (state, n) => state?.iterations?.find((i) => i.n === n)?.costUsd ?? null;

/** Started and never recorded a result: the run died from outside, so its Codex time is unknown. */
export const vanished = (allRows) => allRows.filter((r) => r.started && !r.task);

/** Per module with both a control and a Codex task whose review was done by a measured subagent: the
 *  Claude tokens of each path, measured both sides. Codex's own time is beside it, not converted. */
export function paired(allRows) {
  const out = [];
  for (const c of allRows.filter((r) => r.control).map((r) => r.control)) {
    const t = allRows.find((r) => r.task?.unit === c.unit && Number.isInteger(r.review?.review_tokens));
    if (!t) continue;
    out.push({ unit: c.unit, claude_alone_tokens: c.claude_tokens, claude_alone_secs: c.secs, codex_secs: t.task.codex_secs ?? null,
      review_tokens: t.review.review_tokens, review_secs: t.review.review_secs, claude_tokens_saved: c.claude_tokens - t.review.review_tokens,
      review_changed_lines: t.review.changed_lines, control_review_changed_lines: c.review_changed });
  }
  return out;
}

/** Totals for the report. `state` is a runner state.json. reviewUsd is measured per session; the
 *  share per task divides a session by the tasks it reviewed, which is an estimate. */
export function totals(allRows, state = null) {
  const tasks = allRows.filter((r) => r.task);
  const reviewed = allRows.filter((r) => r.review);
  const sessions = new Set(reviewed.map((r) => r.review.iteration).filter((n) => n !== null && n !== undefined));
  const known = [...sessions].map((n) => usdOf(state, n));
  // A review no session paid for is an unknown cost, never a free one.
  const unattributed = reviewed.filter((r) => r.review.iteration === null || r.review.iteration === undefined).length;
  const reviewUsd = unattributed || known.some((u) => u === null) ? null : known.reduce((a, b) => a + b, 0);
  const counts = (v) => reviewed.filter((r) => r.review.verdict === v).length;
  return {
    measured: {
      tasks: tasks.length,
      started_and_never_finished: vanished(allRows).map((r) => r.id),
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
      reviews_without_a_session: unattributed,
      review_sessions_usd: reviewUsd,
    },
    estimated: {
      note: 'one session reviews many tasks, so a task\'s share of it is an even split, not a measurement; and a session also builds other things, so the figure is an upper bound on the review\'s cost',
      review_usd_per_task: reviewUsd !== null && reviewed.length ? reviewUsd / reviewed.length : null,
    },
    controls: allRows.filter((r) => r.control).map((r) => r.control),
    paired: paired(allRows),
    unmeasured: allRows.some((r) => r.control)
      ? ['dollars of a control run: a subagent reports tokens and seconds, not dollars, so a saving is stated in tokens and seconds per module that has a control, never extrapolated to the rest']
      : ['the Claude cost of writing the same tests without Codex: there is no control run, so no saving can be stated as measured'],
  };
}
