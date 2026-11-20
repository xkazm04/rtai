// Capture native-scale stills. The fixture inherits the shipped ghost review scene in a scratch project.
import { copyFileSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { describe, ensureImport, runGodot } from '../lib/godot.mjs';
import { ROOT } from '../lib/repo.mjs';

const [out, ...marks] = process.argv.slice(2);
if (!out) throw Error('usage: node tools/art/kerf_n21_review.mjs <archive> [guard hover cruise turn hit]');
const scratch = resolve(out, 'wire');
const project = join(scratch, 'project');
const review = 'res://dev/ghost-powers/ghost_review.tscn';
const shots = ['tilt70', 'tilt', 'top'].map(view => [view, 'guard', 32, 88]);
for (const view of ['tilt70', 'top']) {
  for (const [mark, tick] of [['hover', 88], ['cruise', 110], ['turn', 158], ['hit', 88]]) {
    shots.push([view, mark, 64, tick]);
  }
}

function stage() {
  mkdirSync(project, { recursive: true });
  for (const item of readdirSync(join(ROOT, 'project'), { withFileTypes: true })) {
    const source = join(ROOT, 'project', item.name), target = join(project, item.name);
    if (item.isDirectory()) {
      if (!existsSync(target)) symlinkSync(source, target, process.platform === 'win32' ? 'junction' : 'dir');
    } else copyFileSync(source, target);
  }
  copyFileSync(join(ROOT, 'tools/art/kerf_n21_review.gd'), join(project, 'shot_fixture.gd'));
  writeFileSync(join(project, 'shot.tscn'), `[gd_scene load_steps=3 format=3]

[ext_resource type="PackedScene" path="${review}" id="1"]
[ext_resource type="Script" path="res://shot_fixture.gd" id="2"]

[node name="GhostReview" instance=ExtResource("1")]

[node name="ShotFixture" type="Node" parent="."]
script = ExtResource("2")
`);
}

if ((await ensureImport()).status) throw Error('Project import failed');
stage();
for (const [view, mark, ppm, tick] of shots) {
  if (marks.length && !marks.includes(mark)) continue;
  const base = join(scratch, `${mark}_${view}_${ppm}`);
  for (const ext of ['.json', '.png']) rmSync(base + ext, { force: true });
  const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
    '--disable-vsync', '--audio-driver', 'Dummy', '--fixed-fps', '60', '--quit-after', String(tick + 8),
    'res://shot.tscn', '--', '--ghost=kerf', '--ghost-look=spectral', '--take=move', '--clean', '--film-panel',
    '--view=' + view, '--ppm=' + ppm, '--shot-tick=' + tick, '--shot=' + base.replaceAll('\\', '/') + '.png'];
  const r = await runGodot(args, { cwd: scratch, name: 'kerf-review', headless: false, ensure: false,
    timeoutMs: 180000, stopOn: /SCRIPT ERROR|SHADER ERROR/, env: { ...process.env, KERF_REVIEW_MARK: mark } });
  writeFileSync(base + '.log', r.out);
  if (r.status !== 0 || !existsSync(base + '.png')) throw Error(`${describe(r)}: ${base}.log`);
  const meta = JSON.parse(readFileSync(base + '.json'));
  const expected = mark === 'guard' ? 'HOVER' : mark.toUpperCase();
  if (meta.pose !== expected || meta.tick !== tick || meta.ppm !== ppm) throw Error(JSON.stringify(meta));
  console.log(`${view} ${ppm} px/m: ${meta.pose} at tick ${tick}, ${describe(r)}`);
}
