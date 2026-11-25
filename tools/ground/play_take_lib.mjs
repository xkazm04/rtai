// Pure helpers of tools/ground/play_take.mjs: argument parsing and the Godot / ffmpeg command lines.
// The owner's real mode is the gauntlet scene with --pick-view (tilt 70, wheel controls) driven by a bot.
import { join } from 'node:path';

export const SCENES = { 32: 'res://dev/gauntlet/gauntlet.tscn', 64: 'res://dev/ground_n31/gauntlet_64.tscn' };
export const WRAPPER = 'project/dev/ground_n31/gauntlet_64.tscn';
export const FPS = 60;
export const BOTS = ['novice', 'average', 'expert'];
const VALUE = new Set(['rev', 'scene', 'seed', 'ticks', 'out', 'from', 'ppm', 'bot', 'tree', 'side', 'layout', 'timeout', 'lock-wait', 'label']);
const SWITCH = new Set(['native-donor', 'dry-run']);

const USAGE = 'usage: node tools/ground/play_take.mjs --rev=<commit|HEAD> --scene=gauntlet --seed=<n> --ticks=<n> --out=<dir> '
  + '[--from=<tick>] [--ppm=32|64] [--bot=average] [--native-donor] [--dry-run]\n'
  + '       node tools/ground/play_take.mjs --side=<dirA>,<dirB> --out=<file.mp4> [--layout=h|v]';

/** {flags} or {error}. Defaults: scene gauntlet, ppm 32, from 0, bot average (the "human-like" profile; `human` is not a gauntlet flag value). */
export function parseArgv(argv) {
  const flags = { scene: 'gauntlet', ppm: '32', from: '0', bot: 'average', layout: 'h', timeout: '1500', 'lock-wait': '900' };
  for (const a of argv) {
    const m = /^--([a-z-]+)(?:=(.*))?$/.exec(a);
    if (m && SWITCH.has(m[1]) && m[2] === undefined) flags[m[1]] = true;
    else if (m && VALUE.has(m[1]) && m[2]) flags[m[1]] = m[2];
    else return { error: `play_take: bad argument ${a}\n${USAGE}` };
  }
  if (!flags.out) return { error: `play_take: --out= is required\n${USAGE}` };
  if (flags.side) {
    if (flags.side.split(',').length !== 2) return { error: 'play_take: --side takes two take dirs, <dirA>,<dirB>' };
    if (!/^[hv]$/.test(flags.layout)) return { error: 'play_take: --layout must be h or v' };
    return { flags };
  }
  for (const f of ['rev', 'seed', 'ticks']) if (!flags[f]) return { error: `play_take: --${f}= is required\n${USAGE}` };
  if (flags.scene !== 'gauntlet') return { error: `play_take: --scene must be gauntlet (quest1 is a later item), got ${flags.scene}` };
  if (!SCENES[flags.ppm]) return { error: `play_take: --ppm must be 32 or 64, got ${flags.ppm}` };
  if (!BOTS.includes(flags.bot)) return { error: `play_take: --bot must be ${BOTS.join('|')}, got ${flags.bot}` };
  for (const f of ['seed', 'ticks', 'from']) if (!/^\d+$/.test(flags[f])) return { error: `play_take: --${f} must be a whole number, got ${flags[f]}` };
  if (Number(flags.from) >= Number(flags.ticks)) return { error: 'play_take: --from must be below --ticks' };
  return { flags };
}

/** The Godot arguments after `--path project`: windowed d3d12 on the secondary screen, 1080p, fixed 60 Hz, a movie. */
export function godotArgs({ scene, avi, ticks, seed, bot }) {
  return ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', String(FPS),
    '--disable-vsync', '--write-movie', avi, '--quit-after', String(ticks), scene,
    '--', '--pick-view', `--bot=${bot}`, '--controls=wheel', `--seed=${seed}`];
}

/** Three sample frames of the kept window: a quarter, a half and three quarters in. */
export const sampleFrames = (from, ticks) => [0.25, 0.5, 0.75].map((k) => from + Math.floor((ticks - from) * k));

/** ffmpeg arguments: the AVI from frame `from` to a 60 fps h264 yuv420p mp4. */
export const encodeArgs = (avi, mp4, from) => ['-y', '-loglevel', 'error', '-i', avi, '-vf',
  `trim=start_frame=${from},setpts=PTS-STARTPTS,format=yuv420p`, '-r', String(FPS), '-an', '-c:v', 'libx264', '-crf', '23', mp4];

/** ffmpeg arguments for one still: frame `n` of the AVI as a PNG. */
export const stillArgs = (avi, n, png) => ['-y', '-loglevel', 'error', '-i', avi, '-vf', `trim=start_frame=${n}:end_frame=${n + 1}`, '-frames:v', '1', png];

const esc = (s) => String(s).replace(/[':\%]/g, ' ');
const label = (s, x, y) => `drawtext=fontfile=arialbd.ttf:text='${esc(s)}':x=${x}:y=${y}:fontsize=28:fontcolor=white:box=1:boxcolor=black@0.7:boxborderw=8`;

/** ffmpeg arguments stacking two takes into one 1920x1080 60 fps mp4 (h: two
 *  centre columns of 960x1080; v: two centre bands of 1920x540, real pixels, never scaled). Labels on top. */
export function sideArgs(a, b, out, labels, layout) {
  const h = layout === 'h';
  const cut = h ? 'crop=960:1080:480:0' : 'crop=1920:540:0:270';
  const stack = h ? 'hstack' : 'vstack';
  const graph = `[0:v]${cut},${label(labels[0], 12, 12)}[a];[1:v]${cut},${label(labels[1], 12, 12)}[b];[a][b]${stack},format=yuv420p`;
  return ['-y', '-loglevel', 'error', '-i', a, '-i', b, '-filter_complex', graph, '-r', String(FPS), '-an', '-c:v', 'libx264', '-crf', '23', out];
}

/** The caption of a take: `<rev> <sha9>`, or just the hash when the rev already is one. */
export const labelOf = (rev, sha) => (sha.startsWith(rev.toLowerCase()) ? sha.slice(0, 9) : `${rev} ${sha.slice(0, 9)}`);
export const takeFile = (dir) => join(dir, 'take.json');
