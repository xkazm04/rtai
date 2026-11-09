// The named shots of tools/film: each one knows its scene, its bot and its loadout, so a film can
// never again boot the title because the scene path or --loadout was left off (FRICTION, 9 lanes).
// Every id a shot takes is checked against the tree being filmed before anything launches.
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { didYouMean } from '../dev/entries.mjs';
import { walk } from '../lib/repo.mjs';

const ARENA = 'res://dev/arena/arena.tscn';
const REEL = ['--bot=reel', '--loadout=pistol'];

export const SHOTS = {
  arena: { doc: 'the arena fight (showcase reel, pistol)', ticks: 1800, flags: () => REEL },
  city: { doc: 'a city street fight with a crowd', ticks: 1200,
    flags: () => ['--arena=city', '--crowd=120', '--bot=gunplay', '--weapon=pistol', '--reach=6'] },
  chapter: { doc: 'one director chapter: chapter:<id>', ticks: 600, needs: 'chapter',
    flags: (id) => [...REEL, '--reel=director', `--chapter=${id}`] },
  weapon: { doc: 'one lone kill with a table weapon: weapon:<id>', ticks: 900, needs: 'weapon',
    flags: (id) => ['--arena=city', `--weapon=${id}`, '--bot=gunplay', '--lone', '--reach=6'] },
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
    for (const m of readFileSync(f, 'utf8').matchAll(/"(--[a-z][a-z0-9-]*)/g)) flags.add(m[1]);
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
  const [name, arg] = String(text ?? '').split(':');
  const shot = SHOTS[name];
  if (!shot) {
    return { error: `unknown shot ${name}: ${Object.entries(SHOTS).map(([k, s]) => `${k} (${s.doc})`).join(', ')}` };
  }
  if (shot.needs && !arg) return { error: `shot ${name} needs an id: ${name}:<${shot.needs}>` };
  if (!shot.needs && arg) return { error: `shot ${name} takes no id` };
  return { name, arg, shot };
}

/** The Godot args (after --path project) of one fixed-seed, fixed-step film. Pure. */
export function godotArgs({ arg, shot }, o) {
  const head = ['--rendering-driver', 'd3d12', '--resolution', o.res, '--fixed-fps', '60',
    ...(o.movie ? ['--write-movie', o.movie] : []), '--quit-after', String(o.ticks), ARENA, '--'];
  const stills = o.stills.length ? [`--film-stills=${o.stills.join(',')}`] : [];
  const lock = o.lock === 'off' ? [] : [`--cam-lock=${o.lock}`];
  const feel = o.lock === 'off' ? [] : ['--feel=off'];
  return [...head, ...shot.flags(arg), `--seed=${o.seed}`, `--view=${o.view}`, `--ppm=${o.ppm}`,
    '--rigs', '--clean', '--silent', `--film-dir=${o.dir}`, ...stills, ...lock, ...feel, ...o.extra];
}

export const shotLabel = (s) => (s.arg ? `${s.name}-${s.arg}` : s.name);
