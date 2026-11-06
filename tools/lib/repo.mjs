// Shared helpers for tool scripts: repo paths, file walking, git, the Godot binary.
import { execFileSync, spawnSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { join, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { resolveGodot } from './godot.mjs';

export const ROOT = fileURLToPath(new URL('../..', import.meta.url)).replace(/[\\/]$/, '');
export const PROJECT = join(ROOT, 'project');

/** Repo-relative path with forward slashes. */
export const rel = (abs) => relative(ROOT, abs).split(sep).join('/');

export const readJson = (abs) => JSON.parse(readFileSync(abs, 'utf8'));

/** Recursively lists files under `dir` whose name passes `keep`, skipping `skipDirs` names. */
export function walk(dir, keep, skipDirs = ['.godot', '.git', 'node_modules']) {
  const out = [];
  if (!existsSync(dir)) return out;
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const abs = join(dir, entry.name);
    if (entry.isDirectory()) {
      if (!skipDirs.includes(entry.name)) out.push(...walk(abs, keep, skipDirs));
    } else if (keep(entry.name, abs)) {
      out.push(abs);
    }
  }
  return out.sort();
}

/** Our GDScript: everything under project/ except addons/, plus tools/canary.gd. */
export function ownGdFiles() {
  const gd = walk(PROJECT, (name) => name.endsWith('.gd'), ['.godot', 'addons']);
  return [...gd, join(ROOT, 'tools', 'canary.gd')];
}

export function git(...args) {
  return execFileSync('git', ['-C', ROOT, ...args], { encoding: 'utf8' }).trim();
}

/** Tracked or untracked-but-not-ignored changes, as porcelain lines. */
export const dirtyLines = () => git('status', '--porcelain').split('\n').filter(Boolean);

/** The resolved Godot binary (discovery lives in godot.mjs); the env/`godot` fallback when none verified. */
export function godotBin() {
  const g = resolveGodot();
  return g.ok ? g.bin : process.env.GODOT_BIN || process.env.POF_GODOT_BIN || 'godot';
}

export function godotVersion(bin = godotBin()) {
  const res = spawnSync(bin, ['--version'], { encoding: 'utf8' });
  if (res.error || res.status !== 0) return null;
  return res.stdout.trim().split('\n').pop().trim();
}

/** Runs a command, returning {status, out} with stdout+stderr merged and ANSI codes stripped. */
export function run(cmd, args, opts = {}) {
  const res = spawnSync(cmd, args, { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, ...opts });
  const out = `${res.stdout ?? ''}${res.stderr ?? ''}`.replace(/\x1b\[[0-9;]*m/g, '');
  return { status: res.error ? -1 : res.status, out: res.error ? String(res.error) : out };
}
