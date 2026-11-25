import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, existsSync, lstatSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { prepareFilmProject } from './prologue_yard_film.mjs';

test('film project: junction per dir, copied files, 1920x1080 override', () => {
  const root = mkdtempSync(join(tmpdir(), 'yardfilm-'));
  mkdirSync(join(root, 'project', 'boot'), { recursive: true });
  writeFileSync(join(root, 'project', 'boot', 'a.gd'), 'x');
  writeFileSync(join(root, 'project', 'project.godot'), 'p');
  writeFileSync(join(root, 'project', 'override.cfg'), 'never copied');
  const film = prepareFilmProject(root);
  prepareFilmProject(root); // refresh is idempotent
  assert.ok(lstatSync(join(film, 'boot')).isSymbolicLink());
  assert.ok(existsSync(join(film, 'boot', 'a.gd')));
  assert.equal(readFileSync(join(film, 'project.godot'), 'utf8'), 'p');
  const cfg = readFileSync(join(film, 'override.cfg'), 'utf8');
  assert.match(cfg, /viewport_width=1920/);
  assert.match(cfg, /viewport_height=1080/);
  assert.doesNotMatch(cfg, /never copied/);
  rmSync(root, { recursive: true, force: true });
});
