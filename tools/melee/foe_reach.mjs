#!/usr/bin/env node
// n31 melee 01b part A: enemy melee on Rivet, drawn reach vs hit reach (measures only).
//   node tools/melee/foe_reach.mjs [--label=before] [--step=3] [--from=<raw probe json>]
// Runs project/dev/melee_n31/foe_reach.gd under the lane Godot lock (build/n31/godot.lock), then writes
// evidence/n31-melee/01-foes/<label>/foe_reach.json (raw trials + per-foe verdicts) and <label>.md.
import { mkdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';

const r3 = (n) => (n === null || n === undefined ? null : Number(n.toFixed(3)));

export function parseArgs(argv) {
  const o = { label: 'before', step: 3, from: null };
  for (const a of argv) {
    const m = /^--(label|step|from)=(.+)$/.exec(a);
    if (!m) throw new Error('bad argument ' + a);
    if (m[1] === 'step') o.step = Number(m[2]);
    else o[m[1]] = m[2];
  }
  if (!/^[\w.-]+$/.test(o.label)) throw new Error('--label must be a plain word');
  return o;
}

/** Where along the locked aim the hit found Rivet's centre, against the drawn tip. */
export function overhang(foe, trial) {
  const along = foe.foe === 'shield_robot' ? trial.forward_m : trial.centre_dist_m;
  return along - foe.drawn_tip_m;
}

/** Per-foe verdict: how many hits land with Rivet's centre or whole body beyond the drawn tip. */
export function verdict(foe) {
  const hits = foe.trials.filter((t) => t.hit);
  const r = foe.rivet_radius_m;
  const over = hits.map((t) => ({ t, o: overhang(foe, t) }));
  const centre = over.filter((x) => x.o > 0);
  const body = over.filter((x) => x.o - r > 0);
  const side = hits.filter((t) => t.mode === 'side');
  return {
    foe: foe.foe, weapon: foe.weapon, hit_reach_m: r3(foe.authored_reach_m), swing_starts_within_m: r3(foe.swing_starts_within_m),
    hit_reach_centre_m: r3(foe.hit_reach_centre_m), drawn_tip_m: r3(foe.drawn_tip_m), drawn_source: foe.drawn_source,
    telegraph_ticks: foe.telegraph_ticks, trials: foe.trials.length, hits: hits.length,
    hits_centre_beyond_drawn_tip: centre.length, hits_body_beyond_drawn_tip: body.length,
    max_centre_overhang_m: r3(Math.max(0, ...over.map((x) => x.o))),
    hits_while_walking_sideways: side.length,
    max_lateral_at_hit_m: r3(Math.max(0, ...hits.map((t) => t.lateral_m))),
    earliest_hit_since_tell: hits.length ? Math.min(...hits.map((t) => t.since_tell)) : null,
  };
}

export function table(verdicts) {
  const head = '| foe | weapon | hit reach (centre) m | authored reach m | drawn tip m | trials | hits | hits, centre past drawn tip | '
    + 'hits, whole body past drawn tip | max overhang m | hits while walking sideways |\n|---|---|---|---|---|---|---|---|---|---|---|\n';
  return head + verdicts.map((v) => `| ${v.foe} | ${v.weapon} | ${v.hit_reach_centre_m} | ${v.hit_reach_m} | ${v.drawn_tip_m} | `
    + `${v.trials} | ${v.hits} | ${v.hits_centre_beyond_drawn_tip} | ${v.hits_body_beyond_drawn_tip} | ${v.max_centre_overhang_m} | `
    + `${v.hits_while_walking_sideways} |`).join('\n') + '\n';
}

const LOCK = join(ROOT, 'build/n31/godot.lock');
function takeLock() {
  mkdirSync(join(ROOT, 'build/n31'), { recursive: true });
  for (;;) {
    try { writeFileSync(LOCK, `01b ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`, { flag: 'wx' }); return; }
    catch {
      let age = 0;
      try { age = Date.now() - statSync(LOCK).mtimeMs; } catch { continue; }
      if (age > 30 * 60 * 1000) rmSync(LOCK, { force: true });
      else Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 10000);
    }
  }
}

export function main(argv) {
  const o = parseArgs(argv);
  const dir = resolve(ROOT, 'evidence/n31-melee/01-foes', o.label);
  mkdirSync(dir, { recursive: true });
  let raw = o.from ? resolve(o.from) : join(ROOT, 'build/n31/01b/foe_reach_raw.json');
  if (!o.from) {
    mkdirSync(join(ROOT, 'build/n31/01b'), { recursive: true });
    takeLock();
    try {
      const r = spawnSync('node', ['tools/dev/run.mjs', 'foe_reach', `--step=${o.step}`, `--out=${raw}`], { cwd: ROOT, encoding: 'utf8' });
      console.log(r.stdout.trim().split('\n').at(-1));
      if (r.status !== 0) process.exit(r.status ?? 1);
    } finally { rmSync(LOCK, { force: true }); }
  }
  const data = JSON.parse(readFileSync(raw, 'utf8'));
  const verdicts = data.foes.map(verdict);
  writeFileSync(join(dir, 'foe_reach.json'), JSON.stringify({ schema: 'gtai.foe-reach-report/1', label: o.label,
    step_ticks: data.step_ticks, speeds_mps: data.speeds_mps, verdicts, foes: data.foes }, null, 2) + '\n');
  writeFileSync(join(dir, `${o.label}.md`), `# enemy melee on Rivet: ${o.label}\n\n`
    + 'Real CombatArena + ArenaSquad, bare map, 60 Hz. Rivet stands until the foe tells, waits 0..telegraph ticks (step '
    + `${data.step_ticks}), then walks straight away or sideways at ${data.speeds_mps.join(' / ')} m/s (instant speed). `
    + 'Drawn tip: the shield slab is the exact polygon FoeShieldView draws; the others use the authored reach_m (the art strike frame '
    + 'is not measured in metres). overhang = hit-time centre distance past the drawn tip.\n\n' + table(verdicts));
  console.log(table(verdicts));
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
