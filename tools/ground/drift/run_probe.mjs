#!/usr/bin/env node
// n31-07: launches a drift probe scene windowed (d3d12, secondary screen, 1920x1080, --fixed-fps 60)
// through runGodot, holding the lane's Godot mutex build/n31-godot.lock (create-exclusive).
//   node tools/ground/drift/run_probe.mjs <res://scene.tscn> <out abs dir> [--timeout=<s>] [-- user flags]
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { setTimeout as sleep } from 'node:timers/promises';
import { runGodot, SCRIPT_ERROR } from '../../lib/godot.mjs';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const TAG = 'n31-07';

/** The engine + user argv for one probe run. */
export function probeArgs(scene, out, user) {
  return ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', '60',
    scene, '--', ...user, `--result=${out}`];
}

async function takeLock(waitS = 900) {
  const file = join(ROOT, 'build', 'n31-godot.lock');
  mkdirSync(dirname(file), { recursive: true });
  const mine = `${TAG} ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`;
  for (let waited = 0; ; waited += 30) {
    try { writeFileSync(file, mine, { flag: 'wx' }); break; } catch { /* held */ }
    if (waited >= waitS) throw new Error(`run_probe: lock still held after ${waitS} s`);
    console.error(`run_probe: lock held (${existsSync(file) ? readFileSync(file, 'utf8').trim() : '?'}), waiting 30 s`);
    await sleep(30_000);
  }
  return () => { if (existsSync(file) && readFileSync(file, 'utf8') === mine) rmSync(file, { force: true }); };
}

async function main(argv) {
  const cut = argv.indexOf('--');
  const own = cut < 0 ? argv : argv.slice(0, cut);
  const user = cut < 0 ? [] : argv.slice(cut + 1);
  const [scene, out] = own.filter((a) => !a.startsWith('--'));
  const timeout = Number((own.find((a) => a.startsWith('--timeout=')) ?? '--timeout=900').split('=')[1]);
  if (!scene || !out) { console.error('usage: run_probe.mjs <res://scene> <out abs dir> [--timeout=<s>] [-- flags]'); return 2; }
  mkdirSync(out, { recursive: true });
  const release = await takeLock();
  let r;
  try {
    r = await runGodot(probeArgs(scene, out, user), { headless: false, timeoutMs: timeout * 1000, stopOn: SCRIPT_ERROR, name: 'drift-probe' });
  } finally {
    release();
  }
  writeFileSync(join(out, 'godot.log'), r.out ?? '');
  const errors = (r.out?.match(/SCRIPT ERROR/g) ?? []).length;
  console.log(`run_probe: exit ${r.status}; SCRIPT ERROR ${errors}; timed out ${r.timedOut ? 'yes' : 'no'}; log ${join(out, 'godot.log')}`);
  return r.status === 0 && errors === 0 ? 0 : 1;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
