// The kill reel's outputs (tools/film/kill_reel.mjs): clips, the sheet per weapon and zoom, the overview of every
// weapon, reel.json and reel.md. `resheet` rebuilds the sheets, overview and reel.md from a reel.json and the beat
// frames it kept, without Godot (a label or layout change, or a reel filmed by an older kit).
import { existsSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { anchorShifts, boxAt, cellLabel, reelMarkdown, sheetOf } from './kill_reel_lib.mjs';
import { readPng } from './png.mjs';
import { encodePng, label } from './sheet.mjs';

const WORST = ['pass', 'unverifiable', 'fail'];

/** An mp4 of the contiguous saved run up to the kill's last frame, cropped to the kill window, at 60 fps. */
export function encodeClip(job, saved, k, box) {
  let from = k;
  while (saved.has(from - 1)) from -= 1;
  let to = k;
  while (saved.has(to + 1)) to += 1;
  const mp4 = join(job.dir, 'clip.mp4');
  const r = spawnSync('ffmpeg', ['-y', '-loglevel', 'error', '-framerate', '60', '-start_number', String(from), '-i', join(job.dir, 't%d.png'),
    '-frames:v', String(to - from + 1), '-vf', `crop=${box[2]}:${box[3]}:${box[0]}:${box[1]}`, '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', mp4], { windowsHide: true });
  return r.status === 0 ? mp4 : null;
}

/** With the hit feel on, the clip is cut from film's --write-movie (every frame drawn, a held tick's too) at the
 *  probe's frame numbers, so the hit-stop and the camera punch play at the game's real timing; the stills hold one
 *  frame per tick and cannot show a freeze. The whole-film movie goes unless --keep-frames. */
export function cutMovie(job, movie, [first, last], box, keep) {
  const mp4 = join(job.dir, 'clip.mp4');
  const r = spawnSync('ffmpeg', ['-y', '-loglevel', 'error', '-i', movie, '-vf', `select='between(n,${first},${last})',setpts=N/60/TB,crop=${box[2]}:${box[3]}:${box[0]}:${box[1]}`,
    '-r', '60', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', mp4], { windowsHide: true });
  if (!keep) rmSync(movie, { force: true });
  return r.status === 0 ? mp4 : null;
}

/** One sheet: a row per film (beats left to right), every cell the kill window at that film's zoom, anchored to the
 *  street by the film's camera shifts (a reel.json without shifts: fixed on screen, as filmed before n16 s3). */
export function writeSheet(file, rows) {
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
      label(pixels, width, left, top, cw, cellLabel(row.job, row.film, tick, ci));
      const [x0, y0, w, h] = boxAt(row.film.box, row.film.shifts?.[tick]);
      for (let y = 0; y < h; y++) {
        const src = ((y0 + y) * img.width + x0) * img.channels;
        for (let x = 0; x < w; x++) img.data.copy(pixels, ((top + lh + y) * width + left + x) * 3, src + x * img.channels, src + x * img.channels + 3);
      }
    });
  });
  writeFileSync(file, encodePng(width, height, pixels));
  return file;
}

/** One weapon's beat timings from its table row (the data side of the readout). The row's hitstop_ticks is NOT the
 *  screen freeze: SignatureKills.hold makes the pieces (gibs, halves, marks) wait that many sim ticks, while the
 *  freeze is FeelCam's (hit_feel.json kill_hitstop `kill` = camera.json 6 ticks, or a class's bigger stop: the
 *  rocket's 8), which each film measures as `hit-stop N frames`. */
export function beatLine(weapon, row) {
  if (!row?.id) return `${weapon}: no signature row (the standard death)`;
  return `${weapon}: ${row.id} (${row.style}) row hit-stop ${row.hitstop_ticks} (the pieces wait; the screen freeze is hit_feel.json's, measured per film), held ${row.held_ticks} (grind ${row.grind_ticks}, stand ${row.stand_ticks}), crumble ${row.crumble_ticks}, flash ${row.flash_ticks} ticks`
    + (row.body_gone_s ? `; the body and its pieces are gone by ${row.body_gone_s} s, the scorch and spray by ${row.stain_gone_s ?? '?'} s (corpse_decay.json linger + fade)` : '')
    + (row.leftover_kills ? `${row.body_gone_s ? ', the marks sooner if' : '; its scorch and spray stay until'} ${row.leftover_kills} later kills recycle them (leftover_budget ring)` : '');
}

/** Sheets per weapon and zoom, the overview per zoom (more than one weapon), the beat lines, reel.json and reel.md;
 *  returns the reel's outcome (the worst film's). `meta` = { argv, sides } as reel.json records them. */
export function finish(reel, rows, table, meta, out) {
  const sheets = [];
  for (const weapon of reel.weapons) {
    for (const ppm of reel.ppm) {
      const file = writeSheet(join(reel.out, `${weapon}_${ppm}.png`), rows.filter((r) => r.job.weapon === weapon && r.job.ppm === ppm));
      if (file) { sheets.push(sheetOf(file, rows, weapon, ppm)); out(`kill_reel: sheet ${file}`); }
    }
  }
  if (reel.weapons.length > 1) {
    for (const ppm of reel.ppm) {
      const file = writeSheet(join(reel.out, `reel_${ppm}.png`), rows.filter((r) => r.job.ppm === ppm));
      if (file) out(`kill_reel: overview ${file} (a row per film, every weapon)`);
    }
  }
  const outcome = rows.map((r) => r.film.outcome).reduce((a, b) => (WORST.indexOf(b) > WORST.indexOf(a) ? b : a), 'pass');
  for (const w of reel.weapons) out(`kill_reel: ${beatLine(w, table[w])}`);
  writeFileSync(join(reel.out, 'reel.json'), `${JSON.stringify({ schema: 'gtai.kill-reel/1', outcome, argv: meta.argv, sides: meta.sides, table, sheets,
    films: rows.map(({ job, film }) => ({ ...job, ...film })) }, null, 1)}\n`);
  writeFileSync(join(reel.out, 'reel.md'), reelMarkdown(rows, table, `node tools/film/kill_reel.mjs ${meta.argv.join(' ')}`));
  out(`kill_reel: ${outcome.toUpperCase()}; ${join(reel.out, 'reel.json')} and reel.md`);
  return outcome;
}

const JOB_KEYS = ['weapon', 'victim', 'dir_deg', 'ppm', 'side', 'dir'];

/** Rebuilds a reel's sheets, overview and reel.md from `<out>/reel.json` and its kept beat frames: the outcome, or
 *  {error}. The films and the table stay as filmed. */
export function resheet(dir, out) {
  const file = join(dir, 'reel.json');
  if (!existsSync(file)) return { error: `no reel.json in ${dir}` };
  const reel = JSON.parse(readFileSync(file, 'utf8'));
  if (reel.schema !== 'gtai.kill-reel/1' || !Array.isArray(reel.films)) return { error: `${file} is not a gtai.kill-reel/1 reel` };
  const rows = reel.films.map((f) => ({ job: Object.fromEntries(JOB_KEYS.map((k) => [k, f[k]])),
    film: Object.fromEntries(Object.entries(f).filter(([k]) => !JOB_KEYS.includes(k))) }));
  for (const { job, film } of rows) {  // a reel filmed before the street anchor: its shifts from the kept probe
    const probe = join(job.dir ?? '', 'probe.json');
    if (!film.shifts && Number.isInteger(film.kill) && Array.isArray(film.beats) && existsSync(probe)) {
      film.shifts = anchorShifts(JSON.parse(readFileSync(probe, 'utf8')), film.kill, film.beats);
    }
  }
  const plan = { out: dir, weapons: [...new Set(rows.map((r) => r.job.weapon))], ppm: [...new Set(rows.map((r) => r.job.ppm))] };
  return finish(plan, rows, reel.table ?? {}, { argv: reel.argv ?? [], sides: reel.sides ?? [] }, out);
}
