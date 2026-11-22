import { lstatSync, realpathSync } from 'node:fs';
import { basename, dirname, isAbsolute, join, relative, resolve, sep } from 'node:path';

// Resolve existing ancestors too: a new directory below a junction can be outside its apparent root.
export function physical(path) {
  const full = resolve(path);
  if (lstatSync(full, { throwIfNoEntry: false })) return realpathSync(full);
  if (dirname(full) === full) throw new Error('missing path root: ' + full);
  return join(physical(dirname(full)), basename(full));
}

function within(base, path) {
  const rel = relative(base, path);
  return rel && rel !== '..' && !rel.startsWith('..' + sep) && !isAbsolute(rel);
}

export function lanePath(root, path, under) {
  if (!path || !isAbsolute(path) || !within(join(root, under), path)
    || !within(join(realpathSync(root), under), physical(path)))
    throw new Error('expected an absolute path under lane ' + under + ': ' + path);
  return resolve(path);
}
