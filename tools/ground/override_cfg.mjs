// Writes project/override.cfg for a take and hands back a restore: the file goes back to what it was
// (or is deleted). A take on the LIVE tree once left a 1920x1080 window override behind and the gate
// snapshot copied it (selftest red).
import { existsSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

export function writeOverride(tree, text) {
  const file = join(tree, 'project', 'override.cfg');
  const old = existsSync(file) ? readFileSync(file) : null;
  writeFileSync(file, text);
  return () => { if (old === null) rmSync(file, { force: true }); else writeFileSync(file, old); };
}

/** Runs `body(hold)`; whatever `hold.restore` is by then runs afterwards, error or not. */
export async function withRestore(body) {
  const hold = { restore: null };
  try { return await body(hold); } finally { hold.restore?.(); }
}
