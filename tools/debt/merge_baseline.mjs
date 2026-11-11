// A merge conflict in tools/debt/baseline.json, resolved without a person (n15 item 4): the looser of
// both sides, per metric and per file, with both sides' accepted reasons. Each side's numbers were
// already accepted on its branch, so the union raises nothing past what one branch had; the debt step
// that follows (`debt.mjs --check`, then `--update`) re-ratchets it to what the merged tree measures.
// By hand, inside a conflicted merge (the morning merge stops when a CODE file conflicts beside it):
//   node tools/debt/merge_baseline.mjs     writes the merged baseline and stages it; exit 0, 1 failed
// The merged tree can still measure above both sides (two lanes grew one file): then the commit's
// debt ratchet names it, and `node tools/debt/debt.mjs --accept-regression="<why>"` records it.
import { spawnSync } from 'node:child_process';
import { writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { total } from './metrics.mjs';

export const BASELINE = 'tools/debt/baseline.json';

const looser = (a = {}, b = {}) => {
  const out = { ...a };
  for (const [f, n] of Object.entries(b)) out[f] = Math.max(out[f] ?? n, n);
  return Object.fromEntries(Object.entries(out).sort(([x], [y]) => (x < y ? -1 : x > y ? 1 : 0)));
};

/** ours/theirs: parsed baseline.json objects. Returns the merged object (canonical key order). */
export function mergeBaselines(ours, theirs) {
  if (ours?.schema !== theirs?.schema) throw new Error(`baseline schemas differ: ${ours?.schema} vs ${theirs?.schema}`);
  const names = [...new Set([...Object.keys(ours.metrics ?? {}), ...Object.keys(theirs.metrics ?? {})])].sort();
  const metrics = {};
  for (const name of names) {
    const [a, b] = [ours.metrics?.[name] ?? {}, theirs.metrics?.[name] ?? {}];
    const files = looser(a.files, b.files);
    const accepted = [...new Set([...(a.accepted ?? []), ...(b.accepted ?? [])])];
    metrics[name] = { ...(accepted.length ? { accepted } : {}), files, total: total({ files }, name) };
  }
  return { metrics, schema: ours.schema };
}

/** The file text debt.mjs writes (2-space JSON, trailing newline), so the merge commit is not churn. */
export const baselineText = (obj) => `${JSON.stringify(obj, null, 2)}\n`;

/** Merges index stages 2 (ours) and 3 (theirs) of the baseline in `cwd`, writes and stages it.
 *  Returns a line saying what it did; throws with the reason when it cannot. */
export function resolveConflict(cwd, git = spawnSync) {
  const run = (args) => git('git', args, { cwd, encoding: 'utf8', windowsHide: true, maxBuffer: 64 * 1024 * 1024 });
  const [ours, theirs] = [run(['show', `:2:${BASELINE}`]), run(['show', `:3:${BASELINE}`])];
  if (ours.status !== 0 || theirs.status !== 0) throw new Error(`${BASELINE} is not in conflict here (no index stages 2 and 3)`);
  const merged = mergeBaselines(JSON.parse(ours.stdout), JSON.parse(theirs.stdout));
  writeFileSync(join(cwd, BASELINE), baselineText(merged));
  const added = run(['add', BASELINE]);
  if (added.status !== 0) throw new Error(`git add ${BASELINE} failed: ${String(added.stderr).trim()}`);
  return `merge_baseline: ${BASELINE} = the looser of both sides per metric and file, staged (${Object.keys(merged.metrics).length} metrics)`;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    console.log(resolveConflict(process.cwd()));
  } catch (e) {
    console.error(`merge_baseline: ${e.message}`);
    process.exit(1);
  }
}
