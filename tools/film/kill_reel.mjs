#!/usr/bin/env node
// The kill reel (n16 tools item 1): every signature death filmed in the kill lab on the city block,
// for a list of weapons x victim kinds x directions, at each zoom, same seed and same tick; one
// contact sheet per weapon and zoom, optional clips, and a before/after mode against a commit.
//   node tools/film/kill_reel.mjs --out=<dir> [--weapons=all|<id,id>] [--victims=<kind,kind>] [--dirs=0,90,180,270]
//     [--ppm=32,64] [--after=150] [--rev=<commit>] [--before=<commit>] [--native=donor] [--clips] [--keep-frames]
//     [--gore-check] [--feel=on|off|auto] [--quick] [--timeout=<s>] [--dry-run] [-- <extra game flags>]
// --timeout: seconds per film; without it each film gets 120 + 2.5 per still it saves (at least 300).
// --resheet=<reel dir>: rebuild that reel's sheets, overview and reel.md from its reel.json (no Godot).
// --quick: 32 px/m only, dir 90 unless --dirs/--ppm name others (the inner loop: one film per weapon).
// Each film is tools/film/film.mjs's `kill:<weapon>` shot (KillLab via BrutalityHook, `--sig-solo=start`),
// with `--sig-dir=<deg>` turning the guard about Rivet (0 east, 90 south) and `--victim=<kind>` drawing it as
// that card row. Stills: the lab's trigger window (ticks 54-70) and the first kill plus --after ticks.
// Exit: 0 every film passed, 1 a film failed, 2 usage (nothing launched), 3 a film was unverifiable.
import { mkdirSync, readdirSync, rmSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { EXIT, filmOne, pinRev, plan } from './film.mjs';
import { anchorShifts, boxAt, curveText, stopText, goreWhole, killWindow, measureBeats, measureHold, measureStop, movieSpan, pickBeats, reelPlan, tableRows, victimAt } from './kill_reel_lib.mjs';
import { beatLine, cutMovie, encodeClip, finish, resheet } from './kill_reel_out.mjs';
import { diffImages, readPng } from './png.mjs';
import { filmedRoot } from './side.mjs';
import { dirtyStartLine, movedLine, treeMoves, treeState } from './live_tree.mjs';

const USAGE = 'usage: node tools/film/kill_reel.mjs --out=<dir> [--weapons=all|<id,id>] [--victims=<kind,...>] [--dirs=<deg|wall,...>] '
  + '[--ppm=32,64] [--after=150] [--rev=<commit>] [--before=<commit>] [--native=donor] [--clips] [--keep-frames] [--gore-check] [--feel=on|off|auto] [--quick] [--timeout=<s>] [--dry-run] [-- flags]\n'
  + '   or: node tools/film/kill_reel.mjs --resheet=<reel dir>';
/** n16 session 1 (build/kreel/t2 t60, build/film/victim_proof): the lab guard is drawn by no rig the probe finds
 *  (`FilmCard.rig` -> null, draw -1), and at the combo zooms it stood as the riot cop with --victim=thug. Film now
 *  judges the drawn row, so a lab film with a victim kind is UNVERIFIABLE until the probe finds the lab's rig;
 *  the `weapon:` shot's victim is seen (film.mjs weapon:pistol --victim=thug PASS on the drawn row). */

/** The ticks a film with a known kill saves: the beats and the hold run (kill..kill+12, for the measured hold). */
export function filmTicks(kill, after) {
  const run = Array.from({ length: 13 }, (_, i) => kill + i).filter((t) => t <= kill + after);
  return [...new Set([...pickBeats(kill, after), ...run])].sort((a, b) => a - b);
}

/** The lab's trigger tick: pickBeats' first column and the aftermath diff's before-death reference (lab kills come at
 *  63 or later; n16 s5 review of n16t-break-reel-scout: a kill at or before it would make that frame a dead one). */
export const TRIGGER_TICK = 60;

/** n16 s5 (kills-new FRICTION 15:30): a --before Gatling clip film timed out at 305 s twice at t239 of its ~245, still
 *  writing a still every ~1.2 s beside a gate (boot + 46 stills took 134 s). A fixed 300 s fits a beat film (~20
 *  stills), not a full window (~168). Without --timeout a film gets 120 s + 2.5 s per still it saves, never under 300. */
export const FILM_BASE_S = 120;
export const PER_STILL_S = 2.5;

/** The stills a film window saves: its listed ticks (`54-70`, `a,b`) plus the kill run of `kill:<n>+<after>`. */
export function stillCount(window) {
  const listed = String(window.stills ?? '').split(',').filter(Boolean).reduce((n, part) => {
    const [a, b] = part.split('-').map(Number);
    return n + (Number.isInteger(b) ? b - a + 1 : 1);
  }, 0);
  const run = /^kill:\d+(?:\+(\d+))?$/.exec(window.on ?? '');
  return listed + (run ? Number(run[1] ?? 0) + 1 : 0);
}

/** The film's timeout in seconds: the reel's --timeout when given, else sized to the stills it saves. */
export const filmTimeout = (reel, window) => String(reel.timeout ?? Math.max(300, Math.ceil(FILM_BASE_S + PER_STILL_S * stillCount(window))));

/** Plans one film of the reel through film.mjs: {shot, opts} or {error}. With the kill tick `known` (from
 *  this combo's first zoom or its scout run: the zoom is view only and the seed fixed, so the sim kills on the
 *  same tick) and no clip wanted, the film saves filmTicks only: a full window is ~165 PNGs, and writing them
 *  was ~45 of a film's ~65 s (n16 s4: 12-still films ran 15-21 s). A `scout` run saves tick 60 and the kill
 *  frame only, to learn the tick. A clip keeps the full window. */
export function planFilm(job, side, reel, known = undefined, scout = false) {
  const full = { stills: '54-70', on: `kill:1+${reel.after}` };
  const window = reel.clips ? full : scout ? { stills: '60', on: 'kill:1' } : known === undefined ? full : { stills: filmTicks(known, reel.after).join(',') };
  const flags = { out: job.dir, ppm: String(job.ppm), ...window, view: 'combo', lock: 'auto',
    seed: '20261109', res: '1280x800', feel: reel.feel ?? 'auto', subject: 'kill', timeout: filmTimeout(reel, window), tree: side.tree };
  if (job.victim) flags.victim = job.victim;
  if (reel.clips && reel.feel === 'on') flags.movie = true;
  const turn = job.dir_deg === 'wall' ? ['--sig-wall'] : job.dir_deg ? [`--sig-dir=${job.dir_deg}`] : [];
  const extra = [...turn, ...reel.extra];
  return plan(flags, `kill:${job.weapon}`, extra);
}

/** Films a job, picks the beat frames, crops them about the kill; the rest of the frames go unless kept. */
async function filmJob(job, side, reel, runner, known) {
  const firstSeen = known !== undefined ? 'at the first zoom' : 'in its scout run';
  if (known === undefined && !reel.clips) {
    const scouted = planFilm(job, side, reel, undefined, true);
    if (scouted.error) return { outcome: 'fail', reasons: [scouted.error] };
    const s = await filmOne(scouted, { runner });
    known = s.probe?.events?.kill?.[0];
    if (s.outcome === 'fail' || !Number.isInteger(known)) return { outcome: s.outcome === 'pass' ? 'unverifiable' : s.outcome, reasons: s.reasons.length ? s.reasons.map((r) => `scout: ${r}`) : ['scout: no kill'] };
  }
  const planned = planFilm(job, side, reel, known);
  if (planned.error) return { outcome: 'fail', reasons: [planned.error] };
  const r = await filmOne(planned, { runner });
  const k = r.probe?.events?.kill?.[0];
  if (r.outcome === 'fail' || !Number.isInteger(k)) return { outcome: r.outcome === 'pass' ? 'unverifiable' : r.outcome, reasons: r.reasons.length ? r.reasons : ['no kill'] };
  if (k <= TRIGGER_TICK) return { outcome: 'unverifiable', kill: k, reasons: [`the kill came at ${k}, not after the lab's trigger tick ${TRIGGER_TICK}: the sheet's reference column and the aftermath diff would show the dead`] };
  if (known !== undefined && k !== known) return { outcome: 'unverifiable', kill: k, reasons: [`the kill came at ${k} at ${job.ppm} px/m but at ${known} ${firstSeen}: the view moved the sim`] };
  const saved = new Set(r.stills ?? []);
  const beats = pickBeats(k, reel.after).filter((t) => saved.has(t));
  const box = killWindow(r.probe, k, job.ppm);
  const span = r.mp4 ? movieSpan(r.probe, Math.max(0, k - 30), k + reel.after) : null;
  const clip = !reel.clips ? null : span ? cutMovie(job, r.mp4, span, box, reel.keepFrames) : encodeClip(job, saved, k, box);
  const frames = new Map(beats.map((t) => [t, readPng(join(job.dir, `t${t}.png`))]));
  const shifts = anchorShifts(r.probe, k, [...saved]);
  const at = (t) => boxAt(box, shifts[t]);
  const measured = measureBeats(frames, beats, k, at, diffImages);
  const run = Array.from({ length: 13 }, (_, i) => k + i).filter((t) => saved.has(t));
  const held = measureHold(new Map(run.map((t) => [t, frames.get(t) ?? readPng(join(job.dir, `t${t}.png`))])), k, at, diffImages);
  if (measured && held !== null) measured.held_ticks = held;
  if (measured && measureStop(r.probe, k) !== null) measured.hitstop_frames = measureStop(r.probe, k);
  if (measured && (r.manifest?.args ?? []).includes('--feel=off')) measured.feel_off = true;
  if (!reel.keepFrames) {
    for (const name of readdirSync(job.dir)) {
      const t = /^t(\d+)\.png$/.exec(name);
      if (t && !beats.includes(Number(t[1]))) rmSync(join(job.dir, name), { force: true });
    }
  }
  const gore = reel.goreCheck ? goreWhole(r.probe, k) : null;
  const outcome = !gore ? r.outcome : /not drawn whole/.test(gore) ? 'fail' : (r.outcome === 'pass' ? 'unverifiable' : r.outcome);
  return { outcome, reasons: gore ? [...r.reasons, `gore check: ${gore}`] : r.reasons, kill: k, beats, box, shifts: Object.fromEntries(beats.filter((t) => shifts[t]).map((t) => [t, shifts[t]])), clip, measured, died: victimAt(r.probe, k),
    ...(reel.goreCheck ? { whole: gore === null } : {}) };
}

export { beatLine };

/** What to do when a tree older than the kill-lab turn refuses a reel flag (n16 s4: kills-polish's tree has no
 *  --sig-dir; the reel refused, nothing launched). */
export function olderTreeHint(error) {
  const flag = /reads (--sig-dir|--sig-wall|--victim)\b/.exec(error)?.[1];
  if (!flag) return '';
  const what = flag === '--victim' ? 'victim' : 'turn';
  const fix = flag === '--victim' ? 'drop --victims (the lab guard is drawn as himself)' : "film --dirs=0 (the lab's own facing, no turn flag)";
  return `; this tree predates the kill-lab ${what} (tools lane bbee28a9c/afe581336): ${fix}, or cherry-pick that commit's game side`;
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

export async function main(argv, { out = console.log, err = console.error, runner, resolveSide, state = treeState } = {}) {
  const parsed = parseArgv(argv);
  if (parsed.error) { err(`${parsed.error}\n${USAGE}`); return EXIT.usage; }
  if (parsed.flags.resheet !== undefined) {
    const lone = parsed.flags.resheet !== true && Object.keys(parsed.flags).length === 1 && !parsed.extra.length;
    const done = lone ? resheet(resolve(parsed.flags.resheet), out) : { error: '--resheet=<reel dir> takes nothing else' };
    if (done.error) { err(`kill_reel: ${done.error}\n${USAGE}`); return EXIT.usage; }
    return EXIT[done];
  }
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
    sides.push({ name, tree: resolve(f.tree ?? here), live: !rev });
  }
  const jobs = reel.jobs.flatMap((j) => sides.map((s) => ({ ...j, side: s.name, dir: join(reel.out, j.weapon, `${s.name}_${j.victim || 'guard'}_d${j.dir_deg}_${j.ppm}`) })));
  for (const job of jobs) {
    // The plans the reel launches: a clip's full window, else the scout and a beat film (any kill after the trigger).
    const side = sides.find((s) => s.name === job.side);
    const bad = (reel.clips ? [planFilm(job, side, reel)] : [planFilm(job, side, reel, undefined, true), planFilm(job, side, reel, TRIGGER_TICK + 1)]).find((p) => p.error)?.error;
    if (bad) { err(`kill_reel: ${job.weapon}: ${bad}${olderTreeHint(bad)}\n${USAGE}`); return EXIT.usage; }
  }
  out(`kill_reel: ${jobs.length} film(s): ${reel.weapons.join(' ')} x victims [${reel.victims.join(' ') || 'guard'}] x dirs [${reel.dirs.join(' ')}] x ppm [${reel.ppm.join(' ')}] x ${sides.map((s) => s.name).join('/')}`);
  const live = sides.find((s) => s.live);
  const began = live ? state(live.tree) : null;
  const dirtyAtStart = dirtyStartLine(began, jobs.filter((j) => j.side === live?.name).length);
  if (dirtyAtStart) out(dirtyAtStart);
  if (reel.dryRun) { out('kill_reel: dry run, nothing launched'); return EXIT.pass; }
  mkdirSync(reel.out, { recursive: true });
  const rows = [];
  const kills = new Map();
  for (const job of jobs) {
    const key = [job.side, job.weapon, job.victim, job.dir_deg].join('|');
    const side = sides.find((s) => s.name === job.side);
    const now = side.live ? state(side.tree) : null;
    const moved = side.live ? movedLine(`${job.side} ${job.weapon} dir ${job.dir_deg} ${job.ppm} px/m`, began, now) : null;
    if (moved) out(moved);
    const film = await filmJob(job, side, reel, runner, kills.get(key));
    if (moved) film.tree_moved = treeMoves(began, now);
    if (film.outcome === 'fail' && (moved || dirtyAtStart)) out('kill_reel: this film ran on a live tree with uncommitted or moving project/ edits (above): if one broke a script, commit it and re-run with --rev=HEAD');
    if (!kills.has(key) && Number.isInteger(film.kill)) kills.set(key, film.kill);
    rows.push({ job, film });
    out(`kill_reel: ${job.side} ${job.weapon} ${job.victim || 'guard'} dir ${job.dir_deg} ${job.ppm} px/m: ${film.outcome.toUpperCase()}`
      + `${film.kill !== undefined ? ` kill at ${film.kill}` : ''}${film.measured ? `, hit-stop ${stopText(film.measured)} + window still ${film.measured.held_ticks ?? '?'} ticks (measured), settled by +${film.measured.settled_after_ticks ?? '?'}, aftermath ${(film.measured.aftermath_share * 100).toFixed(1)} % of the window (${curveText(film.measured)})` : ''}`
      + `${film.reasons.length ? `: ${film.reasons.join('; ')}` : ''}`);
  }
  return EXIT[finish(reel, rows, tableRows(sides.at(-1).tree, reel.weapons), { argv, sides }, out)];
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
