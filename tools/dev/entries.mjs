// Resolves a dev entry (a scene or an -s script under project/dev) into the Godot args that run it:
// the scene path (or `-s <script>`) before `--`, the entry's own flags after it, and --fixed-fps 60
// --quit-after <n> when the entry declares `const RUN_TICKS: int = <n>` and the caller gave none, and
// --fixed-fps <n> alone when it declares `const FIXED_FPS: int = <n>` (a film scene that must grab every
// tick: under contention real-time frames skip ticks, hero n11 line 255).
// Flags are checked only against a list the entry's script ALREADY declares (`const KNOWN_FLAGS` or
// `const KNOWN`: PackedStringArray), read statically at call time. There is no central flag list:
// an entry that declares none is launched unchecked and says so ("flags unchecked: no declared spec").
import { existsSync, readFileSync } from 'node:fs';
import { basename, dirname, extname, isAbsolute, join, relative, resolve as resolvePath, sep } from 'node:path';
import { PROJECT, walk } from '../lib/repo.mjs';

export const NO_SPEC = 'flags unchecked: no declared spec';
const SPEC = /^const\s+(KNOWN_FLAGS|KNOWN)\s*:\s*PackedStringArray\s*=\s*\[([\s\S]*?)\]/m;
const RUN_TICKS = /^const\s+RUN_TICKS\s*:\s*int\s*=\s*(\d+)\s*(?:#.*)?$/m;
/** Engine options the runner places before the scene; everything else is the entry's. */
const ENGINE = /^--(quit-after|fixed-fps)(?:=(.*))?$/;
const RUN_FPS = '60';
const FIXED_FPS = /^const[ \t]+FIXED_FPS[ \t]*:[ \t]*int[ \t]*=[ \t]*(\d+)[ \t]*(?:#.*)?$/m; // one line only

/** The declared `const FIXED_FPS: int = <literal>` as a string, or null. */
export function readFixedFps(text) {
  const m = FIXED_FPS.exec(text);
  return m && Number(m[1]) > 0 ? m[1] : null;
}

/** {name, flags} from the script's own declared list, or null when it declares none. */
export function readSpec(text) {
  const m = SPEC.exec(text);
  if (!m) return null;
  const body = m[2].split('\n').map((l) => l.replace(/#.*$/, '')).join('\n');
  return { name: m[1], flags: [...body.matchAll(/"([^"]*)"/g)].map((x) => x[1]) };
}

/** The declared `const RUN_TICKS: int = <literal>`, or null (absent or an expression). */
export function readRunTicks(text) {
  const m = RUN_TICKS.exec(text);
  return m ? Number(m[1]) : null;
}

function distance(a, b) {
  const d = Array.from({ length: a.length + 1 }, (_, i) => [i, ...Array(b.length).fill(0)]);
  for (let j = 1; j <= b.length; j++) d[0][j] = j;
  for (let i = 1; i <= a.length; i++) {
    for (let j = 1; j <= b.length; j++) {
      d[i][j] = Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
    }
  }
  return d[a.length][b.length];
}

/** The nearest declared flag within two edits, or null. */
export function didYouMean(flag, known) {
  let best = null;
  let bestD = 3;
  for (const k of known) {
    const dist = distance(flag, k);
    if (dist < bestD) [best, bestD] = [k, dist];
  }
  return best;
}

/** {engine: {quitAfter, fixedFps}, user: [...]}: a `--` ends the runner's part, the rest is verbatim. */
export function splitArgs(args) {
  const engine = {};
  const user = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--') { user.push(...args.slice(i + 1)); break; }
    const m = ENGINE.exec(args[i]);
    if (!m) { user.push(args[i]); continue; }
    engine[m[1] === 'quit-after' ? 'quitAfter' : 'fixedFps'] = m[2] ?? args[++i];
  }
  return { engine, user };
}

const toRes = (abs, projectDir) => `res://${relative(projectDir, abs).split(sep).join('/')}`;
const inside = (abs, dir) => !relative(dir, abs).startsWith('..') && !isAbsolute(relative(dir, abs));

/** The file a name or path points at: {abs} or {error}. */
function locate(entry, projectDir) {
  if (entry.startsWith('res://')) return { abs: join(projectDir, entry.slice(6)) };
  if (entry.includes('/') || entry.includes('\\') || extname(entry)) {
    const tries = [isAbsolute(entry) ? entry : null, join(projectDir, entry), resolvePath(entry)].filter(Boolean);
    const abs = tries.find((p) => existsSync(p) && inside(p, projectDir));
    return abs ? { abs } : { error: `no dev entry at ${entry} (inside ${projectDir})` };
  }
  const hits = walk(join(projectDir, 'dev'), (n) => n === `${entry}.tscn` || n === `${entry}.gd`);
  const scenes = hits.filter((h) => h.endsWith('.tscn'));
  const pick = scenes.length ? scenes : hits;
  if (!pick.length) return { error: `no dev entry named ${entry} (searched ${join(projectDir, 'dev')} for ${entry}.tscn/.gd)` };
  if (pick.length > 1) return { error: `${entry} is ambiguous: ${pick.map((p) => toRes(p, projectDir)).join(', ')}` };
  return { abs: pick[0] };
}

/** The root node's script of a .tscn, as an absolute path (or null). */
function sceneScript(abs, projectDir) {
  const text = readFileSync(abs, 'utf8').replace(/\r\n/g, '\n');
  const root = /^\[node (?![^\]]*\bparent=)[^\]]*\]\n((?:(?!\[)[^\n]*\n?)*)/m.exec(text)?.[1] ?? '';
  const id = /^script\s*=\s*ExtResource\("([^"]+)"\)/m.exec(root)?.[1];
  const ext = id && [...text.matchAll(/^\[ext_resource [^\]]*\]/gm)].map((m) => m[0])
    .find((l) => l.includes(`id="${id}"`));
  const path = ext && /path="res:\/\/([^"]+)"/.exec(ext)?.[1];
  return path ? join(projectDir, path) : null;
}

/** {kind, file, script} for a located file: a .gd that is not a SceneTree/MainLoop falls back to its .tscn. */
function classify(abs, projectDir) {
  if (abs.endsWith('.tscn')) return { kind: 'scene', file: abs, script: sceneScript(abs, projectDir) };
  const text = readFileSync(abs, 'utf8');
  if (/^extends\s+(SceneTree|MainLoop)\b/m.test(text)) return { kind: 'script', file: abs, script: abs };
  const scene = join(dirname(abs), `${basename(abs, '.gd')}.tscn`);
  if (existsSync(scene)) return { kind: 'scene', file: scene, script: abs };
  return { error: `${toRes(abs, projectDir)} is neither a scene nor an -s script (extends SceneTree/MainLoop)` };
}

function engineArgs(engine, runTicks, declaredFps = null) {
  const fps = engine.fixedFps ?? declaredFps ?? (runTicks ? RUN_FPS : null);
  const quit = engine.quitAfter ?? (runTicks ? String(runTicks) : null);
  return [...(fps ? ['--fixed-fps', fps] : []), ...(quit ? ['--quit-after', quit] : [])];
}

/** Resolves `entry` (a bare name searched in project/dev, a res:// path or a file path) with the
 *  args after it. {ok, kind, path, script, spec, specNote, runTicks, userArgs, problems, godotArgs}
 *  or {ok: false, error}. `problems` lists each user flag the declared spec does not have. */
export function resolve(entry, args = [], { projectDir = PROJECT } = {}) {
  const found = locate(entry, projectDir);
  if (found.error) return { ok: false, error: found.error };
  const c = classify(found.abs, projectDir);
  if (c.error) return { ok: false, error: c.error };
  const text = c.script && existsSync(c.script) ? readFileSync(c.script, 'utf8') : '';
  const declared = readSpec(text);
  const runTicks = readRunTicks(text);
  const fixedFps = readFixedFps(text);
  const { engine, user } = splitArgs(args);
  const flags = user.filter((a) => a.startsWith('--'));
  const problems = !declared ? [] : flags.map((arg) => ({ arg, flag: arg.split('=')[0] }))
    .filter((p) => !declared.flags.includes(p.flag))
    .map((p) => ({ ...p, suggestion: didYouMean(p.flag, declared.flags) }));
  const path = toRes(c.file, projectDir);
  const target = c.kind === 'scene' ? [path] : ['-s', path];
  const tail = user.length ? ['--', ...user] : [];
  const godotArgs = c.kind === 'scene' ? [...engineArgs(engine, runTicks, fixedFps), ...target, ...tail]
    : [...target, ...engineArgs(engine, runTicks, fixedFps), ...tail];
  const specNote = declared
    ? `flags checked: ${flags.length} against ${declared.name} (${c.script ? toRes(c.script, projectDir) : path})`
    : NO_SPEC;
  return { ok: true, kind: c.kind, path, script: c.script ? toRes(c.script, projectDir) : null,
    spec: declared?.flags ?? null, specNote, runTicks, userArgs: user, problems, godotArgs };
}
