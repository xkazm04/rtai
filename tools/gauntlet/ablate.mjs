#!/usr/bin/env node
import { execFileSync, spawnSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { mkdirSync, readFileSync, realpathSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { isAbsolute, join, relative, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, readJson } from '../lib/repo.mjs';
import { assertSafe, ensureWorktree, removeWorktree } from '../mutate/worktree.mjs';
import { seedImportCache } from './prepare_worktree.mjs';
import { median } from '../perf/paired.mjs';
import { editScalar, parseAblation } from './ablate_args.mjs';

export function applyEdit(root, tree, edit) {
  const safe = assertSafe(tree, { root, requireMarker: true });
  const target = realpathSync(join(safe, edit.file));
  const rel = relative(safe, target);
  if (isAbsolute(rel) || !rel || rel === '..' || rel.startsWith('..' + sep))
    throw new Error('edit escapes ablation worktree: ' + edit.file);
  execFileSync('git', ['--literal-pathspecs', 'ls-files', '--error-unmatch', '--', rel], { cwd: tree, windowsHide: true });
  const table = JSON.parse(readFileSync(target, 'utf8'));
  const before = editScalar(table, edit);
  writeFileSync(target, JSON.stringify(table, null, 2) + '\n');
  return { ...edit, before };
}

export function summarize(batch) {
  const deaths = batch.results.filter((run) => run.death && run.death.by !== 'timeout');
  return { attempted: batch.runs.length, accepted: batch.results.length, deaths: deaths.length,
    median_wave_reached: batch.results.length ? median(batch.results.map((r) => r.wave_reached)) : null,
    median_death_wave: deaths.length ? median(deaths.map((r) => r.death.wave)) : null,
    capped_alive: batch.runs.filter((r) => r.ok && r.outcome === 'capped').length,
    wave_timeouts: batch.results.filter((r) => r.death?.by === 'timeout').length };
}

export function runAblation(options) {
  const path = join(tmpdir(), 'gtai-ablate-' + randomUUID().slice(0, 12));
  const wt = ensureWorktree({ root: ROOT, path });
  try {
    seedImportCache(ROOT, path);
    const edits = options.edits.map((edit) => applyEdit(ROOT, path, edit));
    const manifest = join(options.out, 'ablation.json');
    const batchPath = join(options.out, 'batch.json');
    const previous = statSync(batchPath, { throwIfNoEntry: false, bigint: true });
    const child = spawnSync(process.execPath, [join(path, 'tools/gauntlet/batch.mjs'), ...options.batchArgs],
      { cwd: path, windowsHide: true, stdio: 'inherit' });
    if (child.error) throw child.error;
    const current = statSync(batchPath, { throwIfNoEntry: false, bigint: true });
    const fresh = current && (!previous || previous.ino !== current.ino || previous.mtimeNs !== current.mtimeNs);
    const batch = fresh ? readJson(batchPath) : null;
    mkdirSync(options.out, { recursive: true });
    const receipt = { schema: 'gtai.gauntlet-ablation/1', name: options.name, head: wt.head,
      edits, pick_filter: options.pickFilter, batch_args: options.batchArgs, batch_exit: child.status,
      summary: batch ? summarize(batch) : null };
    writeFileSync(manifest, JSON.stringify(receipt, null, 2) + '\n');
    if (child.status !== 0 || !batch) throw new Error('batch failed: ' + (child.signal ?? child.status));
    return receipt;
  } finally {
    wt.release();
    removeWorktree({ root: ROOT, path });
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { console.log(JSON.stringify(runAblation(parseAblation(process.argv.slice(2))).summary)); }
  catch (error) { console.error('ablate: ' + error.message); process.exitCode = 1; }
}
