import { join } from 'node:path';
import { ensureImport, runGodot, runProcess, SCRIPT_ERROR } from '../lib/godot.mjs';
import { classifyRun } from './report.mjs';

export const ORACLES = ['tests', 'bake-check'];
const BASELINE_TIMEOUT_MS = 15 * 60 * 1000;

/** A successful exit also needs the complete OK record. Script errors can precede a bogus OK. */
export function classifyBake({ status, out, timedOut }) {
  if (timedOut) return { verdict: 'timeout', via: 'timeout' };
  if (/Parse Error|Compile Error|Failed to load script/i.test(out)) return { verdict: 'invalid', via: 'parse' };
  if (/SCRIPT ERROR/.test(out)) return { verdict: 'killed', via: 'crash' };
  const diff = /^bake_city: (GOLDEN-DIFF|NONDETERMINISTIC) ([^\r\n]+)\r?$/m.exec(out);
  if (status === 1 && diff) {
    const detail = /^(c_\d+_\d+\.bin)\b/.exec(diff[2])?.[1] ?? diff[2];
    return { verdict: 'killed', via: diff[1] === 'GOLDEN-DIFF' ? 'golden' : 'nondeterministic', detail };
  }
  if (status === 0 && /^bake_city: OK deterministic, matches golden\r?$/m.test(out)) {
    return { verdict: 'survived', via: 'ok' };
  }
  return { infra: `exit ${status} with no matching bake result: ${out.trim().split('\n').slice(-3).join(' | ')}` };
}

export function classifyTests(raw, explicit) {
  const result = classifyRun(raw);
  if (!explicit || result.infra) return result;
  if (result.verdict === 'killed') {
    return result.via === 'script error at run time' ? { verdict: 'killed', via: 'crash' }
      : { verdict: 'killed', via: 'tests', detail: result.via };
  }
  return { verdict: result.verdict, via: { survived: 'ok', invalid: 'parse', timeout: 'timeout' }[result.verdict] };
}

export function oracleRunners(wt, tests, env, explicit) {
  return {
    tests: async (timeoutMs) => {
      const raw = await runProcess(process.execPath, [join(wt, 'tools/tests/run_unit.mjs'),
        `--select=${tests.join(',')}`, '--no-rerun'], { cwd: wt, timeoutMs, env });
      return { ...raw, ...classifyTests(raw, explicit) };
    },
    'bake-check': async (timeoutMs) => {
      const raw = await runGodot(['-s', 'res://dev/bake_city.gd', '--', '--check', '--fail-fast'],
        { cwd: wt, timeoutMs, env, stopOn: SCRIPT_ERROR });
      return { ...raw, ...classifyBake(raw) };
    },
  };
}

/** Calibrate on the original bytes. Keep import time separate from the bake timeout. */
export async function baseline({ names, runners, wt, timeoutS, explicit, note, importProject = ensureImport }) {
  let durationMs = 0;
  let timeoutMs = 0;
  let firstImportMs = null;
  for (const name of names) {
    if (name === 'bake-check') {
      const imp = await importProject({ projectDir: join(wt, 'project') });
      if (imp.imported && imp.status !== 0) throw new Error(`baseline red: import exit ${imp.status}; nothing mutated.`);
      if (imp.imported) firstImportMs ??= imp.durationMs;
    }
    const base = await runners[name](BASELINE_TIMEOUT_MS);
    if (base.verdict !== 'survived') {
      const reason = explicit ? `${name}: ${base.infra ?? base.via}` : 'the mapped tests fail on the unmutated file';
      throw new Error(`baseline red: ${reason} (exit ${base.status}${base.timedOut ? ', timeout' : ''}); `
        + `nothing mutated.\n${base.out.trim().split('\n').slice(-12).join('\n')}`);
    }
    if (name === 'tests') {
      const imp = /class cache stale[\s\S]*?--import (?:done|FAILED[^\n]*?) in ([\d.]+) s/.exec(base.out);
      if (imp) firstImportMs ??= Math.round(Number(imp[1]) * 1000);
    }
    const seconds = Math.ceil(base.durationMs / 1000);
    timeoutMs += 1000 * (name === 'tests' ? Math.min(300, Math.max(90, seconds * 3)) : Math.max(60, seconds * 2));
    durationMs += base.durationMs;
    if (names.length > 1) note(`${name} baseline green in ${(base.durationMs / 1000).toFixed(1)} s`);
  }
  return { durationMs, firstImportMs, timeoutMs: timeoutS * 1000 || timeoutMs };
}

/** Only a survivor continues. The selected oracles share one per-mutant time budget. */
export async function judgeMutant(names, runners, timeoutMs) {
  let ms = 0;
  for (const [index, oracle] of names.entries()) {
    if (ms >= timeoutMs) return { oracle, verdict: 'timeout', via: 'timeout', ms };
    const { durationMs, verdict, via, detail, infra } = await runners[oracle](timeoutMs - ms);
    ms += durationMs;
    if (infra) return { infra, oracle };
    if (verdict !== 'survived' || index === names.length - 1) {
      return { oracle, verdict, via, ...(detail && { detail }), ms };
    }
  }
}
