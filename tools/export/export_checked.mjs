// Refuse release exports until the baked city passes its manifest check.
import { join, resolve } from 'node:path';
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

/** Check first, so a missing or invalid bake can never launch an export. */
export async function exportChecked({ out = DEFAULT_OUT, check = defaultCheck, run = defaultRun } = {}) {
  let result;
  try {
    result = await check();
  } catch (error) {
    return { ok: false, reason: `cannot verify baked city (${LIST}, ${CITY}): ${error?.message ?? String(error)}` };
  }
  if (result?.ok !== true) return { ok: false, reason: bakeReason(result) };
  const code = await run(exportArgs(out));
  return { ok: code === 0, code };
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
