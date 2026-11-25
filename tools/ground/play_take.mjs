#!/usr/bin/env node
// The owner's real mode on film, any commit, same seed and ticks: the gauntlet scene with --pick-view
// (tilt 70, wheel controls) driven by a bot, from a snapshot of the commit (tools/lib/snapshot.mjs), as
// an mp4 + three PNG stills + take.json. Two takes stack with --side.
//   node tools/ground/play_take.mjs --rev=ba8e470b0 --seed=7 --ticks=2400 --out=<dir> [--from=0] [--ppm=32|64]
//   node tools/ground/play_take.mjs --side=<dirA>,<dirB> --out=<file.mp4> [--layout=h|v]
// 64 px/m runs the wrapper scene res://dev/ground_n31/gauntlet_64.tscn (camera_ppm 64): a real 64 px/m render.
// One Godot at a time in the lane: the run holds build/n31-godot.lock (create-exclusive) and removes it after.
import { spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { ROOT } from '../lib/repo.mjs';
import { ensureSnapshot, revParse } from '../lib/snapshot.mjs';
import { filmedRoot, nativeDiffers, nativeRefusal } from '../film/side.mjs';
import { encodeArgs, godotArgs, labelOf, parseArgv, sampleFrames, sideArgs, stillArgs, takeFile, SCENES, WRAPPER } from './play_take_lib.mjs';

const OVERRIDE = `[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
`;
const TAG = process.env.PLAY_TAKE_TAG ?? 'n31-02';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function ffmpeg(args, cwd) {
  const font = join(cwd, 'arialbd.ttf');
  if (!existsSync(font)) copyFileSync('C:/Windows/Fonts/arialbd.ttf', font);
  const r = spawnSync('ffmpeg', args, { cwd, encoding: 'utf8', windowsHide: true });
  return r.status === 0 ? null : (r.stderr || 'ffmpeg failed').trim();
}

/** Takes the lane's Godot mutex (create-exclusive), waiting up to `waitS`. Returns the release function. */
async function takeLock(root, waitS) {
  const file = join(root, 'build', 'n31-godot.lock');
  mkdirSync(dirname(file), { recursive: true });
  const mine = `${TAG} ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`;
  for (let waited = 0; ; waited += 30) {
    try { writeFileSync(file, mine, { flag: 'wx' }); break; } catch { /* held */ }
    if (waited >= waitS) throw new Error(`play_take: ${file} still held after ${waitS} s`);
    console.error(`play_take: lock held (${existsSync(file) ? readFileSync(file, 'utf8').trim() : '?'}), waiting 30 s`);
    await sleep(30_000);
  }
  return () => { if (existsSync(file) && readFileSync(file, 'utf8') === mine) rmSync(file, { force: true }); };
}

/** WxH of a video, or `unreadable`. */
function probeSize(file) {
  const r = spawnSync("ffprobe", ["-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "csv=s=x:p=0", file], { encoding: "utf8", windowsHide: true });
  return r.status === 0 ? r.stdout.trim() : "unreadable";
}

function treeFor(f, root) {
  if (f.tree) return { tree: resolve(f.tree), sha: revParse(resolve(f.tree), 'HEAD') ?? 'worktree' };
  const sha = revParse(root, f.rev);
  if (!sha) throw new Error(`play_take: ${f.rev} is not a commit git knows`);
  const refusal = nativeRefusal(f.rev, sha, nativeDiffers(root, sha), f['native-donor'] ? 'donor' : undefined);
  if (refusal) throw new Error(refusal);
  return { tree: ensureSnapshot({ root, rev: f.rev, kind: 'film' }).path, sha };
}

async function take(f) {
  const root = filmedRoot();
  const { tree, sha } = treeFor(f, root);
  const scene = SCENES[f.ppm];
  if (f.ppm === '64') { // older commits have no wrapper scene: copy it into the throwaway tree
    mkdirSync(join(tree, dirname(WRAPPER)), { recursive: true });
    copyFileSync(join(ROOT, WRAPPER), join(tree, WRAPPER));
  }
  writeFileSync(join(tree, "project", "override.cfg"), OVERRIDE); // the movie takes the viewport size, not --resolution
  const out = resolve(f.out);
  mkdirSync(out, { recursive: true });
  const avi = join(out, 'take.avi');
  const args = godotArgs({ scene, avi, ticks: f.ticks, seed: f.seed, bot: f.bot, waveTimeout: f['wave-timeout'] });
  const label = f.label ?? labelOf(f.rev, sha);
  console.log(`play_take: ${label} in ${tree}\n  godot --path project ${args.join(' ')}`);
  if (f['dry-run']) return 0;
  const release = await takeLock(root, Number(f['lock-wait']));
  let r;
  try {
    r = await runGodot(args, { headless: false, cwd: tree, timeoutMs: Number(f.timeout) * 1000, stopOn: SCRIPT_ERROR, name: 'play-take' });
  } finally { release(); }
  writeFileSync(join(out, 'engine.log'), r.out);
  if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out) || !existsSync(avi)) {
    console.error(`play_take: the run failed (exit ${r.status}); see ${join(out, 'engine.log')}`);
    return 1;
  }
  const from = Number(f.from);
  const frames = sampleFrames(from, Number(f.ticks));
  const err = ffmpeg(encodeArgs(avi, join(out, 'take.mp4'), from), out)
    ?? frames.map((n) => ffmpeg(stillArgs(avi, n, join(out, `still_${n}.png`)), out)).find(Boolean);
  if (err) { console.error(`play_take: ffmpeg: ${err}`); return 1; }
  const size = probeSize(join(out, "take.mp4"));
  if (size !== "1920x1080") { console.error(`play_take: the take is ${size}, not 1920x1080`); return 1; }
  rmSync(avi, { force: true });
  writeFileSync(takeFile(out), `${JSON.stringify({ schema: 'gtai.play-take/1', rev: f.rev, sha, label, scene, seed: Number(f.seed), ticks: Number(f.ticks),
    from, ppm: Number(f.ppm), bot: f.bot, controls: 'wheel', stills: frames, mp4: 'take.mp4', run_seconds: Math.round(r.durationMs / 1000) }, null, 1)}\n`);
  console.log(`play_take: ${join(out, 'take.mp4')} (stills ${frames.join(', ')})`);
  return 0;
}

function side(f) {
  const [a, b] = f.side.split(',').map((d) => resolve(d));
  const takes = [a, b].map((d) => JSON.parse(readFileSync(takeFile(d), 'utf8')));
  const out = resolve(f.out);
  mkdirSync(dirname(out), { recursive: true });
  const err = ffmpeg(sideArgs(join(a, takes[0].mp4), join(b, takes[1].mp4), out, takes.map((t) => t.label), f.layout), dirname(out));
  if (err) { console.error(`play_take: ffmpeg: ${err}`); return 1; }
  console.log(`play_take: ${out}`);
  return 0;
}

export async function main(argv) {
  const parsed = parseArgv(argv);
  if (parsed.error) { console.error(parsed.error); return 2; }
  try { return parsed.flags.side ? side(parsed.flags) : await take(parsed.flags); }
  catch (e) { console.error(e.message); return 2; }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) process.exit(await main(process.argv.slice(2)));
