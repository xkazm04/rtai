import { readFileSync } from 'node:fs';
import { isAbsolute, relative, resolve, sep } from 'node:path';

export function batchFile(directory, name) {
  if (typeof name !== 'string') return null;
  const file = resolve(directory, name);
  const local = relative(directory, file);
  return local === '..' || local.startsWith('..' + sep) || isAbsolute(local) ? null : file;
}

// The street prints the final clock after every termination, including a tick-cap exit.
export function streetLog(directory, row) {
  const file = batchFile(directory, row.engine_log);
  if (!file) return {};
  let log;
  try { log = readFileSync(file, 'utf8'); }
  catch (error) { if (error.code === 'ENOENT') return {}; throw error; }
  const clock = [...log.matchAll(/\[INFO\] gauntlet: tick (\d+), segment\b/g)].at(-1);
  const stalled = row.exit === 1 && log.includes('[ERROR] gauntlet: headless tick cap reached before run ended');
  return { ...(clock && { ticks: Number(clock[1]) }), ...(stalled && { outcome: 'stalled' }) };
}
