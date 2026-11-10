#!/usr/bin/env node
// Before/after at the same tick between two commits or two worktrees: one composite with a label on
// each side and a verdict that can be "unverifiable". Identical sides and a subject off screen are
// not passes, because a builder cannot tell them from a change that worked.
//   node tools/film/compare.mjs <shot> --a=<rev|worktree> --b=<rev|worktree> --at=<t,t> --out=<dir>
//     [--clip=<from-to>] [--subject=rivet|hostile|dead|id:<n>] [--label-a=<s>] [--label-b=<s>]
//     [--view=combo] [--ppm=48] [--lock=auto|spawn|at:<tick>|<x,y>|off] [--seed=<n>] [--res=1280x800] [--victim=<kind>] [--feel=auto|on|off] [--clean] [-- flags]
// --victim goes to both sides' film.mjs, which checks the kind exists in each tree (combat n15 REQUEST).
// A commit gets a throwaway snapshot (tools/lib/snapshot.mjs) with the probe injected when it is
// older than the kit; a worktree is filmed where it stands and must already have the probe. The
// snapshot is kept for the next compare of that commit and named at the end; --clean removes it.
// Exit: 0 pass, 1 fail, 2 usage, 3 unverifiable.
import { spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { ensureSnapshot, removeSnapshot, revParse } from '../lib/snapshot.mjs';
import { EXIT, filmOne, plan } from './film.mjs';
import { subjectRow } from './subject.mjs';

export { subjectRow };
import { diffImages, readPng } from './png.mjs';

const USAGE = 'usage: node tools/film/compare.mjs <shot> --a=<rev|worktree> --b=<rev|worktree> --at=<t,t> --out=<dir> '
  + '[--clip=<from-to>] [--subject=rivet|hostile|dead|id:<n>] [--label-a=<s>] [--label-b=<s>] [--view=combo] [--ppm=48] '
  + '[--lock=auto|spawn|at:<tick>|<x,y>|off] [--seed=<n>] [--res=1280x800] [--victim=<kind>] [--feel=auto|on|off] [--timeout=<s>] [--clean] [-- flags]';
const VALUE = new Set(['a', 'b', 'at', 'out', 'clip', 'subject', 'label-a', 'label-b', 'view', 'ppm', 'lock', 'seed', 'res', 'timeout', 'victim', 'feel']);
const DEFAULTS = { view: 'combo', ppm: '48', lock: 'auto', seed: '20261109', res: '1280x800', timeout: '900', subject: 'rivet' };
/** Below this share of changed pixels the two sides are the same picture. */
export const IDENTICAL_FRACTION = 0.00005;
/** Rivet further apart than this (m) at a tick: the two sides are no longer the same moment. */
export const TIMELINE_DELTA_M = 0.05;
const PROBE = 'project/dev/frames/film_probe.gd';
const PROBE_FILES = [PROBE, 'project/dev/frames/film_card.gd', 'project/dev/frames/film_trigger.gd'];
const INJECTED = '.gtai-film-injected';
const HOOK = /^(\s*)FightFrames\.attach\(self, args, session\.world\).*$/m;

/** {shotText, flags, extra} or {error}. */
export function parseArgv(argv) {
  const flags = { ...DEFAULTS };
  let shotText = null;
  const dash = argv.indexOf('--');
  const extra = dash >= 0 ? argv.slice(dash + 1) : [];
  for (const a of dash >= 0 ? argv.slice(0, dash) : argv) {
    const m = /^--([a-z-]+)=(.+)$/.exec(a);
    if (m && VALUE.has(m[1])) flags[m[1]] = m[2];
    else if (a === '--clean') flags.clean = true;
    else if (!a.startsWith('-') && shotText === null) shotText = a;
    else return { error: `compare: bad argument ${a}` };
  }
  for (const f of ['a', 'b', 'at', 'out']) if (!flags[f]) return { error: `compare: --${f}= is required` };
  if (!/^\d+(,\d+)*$/.test(flags.at)) return { error: `compare: --at must be ticks, got ${flags.at}` };
  if (flags.clip && !/^\d+-\d+$/.test(flags.clip)) return { error: `compare: --clip must be <from>-<to>, got ${flags.clip}` };
  if (!/^(rivet|hostile|dead|id:\d+)$/.test(flags.subject)) return { error: `compare: --subject must be rivet, hostile, dead or id:<n>, got ${flags.subject}` };
  return { shotText, flags, extra };
}

/** Pure judgement of one tick. {outcome, reasons, notes}. */
export function judgeTick({ diff, subjectA, subjectB, subject }) {
  const reasons = [];
  const notes = [];
  if (!(diff.fraction > IDENTICAL_FRACTION)) reasons.push(`the two sides are identical (${diff.changed} of ${diff.total} pixels differ)`);
  for (const [side, row] of [['A', subjectA], ['B', subjectB]]) {
    if (!row) reasons.push(`side ${side} has no ${subject} in its numbers at this tick (shots without the probe, such as quest1, cannot prove the subject is in frame)`);
    else if (!row.on_screen) reasons.push(`side ${side}: ${subject} is off screen at (${(row.screen ?? []).map((n) => Math.round(n)).join(', ')})`);
  }
  if (subjectA && subjectB) {
    const d = Math.hypot(subjectA.pos[0] - subjectB.pos[0], subjectA.pos[1] - subjectB.pos[1]);
    if (d > TIMELINE_DELTA_M) notes.push(`the two sides have moved apart: ${subject} is ${d.toFixed(2)} m from itself`);
  }
  return { outcome: reasons.length ? 'unverifiable' : 'pass', reasons, notes };
}

/** A worse outcome always wins: fail, then unverifiable, then pass. */
export const worst = (list) => (list.includes('fail') ? 'fail' : list.includes('unverifiable') ? 'unverifiable' : 'pass');

/** Puts this kit's probe in a snapshot older than the kit (a throwaway tree). Every run copies it
 *  again, because a cached snapshot must not film with last week's probe. */
function injectProbe(path) {
  const mark = join(path, INJECTED);
  if (PROBE_FILES.every((rel) => existsSync(join(path, rel))) && !existsSync(mark)) return false;
  const game = join(path, 'project/dev/arena/arena_game.gd');
  const text = readFileSync(game, 'utf8');
  if (!text.includes('FilmProbe.attach')) {
    if (!HOOK.test(text)) throw new Error(`compare: ${game} has no FightFrames.attach line to hook the probe on`);
    writeFileSync(game, text.replace(HOOK, (line, indent) => `${line}\n${indent}FilmProbe.attach(self, args)`));
  }
  for (const rel of PROBE_FILES) copyFileSync(join(ROOT, rel), join(path, rel));
  writeFileSync(mark, 'probe injected by tools/film/compare.mjs\n');
  return true;
}

/** Resolves a side to a runnable tree: {tree, label, snapshot, injected} or {error}. */
export function resolveSide(value, { root = ROOT, ensure = ensureSnapshot } = {}) {
  const dir = resolve(value);
  if (existsSync(join(dir, 'project', 'project.godot'))) return { tree: dir, label: basename(dir), snapshot: false, injected: false };
  const sha = revParse(root, value);
  if (!sha) return { error: `compare: ${value} is neither a worktree nor a commit git knows` };
  const snap = ensure({ root, rev: value, kind: 'film' });
  return { tree: snap.path, label: sha.slice(0, 8), snapshot: true, injected: injectProbe(snap.path) };
}

const escape = (s) => String(s).replace(/[':\\%]/g, ' ');
const text = (s, y, colour) => `drawtext=fontfile=arialbd.ttf:text='${escape(s)}':x=12:y=${y}:fontsize=20:fontcolor=${colour}:box=1:boxcolor=black@0.7:boxborderw=6`;

function ffmpeg(args, cwd) {
  if (!existsSync(join(cwd, 'arialbd.ttf'))) copyFileSync('C:/Windows/Fonts/arialbd.ttf', join(cwd, 'arialbd.ttf'));
  const r = spawnSync('ffmpeg', ['-y', '-loglevel', 'error', ...args], { cwd, encoding: 'utf8', windowsHide: true });
  return r.status === 0 ? null : (r.stderr || 'ffmpeg failed').trim();
}

/** One side-by-side still; the label says UNVERIFIABLE when the pair is not evidence. Null on success. */
function compose(dir, a, b, labels, tick, banner) {
  const warn = banner ? `,${text(`UNVERIFIABLE ${banner}`, 44, 'red')}` : '';
  const graph = `[0:v]${text(`A ${labels.a} t${tick}`, 10, 'white')}${warn}[a];[1:v]${text(`B ${labels.b} t${tick}`, 10, 'white')}[b];[a][b]hstack`;
  return ffmpeg(['-i', a, '-i', b, '-filter_complex', graph, '-frames:v', '1', `compare-t${tick}.png`], dir);
}

/** One side-by-side clip of the same tick range. Null on success. */
function clip(dir, a, b, labels, from, to) {
  const frame = (row) => row?.frame ?? null;
  const [a0, a1, b0, b1] = [frame(a.rows.find((r) => r.tick >= from)), frame(a.rows.find((r) => r.tick >= to)),
    frame(b.rows.find((r) => r.tick >= from)), frame(b.rows.find((r) => r.tick >= to))];
  if ([a0, a1, b0, b1].some((f) => f === null)) return `the clip ${from}-${to} is outside the filmed ticks`;
  const cut = (s, e) => `trim=start_frame=${s}:end_frame=${e},setpts=PTS-STARTPTS`;
  const graph = `[0:v]${cut(a0, a1)},${text(`A ${labels.a}`, 10, 'white')}[a];[1:v]${cut(b0, b1)},${text(`B ${labels.b}`, 10, 'white')}[b];[a][b]hstack,format=yuv420p`;
  return ffmpeg(['-i', a.mp4, '-i', b.mp4, '-filter_complex', graph, '-an', '-c:v', 'libx264', '-crf', '18', `compare-${from}-${to}.mp4`], dir);
}

export function filmFlags(parsed, side, tick) {
  const f = parsed.flags;
  return { out: join(resolve(f.out), side.name), tree: side.tree, stills: tick, view: f.view, ppm: f.ppm, lock: f.lock, subject: f.subject,
    seed: f.seed, res: f.res, timeout: f.timeout, ...(f.victim ? { victim: f.victim } : {}), ...(f.feel ? { feel: f.feel } : {}), ...(f.clip ? { ticks: String(Number(f.clip.split('-')[1]) + 60) } : {}),
    ...(f.clip ? { movie: true } : { 'no-movie': true }) };
}

function judgeTicks(ticks, shots, flags, labels, dir) {
  return ticks.map((tick) => {
    const [a, b] = [join(shots.a.dir, `t${tick}.png`), join(shots.b.dir, `t${tick}.png`)];
    const rowOf = (s) => s.probe?.rows.find((r) => r.tick === tick);
    const [subjectA, subjectB] = [subjectRow(rowOf(shots.a), flags.subject), subjectRow(rowOf(shots.b), flags.subject)];
    const judged = judgeTick({ diff: diffImages(readPng(a), readPng(b)), subjectA, subjectB, subject: flags.subject });
    const err = compose(dir, a, b, labels, tick, judged.reasons[0]);
    if (err) { judged.outcome = 'unverifiable'; judged.reasons.push(`no composite: ${err}`); }
    return { tick, ...judged, composite: err ? null : join(dir, `compare-t${tick}.png`) };
  });
}

export async function main(argv, { out = console.log, err = console.error, runner } = {}) {
  const parsed = parseArgv(argv);
  if (parsed.error) { err(`${parsed.error}\n${USAGE}`); return EXIT.usage; }
  const f = parsed.flags;
  const [a, b] = [resolveSide(f.a), resolveSide(f.b)];
  for (const s of [a, b]) if (s.error) { err(s.error); return EXIT.usage; }
  a.name = 'A';
  b.name = 'B';
  const labels = { a: f['label-a'] ?? a.label, b: f['label-b'] ?? b.label };
  const planned = [a, b].map((s) => plan(filmFlags(parsed, s, f.at), parsed.shotText, parsed.extra));
  for (const p of planned) if (p.error) { err(p.error); return EXIT.usage; }
  const dir = resolve(f.out);
  mkdirSync(dir, { recursive: true });
  const shots = {};
  for (const [i, key] of ['a', 'b'].entries()) {
    out(`compare: filming side ${key.toUpperCase()} (${labels[key]}) in ${planned[i].opts.tree}`);
    shots[key] = { ...(await filmOne(planned[i], { runner })), dir: planned[i].opts.dir };
    out(`compare: side ${key.toUpperCase()} ${shots[key].outcome}${shots[key].reasons.length ? `: ${shots[key].reasons.join('; ')}` : ''}`);
  }
  const report = { schema: 'gtai.film-compare/1', shot: parsed.shotText, a: { value: f.a, ...labels.a && { label: labels.a }, manifest: shots.a.manifest },
    b: { value: f.b, label: labels.b, manifest: shots.b.manifest }, subject: f.subject, ticks: [], clip: null };
  let outcomes = [shots.a.outcome, shots.b.outcome];
  if (worst(outcomes) === 'pass') {
    const ticks = f.at.split(',').map(Number);
    report.ticks = judgeTicks(ticks, shots, f, labels, dir);
    outcomes.push(...report.ticks.map((t) => t.outcome));
    if (f.clip) {
      const [from, to] = f.clip.split('-').map(Number);
      const e = clip(dir, { rows: shots.a.probe.rows, mp4: shots.a.mp4 }, { rows: shots.b.probe.rows, mp4: shots.b.mp4 }, labels, from, to);
      report.clip = e ? { error: e } : { file: join(dir, `compare-${from}-${to}.mp4`) };
      if (e) outcomes.push('unverifiable');
    }
  }
  report.outcome = worst(outcomes);
  writeFileSync(join(dir, 'comparison.json'), `${JSON.stringify(report, null, 1)}\n`);
  for (const t of report.ticks) {
    out(`compare: t${t.tick} ${t.outcome.toUpperCase()}${t.reasons.length ? `: ${t.reasons.join('; ')}` : ''}${t.notes.length ? ` [${t.notes.join('; ')}]` : ''}${t.composite ? ` -> ${t.composite}` : ''}`);
  }
  if (report.clip?.file) out(`compare: clip -> ${report.clip.file}`);
  if (report.clip?.error) out(`compare: no clip: ${report.clip.error}`);
  for (const l of snapshotLines([a, b], f.clean)) out(l);
  out(`compare: ${report.outcome.toUpperCase()}; ${join(dir, 'comparison.json')}`);
  return EXIT[report.outcome];
}

/** After the run: each commit side's temp checkout is removed (--clean) or named as kept, never left
 *  unseen (each holds a copied import cache, about 1.7 GB). Returns the lines to print. */
export function snapshotLines(sides, clean, remove = (path) => removeSnapshot(ROOT, path)) {
  const lines = [];
  for (const tree of new Set(sides.filter((s) => s.snapshot).map((s) => s.tree))) {
    if (!clean) { lines.push(`compare: kept the temp checkout ${tree} for the next compare of that commit (about 1.7 GB; --clean removes it)`); continue; }
    try { remove(tree); lines.push(`compare: removed the temp checkout ${tree}`); }
    catch (e) { lines.push(`compare: could not remove the temp checkout ${tree}: ${e.message}`); }
  }
  return lines;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
