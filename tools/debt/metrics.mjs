// Debt metrics (the ratchet's measurements). Pure: every function takes a root dir, so tests
// run them over fixture trees. Each metric is {files: {path: number}, detail?}; the total is the
// sum of the per-file values. Definitions live in tools/debt/README.md.
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { FILE_HARD_LINES, FILE_SOFT_LINES, stripComment } from '../style/check_gd.mjs';

export const NEAR_CAP_LINES = 270;
export const SPLIT_FROM = 290;
export const SPLIT_MAX_DROP = 20;
export const CMDLINE_ALLOW = ['project/boot/launch_args.gd', 'project/boot/arena_args.gd'];
export const SHIPPED_DIRS = ['project/boot/', 'project/core/', 'project/features/', 'project/quests/'];
export const LANE_NAME = /^(n|w|d|t|f|lane|night|day|wave|sprint|ticket)[-_]?\d+|^(lane|night)([-_]|$)|\d{4}-\d{2}-\d{2}/i;
export const METRICS = [
  'files_near_cap',
  'files_past_soft_cap',
  'direct_cmdline_reads',
  'dev_loc',
  'lane_named_dev_dirs',
  'unused_class_names',
];
const TEXT_EXT = /\.(gd|tscn|tres|json|godot|cfg|mjs|md)$|^justfile$/;

function walkRel(root, relDir, skip, out = []) {
  const abs = join(root, relDir);
  if (!existsSync(abs)) return out;
  for (const e of readdirSync(abs, { withFileTypes: true })) {
    const r = relDir ? `${relDir}/${e.name}` : e.name;
    if (e.isDirectory()) {
      if (!skip.includes(e.name)) walkRel(root, r, skip, out);
    } else out.push(r);
  }
  return out;
}

const readText = (root, path) => readFileSync(join(root, path), 'utf8');
const lineCount = (text) => {
  const n = text.split('\n').length;
  return text.endsWith('\n') ? n - 1 : n;
};

/** Everything the metrics need, read once. Own GDScript matches ownGdFiles(): project/ minus addons/ plus tools/canary.gd. */
export function scan(root) {
  const skip = ['.godot', '.git', 'node_modules', 'addons'];
  const gd = walkRel(root, 'project', skip).filter((p) => p.endsWith('.gd'));
  if (existsSync(join(root, 'tools/canary.gd'))) gd.push('tools/canary.gd');
  const texts = new Map();
  for (const p of gd) texts.set(p, readText(root, p));
  const other = [
    ...walkRel(root, 'project', skip).filter((p) => TEXT_EXT.test(p) && !p.endsWith('.gd')),
    ...walkRel(root, 'tools', skip).filter((p) => /\.mjs$/.test(p)),
    ...['justfile', 'AGENTS.md'].filter((p) => existsSync(join(root, p))),
  ];
  for (const p of other) texts.set(p, readText(root, p));
  const devFiles = walkRel(root, 'project/dev', skip).map((p) => p.slice('project/dev/'.length));
  return { root, gd: gd.sort(), texts, devFiles };
}

const only = (files, keep) => Object.fromEntries(Object.entries(files).filter(([, v]) => keep(v)));

export function sizes(s) {
  const lines = Object.fromEntries(s.gd.map((p) => [p, lineCount(s.texts.get(p))]));
  return {
    files_near_cap: { files: only(lines, (n) => n >= NEAR_CAP_LINES) },
    files_past_soft_cap: { files: only(lines, (n) => n > FILE_SOFT_LINES) },
    lines,
  };
}

export function cmdlineReads(s) {
  const files = {};
  for (const p of s.gd) {
    if (CMDLINE_ALLOW.includes(p)) continue;
    let n = 0;
    for (const raw of s.texts.get(p).split('\n')) {
      n += (stripComment(raw).match(/\bOS\.get_cmdline(_user)?_args\b/g) ?? []).length;
    }
    if (n) files[p] = n;
  }
  const shipped = Object.entries(files).filter(([p]) => SHIPPED_DIRS.some((d) => p.startsWith(d)));
  const sum = (e) => e.reduce((a, [, v]) => a + v, 0);
  const total = sum(Object.entries(files));
  return { files, detail: `shipped ${sum(shipped)}, dev/tests ${total - sum(shipped)}` };
}

/** dev_loc is tracked per top-level entry of project/dev/ (a dir, or a root-level file). */
export function devLoc(s) {
  const files = {};
  for (const f of s.devFiles.filter((p) => p.endsWith('.gd'))) {
    const parts = f.split('/');
    const key = parts.length > 1 ? `project/dev/${parts[0]}` : `project/dev/${f}`;
    const text = s.texts.get(`project/dev/${f}`) ?? readText(s.root, `project/dev/${f}`);
    files[key] = (files[key] ?? 0) + lineCount(text);
  }
  return { files };
}

const classNameOf = (text) => /^class_name\s+(\w+)/m.exec(text)?.[1] ?? null;

/** Identifier -> set of files mentioning it (comments stripped from .gd). */
function tokenIndex(s) {
  const idx = new Map();
  for (const [p, text] of s.texts) {
    if (p.endsWith('.md')) continue;
    const body = p.endsWith('.gd') ? text.split('\n').map(stripComment).join('\n') : text;
    for (const t of new Set(body.match(/[A-Za-z_]\w*/g) ?? [])) {
      if (!idx.has(t)) idx.set(t, new Set());
      idx.get(t).add(p);
    }
  }
  return idx;
}

export function unusedClassNames(s, idx = tokenIndex(s)) {
  const files = {};
  const names = {};
  for (const p of s.gd) {
    const name = classNameOf(s.texts.get(p));
    if (!name) continue;
    const users = idx.get(name) ?? new Set();
    if (![...users].some((u) => u !== p)) {
      files[p] = 1;
      names[p] = name;
    }
  }
  return { files, names };
}

/** A project/dev/<dir> is lane-named, or unreferenced: no file outside it mentions res://dev/<dir>/ or a class_name declared inside it. */
export function laneDevDirs(s, idx = tokenIndex(s)) {
  const dirs = [...new Set(s.devFiles.filter((f) => f.includes('/')).map((f) => f.split('/')[0]))].sort();
  const files = {};
  const why = {};
  for (const d of dirs) {
    const prefix = `project/dev/${d}/`;
    const reasons = [];
    if (LANE_NAME.test(d)) reasons.push('lane/day-style name');
    const inside = s.gd.filter((p) => p.startsWith(prefix));
    const classes = inside.map((p) => classNameOf(s.texts.get(p))).filter(Boolean);
    const needle = `res://dev/${d}/`;
    const pathRef = [...s.texts].some(([p, t]) => !p.startsWith(prefix) && t.includes(needle));
    const classRef = classes.some((c) => [...(idx.get(c) ?? [])].some((u) => !u.startsWith(prefix)));
    if (!pathRef && !classRef) reasons.push('nothing outside references it');
    if (reasons.length) {
      files[`project/dev/${d}`] = 1;
      why[`project/dev/${d}`] = reasons.join('; ');
    }
  }
  return { files, why };
}

/** All metrics: {name: {files, detail?, names?, why?}}. */
export function computeMetrics(root) {
  const s = scan(root);
  const z = sizes(s);
  const idx = tokenIndex(s);
  const unused = unusedClassNames(s, idx);
  return {
    files_near_cap: z.files_near_cap,
    files_past_soft_cap: z.files_past_soft_cap,
    direct_cmdline_reads: cmdlineReads(s),
    dev_loc: devLoc(s),
    lane_named_dev_dirs: laneDevDirs(s, idx),
    unused_class_names: unused,
    _lines: z.lines,
  };
}

/** Count metrics total the offenders; volume metrics (reads, lines) total the values. */
export const VOLUME = ['direct_cmdline_reads', 'dev_loc'];
export const total = (m, name) => (VOLUME.includes(name) ? Object.values(m.files).reduce((a, b) => a + b, 0) : Object.keys(m.files).length);
export { FILE_HARD_LINES, FILE_SOFT_LINES };
