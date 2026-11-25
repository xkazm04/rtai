#!/usr/bin/env node
// n31 foes: play takes of the real gauntlet (bot, --pick-view, wheel, tilt 70), before beside after.
//   node tools/gauntlet/play_takes.mjs --seed=<n> --wave=<n> --seconds=<15..40> --out=<abs masters dir>
//     --name=<stem> [--profile=average] [--left=rev:<commit>|flags:<extra flags>]
//     [--right=HEAD|live|rev:<commit>|flags:<extra flags>] [--ppm=32|64] [--follow=<archetype>] [--lead=1.0]
// Each side: a headless scout of res://dev/foes_n31/play_take.tscn finds the tick wave n first spawns,
// then a windowed take fast-forwards to `lead` s before it and writes the frames. Revs run in a temp
// worktree (rev_tree.mjs); flags: sides run at the HEAD sha taken at launch. Every Godot run goes through
// runGodot under the lane lock, one at a time. Writes <name>_left/_right.mp4 (crf 20) and <name>_side.mp4
// (centre 960 px of each, hstacked, labelled, crf 23) to --out, upserts its frames.json row, and the
// take summaries to evidence/n31/foes/takes/<name>.json. Scratch: build/n31/takes/<name>/.
import { execFileSync, spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, renameSync, rmSync, writeFileSync } from 'node:fs';
import { isAbsolute, join } from 'node:path';
import { parseArgs } from 'node:util';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { inRevTreeAsync, resolveRev, withLaneLockAsync } from './rev_tree.mjs';

export const MAIN = 'ba8e470b0';
const SCENE = 'res://dev/foes_n31/play_take.tscn';
const SUMMARY = /\[INFO\] play-take: (\{.*\})/;
const TAG = 'b3';

export function parse(argv) {
  const opts = ['seed', 'wave', 'seconds', 'profile', 'out', 'name', 'left', 'right', 'ppm', 'follow', 'lead'];
  const { values: v } = parseArgs({ args: argv, options: Object.fromEntries(opts.map((k) => [k, { type: 'string' }])) });
  const int = (name, min, max) => {
    const x = v[name];
    if (!/^\d+$/.test(x ?? '') || Number(x) < min || Number(x) > max) throw new Error(`--${name} must be an integer in ${min}..${max}`);
    return Number(x);
  };
  if (!v.out || !isAbsolute(v.out)) throw new Error('--out=<absolute masters dir> is required');
  if (!/^[a-z0-9_]+$/.test(v.name ?? '')) throw new Error('--name=<stem> is required (a-z 0-9 _)');
  const profile = v.profile ?? 'average';
  if (!['novice', 'average', 'expert'].includes(profile)) throw new Error('unknown --profile ' + profile);
  const ppm = Number(v.ppm ?? '32');
  if (![32, 64].includes(ppm)) throw new Error('--ppm must be 32 or 64');
  const lead = Number(v.lead ?? '1.0');
  if (!(lead >= 0 && lead <= 10)) throw new Error('--lead must be 0..10 s');
  return { seed: int('seed', 0, 2 ** 31), wave: int('wave', 1, 30), seconds: int('seconds', 15, 40), profile, ppm, lead,
    out: v.out, name: v.name, follow: v.follow ?? '', left: sideSpec(v.left ?? 'rev:' + MAIN, 'left'),
    right: sideSpec(v.right ?? 'HEAD', 'right') };
}

/** `rev:<c>` | `HEAD` | `live` | `flags:<extra flags>` -> { kind, value }. */
export function sideSpec(text, key) {
  if (text === 'HEAD' || text === 'live') return { kind: text === 'HEAD' ? 'rev' : 'live', value: text === 'HEAD' ? 'HEAD' : '' };
  const m = /^(rev|flags):(.+)$/.exec(text);
  if (!m) throw new Error(`--${key} must be rev:<commit>, flags:<extra flags>, HEAD or live`);
  if (m[1] === 'flags' && !m[2].split(/\s+/).every((f) => /^--[a-z][a-z0-9-]*(=\S+)?$/.test(f))) throw new Error(`--${key} flags must be --x or --x=y`);
  return { kind: m[1], value: m[2] };
}

/** Resolves both sides against the launch HEAD: rev (full sha or 'live'), extra flags, label. */
export function sides(a, { head, mainSha, resolve = (r) => r }) {
  return ['left', 'right'].map((key) => {
    const s = a[key];
    if (s.kind === 'flags') return { key, rev: head, flags: s.value.split(/\s+/), label: s.value };
    if (s.kind === 'live') return { key, rev: 'live', flags: [], label: 'live' };
    const rev = s.value === 'HEAD' ? head : resolve(s.value);
    return { key, rev, flags: [], label: rev === mainSha ? 'main' : rev === head ? 'HEAD' : rev.slice(0, 9) };
  });
}

function common(a, side) {
  return ['--seed=' + a.seed, '--bot=' + a.profile, '--pick=greedy', '--controls=wheel', '--pick-view',
    '--take-wave=' + a.wave, ...side.flags];
}

export function scoutArgs(a, side) {
  return [SCENE, '--', ...common(a, side)];
}

/** The windowed take: first drawn tick = spawn - lead (the step after --take-tick). */
export function takeArgs(a, side, spawnTick, framesDir) {
  const frames = a.seconds * 60;
  const takeTick = Math.max(0, spawnTick - Math.round(a.lead * 60) - 1);
  return ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', '60',
    '--disable-vsync', '--quit-after', String(frames + 600), SCENE, '--', ...common(a, side), '--take-tick=' + takeTick,
    '--take-s=' + a.seconds, '--frames-out=' + framesDir.replaceAll('\\', '/'), '--zoom-ppm=' + a.ppm,
    ...(a.follow ? ['--follow=' + a.follow] : [])];
}

/** ffmpeg argv for one side's frames -> mp4 (crf 20) and for the labelled side-by-side (crf 23). */
export function encodeArgs(a, dirs) {
  const frames = String(a.seconds * 60);
  const tail = (crf, file) => ['-frames:v', frames, '-c:v', 'libx264', '-crf', crf, '-preset', 'medium',
    '-pix_fmt', 'yuv420p', '-r', '60', '-movflags', '+faststart', file];
  const input = (dir) => ['-framerate', '60', '-start_number', '1', '-i', join(dir, '%04d.jpg')];
  const label = (k) => `crop=960:1080:480:0,drawtext=fontfile='C\\:/Windows/Fonts/arial.ttf':textfile=label_${k}.txt`
    + ':x=18:y=14:fontsize=34:fontcolor=white:box=1:boxcolor=black@0.55:boxborderw=8';
  return {
    left: [...input(dirs.left), ...tail('20', a.name + '_left.mp4')],
    right: [...input(dirs.right), ...tail('20', a.name + '_right.mp4')],
    side: [...input(dirs.left), ...input(dirs.right), '-filter_complex',
      `[0:v]${label('left')}[l];[1:v]${label('right')}[r];[l][r]hstack=inputs=2`, ...tail('23', a.name + '_side.mp4')],
  };
}

/** '' when the ffprobe stream is 1920x1080, 60 fps and within 0.1 s of `seconds`. */
export function probeProblem(s, seconds) {
  if (s.width !== 1920 || s.height !== 1080) return `size ${s.width}x${s.height}`;
  if (s.avg_frame_rate !== '60/1') return 'fps ' + s.avg_frame_rate;
  if (Math.abs(Number(s.duration) - seconds) > 0.1) return 'duration ' + s.duration;
  return '';
}

async function godot(tree, args, opts, log) {
  return withLaneLockAsync(TAG, async () => {
    const r = await runGodot(args, { cwd: tree, stopOn: SCRIPT_ERROR, ...opts });
    const m = SUMMARY.exec(r.out);
    if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out) || !m) {
      throw new Error(`${opts.name} failed (exit ${r.status}${r.timedOut ? ', timed out' : ''}):\n` + r.out.split('\n').slice(-25).join('\n'));
    }
    return JSON.parse(m[1]);
  }, { log });
}

async function shoot(a, side, tree, scratch, log) {
  const scout = await godot(tree, scoutArgs(a, side), { name: 'play-take-scout', timeoutMs: 15 * 60_000 }, log);
  log(`${side.key} (${side.label}) scout: wave ${a.wave} spawns at tick ${scout.spawn_tick}`);
  const dir = join(scratch, side.key);
  rmSync(dir, { recursive: true, force: true });
  mkdirSync(dir, { recursive: true });
  const take = await godot(tree, takeArgs(a, side, scout.spawn_tick, dir),
    { name: 'play-take', headless: false, timeoutMs: 20 * 60_000 }, log);
  if (take.frames !== a.seconds * 60) throw new Error(`${side.key} wrote ${take.frames} frames`);
  log(`${side.key} take: first tick ${take.first_tick}, spawn tick ${take.spawn_tick}, ${take.frames} frames`);
  return { ...side, scout_spawn_tick: scout.spawn_tick, take };
}

async function shootAll(a, list, scratch, log) {
  const done = [];
  for (const side of list) {
    if (side.rev === 'live') {
      done.push(await shoot(a, side, ROOT, scratch, log));
      continue;
    }
    done.push(await inRevTreeAsync(side.rev, (tree) => shoot(a, side, tree, scratch, log)));
  }
  return done;
}

function ffmpeg(args, cwd) {
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', ...args], { cwd, stdio: 'inherit' });
}

function probe(file, seconds) {
  const s = JSON.parse(execFileSync('ffprobe', ['-v', 'error', '-select_streams', 'v:0', '-show_entries',
    'stream=width,height,avg_frame_rate,nb_frames,duration', '-of', 'json', file])).streams[0];
  const problem = probeProblem(s, seconds);
  if (problem) throw new Error(file + ' failed ffprobe: ' + problem);
  return s;
}

function upsertIndex(out, row) {
  const index = join(out, 'frames.json');
  const old = existsSync(index) ? JSON.parse(readFileSync(index, 'utf8')) : [];
  const at = old.findIndex((r) => r.file === row.file);
  const rows = at >= 0 ? old.map((r, i) => (i === at ? { ...row, note: r.note || row.note } : r)) : [...old, row];
  writeFileSync(index + '.tmp', JSON.stringify(rows, null, 2) + '\n');
  renameSync(index + '.tmp', index);
}

function mean(take, key) {
  return (take.per_s.reduce((t, s) => t + s[key], 0) / Math.max(1, take.per_s.length)).toFixed(1);
}

export async function main(argv, { log = console.log } = {}) {
  const a = parse(argv);
  if (a.left.kind === 'live' || a.right.kind === 'live') {
    const dirty = spawnSync('git', ['-C', ROOT, 'status', '--short', 'project/'], { encoding: 'utf8' }).stdout.trim();
    if (dirty) throw new Error('live refused: project/ is dirty (another builder edits it); use rev:<commit>');
  }
  const list = sides(a, { head: resolveRev('HEAD'), mainSha: resolveRev(MAIN), resolve: resolveRev });
  const scratch = join(ROOT, 'build', 'n31', 'takes', a.name);
  mkdirSync(scratch, { recursive: true });
  const shot = await shootAll(a, list, scratch, log);
  for (const s of shot) writeFileSync(join(scratch, `label_${s.key}.txt`), s.label);
  const enc = encodeArgs(a, { left: join(scratch, 'left'), right: join(scratch, 'right') });
  const files = ['left', 'right', 'side'].map((k) => { ffmpeg(enc[k], scratch); return `${a.name}_${k}.mp4`; });
  const probes = Object.fromEntries(files.map((f) => [f, probe(join(scratch, f), a.seconds)]));
  mkdirSync(a.out, { recursive: true });
  for (const f of files) copyFileSync(join(scratch, f), join(a.out, f));
  const [l, r] = shot;
  const ticks = l.take.spawn_tick === r.take.spawn_tick ? `wave ${a.wave} starts at tick ${l.take.spawn_tick} on both sides`
    : `wave ${a.wave} starts at tick ${l.take.spawn_tick} (${l.label}) and ${r.take.spawn_tick} (${r.label}), ${r.take.spawn_tick - l.take.spawn_tick} ticks apart`;
  const note = `Seed ${a.seed}, ${a.profile} bot, greedy picks, wheel, tilt 70, ${a.ppm} px/m; ${ticks}; each take opens ${a.lead} s before it. `
    + `Mean foes alive / that fired per second: ${mean(l.take, 'alive')} / ${mean(l.take, 'fired')} (${l.label}), ${mean(r.take, 'alive')} / ${mean(r.take, 'fired')} (${r.label}).`;
  upsertIndex(a.out, { file: `${a.name}_side.mp4`, title: `Wave ${a.wave}: ${l.label} | ${r.label}`, ppm: a.ppm, before: `${a.name}_left.mp4`, note });
  const record = { schema: 'gtai.foes-play-takes/1', args: { ...a }, sides: shot, ticks, probes };
  writeFileSync(join(scratch, 'takes.json'), JSON.stringify(record, null, 2) + '\n');
  mkdirSync(join(ROOT, 'evidence', 'n31', 'foes', 'takes'), { recursive: true });
  writeFileSync(join(ROOT, 'evidence', 'n31', 'foes', 'takes', a.name + '.json'), JSON.stringify(record, null, 2) + '\n');
  for (const k of ['left', 'right']) rmSync(join(scratch, k), { recursive: true, force: true });
  for (const f of files) log(`${f}: ${probes[f].width}x${probes[f].height} ${probes[f].avg_frame_rate} ${probes[f].duration} s, ${probes[f].nb_frames} frames`);
  log(ticks);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main(process.argv.slice(2)).then((c) => process.exit(c), (e) => { console.error('play_takes: ' + e.message); process.exit(e.message.startsWith('--') ? 2 : 1); });
}
