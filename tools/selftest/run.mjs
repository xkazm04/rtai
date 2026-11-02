#!/usr/bin/env node
// Render selftest (the `selftest` evidence): renders the city in the D4 look at 32 and 48 px/m,
// windowed (headless renders nothing), and sanity-checks the frames (dev/selftest/city_selftest.gd);
// then the look golden frames (dev/selftest/look_golden.gd, --fixed-fps 60): every look profile at
// 32 / 48 / 64 px/m diffed against tests/golden/look.
//   node tools/selftest/run.mjs
import { existsSync, mkdirSync, readFileSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, godotBin, run } from '../lib/repo.mjs';

export const RESULT_NAME = 'selftest-result.json';
export const GOLDEN_NAME = 'look-golden-result.json';

/** The look golden frames: { ok, frames, summary }; frames is [] when it did not run. */
export function runLookGolden(outDir, out) {
  rmSync(join(outDir, GOLDEN_NAME), { force: true });
  const res = run(godotBin(), ['--fixed-fps', '60', '--path', 'project', 'res://dev/selftest/look_golden.tscn', '--',
    `--out=${out}`], { cwd: ROOT, timeout: 180000 });
  const file = join(outDir, GOLDEN_NAME);
  if (!existsSync(file)) return { ok: false, frames: [], summary: `look goldens: no result (exit ${res.status})` };
  const r = JSON.parse(readFileSync(file, 'utf8'));
  const frames = r.frames ?? [];
  const worst = Math.max(0, ...frames.map((f) => f.mean ?? 255));
  const bad = frames.filter((f) => !f.ok).map((f) => `${f.look}@${f.ppm}`);
  return { ok: res.status === 0 && r.ok === true && frames.length > 0, frames,
    summary: `look goldens ${frames.length - bad.length}/${frames.length} within mean ${r.max_mean} (worst ${worst.toFixed(2)})`
      + (bad.length ? `; OFF: ${bad.join(', ')}` : '') };
}

/** Splits audit offenders into tolerated debt (data/tables/accent_debt.json: accent + layer + ppm
 *  up to max_px) and new offenders. Strings come from accent_audit.gd: "<accent> on <layer>: <n> px",
 *  prefixed here with "<ppm> px/m "; anything else (crowd looks) is never debt. */
export function judgeAccents(offenders, debtRows) {
  const debt = [];
  const fresh = [];
  for (const o of offenders) {
    const m = /^(\d+) px\/m (\w+) on (\w+): (\d+) px$/.exec(o);
    const row = m && debtRows.find((d) => d.ppm === Number(m[1]) && d.accent === m[2] && d.layer === m[3]);
    if (row && Number(m[4]) <= row.max_px) debt.push(`${o} (debt ${row.id}, <= ${row.max_px}, ${row.owner})`);
    else fresh.push(o);
  }
  return { debt, fresh };
}

/** The colour-doctrine audit (dev/selftest/accent_audit.gd). Gating: an offender not covered by
 *  accent_debt.json (or above its max_px) fails the selftest. { ok, frames, offenders, summary }. */
export function runAccentAudit(outDir, out) {
  rmSync(join(outDir, 'accent-audit.json'), { force: true });
  run(godotBin(), ['--fixed-fps', '60', '--path', 'project', 'res://dev/selftest/accent_audit.tscn', '--', `--out=${out}`],
    { cwd: ROOT, timeout: 180000 });
  const file = join(outDir, 'accent-audit.json');
  if (!existsSync(file)) return { ok: false, frames: [], offenders: [], summary: 'accent audit: no result' };
  const r = JSON.parse(readFileSync(file, 'utf8'));
  const frames = r.frames ?? [];
  const offenders = frames.flatMap((f) => f.offenders.map((o) => `${f.ppm} px/m ${o}`));
  const share = frames.map((f) => `${f.ppm}: ${(f.frame_share * 100).toFixed(2)} %`).join(', ');
  // the atlas crowd split at the source: a pedestrian look with vermilion outside its hit flash
  const looks = r.crowd_atlas_by_look ?? [];
  for (const l of looks.filter((x) => x.off_doctrine)) offenders.push(`crowd look ${l.look} (${l.tag}) ${l.vermilion} vermilion texels`);
  const crowd = looks.length ? `; crowd atlas ${looks.filter((x) => x.kind === 'ped' && !x.off_doctrine).length}/`
    + `${looks.filter((x) => x.kind === 'ped').length} pedestrian looks on doctrine` : '';
  const debtRows = JSON.parse(readFileSync(join(ROOT, 'project', 'data', 'tables', 'accent_debt.json'), 'utf8')).rows;
  const { debt, fresh } = judgeAccents(offenders, debtRows);
  const verdict = fresh.length ? `NEW off-doctrine: ${fresh.join('; ')}` : 'no new off-doctrine accents';
  const paid = debtRows.filter((d) => !debt.some((x) => x.includes(`(debt ${d.id},`))).map((d) => d.id);
  return { ok: fresh.length === 0, frames, offenders,
    summary: `accent pixels ${share}${crowd}; ${verdict}${debt.length ? `; known debt: ${debt.join('; ')}` : ''}`
      + (paid.length ? `; debt rows no longer seen (delete them): ${paid.join(', ')}` : '') };
}

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
  const cityOk = res.status === 0 && r.ok === true && pngs.length === frames.length && frames.length > 0;
  const detail = frames.map((f) => `${f.ppm} px/m ${f.ok ? 'ok' : `FAIL (${f.why})`}, ${f.visible_actors} actors, `
    + `${f.distinct_colours} colours`).join('; ');
  const gold = runLookGolden(outDir, out);
  const accents = runAccentAudit(outDir, out);
  const summary = `selftest: D4 city frames ${cityOk ? 'rendered' : 'FAILED'} (${detail}); ${r.art_loaded} art textures, `
    + `${r.placeholders} placeholders, prewarm ${Math.round(r.prewarm_ms)} ms; ${gold.summary}; ${accents.summary}`;
  const metrics = { lookGoldenFrames: gold.frames.length, lookGoldenOk: gold.ok ? 1 : 0, artLoaded: r.art_loaded,
    placeholders: r.placeholders, prewarmMs: r.prewarm_ms, textureLoadMs: r.texture_load_ms };
  for (const f of frames) metrics[`visibleActors${f.ppm}ppm`] = f.visible_actors;
  for (const f of accents.frames) metrics[`accentShare${f.ppm}ppm`] = f.frame_share;
  metrics.accentOffenders = accents.offenders.length;
  metrics.accentNewOffenders = accents.ok ? 0 : Math.max(1, accents.offenders.length);
  const ok = cityOk && gold.ok && accents.ok;
  const all = [...frames, ...gold.frames];
  const goldPngs = gold.frames.map((f) => f.file).filter((f) => existsSync(join(outDir, f)));
  return { ok, counts: { passed: all.filter((f) => f.ok).length, failed: all.filter((f) => !f.ok).length, skipped: 0 },
    summary, metrics, artifacts: [...pngs, RESULT_NAME, ...goldPngs, ...(gold.frames.length ? [GOLDEN_NAME] : []),
      ...(accents.frames.length ? ['accent-audit.json'] : [])] };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const r = runSelftest(join(ROOT, 'build', 'selftest'));
  console.log(r.summary);
  process.exit(r.ok ? 0 : 1);
}
