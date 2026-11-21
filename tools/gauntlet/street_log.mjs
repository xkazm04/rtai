import { readFileSync } from 'node:fs';
import { isAbsolute, relative, resolve, sep } from 'node:path';

// The street prints the final clock after every termination, including a tick-cap exit.
export function streetLog(directory, row) {
  if (typeof row.engine_log !== 'string') return {};
  const file = resolve(directory, row.engine_log);
  const local = relative(directory, file);
  if (local === '..' || local.startsWith('..' + sep) || isAbsolute(local)) return {};
  let log;
  try { log = readFileSync(file, 'utf8'); }
  catch (error) { if (error.code === 'ENOENT') return {}; throw error; }
  const clock = [...log.matchAll(/\[INFO\] gauntlet: tick (\d+), segment\b/g)].at(-1);
  const stalled = row.exit === 1 && log.includes('[ERROR] gauntlet: headless tick cap reached before run ended');
  return { ...(clock && { ticks: Number(clock[1]) }), ...(stalled && { outcome: 'stalled' }) };
}
