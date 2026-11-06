// Debt ratchet CLI + lint check. `node tools/debt/debt.mjs [--check | --update [--accept-regression="why"]]`.
// Debt can only go down: a metric worse than tools/debt/baseline.json fails; --update only tightens.
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { SPLIT_FROM, SPLIT_MAX_DROP, METRICS, computeMetrics, total } from './metrics.mjs';

export const ROOT = fileURLToPath(new URL('../..', import.meta.url)).replace(/[\/]$/, '');
export const BASELINE = fileURLToPath(new URL('./baseline.json', import.meta.url));
export const SCHEMA = 'gtai.debt-baseline/1';
const TIGHTEN = 'tighten: run node tools/debt/debt.mjs --update';
const unit = { dev_loc: 'lines', direct_cmdline_reads: 'reads', files_near_cap: 'lines', files_past_soft_cap: 'lines' };

export function loadBaseline(path = BASELINE) {
  if (!existsSync(path)) return null;
  return JSON.parse(readFileSync(path, 'utf8'));
}

/** Per-metric diff of current vs baseline files: regressions name metric + file + old -> new. */
export function compare(baseline, cur, names = METRICS) {
  const regressions = [];
  const tighten = [];
  const warnings = [];
  for (const name of names) {
    const base = baseline?.metrics?.[name];
    if (!base) {
      regressions.push(`${name}: no baseline entry (run node tools/debt/debt.mjs --update)`);
      continue;
    }
    const [bf, cf] = [base.files ?? {}, cur[name].files];
    const sumB = total({ files: bf }, name);
    const sumC = total(cur[name], name);
    const lines = [];
    for (const [p, v] of Object.entries(cf)) {
      const why = cur[name].why?.[p] ?? cur[name].names?.[p];
      if (!(p in bf)) lines.push(`  NEW ${p}${name.startsWith('files_') ? ` (${v} lines)` : ` (${v})`}${why ? ` [${why}]` : ''}`);
      else if (v > bf[p]) lines.push(`  ${p} grew from ${bf[p]} to ${v} ${unit[name] ?? ''}`.trimEnd());
    }
    if (lines.length || sumC > sumB) regressions.push(`${name}: ${sumB} -> ${sumC}`, ...lines);
    const better = Object.keys(bf).some((p) => !(p in cf) || cf[p] < bf[p]);
    if (!lines.length && (better || sumC < sumB)) tighten.push(name);
  }
  for (const [p, old] of Object.entries(baseline?.metrics?.files_near_cap?.files ?? {})) {
    const now = cur._lines[p];
    if (old >= SPLIT_FROM && now !== undefined && now < 300 && old - now > 0 && old - now < SPLIT_MAX_DROP) {
      warnings.push(`split-to-the-cap? ${p} went ${old} -> ${now} (freed ${old - now} < ${SPLIT_MAX_DROP}): split for real, not to just under 300`);
    }
  }
  return { regressions, tighten, warnings };
}

/** The lint-shaped check: {name, ok, issues, warnings, notes}. */
export function check({ root = ROOT, baselinePath = BASELINE } = {}) {
  const baseline = loadBaseline(baselinePath);
  if (!baseline) return { name: 'debt-ratchet', ok: false, issues: ['tools/debt/baseline.json missing: run node tools/debt/debt.mjs --update'], warnings: [], notes: [] };
  const r = compare(baseline, computeMetrics(root));
  return { name: 'debt-ratchet', ok: !r.regressions.length, issues: r.regressions, warnings: r.warnings, notes: r.tighten.length ? [`${TIGHTEN} (${r.tighten.join(', ')} improved)`] : [] };
}

const today = () => new Date().toISOString().slice(0, 10);

/** Builds the next baseline; refuses to raise a metric without `accept`. Returns {ok, baseline?, issues}. */
export function update({ root = ROOT, baselinePath = BASELINE, accept = null, now = today() } = {}) {
  const old = loadBaseline(baselinePath);
  const cur = computeMetrics(root);
  const metrics = {};
  const refused = [];
  for (const name of METRICS) {
    const prev = old?.metrics?.[name];
    const accepted = [...(prev?.accepted ?? [])];
    if (prev) {
      const mine = compare(old, cur, [name]).regressions;
      if (mine.length) {
        if (!accept) refused.push(...mine);
        else accepted.push(`${now}: ${accept} (${name} ${total({ files: prev.files }, name)} -> ${total(cur[name], name)})`);
      }
    }
    metrics[name] = { files: cur[name].files, total: total(cur[name], name), ...(accepted.length ? { accepted } : {}) };
  }
  if (refused.length) return { ok: false, issues: ['refusing to raise debt; fix it, or record it with --accept-regression="<reason>":', ...refused] };
  return { ok: true, baseline: { schema: SCHEMA, metrics }, issues: [] };
}

export function report(root = ROOT) {
  const cur = computeMetrics(root);
  const out = [];
  for (const name of METRICS) {
    out.push(`${name}: ${total(cur[name], name)}${cur[name].detail ? ` (${cur[name].detail})` : ''}`);
    const top = Object.entries(cur[name].files).sort((a, b) => b[1] - a[1]).slice(0, 5);
    for (const [p, v] of top) out.push(`  ${p}  ${v}`);
    const more = Object.keys(cur[name].files).length - top.length;
    if (more > 0) out.push(`  ... ${more} more`);
  }
  return out;
}

function main(argv) {
  const arg = (k) => argv.find((a) => a.startsWith(`--${k}=`))?.slice(k.length + 3) ?? null;
  if (argv.includes('--update')) {
    const res = update({ accept: arg('accept-regression') });
    if (!res.ok) {
      for (const i of res.issues) console.log(i);
      return 1;
    }
    writeFileSync(BASELINE, canonicalJson(res.baseline));
    console.log(`debt baseline written (${METRICS.map((m) => `${m}=${res.baseline.metrics[m].total}`).join(', ')})`);
    return 0;
  }
  if (argv.includes('--check')) {
    const c = check();
    for (const i of c.issues) console.log(i);
    for (const w of c.warnings) console.log(`warning: ${w}`);
    for (const n of c.notes) console.log(n);
    console.log(c.ok ? 'debt-ratchet: ok' : 'debt-ratchet: FAIL (debt went up; see tools/debt/README.md)');
    return c.ok ? 0 : 1;
  }
  for (const l of report()) console.log(l);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) process.exit(main(process.argv.slice(2)));
