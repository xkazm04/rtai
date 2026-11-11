// The live tree a long reel films (n16 kills-new FRICTION 15:15): a reel's after side with no --rev reads
// project/ as it stands when each film's Godot loads it, so a commit, a save or a new class not yet
// imported part-way through the reel lands in the films after it (a SCRIPT ERROR, or a "before/after" whose
// after side is two different trees). This stamps the tree before the reel and before each film, so the
// reel names the film where the tree moved, and the reel.json row records it. Never writes to the tree.
import { execFileSync } from 'node:child_process';
import { statSync } from 'node:fs';
import { join } from 'node:path';

const NAMED = { n: 10, t: 9, r: 13, a: 7, b: 8, f: 12, v: 11, '\\': 92, '"': 34 };

/** A porcelain path as git prints it: bare, or C-quoted (a space, a quote, and non-ASCII as octal UTF-8 bytes,
 *  `"project/\303\274.gd"`). Codex n16t-break-live-tree found the CRLF case; the octal case was found in review. */
export function unquote(text) {
  if (!/^".*"$/.test(text)) return text;
  const body = text.slice(1, -1);
  const bytes = [];
  for (let i = 0; i < body.length; i += 1) {
    if (body[i] !== '\\') { bytes.push(...Buffer.from(body[i], 'utf8')); continue; }
    const oct = /^[0-7]{3}/.exec(body.slice(i + 1));
    if (oct) { bytes.push(parseInt(oct[0], 8)); i += 3; continue; }
    bytes.push(NAMED[body[i + 1]] ?? body.charCodeAt(i + 1));
    i += 1;
  }
  return Buffer.from(bytes).toString('utf8');
}

/** The path a porcelain line names: the new name of a rename (`R  old -> new`, either side maybe quoted). */
export function porcelainPath(line) {
  const rest = line.slice(3);
  const arrow = /^(?:"(?:[^"\\]|\\.)*"|[^"].*?) -> (.*)$/.exec(rest);
  return unquote(arrow ? arrow[1] : rest);
}

const gitIn =(tree, ...args) => execFileSync('git', ['-C', tree, ...args], { encoding: 'utf8', windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });

/** {head, paths: {path: stamp}} of a tree's project/ (HEAD + every uncommitted path with its size and
 *  mtime), or null when it is not a git tree. A stamp is `gone` for a deleted path. */
export function treeState(tree, { git = gitIn, stat = statSync } = {}) {
  let head;
  let lines;
  try {
    head = git(tree, 'rev-parse', 'HEAD').trim();
    lines = git(tree, 'status', '--porcelain', '--untracked-files=all', '--', 'project').split(/\r?\n/).filter(Boolean);
  } catch { return null; }
  const paths = {};
  for (const line of lines) {
    const path = porcelainPath(line);
    try {
      const s = stat(join(tree, path));
      paths[path] = `${s.size}@${Math.round(s.mtimeMs)}`;
    } catch { paths[path] = 'gone'; }
  }
  return { head, paths };
}

/** What moved between two states, as short phrases ([] when nothing did, or a state is unknown). */
export function treeMoves(from, to) {
  if (!from || !to) return [];
  const moves = [];
  if (from.head !== to.head) moves.push(`HEAD ${from.head.slice(0, 9)} -> ${to.head.slice(0, 9)}`);
  const names = [...new Set([...Object.keys(from.paths), ...Object.keys(to.paths)])].sort();
  const edited = names.filter((p) => from.paths[p] !== to.paths[p]);
  if (edited.length) moves.push(`${edited.length} project/ path(s) changed (${edited.slice(0, 3).join(', ')}${edited.length > 3 ? ', ...' : ''})`);
  return moves;
}

/** The line a reel prints before a live-tree film whose tree moved since the reel began, or null. */
export function movedLine(label, from, to) {
  const moves = treeMoves(from, to);
  if (!moves.length) return null;
  return `kill_reel: the live tree moved since the reel began (${moves.join('; ')}): ${label} films the tree as it stands now, `
    + 'so this reel mixes trees; for a stable side commit and run with --rev=<commit>';
}

/** The line a reel prints once before its first film when its live side has uncommitted project/ paths. */
export function dirtyStartLine(state, films) {
  const n = state ? Object.keys(state.paths).length : 0;
  if (!n) return null;
  const some = Object.keys(state.paths).slice(0, 3).join(', ');
  return `kill_reel: the after side is this live tree with ${n} uncommitted project/ path(s) (${some}${n > 3 ? ', ...' : ''}); `
    + `each of the ${films} film(s) loads project/ as it stands at its start: an edit, commit or not-yet-imported class `
    + 'part-way lands in the films after it. To keep editing while it runs, commit and pass --rev=HEAD';
}
