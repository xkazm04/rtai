import { git } from './tune_state.mjs';

// Resolve object IDs only. A branch, revision expression or tag could move or peel to a commit.
export function commitRevision(root, rev) {
  if (rev === undefined) return undefined;
  const error = '--rev must be an unambiguous commit SHA in this repository: ' + rev;
  if (!/^[0-9a-f]{4,64}$/i.test(rev)) throw new Error(error);
  const sha = git(root, 'rev-parse', '--disambiguate=' + rev.toLowerCase()).trim();
  if (!/^(?:[0-9a-f]{40}|[0-9a-f]{64})$/.test(sha) || git(root, 'cat-file', '-t', sha).trim() !== 'commit')
    throw new Error(error);
  return sha;
}
