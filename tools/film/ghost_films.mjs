#!/usr/bin/env node
// Two native-scale views of the same fixed-tick arena drive. Movie Maker takes its output size
// from the project viewport, so the scratch project mounts the live assets at 1920 x 540.
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, renameSync,
  symlinkSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { describe, ensureImport, runGodot } from '../lib/godot.mjs';

import { FRAMES, START, TURN, plan, stem } from './ghost_films_plan.mjs';
export { plan, stem } from './ghost_films_plan.mjs';

const MORPH_FRAMES = 400;
const views = ['tilt70', 'top'];

function stageProject(dir) {
  const source = join(ROOT, 'project'), dst = join(dir, 'project');
  mkdirSync(dst);
  for (const f of readdirSync(source, { withFileTypes: true })) {
    const a = join(source, f.name), b = join(dst, f.name);
    if (f.isDirectory()) symlinkSync(a, b, process.platform === 'win32' ? 'junction' : 'dir');
    else if (f.name !== 'project.godot') copyFileSync(a, b);
  }
  const config = readFileSync(join(source, 'project.godot'), 'utf8');
  writeFileSync(join(dst, 'project.godot'), config.replace(/viewport_width=\d+/, 'viewport_width=1920')
    .replace(/viewport_height=\d+/, 'viewport_height=540') + '\n[threading]\nworker_pool/max_threads=4\n');
}

function ffmpeg(dir, args) {
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', ...args], { cwd: dir, windowsHide: true, stdio: 'inherit' });
}

async function capture(dir, p, take, ppm, view, end) {
  const base = join(dir, (p.all ? p.ghost + '_' : '') + [take, ppm, view].join('_'));
  const movie = base + '.avi', trace = base + '.jsonl';
  const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x540',
    '--disable-vsync', '--audio-driver', 'Dummy', '--fixed-fps', '60', '--write-movie', movie, '--quit-after', String(end),
    'res://dev/ghost-powers/ghost_review.tscn', '--', '--ghost=' + p.ghost, '--take=' + take, '--view=' + view,
    '--ppm=' + ppm, '--ghost-look=' + p.look, '--clean', '--film-panel', '--film-trace=' + trace];
  const r = await runGodot(args, { cwd: dir, name: 'ghost-film', ensure: false, headless: false,
    timeoutMs: 600000, stopOn: /SCRIPT ERROR|SHADER ERROR|Shader compilation failed/i });
  writeFileSync(base + '.log', r.out);
  if (r.status !== 0 || !r.out.includes('uses ' + p.look + ' look') || !existsSync(movie)) {
    throw Error('capture failed (' + describe(r) + '), see ' + base + '.log');
  }
  const probe = JSON.parse(execFileSync('ffprobe', ['-v', 'error', '-select_streams', 'v:0', '-show_entries',
    'stream=width,height,nb_frames', '-of', 'json', movie], { encoding: 'utf8', windowsHide: true })).streams[0];
  if (probe.width !== 1920 || probe.height !== 540 || Number(probe.nb_frames) < end) throw Error('incomplete panel ' + movie);
  const [, ...rows] = readFileSync(trace, 'utf8').trim().split(/\r?\n/).map(JSON.parse);
  const live = rows.filter(r => r[1] >= START && r[1] < START + FRAMES);
  const forms = rows.map(r => r[2]);
  if (take === 'morph' && !(forms[0] === 'base' && forms.includes(p.ghost) && forms.at(-1) === 'base')) {
    throw Error('incomplete base to form to base transition in ' + trace);
  }
  if (live.some(r => (take !== 'morph' && r[2] !== p.ghost) || Math.abs(r[21] - ppm) > 0.01)) throw Error('form or native scale changed in ' + trace);
  console.log(view, take, ppm + ' px/m', describe(r));
  return { movie, rows };
}

function tickIndex(panel, tick) {
  const row = panel.rows.find(r => r[1] === tick);
  if (!row) throw Error('missing trace tick ' + tick + ' in ' + panel.movie);
  return row[0];
}

function title(text, x, y, size) {
  return "drawtext=fontfile=film.ttf:text='" + text + "':x=" + x + ':y=' + y + ':fontsize=' + size +
    ':fontcolor=white:box=1:boxcolor=0x172023@0.88:boxborderw=5';
}

function compose(dir, p, chapters, target, ppm, still) {
  const inputs = [], filters = [];
  for (const [i, { panels, action, ghost, speed }] of chapters.entries()) {
    const [a, b] = panels.map((panel, j) => {
      inputs.push('-threads', '1', '-i', panel.movie);
      const start = tickIndex(panel, still ?? (action === 'morph' ? 1 : START));
      const count = still === undefined ? (action === 'morph' ? MORPH_FRAMES : FRAMES) : 1;
      const label = 'p' + i + j;
      filters.push('[' + (i * 2 + j) + ':v]trim=start_frame=' + start + ':end_frame=' + (start + count) +
        ',setpts=PTS-STARTPTS,setsar=1[' + label + ']');
      return '[' + label + ']';
    });
    const card = ghost[0].toUpperCase() + ghost.slice(1);
    const label = ({ move: 'Movement', attack: 'Attack', morph: 'Transformation' }[action]) + (still === undefined ? '' : '    /    Tick ' + still);
    filters.push(a + b + 'vstack,drawbox=x=0:y=0:w=iw:h=39:color=0x172023:t=fill,' +
      [title(card + '   ' + speed + ' m/s max    /    ' + ppm + ' px/m', 18, 7, 23),
        title(label + '    /    ' + p.look, 585, 7, 22), title('Play tilt  70\u00b0', 17, 55, 17),
        title('Top view  90\u00b0', 17, 553, 17)].join(',') + '[c' + i + ']');
  }
  const labels = chapters.map((_, i) => '[c' + i + ']').join('');
  filters.push(labels + (chapters.length > 1 ? 'concat=n=' + chapters.length + ':v=1:a=0' : 'null') + '[out]');
  const encode = still === undefined ? ['-c:v', 'libx264', '-preset', 'veryfast', '-crf', '17', '-pix_fmt', 'yuv420p',
    '-movflags', '+faststart'] : ['-frames:v', '1', '-update', '1'];
  ffmpeg(dir, [...inputs, '-filter_complex_threads', '3', '-filter_complex', filters.join(';'), '-map', '[out]', '-an', '-threads', '4', ...encode, target]);
}

function publishMovie(dir, p, chapters, base, ppm) {
  const pending = base + '.' + process.pid;
  compose(dir, p, chapters, pending + '.mp4', ppm);
  ffmpeg(dir, ['-ss', String((TURN - START) / 60), '-i', pending + '.mp4', '-frames:v', '1', '-q:v', '2', '-update', '1', pending + '.jpg']);
  renameSync(pending + '.mp4', base + '.mp4');
  renameSync(pending + '.jpg', base + '.jpg');
  console.log('Wrote ' + base + '.mp4 and poster');
}

export async function film(p) {
  mkdirSync(p.out, { recursive: true });
  const work = join(ROOT, 'build', 'ghost-films');
  mkdirSync(work, { recursive: true });
  const dir = mkdtempSync(join(work, (p.all ? 'all' : p.ghost) + '-' + p.look + '-'));
  console.log('Capture logs and native panels in ' + dir);
  const imported = await ensureImport();
  if (imported.status) throw Error('Godot import failed');
  stageProject(dir);
  const font = process.platform === 'win32' ? join(process.env.WINDIR, 'Fonts', 'segoeuib.ttf') :
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf';
  copyFileSync(font, join(dir, 'film.ttf'));
  const table = JSON.parse(readFileSync(join(ROOT, 'project/data/tables/ghost_forms.json'), 'utf8'));
  const pairs = new Map();
  async function pair(ghost, action, ppm, end = action === 'morph' ? MORPH_FRAMES + 2 : START + FRAMES + 1) {
    const key = [ghost, action, ppm].join('_');
    if (!pairs.has(key)) {
      const panels = [];
      for (const view of views) panels.push(await capture(dir, { ...p, ghost }, action, ppm, view, end));
      pairs.set(key, { panels, action, ghost, speed: table.forms.find(r => r.id === ghost).top_mps });
    }
    return pairs.get(key);
  }
  if (p.all) {
    const chapters = [];
    for (const { ghost, take } of p.chapters) chapters.push(await pair(ghost, take, 32));
    publishMovie(dir, p, chapters, join(p.out, p.name), 32);
    return;
  }
  for (const tick of p.stills) {
    const chapter = await pair(p.ghost, 'move', 64, p.takes.includes('close') ? START + FRAMES + 1 : Math.max(...p.stills) + 1);
    const target = join(p.out, stem(p, 'turn', tick) + '.png');
    const pending = target + '.' + process.pid + '.png';
    compose(dir, p, [chapter], pending, 64, tick);
    renameSync(pending, target);
    console.log('Wrote ' + target);
  }
  for (const take of p.takes) {
    const ppm = take === 'close' ? 64 : 32;
    const chapters = take === 'close' ? [await pair(p.ghost, 'move', ppm), await pair(p.ghost, 'attack', ppm)] : [await pair(p.ghost, take, ppm)];
    const base = join(p.out, stem(p, take));
    publishMovie(dir, p, chapters, base, ppm);
  }
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  try { await film(plan(process.argv.slice(2))); }
  catch (error) { console.error(error.message); process.exitCode = 1; }
}
