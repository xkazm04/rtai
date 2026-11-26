#!/usr/bin/env node
// n31-19: the "what blocks" rule stills, yard (prologue_yard/yard_stills, gate/mid/harbor/west at 32 and
// 64 px/m) and gauntlet street (gauntlet_stills at 64 px/m, one still per street template), for the
// live tree or a snapshot of any commit (tools/lib/snapshot.mjs; the 64 px/m wrapper scene is copied in).
//   node tools/ground/props/rule_stills.mjs --rev=<commit|live> --out=<abs dir> [--only=yard|gauntlet]
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { setTimeout as sleep } from 'node:timers/promises';
import { runGodot, SCRIPT_ERROR } from '../../lib/godot.mjs';
import { ROOT } from '../../lib/repo.mjs';
import { ensureSnapshot } from '../../lib/snapshot.mjs';

export const WRAPPER = 'gauntlet_stills_64.tscn';
const TAG = 'n31-19';
const WINDOW = ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080'];

/** The two runs: [name, godot args after `--path project`, extra env]. */
export function runs(out, only = '') {
  const all = [
    ['yard', [...WINDOW, 'res://dev/prologue_yard/yard_stills.tscn', '--', `--out=${join(out, 'yard')}`, '--tick=300'], {}],
    ['gauntlet', [...WINDOW, `res://dev/ground_n31/${WRAPPER}`], { GTAI_GAUNTLET_STILLS: join(out, 'gauntlet') }],
  ];
  return all.filter(([name]) => !only || name === only);
}

/** {rev, out, only} from `--k=v` arguments, or {error}. */
export function parse(argv) {
  const f = {};
  for (const a of argv) {
    const m = /^--(rev|out|only)=(.+)$/.exec(a);
    if (!m) return { error: `rule_stills: bad argument ${a}` };
    f[m[1]] = m[2];
  }
  if (!f.rev || !f.out) return { error: 'rule_stills: --rev= and --out= are required' };
  if (f.only && !['yard', 'gauntlet'].includes(f.only)) return { error: 'rule_stills: --only=yard|gauntlet' };
  return { f };
}

async function takeLock(waitS = 900) {
  const file = join(ROOT, 'build', 'n31-godot.lock');
  mkdirSync(dirname(file), { recursive: true });
  const mine = `${TAG} ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`;
  for (let waited = 0; ; waited += 30) {
    try { writeFileSync(file, mine, { flag: 'wx' }); break; } catch { /* held */ }
    if (waited >= waitS) throw new Error('rule_stills: lock still held');
    console.error(`rule_stills: lock held (${existsSync(file) ? readFileSync(file, 'utf8').trim() : '?'}), waiting 30 s`);
    await sleep(30_000);
  }
  return () => { if (existsSync(file) && readFileSync(file, 'utf8') === mine) rmSync(file, { force: true }); };
}

export async function main(argv) {
  const p = parse(argv);
  if (p.error) { console.error(p.error); return 2; }
  const out = resolve(p.f.out);
  let tree = ROOT;
  if (p.f.rev !== 'live') {
    tree = ensureSnapshot({ root: ROOT, rev: p.f.rev, kind: 'film' }).path;
    mkdirSync(join(tree, 'project', 'dev', 'ground_n31'), { recursive: true });
    copyFileSync(join(ROOT, 'project', 'dev', 'ground_n31', WRAPPER), join(tree, 'project', 'dev', 'ground_n31', WRAPPER));
  }
  let failed = 0;
  for (const [name, args, env] of runs(out, p.f.only)) {
    mkdirSync(join(out, name), { recursive: true });
    const release = await takeLock();
    let r;
    try {
      r = await runGodot(args, { headless: false, cwd: tree, timeoutMs: 600_000, stopOn: SCRIPT_ERROR, name: `rule-${name}`, env: { ...process.env, ...env } });
    } finally { release(); }
    writeFileSync(join(out, `${name}.log`), r.out ?? '');
    const bad = r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out ?? '');
    console.log(`rule_stills: ${name} ${bad ? 'FAILED' : 'ok'} exit ${r.status} -> ${join(out, name)}`);
    if (bad) failed += 1;
  }
  return failed ? 1 : 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) process.exit(await main(process.argv.slice(2)));
