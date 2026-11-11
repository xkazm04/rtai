// AGENTS rule 8: a .gd is committed with its .gd.uid. Godot writes a missing .uid on its next run,
// so a commit without one dirties every later checkout mid-run: the gate's snapshot then fails
// each evidence kind INVALID (n15 tools, 6b9d2a900 shipped dev/sim/car_route_trails.gd alone).
// Reads the index (`git ls-files`), so the pre-commit hook judges what is being committed.
import { execFileSync } from 'node:child_process';
import { ROOT } from '../lib/repo.mjs';

export const NAME = 'uid-files';

/** Issues for every own project .gd (addons are third-party) whose .gd.uid is not in `files`. */
export function missingUids(files) {
  const have = new Set(files);
  return files
    .filter((f) => f.startsWith('project/') && !f.startsWith('project/addons/') && f.endsWith('.gd') && !have.has(`${f}.uid`))
    .map((f) => `${f}: its .uid is not in the index: git add ${f}.uid (Godot writes it on the next run or --import)`);
}

/** The index's paths, or null outside a git tree (a plain copy has no index to judge). */
export function indexFiles(cwd = ROOT) {
  try {
    return execFileSync('git', ['ls-files', '-z', '--', 'project'], { cwd, maxBuffer: 1 << 28, stdio: ['ignore', 'pipe', 'ignore'] })
      .toString('utf8').split('\0').filter(Boolean);
  } catch { return null; }
}

export function uidCheck(list = indexFiles) {
  const files = list();
  if (files === null) return { name: NAME, ok: true, issues: [], warnings: ['not a git tree: uid-files not judged'] };
  const issues = missingUids(files);
  return { name: NAME, ok: !issues.length, issues };
}
