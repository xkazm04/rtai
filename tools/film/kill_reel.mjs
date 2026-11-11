#!/usr/bin/env node
// The kill reel (n16 tools item 1): every signature death filmed in the kill lab on the city block,
// for a list of weapons x victim kinds x directions, at each zoom, same seed and same tick; one
// contact sheet per weapon and zoom, optional clips, and a before/after mode against a commit.
//   node tools/film/kill_reel.mjs --out=<dir> [--weapons=all|<id,id>] [--victims=<kind,kind>] [--dirs=0,90,180,270]
//     [--ppm=32,64] [--after=150] [--rev=<commit>] [--before=<commit>] [--native=donor] [--clips] [--keep-frames]
//     [--timeout=<s>] [--dry-run] [-- <extra game flags, e.g. --gore=reduced>]
// Each film is tools/film/film.mjs's `kill:<weapon>` shot (KillLab via BrutalityHook, `--sig-solo=start`),
// with `--sig-dir=<deg>` turning the guard about Rivet (0 east, 90 south) and `--victim=<kind>` drawing it as
// that card row. Stills: the lab's trigger window (ticks 54-70) and the first kill plus --after ticks.
// Exit: 0 every film passed, 1 a film failed, 2 usage (nothing launched), 3 a film was unverifiable.
import { existsSync, mkdirSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { EXIT, filmOne, pinRev, plan } from './film.mjs';
import { goreWhole, killWindow, measureBeats, pickBeats, reelPlan, sheetOf, tableRows, victimAt } from './kill_reel_lib.mjs';
import { diffImages, readPng } from './png.mjs';
import { filmedRoot } from './side.mjs';
import { encodePng, label } from './sheet.mjs';
import { spawnSync } from 'node:child_process';

const USAGE = 'usage: node tools/film/kill_reel.mjs --out=<dir> [--weapons=all|<id,id>] [--victims=<kind,...>] [--dirs=<deg|wall,...>] '
  + '[--ppm=32,64] [--after=150] [--rev=<commit>] [--before=<commit>] [--native=donor] [--clips] [--keep-frames] [--gore-check] [--timeout=<s>] [--dry-run] [-- flags]';
const WORST = ['pass', 'unverifiable', 'fail'];
/** n16 session 1 (build/kreel/t2 t60, build/film/victim_proof): the lab guard is drawn by no rig the probe finds
 *  (`FilmCard.rig` -> null, draw -1), and at the combo zooms it stood as the riot cop with --victim=thug. Film now
 *  judges the drawn row, so a lab film with a victim kind is UNVERIFIABLE until the probe finds the lab's rig;
 *  the `weapon:` shot's victim is seen (film.mjs weapon:pistol --victim=thug PASS on the drawn row). */
export const VICTIM_GAP = 'kill_reel: WARNING --victims: the drawn card of the lab guard is not visible to the probe yet, so these films come out UNVERIFIABLE; film one kind with film.mjs weapon:<gun> --victim=<kind>';

/** Plans one film of the reel through film.mjs: {shot, opts} or {error}. With the kill tick `known` from
 *  this combo's first zoom (the zoom is view only, so the sim kills on the same tick) and no clip wanted,
 *  the film saves the beat frames only: a full window is ~170 PNGs, about a minute of a busy machine. */
export function planFilm(job, side, reel, known = undefined) {
  const window = known === undefined || reel.clips ? { stills: '54-70', on: `kill:1+${reel.after}` } : { stills: pickBeats(known, reel.after).join(',') };
  const flags = { out: job.dir, ppm: String(job.ppm), ...window, view: 'combo', lock: 'auto',
    seed: '20261109', res: '1280x800', feel: 'auto', subject: 'rivet', timeout: String(reel.timeout), tree: side.tree };
  if (job.victim) flags.victim = job.victim;
  const turn = job.dir_deg === 'wall' ? ['--sig-wall'] : job.dir_deg ? [`--sig-dir=${job.dir_deg}`] : [];
  const extra = [...turn, ...reel.extra];
  return plan(flags, `kill:${job.weapon}`, extra);
}

/** Films a job, picks the beat frames, crops them about the kill; the rest of the frames go unless kept. */
async function filmJob(job, side, reel, runner, known) {
  const planned = planFilm(job, side, reel, known);
  if (planned.error) return { outcome: 'fail', reasons: [planned.error] };
  const r = await filmOne(planned, { runner });
  const k = r.probe?.events?.kill?.[0];
  if (r.outcome === 'fail' || !Number.isInteger(k)) return { outcome: r.outcome === 'pass' ? 'unverifiable' : r.outcome, reasons: r.reasons.length ? r.reasons : ['no kill'] };
  if (known !== undefined && k !== known) return { outcome: 'unverifiable', kill: k, reasons: [`the kill came at ${k} at ${job.ppm} px/m but at ${known} at the first zoom: the zoom moved the sim`] };
  const saved = new Set(r.stills ?? []);
  const beats = pickBeats(k, reel.after).filter((t) => saved.has(t));
  const box = killWindow(r.probe, k, job.ppm);
  const clip = reel.clips ? encodeClip(job, saved, k, box) : null;
  const frames = new Map(beats.map((t) => [t, readPng(join(job.dir, `t${t}.png`))]));
  const measured = measureBeats(frames, beats, k, box, diffImages);
  if (!reel.keepFrames) {
    for (const name of readdirSync(job.dir)) {
      const t = /^t(\d+)\.png$/.exec(name);
      if (t && !beats.includes(Number(t[1]))) rmSync(join(job.dir, name), { force: true });
    }
  }
  const gore = reel.goreCheck ? goreWhole(r.probe, k) : null;
  const outcome = !gore ? r.outcome : /not drawn whole/.test(gore) ? 'fail' : (r.outcome === 'pass' ? 'unverifiable' : r.outcome);
  return { outcome, reasons: gore ? [...r.reasons, `gore check: ${gore}`] : r.reasons, kill: k, beats, box, clip, measured, died: victimAt(r.probe, k),
    ...(reel.goreCheck ? { whole: gore === null } : {}) };
}

/** An mp4 of the contiguous saved run up to the kill's last frame, cropped to the kill window, at 60 fps. */
function encodeClip(job, saved, k, box) {
  let from = k;
  while (saved.has(from - 1)) from -= 1;
  let to = k;
  while (saved.has(to + 1)) to += 1;
  const mp4 = join(job.dir, 'clip.mp4');
  const r = spawnSync('ffmpeg', ['-y', '-loglevel', 'error', '-framerate', '60', '-start_number', String(from), '-i', join(job.dir, 't%d.png'),
    '-frames:v', String(to - from + 1), '-vf', `crop=${box[2]}:${box[3]}:${box[0]}:${box[1]}`, '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', mp4], { windowsHide: true });
  return r.status === 0 ? mp4 : null;
}

/** One sheet: a row per film (beats left to right), every cell the kill window at that film's zoom. */
function writeSheet(file, rows) {
  const live = rows.filter((row) => row.film?.box);
  if (!live.length) return null;
  const [cw, ch] = [Math.max(...live.map((r) => r.film.box[2])), Math.max(...live.map((r) => r.film.box[3]))];
  const cols = Math.max(...live.map((r) => r.film.beats.length));
  const [g, lh] = [4, 18];
  const width = cols * (cw + g) + g;
  const height = live.length * (ch + lh + g) + g;
  const pixels = Buffer.alloc(width * height * 3, 0x18);
  live.forEach((row, ri) => {
    const top = g + ri * (ch + lh + g);
    row.film.beats.forEach((tick, ci) => {
      const left = g + ci * (cw + g);
      const png = join(row.job.dir, `t${tick}.png`);
      if (!existsSync(png)) return;
      const img = readPng(png);
      label(pixels, width, left, top, cw, tick);
      const [x0, y0, w, h] = row.film.box;
      for (let y = 0; y < h; y++) {
        const src = ((y0 + y) * img.width + x0) * img.channels;
        for (let x = 0; x < w; x++) img.data.copy(pixels, ((top + lh + y) * width + left + x) * 3, src + x * img.channels, src + x * img.channels + 3);
      }
    });
  });
  writeFileSync(file, encodePng(width, height, pixels));
  return file;
}

/** One weapon's beat timings from its table row (the data side of the readout). */
export function beatLine(weapon, row) {
  if (!row?.id) return `${weapon}: no signature row (the standard death)`;
  return `${weapon}: ${row.id} (${row.style}) hit-stop ${row.hitstop_ticks}, held ${row.held_ticks} (grind ${row.grind_ticks}, stand ${row.stand_ticks}), crumble ${row.crumble_ticks}, flash ${row.flash_ticks} ticks`;
}

export function parseArgv(argv) {
  const dash = argv.indexOf('--');
  const extra = dash >= 0 ? argv.slice(dash + 1) : [];
  const flags = {};
  for (const a of dash >= 0 ? argv.slice(0, dash) : argv) {
    const m = /^--([a-z-]+)(?:=(.+))?$/.exec(a);
    if (!m) return { error: `kill_reel: bad argument ${a}` };
    flags[m[1]] = m[2] ?? true;
  }
  return { flags, extra };
}

export async function main(argv, { out = console.log, err = console.error, runner, resolveSide } = {}) {
  const parsed = parseArgv(argv);
  if (parsed.error) { err(`${parsed.error}\n${USAGE}`); return EXIT.usage; }
  // `all` reads the filmed tree's own table (a kill lane runs this from its worktree with rows this tree lacks).
  const here = filmedRoot();
  const reel = reelPlan(parsed.flags, parsed.extra, here);
  if (reel.error) { err(`kill_reel: ${reel.error}\n${USAGE}`); return EXIT.usage; }
  const sides = [];
  for (const [name, rev] of [...(reel.before ? [['before', reel.before]] : []), ['after', reel.rev]]) {
    const f = rev ? { rev, ...(reel.native ? { native: reel.native } : {}) } : {};
    const pinned = pinRev(f, resolveSide);
    if (pinned.error) { err(`${pinned.error}\n${USAGE}`); return EXIT.usage; }
    if (pinned.line) out(pinned.line.replace(/^film:/, `kill_reel: ${name}`));
    sides.push({ name, tree: resolve(f.tree ?? here) });
  }
  const jobs = reel.jobs.flatMap((j) => sides.map((s) => ({ ...j, side: s.name, dir: join(reel.out, j.weapon, `${s.name}_${j.victim || 'guard'}_d${j.dir_deg}_${j.ppm}`) })));
  for (const job of jobs) {
    const bad = planFilm(job, sides.find((s) => s.name === job.side), reel).error;
    if (bad) { err(`kill_reel: ${job.weapon}: ${bad}\n${USAGE}`); return EXIT.usage; }
  }
  out(`kill_reel: ${jobs.length} film(s): ${reel.weapons.join(' ')} x victims [${reel.victims.join(' ') || 'guard'}] x dirs [${reel.dirs.join(' ')}] x ppm [${reel.ppm.join(' ')}] x ${sides.map((s) => s.name).join('/')}`);
  if (reel.victims.length) out(VICTIM_GAP);
  if (reel.dryRun) { out('kill_reel: dry run, nothing launched'); return EXIT.pass; }
  mkdirSync(reel.out, { recursive: true });
  const rows = [];
  const kills = new Map();
  for (const job of jobs) {
    const key = [job.side, job.weapon, job.victim, job.dir_deg].join('|');
    const film = await filmJob(job, sides.find((s) => s.name === job.side), reel, runner, kills.get(key));
    if (!kills.has(key) && Number.isInteger(film.kill)) kills.set(key, film.kill);
    rows.push({ job, film });
    out(`kill_reel: ${job.side} ${job.weapon} ${job.victim || 'guard'} dir ${job.dir_deg} ${job.ppm} px/m: ${film.outcome.toUpperCase()}`
      + `${film.kill !== undefined ? ` kill at ${film.kill}` : ''}${film.measured ? `, settled by +${film.measured.settled_after_ticks ?? '?'}, aftermath ${(film.measured.aftermath_share * 100).toFixed(1)} % of the window` : ''}`
      + `${film.reasons.length ? `: ${film.reasons.join('; ')}` : ''}`);
  }
  const sheets = [];
  for (const weapon of reel.weapons) {
    for (const ppm of reel.ppm) {
      const file = writeSheet(join(reel.out, `${weapon}_${ppm}.png`), rows.filter((r) => r.job.weapon === weapon && r.job.ppm === ppm));
      if (file) { sheets.push(sheetOf(file, rows, weapon, ppm)); out(`kill_reel: sheet ${file}`); }
    }
  }
  const outcome = rows.map((r) => r.film.outcome).reduce((a, b) => (WORST.indexOf(b) > WORST.indexOf(a) ? b : a), 'pass');
  const table = tableRows(sides.at(-1).tree, reel.weapons);
  for (const w of reel.weapons) out(`kill_reel: ${beatLine(w, table[w])}`);
  writeFileSync(join(reel.out, 'reel.json'), `${JSON.stringify({ schema: 'gtai.kill-reel/1', outcome, argv, sides, table, sheets,
    films: rows.map(({ job, film }) => ({ ...job, ...film })) }, null, 1)}\n`);
  out(`kill_reel: ${outcome.toUpperCase()}; ${join(reel.out, 'reel.json')}`);
  return EXIT[outcome];
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
