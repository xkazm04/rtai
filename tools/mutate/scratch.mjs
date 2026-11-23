// An isolated HEAD snapshot for lanes that must keep mutation inside their own build/.
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, realpathSync, rmSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { copyRuntime } from './worktree.mjs';

export function createScratch(root) {
  let base = realpathSync.native(root);
  for (const part of ['build', 'mutate']) {
    base = join(base, part);
    if (!existsSync(base)) mkdirSync(base);
    if (realpathSync.native(base) !== base) throw new Error(`scratch parent is a link: ${base}`);
  }
  const path = mkdtempSync(join(base, 'scratch-'));
  const release = () => {
    if (dirname(path) !== base || realpathSync.native(path) !== path) throw new Error(`unsafe scratch: ${path}`);
    rmSync(path, { recursive: true, force: true });
  };
  try {
    const env = { ...process.env, GIT_INDEX_FILE: join(path, 'snapshot.index') };
    const git = (args, input) => execFileSync('git', args, { cwd: root, windowsHide: true, env, input, encoding: 'utf8' });
    const head = git(['rev-parse', 'HEAD']).trim();
    git(['read-tree', head]);
    const files = git(['ls-files', '-z', '--', 'tools', 'project', 'versions.toml']);
    git(['checkout-index', '-z', '--stdin', `--prefix=${path.replaceAll('\\', '/')}/`], files);
    copyRuntime(root, path);
    return { path, head, created: true, repaired: [], notes: [], release };
  } catch (error) {
    release();
    throw error;
  }
}
