// n31 melee: "the blade passes through and nothing happens", measured.
// Usage: node tools/melee/blade_volume.mjs [--label=before] [--weapons=hands,katana,...] [--tree=<checkout>]
//          [--hits=<dir of 01a hit results>] [--no-render] [--out=<dir>] [--game-flags=--melee-sweep,...]
//          [--raw=<label of build/n31/01d/raw>] [--body-cut=off]   (01e: Rivet's body cut by radius + head column)
//        node tools/melee/blade_volume.mjs --model [--label=x]   (01a's node-read drawn side, headless)
//        node tools/melee/blade_volume.mjs --overlay=<weapon>    (01a's model overlay, one GPU frame)
// Default (01c): the DRAWN side from rendered pixels. One windowed d3d12 Godot run per weapon in
// --tree (default this checkout; it needs project/dev/melee_n31/blade_pixels.*) renders Rivet's swing at
// 64 px/m, tilt 70, facing 0, 90 and 315 deg, in an empty arena; the HIT side is 01a's (headless ring
// and movers, --hits, default evidence/n31-melee/01-volumes/before-model). Holds the lane Godot lock
// (build/n31/godot.lock) only while Godot runs. Writes evidence/n31-melee/01-volumes/<label>/
// {volumes.json,drawn_ticks.json,<weapon>.json,<weapon>.png,sheet.png,table.md} and overlay_pixels_<weapon>.png.
import { execFileSync } from 'node:child_process';
import { mkdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { hurtRadius } from './blade_volume_body.mjs';
import { judge } from './blade_volume_pixels.mjs';
import { plot } from './blade_volume_plot.mjs';
import { overlay, read, render } from './blade_volume_run.mjs';
import { pixelTable, span } from './blade_volume_lib.mjs';

const ROOT = resolve(fileURLToPath(new URL('../..', import.meta.url)));
const ALL = ['hands', 'chainsaw', 'electro_baton', 'katana', 'plasma_sword'];
const LOCK = join(ROOT, 'build/n31/godot.lock');
const arg = (name, dflt) => {
  const hit = process.argv.find((a) => a.startsWith(`--${name}=`));
  return hit ? hit.slice(name.length + 3) : dflt;
};
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function locked(fn) {
  mkdirSync(join(ROOT, 'build/n31'), { recursive: true });
  for (;;) {
    try {
      writeFileSync(LOCK, `01d ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`, { flag: 'wx' });
      break;
    } catch {
      let age = 0;
      try { age = Date.now() - statSync(LOCK).mtimeMs; } catch { continue; }
      if (age > 30 * 60000) { rmSync(LOCK, { force: true }); continue; }
      console.log(`lock busy: ${readFileSync(LOCK, 'utf8').trim()}; waiting 30 s`);
      await sleep(30000);
    }
  }
  try { return await fn(); } finally { rmSync(LOCK, { force: true }); }
}

/** Keeps the ticks the swing is on screen (01a's views: blade/crescent shown or the strip cell's swing,
 * from the press): later diffs are Rivet's moved body or the arena's own motion, not the swing. */
function clip(px, win) {
  for (const d of Object.values(px.facings)) {
    for (const k of Object.keys(d.ticks).map(Number)) {
      if (win && k >= 0 && k <= win[1]) continue;
      delete d.ticks[k];
      delete d.polar[k];
      delete d.masks[k];
      if (d.cuts) delete d.cuts[k];
    }
    d.window = win;
  }
  return px;
}

/** Per tick k of facing f: the mask's angle range off the aim and reach (Item 02 reads this). */
function drawnTicks(px) {
  const out = {};
  for (const [f, d] of Object.entries(px.facings)) out[f] = { cut_ks: d.meta.cut_ks, land_ks: d.meta.land_ks, window: d.window, ticks: d.polar };
  return out;
}

async function main() {
  if (process.argv.includes('--model') || arg('overlay', '')) {
    const { modelMain } = await import('./blade_volume_model.mjs');
    return modelMain(ROOT, arg);
  }
  const label = arg('label', 'before');
  const tree = resolve(arg('tree', ROOT));
  const hitsDir = resolve(arg('hits', join(ROOT, 'evidence/n31-melee/01-volumes/before-model')));
  const weapons = arg('weapons', ALL.join(',')).split(',');
  const vol = join(ROOT, 'evidence/n31-melee/01-volumes');
  const out = resolve(arg('out', join(vol, label)));
  const extra = arg('game-flags', '') ? arg('game-flags', '').split(',') : [];
  mkdirSync(out, { recursive: true });
  const head = execFileSync('git', ['rev-parse', '--short', 'HEAD'], { cwd: tree, encoding: 'utf8' }).trim();
  const radiusM = arg('body-cut', 'on') === 'off' ? 0 : hurtRadius(tree);
  const rows = [], ticks = {};
  for (const w of weapons) {
    const scratch = join(ROOT, 'build/n31/01d/raw', arg('raw', label), w);
    if (!process.argv.includes('--no-render')) await locked(() => render(w, tree, scratch, extra));
    const hit = JSON.parse(readFileSync(join(hitsDir, `${w}.json`), 'utf8'));
    const px = clip(read(scratch, radiusM), span([...hit.shown_ks, ...hit.pixel_ks]));
    const f0 = px.facings['0'];
    const judged = judge(hit, f0.ticks);
    const drawnKs = Object.keys(f0.ticks).map(Number);
    const atK = hit.land_k + 1 in f0.ticks ? hit.land_k + 1 : drawnKs[Math.floor(drawnKs.length / 2)] ?? 0;
    const lastCut = Math.max(...f0.meta.cut_ks.filter((k) => k in f0.ticks), atK);
    for (const k of new Set([atK, lastCut])) overlay(scratch, px, '0', k, join(out, `overlay_${radiusM ? 'body' : 'clean'}_${w}_k${k}.png`));
    const cutTicks = Object.fromEntries(Object.entries(f0.ticks).filter(([k]) => hit.cut_ks.includes(Number(k))));
    const inCut = judge(hit, cutTicks).ring;
    plot(hit, judged, Object.values(f0.ticks).flat(), join(out, `${w}.png`));
    const lateDrawn = judged.cells.filter((c) => c.drawn && !c.hit && c.drawn_ks.some((k) => k > hit.land_k)).length;
    const mv = judged.movers;
    rows.push({ weapon: w, weapon_id: hit.weapon_id, ...judged.ring, drawn_no_hit_after_test: lateDrawn,
      drawn_no_hit_in_cut: inCut.drawn_no_hit, repeats: f0.repeats, body_cut_m: radiusM, body_cut_px: f0.cuts, overlays: [...new Set([atK, lastCut])],
      hit_test_ks: hit.land_ks.length ? hit.land_ks : [hit.land_k], cut_window: span(hit.cut_ks),
      drawn_window: span(drawnKs), overlay_k: atK, overlap_window: span([...new Set(judged.cells.flatMap((c) => c.drawn_ks))]),
      mover: { trials: mv.length, hit: mv.filter((m) => m.hit).length, drawn: mv.filter((m) => m.drawn).length,
        drawn_no_hit: mv.filter((m) => m.drawn && !m.hit).length } });
    ticks[w] = drawnTicks(px);
    writeFileSync(join(out, `${w}.json`), JSON.stringify({ schema: 'gtai.blade-pixels-judged/1', weapon: w, ...rows.at(-1),
      cells: judged.cells, movers: judged.movers, drawn: ticks[w] }, null, '\t'));
  }
  const summary = { schema: 'gtai.blade-volumes/2', source: 'pixels', label, head, tree, hits: hitsDir, ppm: 64, pitch_deg: 70, weapons: rows };
  writeFileSync(join(out, 'volumes.json'), JSON.stringify(summary, null, '\t'));
  writeFileSync(join(out, 'drawn_ticks.json'), JSON.stringify({ schema: 'gtai.drawn-ticks/1', label, head,
    doc: 'per weapon, per facing (deg), per tick k from the press: the drawn swing mask about Rivet start: deg = [min, max] signed off the aim (+ = clockwise on screen, y down), reach_m = max ground distance (m), at gun height; deg_p5_p95 / reach_p95 = the same over the bulk of the mask (use these: stray arena motion widens min/max)', weapons: ticks }, null, '\t'));
  writeFileSync(join(out, 'table.md'), pixelTable(summary));
  if (weapons.length > 1) sheet(weapons, out);
  console.log(pixelTable(summary));
}

function sheet(weapons, out) {
  const inputs = weapons.flatMap((w) => ['-i', join(out, `${w}.png`)]);
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', ...inputs, '-filter_complex',
    `hstack=inputs=${weapons.length}`, join(out, 'sheet.png')], { windowsHide: true });
}

await main();
