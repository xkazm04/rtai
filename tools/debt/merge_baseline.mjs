// A merge conflict in tools/debt/baseline.json, resolved without a person (n15 item 4): the looser of
// both sides, per metric and per file, with both sides' accepted reasons. Each side's numbers were
// already accepted on its branch, so the union raises nothing past what one branch had; the debt step
// that follows (`debt.mjs --check`, then `--update`) re-ratchets it to what the merged tree measures.
import { canonicalJson } from '../lib/canonical_json.mjs';
import { total } from './metrics.mjs';

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
