// node tools/film/arsenal_turn.mjs --weapon=homing_shard --pitch=p55 --a=<sha> --b=<sha> --out=<dir>
import { spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { runGodot } from '../lib/godot.mjs';
import { ensureSnapshot } from '../lib/snapshot.mjs';
import { resolveSide } from './side.mjs';
import { encodePng, label } from './sheet.mjs';
import { readPng } from './png.mjs';

const directions = ['E', 'SE', 'S', 'SW', 'W', 'NW', 'N', 'NE'];
const poses = ['rest', 'fire'];

export function layout(sides) {
  return sides.flatMap((side, row) => directions.flatMap((direction, octant) =>
    poses.map((pose, phase) => ({
      row, col: octant * 2 + phase, side, stem: `oct${octant}_${pose}`,
      caption: `${direction} ${pose} ${side.label}`,
    }))));
}

function sheet(sides, file) {
  const cells = layout(sides);
  const first = readPng(join(sides[0].dir, 'oct0_rest.png'));
  const w = first.width, h = first.height, stride = w + 4, rowHeight = h + 22;
  const width = 16 * stride - 4, height = sides.length * rowHeight;
  const pixels = Buffer.alloc(width * height * 3, 26);
  for (const { row, col, side, stem, caption } of cells) {
    const img = readPng(join(side.dir, stem + '.png'));
    if (img.width !== w || img.height !== h) throw Error('turn: inconsistent frame sizes');
    const left = col * stride, top = row * rowHeight;
    for (let y = 0; y < h; y++) {
      for (let x = 0; x < w; x++) {
        const src = (y * w + x) * img.channels;
        img.data.copy(pixels, ((top + y) * width + left + x) * 3, src, src + 3);
      }
    }
    label(pixels, width, left, top + h, w, caption);
  }
  writeFileSync(file, encodePng(width, height, pixels));
}

function sideAt(rev, root) {
  const side = resolveSide(rev, { root, ensure: opts => ensureSnapshot({
    ...opts, base: join(root, 'build/turn-snapshots'), donor: root,
  }) });
  if (side.error) throw Error(side.error);
  const rel = 'project/dev/rivet_arsenal';
  if (!side.snapshot) return { ...side, script: 'res://dev/rivet_arsenal/arsenal_turn.gd', label: 'WORKTREE' };
  // Load this kit alongside any driver already committed in the historical revision.
  const dest = join(side.tree, 'project/dev/film_turn_probe');
  mkdirSync(dest, { recursive: true });
  for (const file of ['arsenal_turn.gd', 'arsenal_turn_rec.gd']) copyFileSync(join(root, rel, file), join(dest, file));
  return { ...side, script: 'res://dev/film_turn_probe/arsenal_turn.gd' };
}

async function capture(side, weapon, pitch, ppm, scratch) {
  const dir = mkdtempSync(join(scratch, side.label + '-'));
  const r = await runGodot(['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1280x720',
    '--fixed-fps', '60', '-s', side.script, '--', '--weapon=' + weapon, '--pitch=' + pitch,
    '--ppm=' + ppm, '--out=' + dir], {
    cwd: side.tree, headless: false, timeoutMs: 300000, name: 'arsenal-turn', stopOn: /SCRIPT ERROR/,
  });
  writeFileSync(join(dir, 'capture.log'), r.out);
  if (r.status !== 0 || /SCRIPT ERROR/.test(r.out) || !existsSync(join(dir, 'oct7_fire.png'))) {
    throw Error('turn: incomplete capture, see ' + join(dir, 'capture.log'));
  }
  return { ...side, dir };
}

async function main(argv) {
  const { values: v } = parseArgs({ args: argv, options: {
    weapon: { type: 'string' }, pitch: { type: 'string', default: 'p55' }, out: { type: 'string' },
    rev: { type: 'string' }, a: { type: 'string' }, b: { type: 'string' }, stills: { type: 'boolean' },
  } });
  if (!/^[a-z0-9_-]+$/.test(v.weapon ?? '') || !['p55', 'p70', 'top'].includes(v.pitch) || !v.out ||
      (!!v.a !== !!v.b) || (v.rev && v.a)) throw Error('expected --weapon=<id> --out=<dir> [--rev=<sha> | --a=<sha> --b=<sha>]');
  const root = process.cwd(), out = resolve(v.out);
  const name = v.weapon + '_' + v.pitch, scratch = join(root, 'build/arsenal-turn');
  mkdirSync(out, { recursive: true });
  mkdirSync(scratch, { recursive: true });
  const sides = [];
  for (const rev of v.a ? [v.a, v.b] : [v.rev || '.']) {
    sides.push(await capture(sideAt(rev, root), v.weapon, v.pitch, 64, scratch));
  }
  const last = sides.at(-1);
  sheet(sides, join(out, name + '_64.png'));
  if (existsSync(join(last.dir, 'reload.png'))) copyFileSync(join(last.dir, 'reload.png'), join(out, name + '_reload.png'));
  if (!v.stills) {
    const clip = await capture(last, v.weapon, v.pitch, 32, scratch);
    const r = spawnSync('ffmpeg', ['-y', '-loglevel', 'error', '-framerate', '15', '-i', join(clip.dir, 'clip_%04d.png'),
      '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', join(out, name + '_turn32.mp4')], { stdio: 'inherit' });
    if (r.status !== 0) throw Error('turn: ffmpeg failed in ' + clip.dir);
  }
  console.log('turn: ' + name + ' in ' + out);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main(process.argv.slice(2)).catch(error => { console.error(error.message); process.exitCode = 1; });
}
