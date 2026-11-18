// Verdict classification, score and the text/JSON report for a mutation run. Pure.
export const VERDICTS = ['killed', 'survived', 'timeout', 'invalid'];
const PARSE = /Parse Error|Compile Error|Failed to load script|load_all: FAILED/;
const FAILED_N = /(\d+) failed/;

/** One run_unit result -> {verdict, via} | {infra: reason}.
 *  invalid = the mutant did not compile; killed = a test failed (or the code crashed at run time in a
 *  way the baseline never did); survived = every mapped test passed; timeout = the per-mutant cap hit. */
export function classifyRun({ status, out, timedOut }) {
  if (timedOut) return { verdict: 'timeout', via: 'per-mutant timeout' };
  if (status === 0) return { verdict: 'survived', via: 'all tests passed' };
  if (PARSE.test(out)) return { verdict: 'invalid', via: 'parse or compile error' };
  const n = Number(FAILED_N.exec(out)?.[1] ?? 0);
  if (n > 0) return { verdict: 'killed', via: `${n} failing test(s)` };
  if (/SCRIPT ERROR/.test(out)) return { verdict: 'killed', via: 'script error at run time' };
  return { infra: `exit ${status} with no test result: ${out.trim().split('\n').slice(-3).join(' | ')}` };
}

/** killed / (killed + survived); null when nothing was decided. */
export function scoreOf(counts) {
  const d = counts.killed + counts.survived;
  return d === 0 ? null : counts.killed / d;
}

export function tally(results) {
  const counts = { killed: 0, survived: 0, timeout: 0, invalid: 0 };
  for (const r of results) counts[r.verdict] += 1;
  return counts;
}

const pct = (s) => (s === null ? 'n/a' : `${(s * 100).toFixed(1)}%`);

/** `file:line op  before -> after  verdict` for one mutant. */
export function mutantLine(file, m, oracles) {
  const line = `${file}:${m.line} ${m.op}  ${m.before.trim()} -> ${m.after === '' ? '(removed)' : m.after}  ${m.verdict}`;
  if (!oracles) return line;
  if (m.verdict === 'survived') return `${line} [${oracles.join(', ')}]`;
  const reason = m.via === 'tests' ? m.detail : [m.via, m.detail].filter(Boolean).join(' ');
  return `${line} [${m.oracle}: ${reason}]`;
}

function oracleStats(oracles, results) {
  const kills = results.filter((m) => m.verdict === 'killed');
  const total = results.reduce((sum, m) => sum + m.ms, 0);
  const mean = results.length ? total / results.length / 1000 : 0;
  const counts = Array.from(new Set(oracles), (name) => `${name} ${kills.filter((m) => m.oracle === name).length}`);
  const via = new Map();
  for (const m of kills) via.set(m.via, (via.get(m.via) ?? 0) + 1);
  const causes = Array.from(via, ([name, count]) => `${name} ${count}`);
  return `; ${mean.toFixed(2)} s/mutant; kills by oracle: ${counts.join(', ')}; by via: ${causes.join(', ') || 'none'}`;
}

/** Text report: survivors first, then timeouts, invalid, killed; then the score line. */
export function formatReport({ file, results, totalMs, tests, sampled, oracles }) {
  const counts = tally(results);
  const order = ['survived', 'timeout', 'invalid', 'killed'];
  const scope = [oracles && `oracles: ${oracles.join(', ')}`, (!oracles || tests.length) && `tests: ${tests.join(', ')}`];
  const lines = [`mutate ${file}: ${results.length} mutant(s)${sampled ? ` (sampled from ${sampled})` : ''}, ${scope.filter(Boolean).join(', ')}`];
  for (const v of order) {
    for (const m of results.filter((r) => r.verdict === v)) lines.push(`  ${mutantLine(file, m, oracles)}`);
  }
  lines.push(`score ${pct(scoreOf(counts))} = killed ${counts.killed} / (killed ${counts.killed} + survived ${counts.survived});`
    + ` timeout ${counts.timeout}, invalid ${counts.invalid}; ${(totalMs / 1000).toFixed(0)} s`
    + (oracles ? oracleStats(oracles, results) : ''));
  return lines.join('\n');
}

/** The --json document (canonical-JSON'd by the caller). */
export function buildJson({ file, head, tests, oracles, results, totalMs, baselineMs, firstImportMs, total, max }) {
  const counts = tally(results);
  return {
    schema: 'gtai.mutate/1', file, head, tests, counts, score: scoreOf(counts),
    mutants_total: total, max: max ?? null, baseline_ms: baselineMs, first_import_ms: firstImportMs ?? null,
    total_ms: totalMs, ...(oracles && { oracles }),
    mutants: results.map((m) => ({ id: m.id, line: m.line, col: m.col, op: m.op, before: m.before, after: m.after,
      verdict: m.verdict, via: m.via, ms: m.ms, ...(oracles && { oracle: m.oracle }), ...(oracles && m.detail && { detail: m.detail }) })),
  };
}
