// Run and judge director reels. Uses Node builtins only.
import { appendFileSync } from 'node:fs';
import { mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runGodot } from '../lib/godot.mjs';
import { RESULT, parseReel } from './check_reel.mjs';

const DEFAULT_VIEWS = ['top', 'tilt70', 'combo'];
const USAGE = 'usage: node tools/reel/run_reels.mjs --out=<dir> '
  + '[--views=top,tilt70,combo] [--expect=19]';

export function reelArgs(view, loadout = 'pistol') {
  return ['--headless', '--path', 'project', '--quit-after', '40000',
    'res://dev/arena/arena.tscn', '--', '--rigs', '--bot=reel', '--reel=director',
    `--view=${view}`, `--loadout=${loadout}`];
}

const REEL_TIMEOUT_MS = 20 * 60 * 1000;

/** A completed chapter line: check_reel.mjs's own pattern, so live progress counts what the judge
 *  counts (Codex's tester, n11t-break-reels: an unanchored copy reported quoted lines). */
export const CHAPTER = RESULT;

/** A progress printer that throws must not stop a gate or change its verdict. */
const guarded = (progress) => (line) => { try { progress(line); } catch { /* viewer's fault only */ } };

/** Every line lands in the log as it arrives (a killed wrapper keeps the partial log, combat n11
 *  line 132), and each finished chapter is reported live; the whole output replaces it at the end. */
export function lineSink(view, logPath, progress) {
  let chapters = 0;
  return (line) => {
    appendFileSync(logPath, `${line}\n`);
    const m = CHAPTER.exec(line);
    if (m) progress(`run_reels: ${view} chapter ${++chapters} ${m[1]} ${m[2]}/${m[3]} down`);
  };
}

async function runReel(view, logPath, progress = () => {}) {
  const onLine = lineSink(view, logPath, progress);
  // The launcher adds its own headless and path prefix.
  const result = await runGodot(reelArgs(view).slice(3), { name: 'reel', timeoutMs: REEL_TIMEOUT_MS, onLine });
  await writeFile(logPath, result.out);
  return result.status;
}

/** Each view is independent, including launch failures and absent/unreadable logs. */
export async function runReels({ views = DEFAULT_VIEWS, expect = 19, outDir, run = runReel, progress: raw = () => {} }) {
  const progress = guarded(raw);
  // Validate once, before launching any views.
  parseReel('', { expect });
  const directory = resolve(outDir);
  const results = [];
  for (const [index, view] of views.entries()) {
    const name = String(view).replace(/[^a-zA-Z0-9_-]/g, '_');
    const log = join(directory, `${index + 1}-${name}.log`);
    const problems = [];
    const started = Date.now();
    let code = null;
    try {
      await mkdir(directory, { recursive: true });
      // Never judge a previous run's log when this run fails to produce one.
      await rm(log, { force: true });
      code = await run(view, log, progress);
      if (code !== 0) problems.push(`run exited with code ${code}`);
    } catch (error) {
      problems.push(`run failed: ${error.message}`);
    }
    try {
      const judged = parseReel(await readFile(log, 'utf8'), { expect });
      problems.push(...judged.problems);
    } catch (error) {
      problems.push(`cannot read log ${log}: ${error.message}`);
    }
    results.push({ view, code, ok: problems.length === 0, problems, log });
    const secs = ((Date.now() - started) / 1000).toFixed(0);
    progress(`run_reels: [${index + 1}/${views.length}] ${view} ${problems.length ? 'FAIL' : 'OK'}, ${secs} s; log ${log}`);
  }
  return { ok: results.length > 0 && results.every((result) => result.ok), views: results };
}

async function main(argv) {
  if (argv.length === 1 && argv[0] === '--help') {
    console.log(USAGE);
    return 0;
  }
  const options = {};
  for (const arg of argv) {
    const match = /^--(out|views|expect)=(.+)$/.exec(arg);
    if (!match || Object.hasOwn(options, match[1])) {
      console.error(`run_reels: invalid argument ${arg}\n${USAGE}`);
      return 2;
    }
    options[match[1]] = match[2];
  }
  const expect = options.expect === undefined ? 19 : Number(options.expect);
  const views = options.views === undefined ? DEFAULT_VIEWS : options.views.split(',');
  if (!options.out || (options.expect !== undefined && !/^\d+$/.test(options.expect))
    || !Number.isSafeInteger(expect) || expect < 0
    || views.some((view) => !/^[a-zA-Z0-9_-]+$/.test(view))) {
    console.error(`run_reels: provide an output directory, view names and a nonnegative safe integer expectation\n${USAGE}`);
    return 2;
  }
  const result = await runReels({ views, expect, outDir: options.out, progress: (line) => console.error(line) });
  for (const view of result.views) {
    console.log(`${view.view}: ${view.ok ? 'OK' : 'FAIL'}; code ${view.code}; log ${view.log}`);
    for (const problem of view.problems) console.log(`  ${problem}`);
  }
  return result.ok ? 0 : 1;
}

if (process.argv[1] && fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  process.exitCode = await main(process.argv.slice(2));
}
