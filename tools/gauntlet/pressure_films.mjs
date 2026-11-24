#!/usr/bin/env node
// With the lane's APPDATA and GODOT_BIN set, run:
// node tools/gauntlet/pressure_films.mjs --out=<absolute masters directory>
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync, renameSync, writeFileSync } from 'node:fs';
import { isAbsolute, join } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const films = [
  { file: 'standing_punished', title: 'Stand, circle, dash', takes: ['stand', 'circle', 'dash'], seed: 28,
    stillTake: 'dash', stillTick: r => r.first_dash + 4,
    note: 'Wave 6, seed 28. Same pistol and seven seconds from full health in each take.' },
  { file: 'deflect_half', title: 'Guard and plasma sword', takes: ['guard', 'blade'], seed: 19,
    stillTake: 'blade', stillTick: () => 85,
    note: 'Three riflemen start at 9.5 m. The HUD counts passes, returns and shooter kills.' },
  { file: 'rocket_pair', title: 'Rivet and the rocket trooper', takes: ['rockets'], seed: 1,
    stillTake: 'rockets', stillTick: r => r.first_pair + 16,
    note: 'Both launchers fire on the same street. Rivet has the steel casing and amber exhaust.' },
  { file: 'trooper_pair', title: 'Two rocket troopers: circling, then circling with a dash', takes: ['pair_circle', 'pair_dash'],
    side: true, ticks: 1500, seed: 1, stillTake: 'pair_circle', stillTick: r => r.first_launch + 14,
    note: 'Two rocket troopers, Rivet at 10 m, never firing back. Left: steady circle. Right: the same seed and spawn, dashing across each rocket line.' },
  { file: 'deflect_6m', title: 'Guard and plasma sword at 6 m', takes: ['guard6', 'blade6'],
    side: true, ticks: 2200, seed: 19, stillTake: 'blade6', stillTick: r => r.first_return + 3,
    note: 'Three riflemen at 6 m. Left: guard. Right: plasma sword. Dev take: the riflemen carry 1,000,000 HP (not data) so none falls and every return that reaches one is counted. Share = returns that hit a shooter / returned. Measured curve at 6 m: 24 % guard, 31 % sword.' },
];

async function capture(dir, take, seed, ppm, still = 0, side = false, ticks = 1000) {
  mkdirSync(dir, { recursive: true });
  const args = ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080',
    '--fixed-fps', '60', '--disable-vsync', '--quit-after', String(ticks + 5), 'res://dev/gauntlet/pressure_film.tscn',
    '--', '--take=' + take, '--seed=' + seed, '--ppm=' + ppm, '--still=' + still, '--out=' + dir.replaceAll('\\', '/'),
    ...(side ? ['--half=1'] : [])];
  const r = await runGodot(args, { headless: false, timeoutMs: 8 * 60_000, stopOn: SCRIPT_ERROR, name: 'pressure-film' });
  writeFileSync(join(dir, 'engine.log'), r.out);
  const summary = r.out.match(/\[INFO\] pressure-film: (\{.*\})/);
  if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out) || !summary) {
    throw new Error('Capture failed: ' + join(dir, 'engine.log'));
  }
  const row = JSON.parse(summary[1]);
  console.log(take, ppm, row);
  return row;
}

function ffmpeg(args, cwd) {
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', ...args], { cwd, stdio: 'inherit' });
}

function describe(film, samples) {
  if (film.file === 'standing_punished') {
    const [stand, circle, dash] = samples;
    if (stand.dashes || circle.dashes || !dash.dashes || !(stand.hp < circle.hp && circle.hp < dash.hp)) {
      throw new Error('The three movement takes did not demonstrate the HP difference');
    }
    return film.note + ' Final HP: ' + samples.map(r => r.hp.toFixed(1)).join(' / ') + '.';
  }
  if (film.file === 'deflect_half') {
    for (const r of samples) {
      const fraction = r.passed / (r.passed + r.returned);
      if (!(fraction >= 0.4 && fraction <= 0.6 && r.hp < 100 && r.shooter_hits < r.returned)) {
        throw new Error(r.take + ' did not show both throughput and a missed return');
      }
    }
    return film.note + ' ' + samples.map(r => r.take + ': ' + r.passed + ' passed, ' + r.returned + ' returned').join('. ') + '.';
  }
  if (film.file === 'trooper_pair') {
    const [circle, dash] = samples;
    if (!(circle.launches >= 4 && circle.rocket_hits > dash.rocket_hits && dash.dashes > 0)) {
      throw new Error('The pair takes did not show the dash saving health: ' + JSON.stringify(samples));
    }
    const down = r => (r.death_tick ? ', down at ' + (r.death_tick / 60).toFixed(1) + ' s' : '');
    const side = (name, r) => name + ': ' + r.rocket_hits + ' hits in ' + r.launches + ' rockets, HP '
      + r.hp_at_10s.toFixed(1) + ' at 10 s, ' + r.hp.toFixed(1) + ' at the end' + down(r);
    return film.note + ' ' + side('Circle', circle) + '. ' + side('Dash', dash) + '.';
  }
  if (film.file === 'deflect_6m') {
    for (const r of samples) {
      if (r.returned < 30) throw new Error(r.take + ' returned only ' + r.returned + ' rounds');
    }
    return film.note + ' ' + samples.map(r => r.take.replace('6', '') + ': ' + r.fired + ' fired, ' + r.passed + ' passed, '
      + r.returned + ' returned, ' + r.struck + ' hit a shooter (' + (100 * r.struck / r.returned).toFixed(1) + ' %)').join('. ') + '.';
  }
  if (!samples[0].paired_ticks) throw new Error('No frame contained both rockets in flight');
  return film.note;
}

async function buildFilm(film, scratch) {
  const clips = [];
  let ticks = 0;
  const samples = [];
  for (const take of film.takes) {
    const dir = join(scratch, take);
    const row = await capture(dir, take, film.seed, 32, 0, !!film.side, film.ticks);
    ticks += film.side ? 0 : row.tick;
    samples.push(row);
    if (film.side) continue;
    ffmpeg(['-framerate', '60', '-start_number', '1', '-i', join(dir, '%04d.jpg'), '-frames:v', String(row.tick),
      '-c:v', 'libx264', '-crf', '16', '-preset', 'fast', '-pix_fmt', 'yuv420p', take + '.mp4'], scratch);
    clips.push("file '" + take + ".mp4'");
  }
  const note = describe(film, samples);
  const video = film.file + '_32.mp4';
  if (film.side) {
    ticks = film.ticks;
    const [left, right] = film.takes.map(t => join(scratch, t, '%04d.jpg'));
    ffmpeg(['-framerate', '60', '-start_number', '1', '-i', left, '-framerate', '60', '-start_number', '1', '-i', right,
      '-filter_complex', '[0:v]crop=960:1080:480:0[l];[1:v]crop=960:1080:480:0[r];[l][r]hstack=inputs=2',
      '-frames:v', String(ticks), '-c:v', 'libx264', '-crf', '16', '-preset', 'fast', '-pix_fmt', 'yuv420p',
      '-movflags', '+faststart', video], scratch);
  } else {
    writeFileSync(join(scratch, 'clips.txt'), clips.join('\n') + '\n');
    ffmpeg(['-f', 'concat', '-i', 'clips.txt', '-c', 'copy', '-movflags', '+faststart', video], scratch);
  }
  const probe = JSON.parse(execFileSync('ffprobe', ['-v', 'error', '-select_streams', 'v:0', '-show_entries',
    'stream=width,height,avg_frame_rate,nb_frames,duration', '-of', 'json', join(scratch, video)]));
  const s = probe.streams[0];
  if (s.width !== 1920 || s.height !== 1080 || s.avg_frame_rate !== '60/1' || Number(s.nb_frames) !== ticks
      || Math.abs(Number(s.duration) - ticks / 60) > 0.001 || s.duration < 15 || s.duration > 40) {
    throw new Error(video + ' failed ffprobe: ' + JSON.stringify(s));
  }
  const closeup = film.file + '_64.png';
  const dir = join(scratch, film.file + '-still');
  const at = film.stillTick(samples.find(r => r.take === film.stillTake));
  await capture(dir, film.stillTake, film.seed, 64, at, false, at);
  copyFileSync(join(dir, 'still.png'), join(scratch, closeup));
  return [
    { file: video, title: film.title, ppm: 32, before: null, note },
    { file: closeup, title: film.title + ' / close-up', ppm: 64, before: null,
      note: 'Tick ' + at + ' of the ' + film.stillTake + ' take. ' + film.note },
  ];
}

const args = process.argv.slice(2);
const option = args.find(a => a.startsWith('--out=')) ?? '';
const out = option.slice('--out='.length);
const only = args.find(a => a.startsWith('--only='))?.slice('--only='.length).split(',');
const stray = args.filter(a => a !== option && !a.startsWith('--only='));
if (stray.length || !isAbsolute(out) || (only && only.some(n => !films.some(f => f.file === n)))) {
  throw new Error('Use --out=<absolute masters directory> [--only=' + films.map(f => f.file).join(',') + ']');
}
const base = join(ROOT, 'build', 'pressure-films');
mkdirSync(base, { recursive: true });
const scratch = mkdtempSync(join(base, 'capture-'));
const fresh = [];
for (const film of films.filter(f => !only || only.includes(f.file))) fresh.push(...await buildFilm(film, scratch));
mkdirSync(out, { recursive: true });
const index = join(out, 'frames.json');
const old = existsSync(index) ? JSON.parse(readFileSync(index, 'utf8')) : [];
const names = new Set(fresh.map(row => row.file));
for (const row of fresh) {
  const target = join(out, row.file);
  const temporary = target + '.' + process.pid + '.tmp';
  copyFileSync(join(scratch, row.file), temporary);
  renameSync(temporary, target);
}
const rows = [...fresh.filter(r => r.ppm === 32), ...fresh.filter(r => r.ppm === 64), ...old.filter(r => !names.has(r.file))];
const pendingIndex = index + '.' + process.pid + '.tmp';
writeFileSync(pendingIndex, JSON.stringify(rows, null, 2) + '\n');
renameSync(pendingIndex, index);
