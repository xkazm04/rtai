// Record one continuous live arena take per item, encode only the native frame sequence,
// and retain its tick log in build/. Usage: node tools/film/owner_takes.mjs <out> <32|64> <weapons...>
import { execFileSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runGodot } from '../lib/godot.mjs';

const [out, resolution, ...items] = process.argv.slice(2);
const weapons = ['hands', 'chainsaw', 'electro_baton', 'katana', 'plasma_sword', 'electric_robots', 'electro_gun_wrecks', 'claw_shock'];
if (!out || !['32', '64'].includes(resolution) || !items.length || items.some(w => !weapons.includes(w))) {
  throw Error('usage: owner_takes.mjs <master-dir> <32|64> <weapon...>');
}
const ppm = Number(resolution);
const master = resolve(out);
const scratch = resolve('build/p5-takes');
mkdirSync(scratch, { recursive: true });

function ffmpeg(args) {
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', ...args], { windowsHide: true });
}

function stamp(tick) {
  const ms = Math.round(tick * 1000 / 60);
  return '00:00:' + String(Math.floor(ms / 1000)).padStart(2, '0') + ',' + String(ms % 1000).padStart(3, '0');
}

// claw_shock: after the real-time take, the first finish again at quarter speed.
const SLOW = 4;
function slowWindow(take) {
  const kill = take.opponents[0].kill_tick ?? take.opponents[0].hit_tick;
  if (!kill) throw Error('first opponent recorded no contact');
  const from = Math.max(1, kill - 50);
  return { from, count: Math.min(100, take.frames - from + 1) };
}

function subtitles(dir, take, tail = null) {
  const file = join(dir, 'victims.srt');
  const segments = take.opponents.map((o, i) => {
    const begin = o.cue;
    const end = take.opponents[i + 1]?.cue ?? take.frames;
    const words = s => s.replaceAll('_', ' ');
    return [i + 1, stamp(begin) + ' --> ' + stamp(end - 1), words(o.selected) + '  /  ' + words(o.victim)].join('\n');
  });
  writeFileSync(file, segments.join('\n\n') + '\n');
  return file;
}

function filmName(id) {
  if (id === 'claw_shock') return 'claw_shock_robots';
  return ['electric_robots', 'electro_gun_wrecks'].includes(id) ? id : id + '_kills';
}

function film(dir, id, take) {
  const dest = join(master, 'films');
  mkdirSync(dest, { recursive: true });
  const path = join(dest, filmName(id) + '.mp4');
  const slow = id === 'claw_shock' ? slowWindow(take) : null;
  const total = take.frames + (slow ? slow.count * SLOW : 0);
  const video = slow
    ? ['-filter_complex', `[0:v]split[a][b];[b]trim=start_frame=${slow.from - 1}:end_frame=${slow.from - 1 + slow.count},` +
      `setpts=${SLOW}*(PTS-STARTPTS),fps=60[s];[a][s]concat=n=2:v=1:a=0[v]`, '-map', '[v]']
    : ['-map', '0:v'];
  ffmpeg(['-framerate', '60', '-start_number', '1', '-i', join(dir, '%04d.jpg'),
    '-i', subtitles(dir, take, slow ? slow.count : null),
    ...video, '-map', '1:s', '-c:v', 'libx264', '-threads', '4', '-preset', 'veryfast', '-crf', '16',
    '-pix_fmt', 'yuv420p', '-c:s', 'mov_text', '-disposition:s:0', 'default', '-movflags', '+faststart', path]);
  const probe = JSON.parse(execFileSync('ffprobe', ['-v', 'error', '-select_streams', 'v:0', '-show_streams',
    '-show_format', '-of', 'json', path], { encoding: 'utf8', windowsHide: true }));
  const v = probe.streams[0];
  if (v.width !== 1920 || v.height !== 1080 || v.avg_frame_rate !== '60/1' ||
      Number(v.nb_frames) !== total || +v.duration < 15 || +v.duration > 40) throw Error('bad film: ' + path);
  writeFileSync(join(dir, 'ffprobe.json'), JSON.stringify(probe, null, 2));
  return path;
}

function closeup(dir, id, take) {
  const o = take.opponents[0];
  const tick = o.kill_tick ?? o.hit_tick;
  if (!tick) throw Error('first opponent recorded no contact');
  const dest = join(master, 'closeups');
  mkdirSync(dest, { recursive: true });
  const file = join(dest, id + '_64.png');
  const frame = t => join(dir, String(t).padStart(4, '0') + '.jpg');
  if (id === 'claw_shock') {
    const ticks = [-6, 6, 18, 34].map(d => Math.max(1, tick + d));
    ffmpeg([...ticks.flatMap(t => ['-i', frame(t)]), '-filter_complex',
      ticks.map((_, i) => `[${i}:v]crop=480:320:800:300[c${i}]`).join(';') +
      ';[c0][c1]hstack[top];[c2][c3]hstack[bottom];[top][bottom]vstack', '-frames:v', '1', file]);
    return file;
  }
  ffmpeg(['-i', frame(tick), '-i', frame(tick + 20), '-filter_complex',
    '[0:v]crop=536:360:780:295[a];[1:v]crop=536:360:780:295[b];[a][b]hstack', '-frames:v', '1', file]);
  return file;
}

for (const id of items) {
  const dir = mkdtempSync(join(scratch, id + '-' + ppm + '-'));
  const loadout = id === 'electric_robots' ? 'katana,electro_baton' : id === 'electro_gun_wrecks' ? 'electro_gun,electro_gun' : id;
  const expectedFrames = ppm === 64 ? 180 : ({ electric_robots: 1080, electro_gun_wrecks: 1080, claw_shock: 1232 }[id] ?? 960);
  const args = ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080',
    '--fixed-fps', '60', '--quit-after', String(expectedFrames + 30), fileURLToPath(new URL('./owner_take.tscn', import.meta.url)), '--',
    '--loadout=' + loadout, '--enemy-brain=squad', '--seed=20261109', '--view=tilt70', '--ppm=' + ppm,
    '--rigs', '--clean', '--silent', '--feel=off'];
  const env = { ...process.env, GTAI_MELEE_TAKE: dir, GTAI_MELEE_NATIVE: '1', GTAI_MELEE_CLOSE: ppm === 64 ? '1' : '0' };
  const r = await runGodot(args, { headless: false, timeoutMs: 300000, name: 'owner-take', env });
  writeFileSync(join(dir, 'film.log'), r.out);
  if (r.status !== 0 || r.timedOut || /SCRIPT ERROR:|\[ERROR\] owner_take/.test(r.out)) throw Error('see ' + dir);
  const take = JSON.parse(readFileSync(join(dir, 'take.json'), 'utf8'));
  if (take.frames !== expectedFrames) throw Error('incomplete take: ' + dir);
  const path = ppm === 64 ? closeup(dir, id, take) : film(dir, id, take);
  console.log(path, take.frames, 'native frames;', take.starts.length, 'starts;', dir);
}
