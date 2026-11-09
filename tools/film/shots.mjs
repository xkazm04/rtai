// The named shots of tools/film: each one knows its scene, its bot and its loadout, so a film can
// never again boot the title because the scene path or --loadout was left off (FRICTION, 9 lanes).
// Every id a shot takes is checked against the tree being filmed before anything launches.
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { didYouMean } from '../dev/entries.mjs';
import { walk } from '../lib/repo.mjs';
import { stripComment } from '../style/check_gd.mjs';

const ARENA = 'res://dev/arena/arena.tscn';
const REEL = ['--bot=reel', '--loadout=pistol'];

export const SHOTS = {
  arena: { doc: 'the arena fight (showcase reel, pistol)', ticks: 1800, flags: () => REEL },
  city: { doc: 'a city street fight with a crowd', ticks: 1200,
    travels: true, flags: () => ['--arena=city', '--crowd=120', '--bot=gunplay', '--weapon=pistol', '--reach=6'] },
  chapter: { doc: 'one director chapter: chapter:<id>', ticks: 600, needs: 'chapter',
    flags: (id) => [...REEL, '--reel=director', `--chapter=${id}`] },
  weapon: { doc: 'one lone kill with a table weapon: weapon:<id>', ticks: 900, needs: 'weapon',
    travels: true, flags: (id) => ['--arena=city', `--weapon=${id}`, '--bot=gunplay', '--lone', '--reach=6'] },
  // Quest 1 runs through its own recorder: --stills (even ticks) only, no numbers, no locked camera.
  quest1: { doc: 'quest 1 through its scripted pad: --stills required (even ticks)', ticks: 0, script: 'res://dev/frames/quest1_clip.gd',
    flags: () => ['--rigs'] },
};

const read = (tree, rel) => JSON.parse(readFileSync(join(tree, 'project', rel), 'utf8'));

const ids = {
  weapon: (tree) => read(tree, 'data/tables/weapons.json').weapons.map((w) => w.id),
  view: (tree) => read(tree, 'data/tables/view.json').views.map((v) => v.id),
  chapter: (tree) => {
    const file = join(tree, 'project/dev/showcase/reel_chapters.gd');
    return existsSync(file) ? [...readFileSync(file, 'utf8').matchAll(/Chapter\.new\(\s*&"([a-z0-9_]+)"/g)].map((m) => m[1]) : [];
  },
};

/** Checks `value` against the tree's real ids: null, or one line naming the nearest. */
export function checkId(kind, value, tree) {
  const known = ids[kind](tree);
  if (known.includes(value)) return null;
  const near = didYouMean(value, known);
  return `unknown ${kind} ${value} in ${tree}: ${near ? `did you mean ${near}?` : `known: ${known.join(' ')}`}`;
}

/** Every `"--flag` literal the tree's game code reads: the arena has no central flag list. */
export function knownFlags(tree) {
  const flags = new Set();
  for (const f of walk(join(tree, 'project'), (n) => n.endsWith('.gd'))) {
    if (/[\\/](addons|\.godot)[\\/]/.test(f)) continue;
    for (const line of readFileSync(f, 'utf8').split('\n')) {
      for (const m of stripComment(line).matchAll(/"(--[a-z][a-z0-9-]*)/g)) flags.add(m[1]);
    }
  }
  return flags;
}

/** One line per flag no script in the tree reads (empty = all known). */
export function checkFlags(extra, tree) {
  const given = extra.filter((a) => a.startsWith('--')).map((a) => a.split('=')[0]);
  if (!given.length) return [];
  const known = [...knownFlags(tree)];
  return given.filter((f) => !known.includes(f)).map((f) => {
    const near = didYouMean(f, known);
    return `no script in ${tree} reads ${f}${near ? `: did you mean ${near}?` : ''}`;
  });
}

/** {name, arg, shot} from `chapter:pistol`, or {error}. */
export function parseShot(text) {
  const [name, arg, stray] = String(text ?? '').split(':');
  const shot = Object.hasOwn(SHOTS, name) ? SHOTS[name] : null;
  if (stray !== undefined) return { error: `shot ${text} has more than one id` };
  if (!shot) {
    return { error: `unknown shot ${name}: ${Object.entries(SHOTS).map(([k, s]) => `${k} (${s.doc})`).join(', ')}` };
  }
  if (shot.needs && !arg) return { error: `shot ${name} needs an id: ${name}:<${shot.needs}>` };
  if (!shot.needs && arg) return { error: `shot ${name} takes no id` };
  return { name, arg, shot };
}

/** The Godot args (after --path project) of one fixed-seed, fixed-step film. Pure. */
export function godotArgs({ arg, shot }, o) {
  if (shot.script) {
    return ['--rendering-driver', 'd3d12', '--resolution', o.res, '-s', shot.script, '--', ...shot.flags(arg),
      `--out=${o.dir}`, `--view=${o.view}`, `--ppm=${o.ppm}`, `--stills=${o.stills.join(',')}`, ...o.extra];
  }
  const head = ['--rendering-driver', 'd3d12', '--resolution', o.res, '--fixed-fps', '60',
    ...(o.movie ? ['--write-movie', o.movie] : []), '--quit-after', String(o.ticks), ARENA, '--'];
  const stills = [...(o.stills.length ? [`--film-stills=${o.stills.join(',')}`] : []), ...(o.onText ? [`--film-on=${o.onText}`] : [])];
  const lock = o.lock === 'off' ? [] : [`--cam-lock=${o.lock}`];
  const feel = o.lock === 'off' ? [] : ['--feel=off'];
  return [...head, ...shot.flags(arg), `--seed=${o.seed}`, `--view=${o.view}`, `--ppm=${o.ppm}`,
    '--rigs', '--clean', '--silent', `--film-dir=${o.dir}`, ...stills, ...lock, ...feel, ...o.extra];
}

/** The camera lock a shot gets when none is asked for. Rivet walks far in the street shots, so the
 *  camera follows him and freezes at the first tick that matters: `from`, or the --on event. */
export function autoLock(shot, from, onEvent = false) {
  if (!shot.travels) return 'spawn';
  if (from !== null) return `at:${from}`;
  return onEvent ? 'trigger' : 'off';
}

const MAX_STILLS = 240;

/** `300,310-315` -> ticks, or {error}. A reversed or huge range is refused, never reordered. */
export function parseStills(text) {
  const ticks = [];
  for (const part of String(text ?? '').split(',').filter(Boolean)) {
    const span = /^(\d+)-(\d+)$/.exec(part);
    if (!span) { ticks.push(Number(part)); continue; }
    const [from, to] = [Number(span[1]), Number(span[2])];
    if (to < from) return { error: `--stills range ${part} runs backwards` };
    if (to - from >= MAX_STILLS) return { error: `--stills range ${part} is over ${MAX_STILLS} frames` };
    for (let t = from; t <= to; t += 1) ticks.push(t);
  }
  return ticks.length > MAX_STILLS ? { error: `--stills asks for ${ticks.length} frames, over ${MAX_STILLS}` } : ticks;
}

/** `fire:3+4,kill:1` -> [{kind, nth, after}], or {error}. */
export function parseOn(text) {
  const rules = [];
  for (const part of String(text ?? '').split(',').filter(Boolean)) {
    const m = /^(fire|kill):([1-9]\d*)(?:\+(\d+))?$/.exec(part);
    if (!m) return { error: `--on takes fire:<n>[+<frames after>] or kill:<n>[+<frames after>], got ${part}` };
    const after = Number(m[3] ?? 0);
    if (after >= MAX_STILLS) return { error: `--on ${part} is over ${MAX_STILLS} frames` };
    rules.push({ kind: m[1], nth: Number(m[2]), after });
  }
  return rules;
}

/** The ticks --on resolved to in this run. What never happened is a reason, never an empty pass. */
export function triggeredTicks(rules, events, runTicks) {
  const ticks = [];
  const reasons = [];
  for (const { kind, nth, after } of rules) {
    const happened = events?.[kind];
    const name = `${kind}:${nth}`;
    if (!Array.isArray(happened)) { reasons.push(`--on ${name}: this probe records no ${kind} events`); continue; }
    if (happened.length < nth) { reasons.push(`--on ${name} never happened: ${happened.length} ${kind} event(s) in ${runTicks} ticks`); continue; }
    const at = happened[nth - 1];
    if (at + after >= runTicks) reasons.push(`--on ${name} at tick ${at}: its last frame ${at + after} is past the end of the run (${runTicks} ticks)`);
    for (let t = at; t <= Math.min(at + after, runTicks - 1); t += 1) ticks.push(t);
  }
  return { ticks, reasons };
}

export const shotLabel = (s) => (s.arg ? `${s.name}-${s.arg}` : s.name);
