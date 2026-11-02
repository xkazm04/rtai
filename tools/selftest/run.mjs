#!/usr/bin/env node
// Render selftest (the `selftest` evidence): renders the city in the D4 look at 32 and 48 px/m,
// windowed (headless renders nothing), and sanity-checks the frames (dev/selftest/city_selftest.gd).
//   node tools/selftest/run.mjs
import { existsSync, mkdirSync, readFileSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, godotBin, run } from '../lib/repo.mjs';

export const RESULT_NAME = 'selftest-result.json';

export function runSelftest(outDir) {
  mkdirSync(outDir, { recursive: true });
  const out = outDir.replace(/\\/g, '/');
  for (const stale of [RESULT_NAME, 'selftest-32ppm.png', 'selftest-48ppm.png']) {
    rmSync(join(outDir, stale), { force: true });
  }
  const res = run(godotBin(), ['--path', 'project', 'res://dev/selftest/city_selftest.tscn', '--', `--out=${out}`],
    { cwd: ROOT, timeout: 180000 });
  const file = join(outDir, RESULT_NAME);
  if (!existsSync(file)) {
    return { ok: false, summary: `selftest: no result (exit ${res.status}; needs a display)` };
  }
  const r = JSON.parse(readFileSync(file, 'utf8'));
  const frames = r.frames ?? [];
  const pngs = frames.map((f) => f.file).filter((f) => existsSync(join(outDir, f)));
  const ok = res.status === 0 && r.ok === true && pngs.length === frames.length && frames.length > 0;
  const detail = frames.map((f) => `${f.ppm} px/m ${f.ok ? 'ok' : `FAIL (${f.why})`}, ${f.visible_actors} actors, `
    + `${f.distinct_colours} colours`).join('; ');
  const summary = `selftest: D4 city frames ${ok ? 'rendered' : 'FAILED'} (${detail}); ${r.art_loaded} art textures, `
    + `${r.placeholders} placeholders, prewarm ${Math.round(r.prewarm_ms)} ms`;
  const metrics = { artLoaded: r.art_loaded, placeholders: r.placeholders, prewarmMs: r.prewarm_ms,
    textureLoadMs: r.texture_load_ms };
  for (const f of frames) metrics[`visibleActors${f.ppm}ppm`] = f.visible_actors;
  return { ok, counts: { passed: frames.filter((f) => f.ok).length, failed: frames.filter((f) => !f.ok).length, skipped: 0 },
    summary, metrics, artifacts: [...pngs, RESULT_NAME] };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const r = runSelftest(join(ROOT, 'build', 'selftest'));
  console.log(r.summary);
  process.exit(r.ok ? 0 : 1);
}
