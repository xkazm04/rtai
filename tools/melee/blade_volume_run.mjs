// n31 melee 01c: renders one weapon's swing (blade_pixels.tscn, windowed d3d12, 64 px/m, tilt 70)
// and reads the frames into per-facing, per-tick drawn masks in ground metres, plus overlay frames.
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { BODY_DILATE, THRESHOLD, diffMask, dilate, groundToScreen, maskPoints, polar, swingMask } from './blade_volume_pixels.mjs';

const SCENE = 'res://dev/melee_n31/blade_pixels.tscn';
const BASE = ['--enemy-brain=squad', '--silent', '--seed=20261109'];

/** One windowed Godot run for `weapon` in `tree` (a checkout with blade_pixels.*); raw crops land in `scratch`. */
export async function render(weapon, tree, scratch) {
  rmSync(scratch, { recursive: true, force: true });
  mkdirSync(scratch, { recursive: true });
  const env = { ...process.env, GTAI_BLADE_WEAPON: weapon, GTAI_BLADE_OUT: scratch };
  const args = ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', '60',
    SCENE, '--', ...BASE, '--ppm=64', '--clean'];
  const r = await runGodot(args, { name: 'blade-pixels', cwd: tree, headless: false, env, timeoutMs: 300000,
    stopOn: /SCRIPT ERROR|Failed to load script/, onLine: (l) => /blade_pixels|SCRIPT ERROR/.test(l) && console.log(l) });
  writeFileSync(join(scratch, 'godot.log'), r.out);
  if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out) || !existsSync(join(scratch, 'frames.json'))) {
    throw Error(`${weapon}: exit ${r.status}${r.timedOut ? ' timed out' : ''}; see ${join(scratch, 'godot.log')}`);
  }
}

const raw = (dir, facing, name) => readFileSync(join(dir, `${facing}_${name}.rgb`));

/** Per facing: {meta, ticks: {k: ground points}, polar: {k: {deg, reach_m}}} from the saved crops. */
export function read(scratch) {
  const frames = JSON.parse(readFileSync(join(scratch, 'frames.json'), 'utf8'));
  const out = { weapon: frames.weapon, threshold: THRESHOLD, body_dilate_px: BODY_DILATE, facings: {} };
  for (const [facing, m] of Object.entries(frames.facings)) {
    const meta = { ...m, px_per_m: frames.px_per_m };
    const [, , w, h] = meta.crop;
    const n = w * h;
    const bg = raw(scratch, facing, 'bg');
    const body = dilate(diffMask(raw(scratch, facing, 'idle'), bg, n), w, h, BODY_DILATE);
    const ticks = {}, pol = {}, masks = {};
    for (let k = 0; k <= m.k_end; k++) {
      const mask = swingMask(raw(scratch, facing, `k${k}`), bg, body, n);
      const pts = maskPoints(mask, meta);
      if (pts.length === 0) continue;
      ticks[k] = pts;
      masks[k] = mask;
      const p = polar(pts, Number(facing));
      if (p) pol[k] = p;
    }
    out.facings[facing] = { meta, ticks, polar: pol, masks, body };
  }
  return out;
}

/** The tick k's frame with the mask outline (magenta), the idle body mask edge (dim) and the mask's
 * ground footprint (cyan: each point dropped from gun height to the floor), Rivet's ground point (yellow). */
export function overlay(scratch, read1, facing, k, png) {
  const f = read1.facings[facing];
  const [cx, cy, w, h] = f.meta.crop;
  const img = Buffer.from(raw(scratch, facing, `k${k}`));
  const mask = f.masks[k] ?? new Uint8Array(w * h);
  const put = (x, y, c) => {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    const o = (y * w + x) * 3;
    img[o] = c[0]; img[o + 1] = c[1]; img[o + 2] = c[2];
  };
  const edge = (m, x, y) => m[y * w + x] && (x === 0 || y === 0 || x === w - 1 || y === h - 1
    || !m[y * w + x - 1] || !m[y * w + x + 1] || !m[(y - 1) * w + x] || !m[(y + 1) * w + x]);
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      if (edge(f.body, x, y)) put(x, y, [90, 90, 110]);
      if (edge(mask, x, y)) put(x, y, [255, 0, 255]);
    }
  }
  for (const p of f.ticks[k] ?? []) {
    const [sx, sy] = groundToScreen(p[0], p[1], f.meta, false);
    put(Math.round(sx - cx), Math.round(sy - cy), [0, 230, 255]);
  }
  const [rx, ry] = groundToScreen(0, 0, f.meta, false);
  for (let d = -6; d <= 6; d++) {
    put(Math.round(rx - cx) + d, Math.round(ry - cy), [255, 230, 0]);
    put(Math.round(rx - cx), Math.round(ry - cy) + d, [255, 230, 0]);
  }
  const tmp = png + '.rgb';
  writeFileSync(tmp, img);
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
    '-s', `${w}x${h}`, '-i', tmp, png], { windowsHide: true });
  rmSync(tmp);
}
