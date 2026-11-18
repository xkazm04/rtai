#!/usr/bin/env node
import { writeFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import { parseArgs, pickTests, UsageError, withMutationFile } from './mutate.mjs';
import { maskLines } from './operators.mjs';
import { baseline, judgeMutant, oracleRunners } from './oracles.mjs';
import { restoreFile } from './worktree.mjs';

const controls = {
  hang: { statements: ['while true: pass'], expected: 'timeout/timeout' },
  crash: { statements: ['var _crash: Array[int] = []', '_crash[1] = 0'], expected: 'killed/crash' },
  parse: { statements: ['var = '], expected: 'invalid/parse' },
  clean: { statements: [], expected: 'survived/ok' },
};

/** Insert immediately below the signature, preserving original bytes and the local line ending. */
export function plantControl(source, name) {
  if (!Object.hasOwn(controls, name)) throw new UsageError(`unknown control: ${name}`);
  if (name === 'clean') return source;
  const lines = source.split('\n');
  const code = maskLines(lines);
  let inSignature = false;
  for (const [i, line] of code.entries()) {
    if (/^(?:static\s+)?func\s+\w+\s*\(/.test(line)) inSignature = true;
    else if (/^[^\s)]/.test(line)) inSignature = false;
    if (!inSignature || !/\)\s*(?:->[\w.\[\], \t]+)?\s*:\s*$/.test(line)) continue;
    inSignature = false;
    let body = i + 1;
    while (body < code.length && !code[body].trim()) body++;
    if (body === code.length || !/^\t\S/.test(code[body])) continue;
    const end = lines[i].endsWith('\r') ? '\r' : '';
    lines.splice(i + 1, 0, ...controls[name].statements.map((statement) => `\t${statement}${end}`));
    return lines.join('\n');
  }
  throw new UsageError('no func with a one-tab-indented body found');
}

export function judgeControl(name, decision, wallMs, capMs) {
  const { expected } = controls[name];
  const got = decision.infra ? 'infra/error' : `${decision.verdict}/${decision.via}`;
  const pass = got === expected && (name !== 'hang' || wallMs <= capMs + 15000);
  return { expected, got, pass };
}

async function main(argv) {
  for (const arg of argv) {
    if (!/^--(?:file|oracle|tests|timeout)=/.test(arg)) throw new UsageError(`unknown control argument: ${arg}`);
  }
  const o = parseArgs(argv);
  return withMutationFile(o, async ({ wt, target, original, saveOriginal, env }) => {
    const source = original.toString('utf8');
    const plants = Object.keys(controls).map((name) => [name, plantControl(source, name)]);
    const tests = o.oracles.includes('tests') ? await pickTests(o, wt) : [];
    const runners = oracleRunners(wt, tests, env, true);
    const { timeoutMs } = await baseline({ names: o.oracles, runners, wt, timeoutS: o.timeoutS,
      explicit: true, note: console.error });
    saveOriginal();
    let failed = false;
    for (const [name, planted] of plants) {
      let decision;
      let wallMs;
      try {
        if (name !== 'clean') writeFileSync(target, planted);
        const start = performance.now();
        decision = await judgeMutant(o.oracles, runners, timeoutMs);
        wallMs = performance.now() - start;
      } finally { restoreFile(target, original); }
      const { expected, got, pass } = judgeControl(name, decision, wallMs, timeoutMs);
      console.log(`control ${name}: expected ${expected} got ${got} in ${(wallMs / 1000).toFixed(2)} s  ${pass ? 'PASS' : 'FAIL'}`);
      if (decision.infra) throw new Error(`${name}: ${decision.infra}`);
      if (!pass) failed = true;
    }
    return failed ? 1 : 0;
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { process.exitCode = await main(process.argv.slice(2)); } catch (err) {
    console.error(`controls: ${err.message}`);
    process.exitCode = 2;
  }
}
