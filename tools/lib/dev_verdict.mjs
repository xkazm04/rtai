// One verdict line for a Godot run, so no lane hand-assembles "0 SCRIPT ERROR, 0 unknown arg" from
// its log again: the exit code (0 ok / 1 fail / 2 usage / -1 never ran, or a timeout), every
// SCRIPT ERROR line (with the first one's res:// location), every unknown-arg warning (boot.gd's
// "unknown launch arg", the dev scripts' "unknown argument") and, when the caller names one,
// whether the result file was written by THIS run. Used by tools/dev/run.mjs and tools/selftest.
//   verdict({status, out, timedOut, durationMs}, {resultFile, startedAt, notes}) -> {ok, line, ...}
import { existsSync, statSync } from 'node:fs';
import { SCRIPT_ERROR } from './godot.mjs';

const UNKNOWN_ARG = /unknown (?:launch )?arg(?:ument)?\s+(\S+)/i;
const LOCATION = /(res:\/\/[^\s():]+:\d+)/;
const LABELS = { 1: 'fail', 2: 'usage', [-1]: 'never ran' };
/** A result file stamped this long before the launch still counts. Linux stamps files from the kernel's
 *  coarse clock: on WSL Ubuntu a file written right after `Date.now()` measured up to 6.66 ms EARLIER
 *  (n15, 2000 writes), so the old 2 ms slack called fresh results stale on Linux, depending on the tick's
 *  phase (tools/selftest's runWorldLock test failed 3 of 3 there). A stale file is minutes old, never 1 s:
 *  the same rule as film.mjs FRESH_SLACK_MS. */
export const MTIME_SLACK_MS = 1000;

/** [{text, at}] for each SCRIPT ERROR line; `at` is the first res:// location on it or the next 3 lines. */
export function scriptErrors(out) {
  const lines = String(out ?? '').split(/\r?\n/);
  const found = [];
  lines.forEach((line, i) => {
    if (!SCRIPT_ERROR.test(line)) return;
    const near = lines.slice(i, i + 4).map((l) => LOCATION.exec(l)?.[1]).find(Boolean);
    found.push({ text: line.trim(), at: near ?? null });
  });
  return found;
}

/** The args named by unknown-arg warnings, in order. */
export const unknownArgs = (out) => String(out ?? '').split(/\r?\n/)
  .map((l) => UNKNOWN_ARG.exec(l)?.[1]).filter(Boolean);

/** 'fresh' | 'stale' | 'missing' for a result file against the launch time. */
export function resultState(file, startedAt = 0) {
  if (!existsSync(file)) return 'missing';
  return statSync(file).mtimeMs + MTIME_SLACK_MS < startedAt ? 'stale' : 'fresh';
}

function head(res, ok) {
  if (res.timedOut) return `FAIL timeout after ${Math.round((res.durationMs ?? 0) / 1000)} s`;
  if (res.stopped) return `FAIL stopped at the first script error after ${((res.durationMs ?? 0) / 1000).toFixed(1)} s (--keep-going to wait it out)`;
  const label = LABELS[res.status];
  return `${ok ? 'ok' : 'FAIL'} exit ${res.status}${label ? ` (${label})` : ''}`;
}

/** {ok, line, scriptErrors, unknownArgs, result}. ok = exit 0, no timeout, no SCRIPT ERROR, no
 *  unknown arg and (when `resultFile` is given) a result written after `startedAt`. */
export function verdict(res, { resultFile = null, startedAt = 0, notes = [] } = {}) {
  const errors = scriptErrors(res.out);
  const unknown = unknownArgs(res.out);
  const result = resultFile ? resultState(resultFile, startedAt) : null;
  const ok = !res.timedOut && !res.stopped && res.status === 0 && !errors.length && !unknown.length && (!result || result === 'fresh');
  const first = errors[0];
  const parts = [
    head(res, ok),
    `SCRIPT ERROR ${errors.length}${first ? ` (first ${first.at ?? first.text})` : ''}`,
    `unknown arg ${unknown.length}${unknown.length ? `: ${unknown.join(', ')}` : ''}`,
    ...(result ? [`result ${result}`] : []),
    ...notes,
  ];
  return { ok, line: parts.join('; '), scriptErrors: errors, unknownArgs: unknown, result };
}
