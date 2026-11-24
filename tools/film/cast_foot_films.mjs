#!/usr/bin/env node
// Riot, SWAT and lancer before (shipped four-drawing strip) and after (eight) at a true 1920 x 1080.
// Stills at 64 px/m tilt 70 with sole dots and the contacts bracketed; one 32 px/m clip with the
// before band over the after band. "Before" flips each anchor table's WALK constant to FOUR in the
// working tree for the run and restores the file afterwards (a scratch project mounts the live assets).
// usage: node tools/film/cast_foot_films.mjs <output-dir> [stills|clip|all]
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, symlinkSync,
  writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { describe, runGodot } from '../lib/godot.mjs';

const [out, what = 'all'] = process.argv.slice(2);
if (!out) { console.error('usage: node tools/film/cast_foot_films.mjs <output-dir> [stills|clip|all]'); process.exit(2); }
const CHARS = [
  { id: 'riot', subject: 'riot_cop', speed: 2.8, ticks: 420, file: 'cop_riot_anchors', label: 'riot cop walk 2.8 m/s' },
  { id: 'swat_walk', subject: 'swat', speed: 3.4, ticks: 420, file: 'cast_swat_anchors', label: 'SWAT walk 3.4 m/s' },
  { id: 'swat_run', subject: 'swat', speed: 6.0, ticks: 300, file: 'cast_swat_anchors', label: 'SWAT run 6 m/s' },
  { id: 'lancer', subject: 'rocket_trooper', speed: 3.2, ticks: 420, file: 'cast_lancer_anchors', label: 'lancer walk 3.2 m/s' },
];
const anchors = (c) => join(ROOT, 'project/features/characters', c.file.replace('cop_riot', 'cast_riot') + '.gd');

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
    .replace(/viewport_height=\d+/, 'viewport_height=1080') + '\n[threading]\nworker_pool/max_threads=4\n');
}

const work = join(ROOT, 'build', 'film');
mkdirSync(work, { recursive: true });
const dir = mkdtempSync(join(work, 'foot-'));
stageProject(dir);
const outDir = resolve(out);
mkdirSync(outDir, { recursive: true });
const soles = join(ROOT, 'build', 'cast', 'film_soles.json');

async function take(c, mode, ppm, extra) {
  const path = anchors(c);
  const original = readFileSync(path, 'utf8');
  if (mode === 'before') writeFileSync(path, original.replace('const WALK: String = EIGHT', 'const WALK: String = FOUR'));
  try {
    const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
      '--fixed-fps', '60', '--audio-driver', 'Dummy', ...extra.args, 'res://dev/cast/cast_foot_film.tscn'];
    const r = await runGodot(args, { cwd: dir, name: 'cast-foot-film', ensure: false, headless: false,
      timeoutMs: 600000, stopOn: /SCRIPT ERROR|SHADER ERROR/i,
      env: { ...process.env, GTAI_CAST_PPM: String(ppm), GTAI_CAST_SUBJECT: c.subject, GTAI_CAST_SPEED: String(c.speed),
        GTAI_CAST_TICKS: String(extra.ticks), GTAI_CAST_SOLES: soles, GTAI_CAST_STILL: extra.still ?? '' } });
    if (r.status !== 0 || (extra.still && !existsSync(extra.still)) || (extra.avi && !existsSync(extra.avi))) {
      writeFileSync(join(dir, 'fail.log'), r.out);
      throw Error(`${c.id} ${mode} ${ppm} failed (${describe(r)}), see ${join(dir, 'fail.log')}`);
    }
    console.log(c.id, mode, ppm, describe(r));
  } finally { writeFileSync(path, original); }
}

if (what !== 'clip') {
  for (const c of CHARS.filter((x) => x.id !== 'swat_run')) {
    for (const mode of ['before', 'after']) {
      const still = join(dir, `${c.id}_${mode}_64.png`);
      await take(c, mode, 64, { ticks: 150, still, args: [] });
    }
  }
}
if (what !== 'stills') {
  for (const c of CHARS) {
    for (const mode of ['before', 'after']) {
      const avi = join(dir, `${c.id}_${mode}_32.avi`);
      await take(c, mode, 32, { ticks: c.ticks, avi, args: ['--write-movie', avi, '--quit-after', String(c.ticks + 40)] });
    }
  }
}
console.log('work dir', dir);
