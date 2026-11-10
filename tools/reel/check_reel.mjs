// Judge completed director chapters; chapter-start messages are deliberately ignored.
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const USAGE = 'usage: node tools/reel/check_reel.mjs <log> [--expect=19]';
export const RESULT = /^\[INFO\] showcase: director chapter (.+?): (\d+)\/(\d+) down\s*$/;
const validExpect = (expect) => Number.isSafeInteger(expect) && expect >= 0;

/** Counts are per result/error line. `fullyDown` counts positive N/N results. */
export function parseReel(text, { expect = 19 } = {}) {
  if (!validExpect(expect)) throw new RangeError('expect must be a nonnegative safe integer');
  let chapters = 0;
  let fullyDown = 0;
  let scriptErrors = 0;
  let noCarry = 0;
  const problems = [];
  for (const [index, line] of text.split(/\r?\n/).entries()) {
    const match = RESULT.exec(line);
    if (match) {
      chapters += 1;
      const [, name, down, total] = match;
      if (BigInt(down) === BigInt(total) && BigInt(total) > 0n) fullyDown += 1;
      else problems.push(`chapter ${name}: ${down}/${total} down; expected positive N/N down`);
    }
    if (line.includes('SCRIPT ERROR')) {
      scriptErrors += 1;
      problems.push(`line ${index + 1}: ${line.trim()}`);
    }
    if (line.includes('no carry')) {
      noCarry += 1;
      problems.push(`line ${index + 1}: ${line.trim()}`);
    }
  }
  if (chapters !== expect) problems.push(`reel: expected ${expect} chapters, found ${chapters}`);
  return { chapters, fullyDown, scriptErrors, noCarry, ok: problems.length === 0, problems };
}

function main(argv) {
  if (argv.length === 1 && argv[0] === '--help') {
    console.log(USAGE);
    return 0;
  }
  let log;
  let expect = 19;
  let seenExpect = false;
  for (const arg of argv) {
    if (arg.startsWith('--expect=') && !seenExpect && /^\d+$/.test(arg.slice(9))) {
      expect = Number(arg.slice(9));
      seenExpect = true;
    } else if (!arg.startsWith('-') && log === undefined) log = arg;
    else {
      console.error(`check_reel: unexpected argument ${arg}\n${USAGE}`);
      return 2;
    }
  }
  if (log === undefined || !validExpect(expect)) {
    console.error(`check_reel: provide a log and a nonnegative safe integer expectation\n${USAGE}`);
    return 2;
  }
  let text;
  try {
    text = readFileSync(log, 'utf8');
  } catch (error) {
    console.error(`check_reel: cannot read ${log}: ${error.message}`);
    return 2;
  }
  const result = parseReel(text, { expect });
  for (const problem of result.problems) console.log(problem);
  return result.ok ? 0 : 1;
}

if (process.argv[1] && fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  process.exitCode = main(process.argv.slice(2));
}
