// Refuse release exports until the baked city passes its manifest check.
import { mkdirSync, statSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { runGodot } from '../lib/godot.mjs';
import { checkBaked } from './check_baked.mjs';

const DEFAULT_OUT = '../build/export/windows/RTAI.exe';
const LIST = 'project/data/generated/city_chunks.sha256';
const CITY = 'project/data/generated/city';
const USAGE = `usage: node tools/export/export_checked.mjs [--out=${DEFAULT_OUT}]`;

export function exportArgs(out) {
  return ['--headless', '--path', 'project', '--export-release', 'windows-showcase', out];
}

function defaultCheck() {
  return checkBaked({ list: join(ROOT, LIST), city: join(ROOT, CITY) });
}

async function defaultRun(args) {
  // The shared launcher supplies the headless/path prefix itself.
  const result = await runGodot(args.slice(3), { name: 'export-checked' });
  if (result.out) process.stdout.write(result.out);
  return result.status;
}

function bakeReason(result) {
  const reasons = [];
  if (result?.reason) reasons.push(String(result.reason));
  if (result?.missing?.length) reasons.push(`missing chunks: ${result.missing.join(', ')}`);
  if (result?.mismatched?.length) {
    reasons.push(`mismatched chunks: ${result.mismatched.join(', ')}`);
  }
  return reasons.length ? reasons.join('; ')
    : `missing or invalid baked city: ${LIST} or ${CITY}; run the city bake`;
}

/** Where Godot writes `out`: it resolves a relative path against project/. */
export const outPath = (out, root = ROOT) => resolve(root, 'project', out);

/** Check first, so a missing or invalid bake can never launch an export. The output's folder is made
 *  only after the check passes: a fresh worktree has no build/export (hero n11 line 219). */
export async function exportChecked({ out = DEFAULT_OUT, check = defaultCheck, run = defaultRun, root = ROOT } = {}) {
  let result;
  try {
    result = await check();
  } catch (error) {
    return { ok: false, reason: `cannot verify baked city (${LIST}, ${CITY}): ${error?.message ?? String(error)}` };
  }
  if (result?.ok !== true) return { ok: false, reason: bakeReason(result) };
  const file = outPath(out, root);
  mkdirSync(dirname(file), { recursive: true });
  const started = Date.now();
  const code = await run(exportArgs(out));
  if (code !== 0) return { ok: false, code };
  return { ...written(file, started), code };
}

/** Exit 0 is not the evidence: the exe must exist, be non-empty and be written by this run
 *  (mtime from its start, less FS_SLACK_MS for a coarse file clock). */
export const FS_SLACK_MS = 2000;
export function written(file, started, stat = statSync) {
  let st;
  try { st = stat(file); } catch { return { ok: false, reason: `Godot exited 0 but wrote no ${file}` }; }
  if (!st.isFile() || st.size === 0) return { ok: false, reason: `Godot exited 0 but ${file} is empty or not a file` };
  if (st.mtimeMs < started - FS_SLACK_MS) {
    return { ok: false, reason: `Godot exited 0 but did not rewrite ${file} (last written ${new Date(st.mtimeMs).toISOString()})` };
  }
  return { ok: true, bytes: st.size };
}

async function main(argv) {
  if (argv.length === 1 && argv[0] === '--help') {
    console.log(USAGE);
    return 0;
  }
  if (argv.length > 1 || (argv.length === 1 && !/^--out=.+$/.test(argv[0]))) {
    console.error(`export_checked: invalid arguments\n${USAGE}`);
    return 1;
  }
  try {
    const result = await exportChecked({ out: argv[0]?.slice(6) ?? DEFAULT_OUT });
    if (!result.ok) console.error(`export_checked: ${result.reason ?? `Godot exited ${result.code}`}`);
    return result.ok ? 0 : 1;
  } catch (error) {
    console.error(`export_checked: ${error?.message ?? String(error)}`);
    return 1;
  }
}

if (process.argv[1] && fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  process.exitCode = await main(process.argv.slice(2));
}
