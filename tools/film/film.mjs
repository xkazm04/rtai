#!/usr/bin/env node
// One command for a game film: a named shot, always with its scene, loadout, fixed seed and fixed
// step; ids and flags checked against the tree before anything launches; tick-exact stills and
// per-tick numbers from dev/frames/film_probe.gd; one verdict: pass, fail or unverifiable.
//   node tools/film/film.mjs <shot> --out=<dir> [--ticks=<n>] [--stills=<t,t-t>] [--on=fire:3+4,kill:1+6] [--view=combo]
//     [--ppm=48] [--lock=auto|spawn|trigger|at:<tick>|<x,y>|off] [--seed=<n>] [--res=1280x800] [--movie] [--no-movie] [--tree=<dir>]
//     [--timeout=<s>] [--dry-run] [-- <extra game flags>]
// Exit: 0 pass, 1 fail (the run broke), 2 usage (nothing launched), 3 unverifiable (it ran, but the
// numbers or stills it was asked for do not exist).
import { existsSync, mkdirSync, readFileSync, readdirSync, renameSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { spawnSync, execFileSync } from 'node:child_process';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { staleAssets, touchStale } from '../lib/asset_cache.mjs';
import { describe, runGodot } from '../lib/godot.mjs';
import { verdict } from '../lib/dev_verdict.mjs';
import { autoLock, checkFlags, checkId, godotArgs, parseOn, parseShot, parseStills, shotLabel, triggeredTicks } from './shots.mjs';
import { subjectRow } from './subject.mjs';

export const EXIT = { pass: 0, fail: 1, usage: 2, unverifiable: 3 };
const USAGE = 'usage: node tools/film/film.mjs <shot> --out=<dir> [--ticks=<n>] [--stills=<t,t-t>] [--on=fire:3+4,kill:1+6] [--view=combo] '
  + '[--ppm=48] [--lock=auto|spawn|trigger|at:<tick>|<x,y>|off] [--seed=<n>] [--res=1280x800] [--movie] [--no-movie] [--tree=<dir>] [--timeout=<s>] [--dry-run] [-- flags]';
const VALUE = new Set(['out', 'ticks', 'stills', 'on', 'view', 'ppm', 'lock', 'seed', 'res', 'tree', 'timeout', 'subject']);
const SWITCH = new Set(['movie', 'no-movie', 'dry-run']);
const DEFAULTS = { subject: 'rivet', view: 'combo', ppm: '48', lock: 'auto', seed: '20261109', res: '1280x800', timeout: '900' };

/** {shotText, flags, extra} or {error}. */
export function parseArgv(argv) {
  const flags = { ...DEFAULTS };
  let shotText = null;
  const dash = argv.indexOf('--');
  const extra = dash >= 0 ? argv.slice(dash + 1) : [];
  for (const a of dash >= 0 ? argv.slice(0, dash) : argv) {
    const m = /^--([a-z-]+)(?:=(.*))?$/.exec(a);
    if (m && SWITCH.has(m[1]) && m[2] === undefined) flags[m[1]] = true;
    else if (m && VALUE.has(m[1]) && m[2]) flags[m[1]] = m[2];
    else if (!a.startsWith('-') && shotText === null) shotText = a;
    else return { error: `film: bad argument ${a}` };
  }
  return { shotText, flags, extra };
}

/** Everything checkable before a launch: {shot, opts} or {error}. */
export function plan(flags, shotText, extra) {
  if (!flags.out) return { error: 'film: --out=<dir> is required' };
  const shot = parseShot(shotText);
  if (shot.error) return { error: `film: ${shot.error}` };
  const tree = resolve(flags.tree ?? ROOT);
  if (!existsSync(join(tree, 'project', 'project.godot'))) return { error: `film: ${tree} has no project/project.godot` };
  const stills = parseStills(flags.stills);
  if (stills.error) return { error: `film: ${stills.error}` };
  const on = parseOn(flags.on);
  if (on.error) return { error: `film: ${on.error}` };
  if (shot.shot.script && on.length) return { error: 'film: quest1 has no probe, so --on cannot see its shots' };
  if (flags.lock === 'trigger' && !on.length) return { error: 'film: --lock=trigger needs --on=<what to wait for>' };
  if (shot.shot.script && (!stills.length || stills.some((t) => t % 2 !== 0))) {
    return { error: 'film: quest1 needs --stills=<even ticks> (its recorder saves on even ticks only)' };
  }
  const ticks = shot.shot.script ? Math.max(...stills) + 1
    : Number(flags.ticks ?? Math.max(shot.shot.ticks, Math.max(0, ...stills) + 120));
  if (!Number.isInteger(ticks) || ticks <= 0) return { error: `film: --ticks must be a positive integer, got ${flags.ticks}` };
  if (stills.some((t) => !Number.isInteger(t) || t < 0 || t >= ticks)) return { error: `film: --stills must be ticks below ${ticks}` };
  if (!/^\d+x\d+$/.test(flags.res)) return { error: `film: --res must be WxH, got ${flags.res}` };
  if (!/^(auto|spawn|trigger|off|at:\d+|-?\d+(\.\d+)?,-?\d+(\.\d+)?)$/.test(flags.lock)) return { error: `film: --lock must be auto, spawn, trigger, off, at:<tick> or x,y, got ${flags.lock}` };
  const lock = flags.lock === 'auto' ? autoLock(shot.shot, stills.length ? Math.min(...stills) : null, on.length > 0) : flags.lock;
  const bad = [...(shot.shot.needs ? [checkId(shot.shot.needs, shot.arg, tree)] : []), checkId('view', flags.view, tree),
    ...checkFlags(extra, tree)].filter(Boolean);
  if (bad.length) return { error: bad.map((b) => `film: ${b}`).join('\n') };
  if (!shot.shot.script && !existsSync(join(tree, 'project/dev/frames/film_probe.gd'))) {
    return { error: `film: ${tree} has no dev/frames/film_probe.gd (older than the kit): film a commit with tools/film/compare.mjs, which injects it` };
  }
  if (flags.subject !== undefined && !/^(rivet|hostile|dead|id:\d+)$/.test(flags.subject)) return { error: `film: --subject must be rivet, hostile, dead or id:<n>, got ${flags.subject}` };
  for (const key of ['timeout', 'ppm']) {
    if (flags[key] !== undefined && !(Number(flags[key]) > 0)) return { error: `film: --${key} must be a positive number, got ${flags[key]}` };
  }
  const dir = resolve(flags.out);
  // A movie costs real time (combat measured about 1.5 fps with Godots running beside it), so stills skip it unless asked.
  const wantMovie = flags.movie === true || (!stills.length && !on.length && !flags['no-movie']);
  const movie = wantMovie && !shot.shot.script ? join(dir, `${shotLabel(shot)}.avi`) : null;
  return { shot, opts: { tree, dir, ticks, stills, on, onText: flags.on ?? '', movie, extra, view: flags.view, ppm: flags.ppm, lock,
    subject: flags.subject ?? 'rivet', seed: flags.seed, res: flags.res, timeoutMs: Number(flags.timeout) * 1000, label: shotLabel(shot),
    noProbe: Boolean(shot.shot.script) } };
}

const gitHead = (tree) => {
  try {
    const head = execFileSync('git', ['-C', tree, 'rev-parse', 'HEAD'], { encoding: 'utf8', windowsHide: true }).trim();
    const dirty = execFileSync('git', ['-C', tree, 'status', '--porcelain', '--', 'project'], { encoding: 'utf8', windowsHide: true }).trim();
    return { head, dirty: dirty.length > 0 };
  } catch { return { head: null, dirty: null }; }
};

/** ffmpeg AVI -> mp4 beside it; the AVI goes after a good encode. Returns the mp4, or null. */
function encode(avi) {
  if (!existsSync(avi)) return null;
  const mp4 = avi.replace(/\.avi$/, '.mp4');
  const r = spawnSync('ffmpeg', ['-y', '-loglevel', 'error', '-i', avi, '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', mp4], { windowsHide: true });
  if (r.status !== 0) return null;
  rmSync(avi, { force: true });
  return mp4;
}

/** A shot without the probe (quest 1): pass means every still exists and is from this run. */
function judgeStills(opts, startedAt) {
  const reasons = [];
  for (const t of opts.stills) {
    const from = join(opts.dir, `still_${t}_${opts.ppm}.png`);
    if (!existsSync(from) || statSync(from).mtimeMs + 2 < startedAt) { reasons.push(`no still at tick ${t}`); continue; }
    renameSync(from, join(opts.dir, `t${t}.png`));
  }
  return { outcome: reasons.length ? 'unverifiable' : 'pass', reasons, probe: null };
}

/** Reads what the run wrote: what is missing is a reason, never a default. */
export function judge(res, opts, startedAt) {
  const v = verdict(res, {});
  if (!v.ok) return { outcome: 'fail', reasons: [v.line], probe: null };
  if (opts.noProbe) return judgeStills(opts, startedAt);
  const file = join(opts.dir, 'probe.json');
  if (!existsSync(file) || statSync(file).mtimeMs + 2 < startedAt) {
    return { outcome: 'unverifiable', reasons: ['the probe wrote no probe.json in this run'], probe: null };
  }
  let probe = null;
  try { probe = JSON.parse(readFileSync(file, 'utf8')); } catch { /* a run killed mid-write leaves half a file */ }
  if (!probe || !Array.isArray(probe.rows)) return { outcome: 'unverifiable', reasons: ['probe.json is damaged or empty'], probe: null };
  const reasons = [];
  if (!probe.rows.length) reasons.push('probe.json has no ticks');
  const [w, h] = opts.res.split('x').map(Number);
  if (probe.view?.[0] !== w || probe.view?.[1] !== h) reasons.push(`the run drew ${probe.view?.join('x')}, not the asked ${opts.res}`);
  const fired = triggeredTicks(opts.on ?? [], probe.events, opts.ticks);
  reasons.push(...fired.reasons);
  const seen = new Set(probe.stills ?? []);
  const wanted = [...new Set([...opts.stills, ...fired.ticks])].sort((a, b) => a - b);
  for (const t of wanted) {
    const png = join(opts.dir, `t${t}.png`);
    if (!seen.has(t) || !existsSync(png) || statSync(png).mtimeMs + 2 < startedAt) { reasons.push(`no still at tick ${t}`); continue; }
    const who = subjectRow(probe.rows.find((r) => r.tick === t), opts.subject);
    if (!who) reasons.push(`no ${opts.subject} in the numbers at tick ${t}`);
    else if (!who.on_screen) reasons.push(`${opts.subject} is off screen at tick ${t} (${(who.screen ?? []).map((n) => Math.round(n)).join(', ')})`);
  }
  return { outcome: reasons.length ? 'unverifiable' : 'pass', reasons, probe, stills: wanted };
}

/** Films one shot. {outcome, reasons, probe, mp4, manifest}; `runner` is for tests. */
export async function filmOne({ shot, opts }, { runner = runGodot } = {}) {
  mkdirSync(opts.dir, { recursive: true });
  for (const name of readdirSync(opts.dir)) if (/^t\d+\.png$/.test(name)) rmSync(join(opts.dir, name), { force: true });
  rmSync(join(opts.dir, 'probe.json'), { force: true });
  const project = join(opts.tree, 'project');
  const stale = staleAssets(project, { onFirstScan: () => console.error('film: first asset check in this tree, hashing every source once (up to a minute beside other lanes)') });
  if (stale.count) {
    console.error(`film: ${stale.count} asset(s) changed since the last import (${stale.sample.join(', ')}): running --import, or the film draws the old pixels`);
    touchStale(project);
    const imported = await runner(['--import'], { timeoutMs: opts.timeoutMs, name: 'import', cwd: opts.tree, ensure: false });
    if (imported.status !== 0 || imported.timedOut) return { outcome: 'fail', reasons: [`--import failed: ${describe(imported)}`], probe: null, mp4: null, manifest: null };
    const still = staleAssets(project);
    if (still.count) return { outcome: 'unverifiable', reasons: [`${still.count} asset(s) still do not match their import after --import (${still.sample.join(', ')}): this film would draw the old pixels`], probe: null, mp4: null, manifest: null };
  }
  const args = godotArgs(shot, opts);
  const startedAt = Date.now();
  const res = await runner(args, { headless: false, timeoutMs: opts.timeoutMs, name: `film-${opts.label}`, cwd: opts.tree });
  writeFileSync(join(opts.dir, 'film.log'), `# ${args.join(' ')}\n# ${describe(res)}\n${res.out}`);
  const judged = judge(res, opts, startedAt);
  const mp4 = opts.movie && judged.outcome !== 'fail' ? encode(opts.movie) : null;
  if (opts.movie && !mp4 && judged.outcome === 'pass') {
    judged.outcome = 'unverifiable';
    judged.reasons.push('the movie did not encode');
  }
  const manifest = { schema: 'gtai.film/1', shot: opts.label, outcome: judged.outcome, reasons: judged.reasons, ...gitHead(opts.tree),
    tree: opts.tree, ticks: opts.ticks, stills: judged.stills ?? opts.stills, on: opts.onText, events: judged.probe?.events ?? null, view: opts.view, ppm: opts.ppm, lock: opts.lock, seed: opts.seed,
    res: opts.res, mp4, ran: describe(res), args };
  writeFileSync(join(opts.dir, 'film.json'), `${JSON.stringify(manifest, null, 1)}\n`);
  return { ...judged, mp4, manifest };
}

/** "fire at 214 230 ... (31); kill at 402": what a builder otherwise guesses one launch at a time. */
export function eventLine(events) {
  if (!events) return '';
  const list = (name, ts) => `${name} at ${ts.length ? ts.slice(0, 12).join(' ') : 'no tick'}${ts.length > 12 ? ` ... (${ts.length})` : ''}`;
  return [list('fire', events.fire ?? []), list('kill', events.kill ?? [])].join('; ');
}

export async function main(argv, { out = console.log, err = console.error, runner } = {}) {
  const parsed = parseArgv(argv);
  if (parsed.error) { err(`${parsed.error}\n${USAGE}`); return EXIT.usage; }
  const planned = plan(parsed.flags, parsed.shotText, parsed.extra);
  if (planned.error) { err(`${planned.error}\n${USAGE}`); return EXIT.usage; }
  out(`film: godot --path project ${godotArgs(planned.shot, planned.opts).join(' ')}`);
  if (parsed.flags['dry-run']) { out('film: dry run, nothing launched'); return EXIT.pass; }
  const r = await filmOne(planned, { runner });
  const happened = eventLine(r.probe?.events);
  if (happened) out(`film: ${happened}`);
  out(`film: ${r.outcome.toUpperCase()}${r.reasons.length ? `: ${r.reasons.join('; ')}` : ''}; ${join(planned.opts.dir, 'film.json')}`);
  return EXIT[r.outcome];
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
