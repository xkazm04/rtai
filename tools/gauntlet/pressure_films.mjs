#!/usr/bin/env node
// With the lane's APPDATA and GODOT_BIN set, run:
// node tools/gauntlet/pressure_films.mjs --out=<absolute masters directory>
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync, renameSync, rmSync, writeFileSync } from 'node:fs';
import { isAbsolute, join } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

// The side-by-side masters encode at crf 23: a 40 s 1080p60 take is about 15 MB, not 100 MB.
const SIDE_CRF = '23';
// deflect_6m is busy (rounds, sparks on every frame): crf 26 keeps it near 27 MB where crf 23 is 42 MB.
// Why the dashing take dashes once per two rockets (measured: launches at ticks 81, 82, 195, 196, ...).
const DASH_REASON = 'The troopers fire in volleys of two rockets one tick apart every 114 ticks, so every volley asks for two dashes one tick apart and the second press lands inside the first dash (10 ticks, then a 40-tick cooldown): one dash per volley, 13 volleys in 1500 ticks.';

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
    side: true, crf: '26', ticks: 2380, seed: 1, stillTake: 'blade6', stillTick: r => r.first_return + 3,
    note: 'Three riflemen at 6 m. Left: guard. Right: plasma sword. Dev take: the riflemen carry 1,000,000 HP (not data) so none falls and every return that reaches one is counted. Rivet also carries dev HP, so the HP bar is hidden. Cadence differs: the guard (meter refills only while lowered) faces 6-round salvos 9 ticks apart then a pause; the sword faces pairs 18 ticks apart every 0.6 s and catches about half of the rounds. Share = returns that hit a shooter / returned. Measured curve at 6 m: 24 % guard, 31 % sword.' },
  { file: 'blade_cadence', title: 'Plasma sword: rounds in pairs and rounds spaced', takes: ['blade6', 'blade6_spaced'],
    side: true, ticks: 2380, seed: 1, cadence: true, noCloseup: true, stillTake: 'blade6_spaced', stillTick: () => 0,
    note: 'Same three riflemen at 6 m, same plasma sword, same seed. Left: the shipped pairs, the second round 18 ticks after the first, so it arrives while the sword is still finishing the swing it started for the first. Right: one round at a time, 36 ticks apart (the riflemen take turns), so every round meets a fresh swing. Dev take: riflemen and Rivet carry dev HP so none falls and every return that reaches a shooter is counted.' },
];

// Single-take stills: the tick comes from the take's own moments (PressureMoments) at the film seed,
// the notes quote the pooled ten-seed table in evidence/n27-pressure/takes/seeds.json.
const seeds = () => JSON.parse(readFileSync(join(ROOT, 'evidence', 'n27-pressure', 'takes', 'seeds.json'), 'utf8')).rows;
const total = (take, key) => seeds().filter(r => r.take === take).reduce((a, r) => a + r[key], 0);
const median = (take, key) => {
  const v = seeds().filter(r => r.take === take).map(r => r[key]).sort((a, b) => a - b);
  return (v[Math.floor((v.length - 1) / 2)] + v[Math.floor(v.length / 2)]) / 2;
};
const pct = (k, n) => (100 * k / n).toFixed(1) + ' %';
const pooled = take => total(take, 'returned') + ' of ' + total(take, 'fired') + ' rounds ('
  + pct(total(take, 'returned'), total(take, 'fired')) + '), and ' + total(take, 'struck') + ' of those returns hit a shooter ('
  + pct(total(take, 'struck'), total(take, 'returned')) + ')';
const stills = [
  { file: 'pair_dash_cross_64.png', take: 'pair_dash', ppm: 64, moment: 'moment_dash_cross', shift: 4,
    title: 'Mid-dash across a rocket line',
    note: (t) => 'Rivet is mid-dash sideways (the faint copies behind him are the dash trail) while two rockets fly down the street at the spot he just left. Take pair_dash, seed 1, tick ' + t
      + '. Over seeds 1 to 10 the dashing Rivet is hit directly by ' + total('pair_dash', 'direct') + ' of ' + total('pair_dash', 'launches')
      + ' rockets (' + pct(total('pair_dash', 'direct'), total('pair_dash', 'launches')) + ') and loses a median of '
      + median('pair_dash', 'hp_lost').toFixed(1) + ' HP in 25 s.' },
  { file: 'pair_circle_fatal_64.png', take: 'pair_circle', ppm: 64, moment: 'moment_before_fatal', shift: 0,
    title: 'The rocket that downs a circling Rivet',
    note: (t, r) => 'Two rockets fly at a circling Rivet, 13 ticks before the leading one downs him (HP already 8.9 of 100). Take pair_circle, seed 1, tick ' + t
      + ' (down at tick ' + r.death_tick + '). Over seeds 1 to 10 the steady circle is hit directly by '
      + total('pair_circle', 'direct') + ' of ' + total('pair_circle', 'launches') + ' rockets ('
      + pct(total('pair_circle', 'direct'), total('pair_circle', 'launches')) + ') and goes down in every seed.' },
  { file: 'guard_return_64.png', take: 'guard6', ppm: 64, moment: 'moment_returned_flight', shift: 0,
    title: 'Guard: a returned round flying back',
    note: (t) => 'A rifle round turned back by the guard streaks back toward the riflemen (the thin dark line right of the white spark). Take guard6, seed 1, tick ' + t
      + '. Over seeds 1 to 10 the guard turns back ' + total('guard6', 'returned') + ' of ' + total('guard6', 'fired')
      + ' rounds and ' + total('guard6', 'struck') + ' of those hit a shooter (' + pct(total('guard6', 'struck'), total('guard6', 'returned')) + ').' },
  { file: 'blade_struck_64.png', take: 'blade6', ppm: 64, moment: 'moment_unswung_round', shift: 0,
    title: 'Plasma sword: a round arrives during a swing',
    note: (t) => 'An orange rifle round is about to hit Rivet while his sword is in the slow end of a swing, so nothing turns it back (the second round of each pair arrives like this). Take blade6, seed 1, tick ' + t
      + '. Over seeds 1 to 10 exactly ' + total('blade6', 'fate_unswung_hit') + ' of ' + total('blade6', 'fired')
      + ' rounds arrive this way (half), all of them during a swing; the sword turns back ' + total('blade6', 'returned') + '.' },
  { file: 'blade_spaced_return_64.png', take: 'blade6_spaced', ppm: 64, moment: 'moment_returned_flight', shift: 0,
    title: 'Plasma sword with rounds spaced: a round turned back',
    note: (t) => 'With the rounds a full swing apart, the sword turns a rifle round back toward the riflemen. Take blade6_spaced, seed 1, tick ' + t
      + '. Over seeds 1 to 10 the spaced sword turns back ' + pooled('blade6_spaced') + '; with the shipped pairs it turns back '
      + pooled('blade6') + '.' },
  { file: 'pair_dash_32.png', take: 'pair_dash', ppm: 32, moment: 'moment_dash_cross', shift: 4,
    title: 'Dashing across a rocket line, whole street',
    note: (t) => 'The same dash at 32 px/m, both troopers in frame. Take pair_dash, seed 1, tick ' + t + '. Rockets that land directly: '
      + total('pair_dash', 'direct') + ' of ' + total('pair_dash', 'launches') + ' over ten seeds.' },
  { file: 'blade6_32.png', take: 'blade6', ppm: 32, moment: 'moment_unswung_round', shift: 0,
    title: 'Plasma sword at 6 m, whole street',
    note: (t) => 'The round that arrives mid-swing at 32 px/m, three riflemen in frame. Take blade6, seed 1, tick ' + t
      + '. Over seeds 1 to 10 the sword turns back ' + pct(total('blade6', 'returned'), total('blade6', 'fired')) + ' of the rounds fired at it.' },
];

async function buildStills(scratch, only) {
  const rows = [];
  const takes = new Map();
  for (const st of stills.filter(x => !only || only.includes('stills') || only.includes(x.file))) {
    if (!takes.has(st.take)) {
      const r = await runGodot(['res://dev/gauntlet/pressure_film.tscn', '--', '--take=' + st.take, '--seed=1', '--ppm=32'],
        { name: 'pressure-moments', timeoutMs: 5 * 60_000, stopOn: SCRIPT_ERROR });
      const m = r.out.match(/\[INFO\] pressure-film: (\{.*\})/);
      if (r.status !== 0 || !m) throw new Error('Moments run failed for ' + st.take);
      takes.set(st.take, JSON.parse(m[1]));
    }
    const row = takes.get(st.take);
    if (!(row[st.moment] > 0)) throw new Error(st.take + ' has no ' + st.moment);
    const at = row[st.moment] + st.shift;
    const dir = join(scratch, st.file + '-still');
    await capture(dir, st.take, 1, st.ppm, at, false, at);
    copyFileSync(join(dir, 'still.png'), join(scratch, st.file));
    rows.push({ file: st.file, title: st.title, ppm: st.ppm, before: null, note: st.note(at, row) });
  }
  return rows;
}

async function capture(dir, take, seed, ppm, still = 0, side = false, ticks = 1000, extra = []) {
  mkdirSync(dir, { recursive: true });
  const args = ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080',
    '--fixed-fps', '60', '--disable-vsync', '--quit-after', String(ticks + 5), 'res://dev/gauntlet/pressure_film.tscn',
    '--', '--take=' + take, '--seed=' + seed, '--ppm=' + ppm, '--still=' + still, '--out=' + dir.replaceAll('\\', '/'),
    ...(side ? ['--half=1'] : []), ...extra];
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
    if (!(circle.launches >= 4 && circle.direct > dash.direct && dash.dashes > 0 && circle.hp_lost > dash.hp_lost)) {
      throw new Error('The pair takes did not show the dash saving health: ' + JSON.stringify(samples));
    }
    const down = r => (r.death_tick ? ', down at ' + (r.death_tick / 60).toFixed(1) + ' s' : '');
    const side = (name, r) => name + ': ' + r.launches + ' rockets, ' + r.direct + ' direct, ' + r.splash + ' splash, '
      + r.other + ' other, HP lost ' + r.hp_lost.toFixed(1) + ', HP ' + r.hp_at_10s.toFixed(1) + ' at 10 s' + down(r);
    return film.note + ' ' + side('Circle', circle) + '. ' + side('Dash', dash) + '. Dash count: ' + dash.dashes
      + ' dashes for ' + dash.dash_presses + ' presses and ' + dash.launches + ' rockets. ' + DASH_REASON;
  }
  if (film.file === 'deflect_6m') {
    for (const r of samples) {
      if (r.returned < 30) throw new Error(r.take + ' returned only ' + r.returned + ' rounds');
    }
    return film.note + ' ' + samples.map(r => r.take.replace('6', '') + ': ' + r.fired + ' fired, ' + r.passed + ' passed, '
      + r.returned + ' returned, ' + r.struck + ' hit a shooter (' + (100 * r.struck / r.returned).toFixed(1) + ' %)').join('. ') + '.';
  }
  if (film.file === 'blade_cadence') {
    const [paired, spaced] = samples;
    if (paired.returned < 30 || !(spaced.returned / spaced.fired > paired.returned / paired.fired)) {
      throw new Error('The spaced sword did not turn back a larger share than the paired one');
    }
    const side = (name, r) => name + ': ' + r.fired + ' fired, ' + r.returned + ' returned, ' + r.passed + ' passed, '
      + r.struck + ' hit a shooter, ' + (100 * r.returned / r.fired).toFixed(0) + ' % turned back';
    return film.note + ' Seed 1: ' + side('pairs', paired) + '; ' + side('spaced', spaced) + '. Over seeds 1 to 10: with pairs the sword turns back '
      + pooled('blade6') + '; spaced, it turns back ' + pooled('blade6_spaced') + '.';
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
    const row = await capture(dir, take, film.seed, 32, 0, !!film.side, film.ticks, film.cadence ? ['--cadence'] : []);
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
      '-frames:v', String(ticks), '-c:v', 'libx264', '-crf', film.crf ?? SIDE_CRF, '-preset', 'slow', '-pix_fmt', 'yuv420p',
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
  if (film.noCloseup) return [{ file: video, title: film.title, ppm: 32, before: null, note }];
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
if (stray.length || !isAbsolute(out) || (only && only.some(n => n !== 'stills' && !films.some(f => f.file === n) && !stills.some(st => st.file === n)))) {
  throw new Error('Use --out=<absolute masters directory> [--only=' + films.map(f => f.file).join(',') + ',stills,' + stills.map(st => st.file).join(',') + ']');
}
const base = join(ROOT, 'build', 'pressure-films');
mkdirSync(base, { recursive: true });
const scratch = mkdtempSync(join(base, 'capture-'));
const fresh = [];
for (const film of films.filter(f => !only || only.includes(f.file))) fresh.push(...await buildFilm(film, scratch));
if (!only || only.includes('stills') || stills.some(st => only.includes(st.file))) fresh.push(...await buildStills(scratch, only));
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
// Best first: the story videos and the stills that carry the findings, then the supporting frames.
const ORDER = ['trooper_pair_32.mp4', 'pair_dash_cross_64.png', 'blade_cadence_32.mp4', 'blade_spaced_return_64.png',
  'pair_circle_fatal_64.png', 'deflect_6m_32.mp4',
  'blade_struck_64.png', 'guard_return_64.png', 'trooper_pair_64.png', 'deflect_6m_64.png', 'pair_dash_32.png', 'blade6_32.png'];
const rank = r => (ORDER.includes(r.file) ? ORDER.indexOf(r.file) : ORDER.length);
const rows = [...fresh, ...old.filter(r => !names.has(r.file))].sort((a, b) => rank(a) - rank(b));
const pendingIndex = index + '.' + process.pid + '.tmp';
writeFileSync(pendingIndex, JSON.stringify(rows, null, 2) + '\n');
renameSync(pendingIndex, index);
rmSync(scratch, { recursive: true, force: true });
