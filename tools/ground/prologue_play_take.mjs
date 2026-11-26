#!/usr/bin/env node
// n31-16: the prologue as the owner plays it (project stretch ON, tilt 70) on film, any commit, from a
// snapshot (tools/lib/snapshot.mjs), as take.mp4 + stills + take.json that play_take.mjs --side can stack.
//   node tools/ground/prologue_play_take.mjs --rev=ba8e470b0 --out=<dir> [--ppm=32] [--limit=2700] [--from=1140] [--label=..]
// The movie takes the base viewport (1280x800), so the window override (1920x1080) goes in a snapshot-only
// override.cfg: the stretch stays 1.35 as in a 1080p window. The probe is copied into the snapshot.
import { spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { setTimeout as sleep } from 'node:timers/promises';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { ROOT } from '../lib/repo.mjs';
import { ensureSnapshot, revParse } from '../lib/snapshot.mjs';
import { filmedRoot } from '../film/side.mjs';
import { encodeArgs, labelOf, takeFile } from './play_take_lib.mjs';

export const SCENE = 'res://dev/ground_n31/play_film.tscn';
export const PROBE = ['play_film.gd', 'play_film.gd.uid', 'play_film.tscn'];
export const OVERRIDE = '[display]\n\nwindow/size/window_width_override=1920\nwindow/size/window_height_override=1080\n';
const TAG = 'n31-16';

/** The Godot arguments after `--path project`. */
export function godotArgs({ avi, ppm, from, limit, result }) {
  return ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', '60',
    '--disable-vsync', '--write-movie', avi, SCENE, '--', '--bot', `--clip=${ppm}:${from}:${limit}`, `--result=${result}`];
}

/** {rev, out, ppm, limit, from, label} from `--k=v` arguments, or {error}. */
export function parse(argv) {
  const f = { ppm: '32', limit: '2700', from: '1140' };
  for (const a of argv) {
    const m = /^--(rev|out|ppm|limit|from|label)=(.+)$/.exec(a);
    if (!m) return { error: `prologue_play_take: bad argument ${a}` };
    f[m[1]] = m[2];
  }
  if (!f.rev || !f.out) return { error: 'prologue_play_take: --rev= and --out= are required' };
  if ([f.ppm, f.limit, f.from].some((v) => !/^\d+$/.test(v))) return { error: 'prologue_play_take: --ppm, --limit, --from are whole numbers' };
  return { f };
}

async function takeLock(waitS = 900) {
  const file = join(ROOT, 'build', 'n31-godot.lock');
  mkdirSync(dirname(file), { recursive: true });
  const mine = `${TAG} ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`;
  for (let waited = 0; ; waited += 30) {
    try { writeFileSync(file, mine, { flag: 'wx' }); break; } catch { /* held */ }
    if (waited >= waitS) throw new Error('prologue_play_take: lock still held');
    console.error(`prologue_play_take: lock held (${existsSync(file) ? readFileSync(file, 'utf8').trim() : '?'}), waiting 30 s`);
    await sleep(30_000);
  }
  return () => { if (existsSync(file) && readFileSync(file, 'utf8') === mine) rmSync(file, { force: true }); };
}

const ff = (bin, args, cwd) => spawnSync(bin, args, { cwd, encoding: 'utf8', windowsHide: true });

export async function main(argv) {
  const p = parse(argv);
  if (p.error) { console.error(p.error); return 2; }
  const f = p.f;
  const sha = revParse(filmedRoot(), f.rev);
  if (!sha) { console.error(`prologue_play_take: ${f.rev} is not a commit`); return 2; }
  const tree = ensureSnapshot({ root: filmedRoot(), rev: f.rev, kind: 'film' }).path;
  mkdirSync(join(tree, 'project', 'dev', 'ground_n31'), { recursive: true });
  for (const n of PROBE) copyFileSync(join(ROOT, 'project', 'dev', 'ground_n31', n), join(tree, 'project', 'dev', 'ground_n31', n));
  writeFileSync(join(tree, 'project', 'override.cfg'), OVERRIDE);
  const out = resolve(f.out);
  mkdirSync(out, { recursive: true });
  const avi = join(out, 'take.avi');
  const release = await takeLock();
  let r;
  try {
    r = await runGodot(godotArgs({ avi, ppm: f.ppm, from: f.from, limit: f.limit, result: out }), { headless: false, cwd: tree, timeoutMs: 1_500_000, stopOn: SCRIPT_ERROR, name: 'play-take' });
  } finally { release(); }
  writeFileSync(join(out, 'engine.log'), r.out ?? '');
  if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out ?? '') || !existsSync(avi)) { console.error(`prologue_play_take: run failed (exit ${r.status})`); return 1; }
  const e = ff('ffmpeg', encodeArgs(avi, join(out, 'take.mp4'), 0), out);
  if (e.status !== 0) { console.error(`prologue_play_take: ffmpeg: ${e.stderr}`); return 1; }
  const size = ff('ffprobe', ['-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=width,height,nb_frames', '-of', 'csv=s=x:p=0', join(out, 'take.mp4')]).stdout.trim();
  const label = f.label ?? labelOf(f.rev, sha);
  writeFileSync(takeFile(out), `${JSON.stringify({ schema: 'gtai.play-take/1', rev: f.rev, sha, label, scene: SCENE, ppm: Number(f.ppm), from: Number(f.from), limit: Number(f.limit), mp4: 'take.mp4', size }, null, 1)}\n`);
  rmSync(avi, { force: true });
  console.log(`prologue_play_take: ${join(out, 'take.mp4')} ${size}`);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) process.exit(await main(process.argv.slice(2)));
