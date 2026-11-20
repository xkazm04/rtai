#!/usr/bin/env node
// Fixed-tick Dent review captures. Usage: node tools/film/dent_tether_films.mjs <scratch directory>
// The regular attack ends before 20 m. A second staging mark exercises range with the same input.
import { copyFileSync, existsSync, linkSync, mkdirSync, mkdtempSync, readdirSync, readFileSync,
  symlinkSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { describe, ensureImport, runGodot } from '../lib/godot.mjs';
import { plan } from './ghost_films.mjs';

if (!process.argv[2] || process.argv.length > 4 || (process.argv[3] && process.argv[3] !== 'range')) {
  throw Error('Usage: node tools/film/dent_tether_films.mjs <capture-directory> [range]');
}
const p = plan(['--ghost=dent', '--look=spectral', '--takes=attack', '--out=' + resolve(process.argv[2])]);
const source = join(ROOT, 'project');
const driver = 'dev/ghost-powers/ghost_review.gd';
const input = 'dev/ghost-powers/ghost_review_input.gd';
const viewScript = 'features/souls/dent_view.gd';
const read = path => readFileSync(join(source, path), 'utf8');
const scratch = join(ROOT, 'build', 'dent-tether-films');
mkdirSync(scratch, { recursive: true });
mkdirSync(p.out, { recursive: true });

function replaceOnce(text, from, to) {
  if (!text.includes(from) || text.indexOf(from) !== text.lastIndexOf(from)) throw Error('Review source changed at ' + from);
  return text.replace(from, to);
}

// Mount read-only inputs like ghost_films. All generated scripts and config are private copies.
function stage(dir, far, blank) {
  const replaced = ['project.godot', driver, viewScript, ...(far ? [input] : []), ...(blank ? ['features/souls/dent_strings.gd'] : [])];
  function mount(rel) {
    const dst = join(dir, 'project', rel);
    mkdirSync(dst, { recursive: true });
    for (const item of readdirSync(join(source, rel), { withFileTypes: true })) {
      const path = rel ? rel + '/' + item.name : item.name;
      if (replaced.includes(path)) continue;
      const a = join(source, path), b = join(dst, item.name);
      if (item.isDirectory() && replaced.some(name => name.startsWith(path + '/'))) mount(path);
      else if (item.isDirectory()) symlinkSync(a, b, process.platform === 'win32' ? 'junction' : 'dir');
      else copyFileSync(a, b);
    }
  }
  mount('');
  for (const file of ['dent_tether_probe.gd', 'dent_tether_probe.gd.uid']) {
    copyFileSync(join(ROOT, 'tools', 'film', file), join(dir, 'project', 'dev', 'ghost-powers', file));
  }
  const put = (path, text) => writeFileSync(join(dir, 'project', path), text);
  const cfg = read('project.godot').replace(/viewport_width=\d+/, 'viewport_width=1280')
    .replace(/viewport_height=\d+/, 'viewport_height=800');
  put('project.godot', cfg + '\n[threading]\nworker_pool/max_threads=4\n');
  // The flight driver rejects unknown user flags. Its scratch mount admits just the Dent flag.
  const adapter = join(dir, 'dent_review_driver.gd');
  writeFileSync(adapter, replaceOnce(read(driver), '"--ohm-bolt-delay",', '"--dent-tether",\n\t"--ohm-bolt-delay",'));
  linkSync(adapter, join(dir, 'project', driver));
  if (far) {
    // The stock pad aims at 14 m and cannot seize a car parked at 20. Use legal cursor reach,
    // seizing the car at the edge of the pad reticle and driving through the 20 m mark.
    const parked = replaceOnce(read(input), '&"dent": Vector2(3, -1.8)', '&"dent": Vector2(14, -1.8)');
    const rangeInput = join(dir, 'dent_range_input.gd');
    writeFileSync(rangeInput, replaceOnce(parked, 'PlayerCommand.pack_aim(aim, session.actions)',
      'PlayerCommand.pack_aim(aim, session.actions, 18.0)'));
    linkSync(rangeInput, join(dir, 'project', input));
  }
  if (blank) {
    const path = 'features/souls/dent_strings.gd';
    // The body, corners, clocks and measurement paths still run; omit only the ink for subtraction.
    put(path, read(path).split('func paint(canvas:')[0] + 'func paint(_canvas: DentStrapCanvas, _fill: Color) -> void:\n\tpass\n');
  }
  put(viewScript, replaceOnce(read(viewScript), 'func _draw() -> void:', 'func _game_draw() -> void:') +
    '\nvar _film_probe := preload("res://dev/ghost-powers/dent_tether_probe.gd").new()\n\n' +
    'func _draw() -> void:\n\tvar start: int = Time.get_ticks_usec()\n\t_game_draw()\n' +
    '\t_film_probe.sample(self, Time.get_ticks_usec() - start)\n');
}

const imported = await ensureImport();
if (imported.status) throw Error('Import failed: ' + describe(imported));
for (const [far, blank] of [[false, false], [true, false], [false, true], [true, true]]) {
  if (process.argv[3] === 'range' && !far) continue;
  const dir = mkdtempSync(join(scratch, far ? 'range-' : 'attack-'));
  stage(dir, far, blank);
  const configs = far || blank ? [['tilt70', 32], ['top', 32]] : [['tilt70', 32], ['top', 32], ['tilt70', 64]];
  for (const [v, ppm] of configs) {
    for (const look of blank ? ['strings'] : ['strap', 'strings']) {
      const base = join(p.out, [far ? 'range' : 'attack', v, ppm, blank ? 'blank' : look].join('_'));
      const stem = base.replaceAll('\\', '/');
      const frames = far ? 255 : blank ? 207 : 405;
      const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1280x800',
        '--disable-vsync', '--audio-driver', 'Dummy', '--fixed-fps', '60', '--write-movie', stem + '.avi',
        '--quit-after', String(frames), 'res://dev/ghost-powers/ghost_review.tscn', '--', '--ghost=' + p.ghost,
        '--take=attack', '--ghost-look=' + p.look, '--dent-tether=' + look, '--view=' + v, '--ppm=' + ppm,
        '--clean', '--film-panel', '--film-trace=' + stem + '.jsonl'];
      const r = await runGodot(args, { cwd: dir, ensure: false, headless: false, timeoutMs: 360000,
        name: 'dent-tether-film', stopOn: /SCRIPT ERROR|SHADER ERROR|Shader compilation failed|unknown argument/i });
      writeFileSync(base + '.log', r.out);
      if (r.status || !r.out.includes('uses spectral look') || !existsSync(base + '.jsonl.draw')) {
        throw Error(describe(r) + ' — see ' + base + '.log');
      }
      const draws = readFileSync(base + '.jsonl.draw', 'utf8').trim().split(/\r?\n/).map(JSON.parse);
      if (!draws.some(r => r.look === look && Math.abs(r.distance_m - (far ? 20 : 5)) < 0.4)) {
        throw Error('Missed distance mark in ' + base);
      }
      console.log(look, v, ppm, far ? '20 m mark' : 'attack', describe(r));
    }
  }
}
