// n31 melee 01a: the MODEL drawn side (node reads of the held blade and swipe crescent, headless), kept
// behind `blade_volume.mjs --model` / `--overlay=<weapon>`. Its overlay check failed (before-model/).
import { execFileSync } from 'node:child_process';
import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { summarize, table } from './blade_volume_lib.mjs';

let ROOT = '';
const ALL = ['hands', 'chainsaw', 'electro_baton', 'katana', 'plasma_sword'];
const SCENE = 'res://dev/melee_n31/blade_volume.tscn';
const BASE = ['--enemy-brain=squad', '--silent', '--seed=20261109'];
let arg = null;
// 01d: --game-flags=--melee-sweep (comma list) reaches the hit probe, so an after that changes hit rules is measured.
const gameFlags = () => (arg('game-flags', '') ? arg('game-flags', '').split(',') : []);

async function measure(weapon, scratch) {
  const env = { ...process.env, GTAI_BLADE_WEAPON: weapon, GTAI_BLADE_OUT: scratch };
  const r = await runGodot(['--fixed-fps', '60', SCENE, '--', ...BASE, ...gameFlags()], { name: 'blade-volume', env, timeoutMs: 420000, onLine: (l) => /blade_volume|SCRIPT ERROR|ERROR/.test(l) && console.log(l) });
  writeFileSync(join(scratch, `${weapon}.log`), r.out);
  if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out) || /\[ERROR\] blade_/.test(r.out)) {
    throw Error(`${weapon}: exit ${r.status}${r.timedOut ? ' timed out' : ''}; see ${join(scratch, weapon + '.log')}`);
  }
  return JSON.parse(readFileSync(join(scratch, `${weapon}.json`), 'utf8'));
}

async function overlay(weapon) {
  const dir = join(ROOT, 'evidence/n31-melee/01-volumes');
  mkdirSync(dir, { recursive: true });
  const png = join(dir, `overlay_check_${weapon}.png`);
  const env = { ...process.env, GTAI_BLADE_WEAPON: weapon, GTAI_BLADE_OUT: dir, GTAI_BLADE_OVERLAY: png };
  const args = ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', '60',
    '--quit-after', '400', SCENE, '--', ...BASE, '--ppm=64', '--clean'];
  const r = await runGodot(args, { name: 'blade-overlay', headless: false, env, timeoutMs: 180000 });
  if (r.status !== 0 || SCRIPT_ERROR.test(r.out) || !/overlay .* at k/.test(r.out)) throw Error(r.out.slice(-4000));
  console.log(png);
}

export async function modelMain(root, argOf) {
  ROOT = root;
  arg = argOf;
  const ov = arg('overlay', '');
  if (ov) return overlay(ov);
  const label = arg('label', 'before-model');
  const weapons = arg('weapons', ALL.join(',')).split(',');
  const scratch = join(ROOT, 'build/n31/01a', label);
  const out = join(ROOT, 'evidence/n31-melee/01-volumes', label);
  mkdirSync(scratch, { recursive: true });
  mkdirSync(out, { recursive: true });
  const results = [];
  for (const w of weapons) {
    results.push(await measure(w, scratch));
    copyFileSync(join(scratch, `${w}.png`), join(out, `${w}.png`));
    writeFileSync(join(out, `${w}.json`), JSON.stringify(results.at(-1), null, '\t'));
  }
  const head = execFileSync('git', ['rev-parse', '--short', 'HEAD'], { cwd: ROOT, encoding: 'utf8' }).trim();
  const summary = summarize(results, { label, head, tick_rate: 60 });
  writeFileSync(join(out, 'volumes.json'), JSON.stringify(summary, null, '\t'));
  writeFileSync(join(out, 'table.md'), table(summary));
  const inputs = weapons.flatMap((w) => ['-i', join(out, `${w}.png`)]);
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', ...inputs, '-filter_complex',
    `hstack=inputs=${weapons.length}`, join(out, 'sheet.png')], { windowsHide: true });
  console.log(table(summary));
}

