#!/usr/bin/env node
// The parity gate (NAT-06): native CitySim vs the GDScript reference, 1200 steps, exact, plus a
// planted mutation that must be caught. Needs the native library for this platform.
//   node tools/tests/run_parity.mjs
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { describe, removeStale, runGodot } from '../lib/godot.mjs';

export const RESULT_NAME = 'parity-result.json';
export const LOG_NAME = 'parity.log';

export async function runParity(outDir, steps = 1200) {
  mkdirSync(outDir, { recursive: true });
  const out = join(outDir, RESULT_NAME).replace(/\\/g, '/');
  removeStale(join(outDir, RESULT_NAME));
  const res = await runGodot(['-s', 'res://tests/parity/run_parity.gd', '--', `--steps=${steps}`, `--out=${out}`],
    { name: 'parity' });
  writeFileSync(join(outDir, LOG_NAME), `===== parity (${describe(res)})\n${res.out}`, 'utf8');
  if (res.timedOut) return { ok: false, summary: `parity: ${describe(res)}`, artifacts: [LOG_NAME] };
  if (res.status === 2 || !existsSync(out)) {
    return { ok: false, summary: 'parity: native CitySim not loaded (build native/ and --import first)', artifacts: [LOG_NAME] };
  }
  const r = JSON.parse(readFileSync(out, 'utf8'));
  const ok = res.status === 0 && r.exact === true && r.planted_mutation_caught === true;
  const metrics = {
    steps: r.steps,
    checks: r.checks,
    snapshotFloats: r.snapshot_floats,
    stepMsGd: Math.round(r.step_ms_a * 1000) / 1000,
    stepMsNative: Math.round(r.step_ms_b * 10000) / 10000,
    plantedMismatchStep: r.planted_first_mismatch_step,
  };
  const summary = ok
    ? `parity: native == GDScript reference bit for bit over ${r.steps} steps (${r.checks} snapshot checks, `
      + `${r.snapshot_floats} floats); planted mutation caught at step ${r.planted_first_mismatch_step}`
    : `parity: FAILED (exact=${r.exact}, first mismatch step ${r.first_mismatch_step}, planted caught=${r.planted_mutation_caught})`;
  return { ok, counts: { passed: ok ? 2 : (r.exact ? 1 : 0), failed: ok ? 0 : (r.exact ? 1 : 2), skipped: 0 },
    summary, metrics, artifacts: [RESULT_NAME, LOG_NAME] };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const r = await runParity(join(ROOT, 'build', 'test-results'));
  console.log(r.summary);
  process.exit(r.ok ? 0 : 1);
}
