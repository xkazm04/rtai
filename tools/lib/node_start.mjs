// What a test that kills a child on a timer must allow for: the timer starts before the child's first
// line runs, and a cold `node` start takes 0.1 s on a quiet machine and 2-5 s beside two Godot runs
// and lint (n15 item 6: the morning_run and step_guard flakes). A fixed budget hides that term; this
// measures it now and gives it to the budget explicitly, per node start the budget contains.
import { spawnSync } from 'node:child_process';
import { performance } from 'node:perf_hooks';

/** Each cold start in a budget is given this many times its measured cost. */
export const START_FACTOR = 3;

/** The slowest of `samples` cold starts of this node, in ms, measured now (same env and preloads). */
export function nodeStartMs(samples = 2, spawn = spawnSync) {
  let worst = 0;
  for (let i = 0; i < samples; i++) {
    const t0 = performance.now();
    spawn(process.execPath, ['-e', ''], { stdio: 'ignore', windowsHide: true });
    worst = Math.max(worst, performance.now() - t0);
  }
  return worst;
}

/** A budget in ms: what the test means to allow (`baseMs`) plus `starts` cold node starts. */
export const budgetMs = (baseMs, starts, startMs = nodeStartMs()) => baseMs + START_FACTOR * starts * startMs;
