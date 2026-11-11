// combat n15 REQUESTs: a film can name a director extra chapter (`chapter:electro_baton_left`), and can
// say `--feel=on|off` before the -- (the game reads the FIRST --feel=, so a trailing one never worked).
import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { filmFlags, parseArgv as parseCompare } from './compare.mjs';
// filmFlags + plan: the compare path that broke on the first real run (feel undefined, 23:43).
import { parseArgv, plan } from './film.mjs';
import { chapterIds, feelArgs, godotArgs, parseShot } from './shots.mjs';

const EXTRAS = `static func extras() -> Array[Chapter]:
\tvar out: Array[Chapter] = [
\t\tChapter.new(&"plasma_sword", &"plasma_sword", &"blade", 330, [Vector2(2.6, 0.0)])
\t]
\tfor w: StringName in [&"plasma_sword", &"katana"]:
\t\tout.append(Chapter.new(StringName(w + "_left"), w, &"blade", 330, [Vector2(-2.4, 0.0)]))
\t\tout.append(Chapter.new(StringName(w + "_cam"), w, &"blade", 330, [Vector2(0.0, 2.4)]))
\treturn out
`;

function tree() {
  const root = mkdtempSync(join(tmpdir(), 'gtai-film-feel-'));
  const files = { 'project/project.godot': '', 'project/dev/frames/film_probe.gd': '',
    'project/data/tables/weapons.json': '{"weapons":[{"id":"pistol"}]}',
    'project/data/tables/view.json': '{"views":[{"id":"combo"}]}',
    'project/dev/showcase/reel_chapters.gd': `Chapter.new(&"pistol", &"pistol")\n${EXTRAS}`,
    'project/features/a.gd': 'var x = "--feel="\n' };
  for (const [rel, text] of Object.entries(files)) {
    mkdirSync(join(root, rel, '..'), { recursive: true });
    writeFileSync(join(root, rel), text);
  }
  return root;
}

test('the extras a loop builds are chapters a film may name', () => {
  assert.deepEqual(chapterIds(`Chapter.new(&"pistol", &"pistol")\n${EXTRAS}`),
    ['pistol', 'plasma_sword', 'plasma_sword_left', 'katana_left', 'plasma_sword_cam', 'katana_cam']);
});

test('a commented-out loop or chapter builds nothing', () => {
  const src = '# Chapter.new(&"gone", &"x")\n# for w in [&"a"]:\n#\tChapter.new(StringName(w + "_left"))\n';
  assert.deepEqual(chapterIds(src), []);
});

test('a suffix built from another loop variable is not crossed with this loop', () => {
  const src = 'for w in [&"a", &"b"]:\n\tpass\nfor v in [&"c"]:\n\tChapter.new(StringName(v + "_x"), v)\n';
  assert.deepEqual(chapterIds(src), ['c_x']);
});

test('this tree\'s own reel_chapters.gd lists every blade extra (the request\'s example among them)', () => {
  const ids = chapterIds(readFileSync(new URL('../../project/dev/showcase/reel_chapters.gd', import.meta.url), 'utf8'));
  for (const id of ['pistol', 'plasma_sword', 'electro_baton_left', 'chainsaw_cam', 'katana_left']) assert.ok(ids.includes(id), id);
});

test('a film plans chapter:<extra> and refuses a misspelt one with the nearest name', () => {
  const t = tree();
  try {
    const base = { ...parseArgv([]).flags, out: 'o', tree: t };
    assert.equal(plan(base, 'chapter:katana_left', []).error, undefined);
    assert.match(plan(base, 'chapter:katana_lft', []).error, /did you mean katana_left/);
  } finally { rmSync(t, { recursive: true, force: true }); }
});

test('--feel: auto keeps the old rule, on and off are passed whatever the lock', () => {
  assert.deepEqual(feelArgs('auto', 'spawn'), ['--feel=off']);
  assert.deepEqual(feelArgs('auto', 'off'), []);
  assert.deepEqual(feelArgs('on', 'spawn'), ['--feel=on']);
  assert.deepEqual(feelArgs('off', 'off'), ['--feel=off']);
  const args = (feel) => godotArgs(parseShot('arena'), { res: 'a', movie: null, ticks: 9, stills: [], seed: '1', view: 'v', ppm: '1', lock: 'spawn', dir: 'D', extra: [], feel });
  const on = args('on');
  assert.ok(on.includes('--cam-lock=spawn') && on.includes('--feel=on') && !on.includes('--feel=off'));
  assert.equal(args(undefined).filter((a) => a.startsWith('--feel=')).join(), '--feel=off', 'no feel given = auto');
});

test('--feel: a bad value, or a --feel after the --, is refused before a launch', () => {
  const t = tree();
  try {
    const base = { ...parseArgv([]).flags, out: 'o', tree: t };
    assert.equal(base.feel, 'auto');
    assert.match(plan({ ...base, feel: 'yes' }, 'arena', []).error, /--feel must be auto, on or off/);
    assert.match(plan(base, 'arena', ['--feel=on']).error, /before the --/);
    assert.equal(plan({ ...base, feel: 'on' }, 'arena', []).opts.feel, 'on');
    assert.equal(parseArgv(['arena', '--feel=on']).flags.feel, 'on');
  } finally { rmSync(t, { recursive: true, force: true }); }
});

test('compare passes --feel to both sides, and nothing when it was not given', () => {
  const p = parseCompare(['chapter:katana_left', '--a=HEAD~1', '--b=HEAD', '--at=10', '--out=o', '--feel=on']);
  assert.equal(p.error, undefined);
  assert.equal(filmFlags(p, { name: 'a', tree: 't' }, '10').feel, 'on');
  const q = parseCompare(['arena', '--a=HEAD~1', '--b=HEAD', '--at=10', '--out=o']);
  assert.equal(filmFlags(q, { name: 'a', tree: 't' }, '10').feel, undefined);
});

test('compare side flags plan without a --feel (film defaults are not in them): auto', () => {
  const t = tree();
  try {
    const p = parseCompare(['arena', `--a=${t}`, `--b=${t}`, '--at=10', '--out=o']);
    const planned = plan(filmFlags(p, { name: 'a', tree: t }, '10'), p.shotText, p.extra);
    assert.equal(planned.error, undefined);
    assert.equal(planned.opts.feel, 'auto');
  } finally { rmSync(t, { recursive: true, force: true }); }
});
