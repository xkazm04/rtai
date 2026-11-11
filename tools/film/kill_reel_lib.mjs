// The kill reel's pure parts (tools/film/kill_reel.mjs): the plan of films, the beat frames, the
// crop about a kill, and the signature_kills rows each weapon's death is drawn from.
import { readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';

/** The burn death is the fire's, not a gun's: these weapons set a man ablaze. */
export const BURN_WEAPONS = ['flamethrower', 'molotov'];
/** Kill window size in metres (wide enough for a gib's flight, the nuke pack and Rivet). */
export const WINDOW_M = [12, 9];
export const VIEW = [1280, 800];
export const MAX_AFTER = 230;
/** Metres of the kill window kept free about Rivet and the victim before the window gives Rivet up (killWindow). */
export const FIT_MARGIN_M = 2;

const table = (tree, rel) => JSON.parse(readFileSync(join(tree, 'project', rel), 'utf8'));

/** The weapons a signature row is drawn for: its `weapon`, its `also_weapons`, and the fire weapons for `burn`. */
const rowWeapons = (row) => [row.weapon, ...(row.also_weapons ?? []), ...(row.weapon === 'burn' ? BURN_WEAPONS : [])];

/** The weapons Rivet can carry into the lab that have a signature death in `tree`. */
export function reelWeapons(tree = ROOT) {
  const armed = new Set([...table(tree, 'data/tables/weapons.json').weapons.map((w) => w.id),
    ...Object.keys(table(tree, 'data/tables/melee_weapons.json').weapons)]);
  const rows = table(tree, 'data/tables/signature_kills.json').kills;
  return [...new Set(rows.flatMap(rowWeapons).filter((w) => armed.has(w)))];
}

/** The beat timings a weapon's death takes from its signature_kills row ({} = no row: the standard death).
 *  `held_ticks` is the beat the body holds before it leaves: hit-stop + grind + stand (a burning or
 *  dissolving man standing), `crumble_ticks` the fall after it. The measured side is the reel's films. */
export function tableRows(tree, weapons) {
  const t = table(tree, 'data/tables/signature_kills.json');
  const kills = t.kills;
  const out = {};
  for (const w of weapons) {
    const row = kills.find((k) => rowWeapons(k).includes(w));
    const n = (key) => row?.[key] ?? 0;
    out[w] = row ? { id: row.id, style: row.style, hitstop_ticks: n('hitstop_ticks'), grind_ticks: n('grind_ticks'),
      stand_ticks: n('stand_ticks'), crumble_ticks: n('crumble_ticks'), flash_ticks: n('flash_ticks'),
      held_ticks: n('hitstop_ticks') + n('grind_ticks') + n('stand_ticks'),
      ...(t.leftover_budget ? { leftover_kills: t.leftover_budget } : {}) } : {};
  }
  return out;
}

const list = (text, fallback) => (text === undefined || text === true ? fallback : String(text).split(',').map((s) => s.trim()).filter(Boolean));

/** Everything the reel needs before a launch, or {error}. Pure apart from reading `tree`'s tables for `all`. */
export function reelPlan(flags, extra, tree = ROOT) {
  const known = new Set(['out', 'weapons', 'victims', 'dirs', 'ppm', 'after', 'rev', 'before', 'native', 'clips', 'keep-frames', 'timeout', 'dry-run', 'gore-check', 'feel', 'quick']);
  const stray = Object.keys(flags).find((k) => !known.has(k));
  if (stray) return { error: `unknown option --${stray}` };
  if (!flags.out || flags.out === true) return { error: '--out=<dir> is required' };
  for (const k of ['clips', 'keep-frames', 'dry-run', 'gore-check', 'quick']) if (flags[k] !== undefined && flags[k] !== true) return { error: `--${k} takes no value` };
  const weapons = flags.weapons === undefined || flags.weapons === 'all' ? reelWeapons(tree) : list(flags.weapons, []);
  // --quick, the builders' inner loop: one zoom (play zoom) and one side-on direction unless named.
  const quick = flags.quick === true;
  const dirs = list(flags.dirs, [quick ? '90' : '0']).map((d) => (d === 'wall' ? d : Number(d)));
  const ppm = list(flags.ppm, quick ? ['32'] : ['32', '64']).map(Number);
  const after = Number(flags.after ?? 150);
  if (!weapons.length) return { error: '--weapons names no weapon' };
  if (dirs.some((d) => d !== 'wall' && (!Number.isInteger(d) || d < 0 || d >= 360))) return { error: `--dirs takes whole degrees 0-359 (0 east, 90 south) or wall, got ${flags.dirs}` };
  if (ppm.some((p) => !Number.isInteger(p) || p < 8 || p > 96)) return { error: `--ppm takes whole px/m 8-96, got ${flags.ppm}` };
  if (!Number.isInteger(after) || after < 1 || after > MAX_AFTER) return { error: `--after takes 1-${MAX_AFTER} ticks, got ${flags.after}` };
  for (const k of ['rev', 'before', 'native', 'timeout']) if (flags[k] === true) return { error: `--${k} needs a value` };
  if (flags.native !== undefined && !flags.rev && !flags.before) return { error: '--native=donor goes with --rev or --before' };
  if (extra.some((a) => /^--(sig-dir|sig-wall|sig-gun|sig-solo|victim|seed|ppm)(=|$)/.test(a))) return { error: 'the reel sets --sig-dir, --sig-wall, --sig-gun, --sig-solo, --victim, --seed and --ppm itself: use --dirs, --weapons, --victims, --ppm' };
  if (flags['gore-check'] && extra.some((a) => a.startsWith('--gore='))) return { error: '--gore-check passes --gore=reduced itself' };
  if (flags.feel !== undefined && !['on', 'off', 'auto'].includes(flags.feel)) return { error: `--feel takes on, off or auto, got ${flags.feel}` };
  const victims = list(flags.victims, ['']);
  const jobs = weapons.flatMap((weapon) => victims.flatMap((victim) => dirs.flatMap((dir_deg) => ppm.map((p) => ({ weapon, victim, dir_deg, ppm: p })))));
  const gore = flags['gore-check'] === true;
  return { out: resolve(flags.out), weapons, victims: victims.filter(Boolean), dirs, ppm, after, jobs, goreCheck: gore, feel: flags.feel ?? 'auto',
    extra: gore ? [...extra, '--gore=reduced'] : extra,
    rev: flags.rev ?? null, before: flags.before ?? null, native: flags.native ?? null, clips: flags.clips === true,
    keepFrames: flags['keep-frames'] === true, dryRun: flags['dry-run'] === true, timeout: Number(flags.timeout ?? 300) };
}

/** The sheet's columns: the lab's trigger tick, the kill and its first frames, then the held beat and the aftermath. */
export function pickBeats(kill, after) {
  const offsets = [-2, 0, 1, 2, 4, 6, 10, 20, 40, 80, after];
  return [...new Set([60, ...offsets.filter((o) => o <= after).map((o) => kill + o)])].filter((t) => t >= 0).sort((a, b) => a - b);
}

/** The hostile that died at `kill` (alive the tick before, dead on it), or null. */
export function victimAt(probe, kill) {
  const at = (t) => probe?.rows?.find((r) => r.tick === t)?.fighters ?? [];
  const before = new Map(at(kill - 1).filter((f) => f.role === 'hostile' && f.alive).map((f) => [f.id, f]));
  const died = at(kill).find((f) => f.role === 'hostile' && !f.alive && before.has(f.id));
  return died ? { id: died.id, pos: died.pos, screen: before.get(died.id).screen } : null;
}

/** The crop [x, y, w, h] (even sizes, inside the view) centred between Rivet and his victim at the kill, or on the
 *  victim when the two are too far apart to share it with FIT_MARGIN_M to spare (the mini nuke kills ~25 m off).
 *  The victim is placed from the sim: Rivet's screen point plus the metres between them at `ppm`, because
 *  the probe has no screen point for a guard whose card it cannot see (a turned guard read 9010, 8368). */
export function killWindow(probe, kill, ppm, view = VIEW) {
  const r = probe?.rows?.find((row) => row.tick === kill)?.fighters?.find((f) => f.role === 'rivet');
  const rivet = r?.screen ?? [view[0] / 2, view[1] / 2];
  const died = victimAt(probe, kill);
  const victim = died?.pos && r?.pos ? [rivet[0] + (died.pos[0] - r.pos[0]) * ppm, rivet[1] + (died.pos[1] - r.pos[1]) * ppm] : rivet;
  const w = Math.min(view[0], 2 * Math.round((WINDOW_M[0] * ppm) / 2));
  const h = Math.min(view[1], 2 * Math.round((WINDOW_M[1] * ppm) / 2));
  const margin = FIT_MARGIN_M * ppm;
  const apart = Math.abs(rivet[0] - victim[0]) > w - margin || Math.abs(rivet[1] - victim[1]) > h - margin;
  const cx = apart ? victim[0] : (rivet[0] + victim[0]) / 2;
  const cy = apart ? victim[1] : (rivet[1] + victim[1]) / 2;
  const x = Math.max(0, Math.min(view[0] - w, Math.round(cx - w / 2)));
  const y = Math.max(0, Math.min(view[1] - h, Math.round(cy - h / 2)));
  return [x, y, w, h];
}

/** What a sheet's rows are, top to bottom (the PNG labels each cell with its tick only). */
export function sheetOf(file, rows, weapon, ppm) {
  const mine = rows.filter((r) => r.job.weapon === weapon && r.job.ppm === ppm && r.film?.box);
  return { file, weapon, ppm, rows: mine.map(({ job, film }) => ({ side: job.side, victim: job.victim || 'guard', dir_deg: job.dir_deg,
    kill: film.kill, beats: film.beats, outcome: film.outcome })) };
}

/** The --gore-check verdict for one film run with --gore=reduced: null when the victim still lies drawn as ONE
 *  card `settle` ticks after the kill (the standard death: dropped whole), else why not. A signature death hides
 *  the victim's rig (consumed), so its card is gone (draw -1) while gibs or halves fly. */
export function goreWhole(probe, kill, settle = 20) {
  const died = victimAt(probe, kill);
  if (!died) return `no victim died on tick ${kill}`;
  const before = probe.rows.find((r) => r.tick === kill - 1)?.fighters?.find((f) => f.id === died.id);
  if (!before || before.draw?.[0] < 0) return `the victim (id ${died.id}) had no card the tick before it died, so whole or not is not seen`;
  const after = probe.rows.find((r) => r.tick === kill + settle)?.fighters?.find((f) => f.id === died.id);
  if (!after) return `no numbers for the victim ${settle} ticks after the kill`;
  return after.draw?.[0] > 0 ? null : `the victim (id ${died.id}) is not drawn whole ${settle} ticks after the kill (draw ${after.draw?.join('x')}): a signature death under --gore=reduced`;
}

/** The `box` part of a decoded PNG, as an image diffImages takes. */
export function cropImage(img, [x0, y0, w, h]) {
  const data = Buffer.alloc(w * h * img.channels);
  for (let y = 0; y < h; y++) img.data.copy(data, y * w * img.channels, ((y0 + y) * img.width + x0) * img.channels, ((y0 + y) * img.width + x0 + w) * img.channels);
  return { width: w, height: h, channels: img.channels, data };
}

/** The measured side of the beat readout, from a film's beat frames inside the kill window: `aftermath_share`,
 *  the share of the window still differing from the trigger frame at the last beat (what stays on the street),
 *  and `settled_by`, the first beat after the kill from which the window differs from the last beat by under
 *  `still` (the motion is over by then; coarse: beats only). `frames` maps tick -> decoded image. */
export function measureBeats(frames, beats, kill, box, diff, { tolerance = 12, still = 0.01 } = {}) {
  const last = beats.at(-1);
  if (!frames.has(60) || !frames.has(last) || last <= kill) return null;
  const crop = (t) => cropImage(frames.get(t), box);
  const end = crop(last);
  const settled = beats.filter((t) => t > kill && frames.has(t)).find((t) => diff(crop(t), end, tolerance).fraction < still) ?? null;
  return { aftermath_share: Number(diff(crop(60), end, tolerance).fraction.toFixed(4)), settled_by: settled, settled_after_ticks: settled === null ? null : settled - kill };
}

/** The measured hit-stop: frames the game drew while the sim held a tick (SimClock.hold, FeelCam's hit-stop) from
 *  the tick before the kill to `span` after it: each probe row records its process `frame`, so a tick held for N
 *  frames shows as a gap of N + 1 to the next row. No still shows these frames (a still is saved per tick). null
 *  when the rows there carry no frame. Only a `--feel=on` film holds. */
export function measureStop(probe, kill, span = 12) {
  const frame = new Map((probe?.rows ?? []).filter((r) => Number.isInteger(r.frame)).map((r) => [r.tick, r.frame]));
  if (!frame.has(kill) || !frame.has(kill + 1)) return null;
  let held = 0;
  for (let t = kill - 1; t <= kill + span; t++) if (frame.has(t) && frame.has(t + 1)) held += frame.get(t + 1) - frame.get(t) - 1;
  return held;
}

/** The measured held beat: ticks from the kill on that the kill window holds still (each frame differs from the one
 *  before by under `still`), counted over consecutive frames `frames` (tick -> image) from the kill tick; null when
 *  the frames are not consecutive there (a later zoom saves beats only). Beside the table's hit-stop + held ticks:
 *  a freeze reads as hold; a window that never stops moving reads 0. */
export function measureHold(frames, kill, box, diff, { tolerance = 12, still = 0.002, max = 12 } = {}) {
  if (!frames.has(kill) || !frames.has(kill + 1)) return null;
  const crop = (t) => cropImage(frames.get(t), box);
  let held = 0;
  for (let t = kill + 1; t <= kill + max && frames.has(t); t++) {
    if (diff(crop(t - 1), crop(t), tolerance).fraction >= still) break;
    held += 1;
  }
  return held;
}

/** A sheet cell's label: every cell its tick and its offset from the kill; the first cell (the trigger frame) its
 *  offset and the film instead (weapon, `before` on a before row, victim, direction, zoom: it fits a 32 px/m cell),
 *  and the kill cell the measured hit-stop (frames drawn while the sim held a tick: no still can show those). */
export function cellLabel(job, film, tick, column) {
  const off = tick - film.kill;
  const stop = film.measured?.hitstop_frames;
  const tag = off === 0 ? `kill${Number.isInteger(stop) && stop > 0 ? ` hs${stop}` : ''}` : off > 0 ? `+${off}` : `${off}`;
  if (column === 0) return `${tag} ${job.weapon}${job.side === 'before' ? ' before' : ''} ${job.victim || 'guard'} d${job.dir_deg} ${job.ppm}`;
  return `${tick} ${tag}`;
}

/** The movie frame (0-based) that shows process frame 1: Godot's --write-movie writes one frame per drawn frame,
 *  and the probe row's `frame` (Engine.get_process_frames) IS its movie index. Calibrated n16 s3 on a katana film
 *  (build/kreel/s3movie, 420 movie frames, rows tick 1 frame 0 .. tick 414 frame 419): against the lossless stills
 *  of 7 ticks, index = frame matched at 3.0-3.8 % pixels off (x264 loss), index = frame - 1 or + 1 at 18-44 %. */
export const MOVIE_FRAME_OF_PROCESS_1 = 1;

/** The movie frames [first, last] (0-based) drawn from tick `from` up to the last frame of tick `to`, from the probe
 *  rows' process `frame`: a held tick (hit-stop) keeps all its frames, so a clip cut here runs at the game's real
 *  timing. null when the rows lack a frame there. */
export function movieSpan(probe, from, to) {
  const frame = new Map((probe?.rows ?? []).filter((r) => Number.isInteger(r.frame)).map((r) => [r.tick, r.frame]));
  if (from > to || !frame.has(from) || !frame.has(to)) return null;
  const last = frame.has(to + 1) ? frame.get(to + 1) - 1 : frame.get(to);
  const at = (f) => f - 1 + MOVIE_FRAME_OF_PROCESS_1;
  return [at(frame.get(from)), at(last)];
}

/** reel.md: one table row per film, the measured beats beside the row's data, for a REPORT or a JOURNAL. */
export function reelMarkdown(rows, table, cmd) {
  const cell = (v) => (v === undefined || v === null ? '-' : String(v));
  const lines = [`# kill reel`, '', `\`${cmd}\``, '',
    '| weapon | side | victim | dir | px/m | outcome | kill | freeze (frames, measured) | pieces wait (row ticks) | settled | aftermath | whole |',
    '|---|---|---|---|---|---|---|---|---|---|---|---|'];
  for (const { job, film } of rows) {
    const m = film.measured ?? {};
    const row = table[job.weapon] ?? {};
    lines.push(`| ${job.weapon} | ${job.side} | ${job.victim || 'guard'} | ${job.dir_deg} | ${job.ppm} | ${film.outcome.toUpperCase()} | ${cell(film.kill)} | ${cell(m.hitstop_frames)} | `
      + `${row.id ? `${row.hitstop_ticks} (${row.id})` : 'standard death'} | ${m.settled_after_ticks === undefined || m.settled_after_ticks === null ? '-' : `+${m.settled_after_ticks}`} | `
      + `${m.aftermath_share === undefined ? '-' : `${(m.aftermath_share * 100).toFixed(1)} %`} | ${film.whole === undefined ? '-' : film.whole ? 'yes' : 'NO'} |`);
  }
  return `${lines.join('\n')}\n`;
}
