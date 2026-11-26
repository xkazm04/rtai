#!/usr/bin/env node
// n31-21 item 4 play take: Rivet walks into props with the real input path, from a snapshot of any commit, on film.
//   node tools/ground/prop_take.mjs --rev=ba8e470b0 --arena=yard|gauntlet --out=<dir> [--label=..] [--dry-run]
//   node tools/ground/prop_take.mjs --side=<dirA>,<dirB> --out=<file.mp4>
// Writes <out>/take.mp4 (crf 28), stops.json (scene), probes.json, stops.md, stills at each stop, take.json (play_take --side reads it).
// The drawn base edges come from the rev's own prop audit when the snapshot has tools/ground/props, else from the committed
// audit evidence of main (evidence/n31-ground/prop_audit_*.json). One Godot at a time in the lane (build/n31-godot.lock).
import { spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { ROOT } from '../lib/repo.mjs';
import { withRestore, writeOverride } from './override_cfg.mjs';
import { ensureSnapshot, revParse } from '../lib/snapshot.mjs';
import { filmedRoot } from '../film/side.mjs';
import { labelOf, sideArgs, takeFile } from './play_take_lib.mjs';
import { gauntletProbes, stopsMarkdown, yardProbes } from './prop_take_lib.mjs';

export const SCENE = 'res://dev/ground_n31/prop_walk.tscn';
export const PROBE = ['prop_walk.gd', 'prop_walk.gd.uid', 'prop_walk.tscn', 'prop_walk_probe.gd', 'prop_walk_probe.gd.uid', 'prop_walk_out.gd', 'prop_walk_out.gd.uid', 'prop_walk_place.gd', 'prop_walk_place.gd.uid', 'prop_walk_open.gd', 'prop_walk_open.gd.uid'];
const OVERRIDES = {
  yard: '[display]\n\nwindow/size/window_width_override=1920\nwindow/size/window_height_override=1080\n',
  gauntlet: '[display]\n\nwindow/size/viewport_width=1920\nwindow/size/viewport_height=1080\n',
};
const TAG = process.env.PLAY_TAKE_TAG ?? 'n31-21';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const readJson = (file) => JSON.parse(readFileSync(file, 'utf8'));
const run = (bin, args, cwd) => spawnSync(bin, args, { cwd, encoding: 'utf8', windowsHide: true });

export function parse(argv) {
  const f = { arena: 'yard', seed: '1', ppm: '32' };
  for (const a of argv) {
    const m = /^--(rev|arena|out|label|side|seed|ppm|tree|only|dry-run)(?:=(.*))?$/.exec(a);
    if (!m) return { error: `prop_take: bad argument ${a}` };
    f[m[1]] = m[2] ?? true;
  }
  if (!f.out) return { error: 'prop_take: --out= is required' };
  if (!f.side && !f.rev) return { error: 'prop_take: --rev= (or --side=) is required' };
  if (!['yard', 'gauntlet'].includes(f.arena)) return { error: 'prop_take: --arena is yard or gauntlet' };
  return { f };
}

/** Audit rows of the yard and the tilt70 gauntlet strip cards for the tree's data: its own tools when it has them. */
async function auditRows(tree) {
  const mod = join(tree, 'tools', 'ground', 'props', 'audit.mjs');
  if (existsSync(mod) && existsSync(join(tree, 'tools', 'ground', 'props', 'strip_cards.mjs'))) {
    const audit = await import(pathToFileURL(mod).href);
    const strips = await import(pathToFileURL(join(tree, 'tools', 'ground', 'props', 'strip_cards.mjs')).href);
    return { yard: audit.auditYard(), strips: strips.auditStrips('p70'), source: 'the rev\'s own tools/ground/props' };
  }
  const ev = join(ROOT, 'evidence', 'n31-ground');
  return { yard: readJson(join(ev, 'prop_audit_before.json')).rows.filter((r) => r.arena === 'yard'), strips: readJson(join(ev, 'prop_audit_strip.json')).rows, source: 'evidence/n31-ground/prop_audit_*.json (main ba8e470b0 data)' };
}

export async function buildProbes(tree, arena) {
  const audit = await auditRows(tree);
  const data = join(tree, 'project', 'data', 'tables');
  const base = existsSync(join(tree, 'project', 'features', 'gauntlet', 'prop_base.gd'));
  audit.base = base;
  if (arena === 'gauntlet') return { probes: gauntletProbes(readJson(join(data, 'gauntlet.json')).segments, audit.strips, base), audit };
  const stage = readJson(join(data, 'prologue_stage.json'));
  const look = readJson(join(data, 'prologue_yard_dressings.json')).dressings[stage.yard.dressing];
  return { probes: yardProbes(look, audit.yard), audit }; // the yard is judged on the art (stop_m), the gauntlet on its pad (base_m)
}

async function takeLock(waitS = 900) {
  const file = join(ROOT, 'build', 'n31-godot.lock');
  mkdirSync(dirname(file), { recursive: true });
  const mine = `${TAG} ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`;
  for (let waited = 0; ; waited += 30) {
    try { writeFileSync(file, mine, { flag: 'wx' }); break; } catch { /* held */ }
    if (waited >= waitS) throw new Error('prop_take: lock still held');
    console.error(`prop_take: lock held (${existsSync(file) ? readFileSync(file, 'utf8').trim() : '?'}), waiting 30 s`);
    await sleep(30_000);
  }
  return () => { if (existsSync(file) && readFileSync(file, 'utf8') === mine) rmSync(file, { force: true }); };
}

export const godotArgs = (arena, avi, seed) => ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', '60',
  '--disable-vsync', '--write-movie', avi, SCENE, ...(arena === 'gauntlet' ? ['--', '--pick-view', '--controls=wheel', `--seed=${seed}`] : [])];

const take = (f) => withRestore((hold) => takeIn(f, hold));

async function takeIn(f, hold) {
  const sha = revParse(filmedRoot(), f.rev);
  if (!sha) throw new Error(`prop_take: ${f.rev} is not a commit`);
  const tree = f.tree ? resolve(f.tree) : ensureSnapshot({ root: filmedRoot(), rev: f.rev, kind: 'film' }).path;
  mkdirSync(join(tree, 'project', 'dev', 'ground_n31'), { recursive: true });
  for (const n of PROBE.filter((x) => existsSync(join(ROOT, 'project', 'dev', 'ground_n31', x)))) copyFileSync(join(ROOT, 'project', 'dev', 'ground_n31', n), join(tree, 'project', 'dev', 'ground_n31', n));
  hold.restore = writeOverride(tree, OVERRIDES[f.arena]);
  const out = resolve(f.out);
  mkdirSync(out, { recursive: true });
  const built = await buildProbes(tree, f.arena);
  const { audit } = built;
  const only = f.only ? String(f.only).split(',').map(Number) : null; // probe indexes: a short take for a 64 px/m still
  const probes = only ? built.probes.filter((_, i) => only.includes(i)) : built.probes;
  const cfg = join(out, 'probes.json');
  writeFileSync(cfg, `${JSON.stringify({ arena: f.arena, result: out, ppm: Number(f.ppm), probes, drawn_from: audit.source }, null, 1)}\n`);
  const avi = join(out, 'take.avi');
  const args = godotArgs(f.arena, avi, f.seed);
  console.log(`prop_take: ${f.rev} ${sha.slice(0, 9)} ${f.arena}, ${probes.length} probes (drawn edges from ${audit.source})\n  godot --path project ${args.join(' ')}`);
  if (f['dry-run']) return 0;
  const release = await takeLock();
  let r;
  try {
    r = await runGodot(args, { headless: false, cwd: tree, timeoutMs: 1_200_000, stopOn: SCRIPT_ERROR, name: 'prop-take', env: { ...process.env, PROP_WALK: cfg } });
  } finally { release(); }
  writeFileSync(join(out, 'engine.log'), r.out ?? '');
  if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out ?? '') || !existsSync(avi)) { console.error(`prop_take: run failed (exit ${r.status}); see ${join(out, 'engine.log')}`); return 1; }
  const stops = readJson(join(out, 'stops.json')).stops;
  stills(avi, out, stops);
  const enc = run('ffmpeg', ['-y', '-loglevel', 'error', '-i', avi, '-vf', 'format=yuv420p', '-r', '60', '-an', '-c:v', 'libx264', '-crf', '28', join(out, 'take.mp4')], out);
  if (enc.status !== 0) { console.error(`prop_take: ffmpeg: ${enc.stderr}`); return 1; }
  const size = run('ffprobe', ['-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=width,height,nb_frames', '-of', 'csv=s=x:p=0', join(out, 'take.mp4')]).stdout.trim();
  const label = f.label ?? labelOf(f.rev, sha);
  writeFileSync(join(out, 'stops.md'), stopsMarkdown(`prop walk ${f.arena} ${label}`, probes, stops));
  writeFileSync(takeFile(out), `${JSON.stringify({ schema: 'gtai.play-take/1', rev: f.rev, sha, label, scene: SCENE, arena: f.arena, mp4: 'take.mp4', size, drawn_from: audit.source, prop_base: audit.base }, null, 1)}\n`);
  rmSync(avi, { force: true });
  console.log(`prop_take: ${join(out, 'take.mp4')} ${size}`);
  return 0;
}

/** One still per probe at its stop tick (frame index = sim tick: one tick per frame, the first frame is tick 1). */
function stills(avi, out, stops) {
  stops.filter((s) => s.tick).forEach((s, i) => run('ffmpeg', ['-y', '-loglevel', 'error', '-i', avi, '-vf', `trim=start_frame=${s.tick - 1}:end_frame=${s.tick},scale=1920:1080`, '-frames:v', '1', join(out, `still_${String(i).padStart(2, '0')}_${s.id.replace(/[^a-z0-9]+/gi, '_').slice(0, 40)}.png`)], out));
}

function side(f) {
  const [a, b] = f.side.split(',').map((d) => resolve(d));
  const takes = [a, b].map((d) => readJson(takeFile(d)));
  const out = resolve(f.out);
  mkdirSync(dirname(out), { recursive: true });
  const font = join(dirname(out), 'arialbd.ttf');
  if (!existsSync(font)) copyFileSync('C:/Windows/Fonts/arialbd.ttf', font);
  const r = run('ffmpeg', sideArgs(join(a, takes[0].mp4), join(b, takes[1].mp4), out, takes.map((t) => t.label), 'h'), dirname(out));
  if (r.status !== 0) { console.error(`prop_take: ffmpeg: ${r.stderr}`); return 1; }
  console.log(`prop_take: ${out}`);
  return 0;
}

export async function main(argv) {
  const p = parse(argv);
  if (p.error) { console.error(p.error); return 2; }
  try { return p.f.side ? side(p.f) : await take(p.f); } catch (e) { console.error(e.message); return 2; }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) process.exit(await main(process.argv.slice(2)));
