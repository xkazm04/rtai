#!/usr/bin/env node
// Repeat one scenario and group its first errors. Uses Node builtins only.
import { spawn } from 'node:child_process';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const USAGE = 'usage: node tools/tests/repeat_scenario.mjs --select=<scenario> [--n=10]';
const validCount = (n) => Number.isSafeInteger(n) && n >= 1;

/** Return the message on the first error line, or null when none exists. */
export function firstError(text) {
  const match = /^(?:ERROR:|SCRIPT ERROR:)([^\r\n]*)/m.exec(text);
  return match ? match[1].trim() : null;
}

/** Run sequentially, grouping failed runs by their first error (ties keep first-seen order). */
export async function repeat({ n, run, stopOnFail = false }) {
  if (!validCount(n)) throw new RangeError('n must be a positive safe integer');
  const result = { runs: 0, passed: 0, failed: 0, errors: [] };
  const errors = new Map();
  for (let i = 0; i < n; i += 1) {
    const { code, out } = await run();
    const error = firstError(out);
    result.runs += 1;
    if (code === 0 && error === null) {
      result.passed += 1;
      continue;
    }
    result.failed += 1;
    const label = error ?? `exit code ${code}`;
    errors.set(label, (errors.get(label) ?? 0) + 1);
    if (stopOnFail) break;
  }
  result.errors = [...errors].map(([error, count]) => ({ error, count }))
    .sort((a, b) => b.count - a.count);
  return result;
}

function runScenario(select) {
  return new Promise((done) => {
    const child = spawn(process.execPath, ['tools/tests/run_scenarios.mjs', `--select=${select}`], {
      cwd: ROOT,
      stdio: ['ignore', 'pipe', 'pipe'],
      windowsHide: true,
    });
    let out = '';
    child.stdout.setEncoding('utf8');
    child.stderr.setEncoding('utf8');
    child.stdout.on('data', (text) => { out += text; });
    child.stderr.on('data', (text) => { out += text; });
    child.on('error', (error) => { out += `\nERROR: ${error.message}\n`; });
    child.on('close', (code) => { done({ code: code ?? -1, out }); });
  });
}

async function main(argv) {
  if (argv.length === 1 && argv[0] === '--help') {
    console.log(USAGE);
    return 0;
  }
  let select;
  let n = 10;
  let seenN = false;
  for (const arg of argv) {
    if (arg.startsWith('--select=') && select === undefined && arg.slice(9).trim()) {
      select = arg.slice(9);
    } else if (arg.startsWith('--n=') && !seenN && /^\d+$/.test(arg.slice(4))) {
      n = Number(arg.slice(4));
      seenN = true;
    } else {
      console.error(`repeat_scenario: unexpected or malformed argument ${arg}\n${USAGE}`);
      return 2;
    }
  }
  if (select === undefined || !validCount(n)) {
    console.error(`repeat_scenario: provide a scenario and a positive safe integer n\n${USAGE}`);
    return 2;
  }
  const result = await repeat({ n, run: () => runScenario(select) });
  console.log(JSON.stringify(result, null, 2));
  return result.failed === 0 ? 0 : 1;
}

if (process.argv[1] && fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  process.exitCode = await main(process.argv.slice(2));
}
