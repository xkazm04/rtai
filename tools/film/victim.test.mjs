// --victim=<kind> on the weapon shot (combat n11 REQUEST line 225): checked against the filmed
// tree's StreetDeadPlan.CLASS_OF rows, refused where the game does not read it, and a pass only
// when the run itself names the victim it drew.
import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { judge, parseArgv, plan } from './film.mjs';
import { godotArgs, parseShot, victimKinds, victimSaid } from './shots.mjs';

const PLAN = 'project/features/characters/street_dead_plan.gd';
const CLASS_OF = 'const POSES: int = 5\n## Card row -> body class strip\nconst CLASS_OF: Dictionary[String, String] = {\n'
  + '\t"ped/head_worker": "ped_worker",\n\t"cop/head_helmet": "cop_riot",\n\t"cop/head_swat": "swat",\n\t"thug": "thug",\n}\n'
  + 'const HEAD_ANGLE: PackedFloat32Array = [0.0]\nconst BY_KIND: Dictionary[StringName, PackedInt32Array] = {\n\t&"death_blast": [1],\n}\n';

function tree({ hook = true, table = CLASS_OF } = {}) {
  const root = mkdtempSync(join(tmpdir(), 'gtai-film-victim-'));
  const files = { 'project/project.godot': '', 'project/dev/frames/film_probe.gd': '',
    'project/data/tables/weapons.json': '{"weapons":[{"id":"pistol"}]}',
    'project/data/tables/view.json': '{"views":[{"id":"combo"}]}',
    'project/features/a.gd': `if args.has("--lone"): pass\n${hook ? 'var v = args.text("--victim")\n' : ''}` };
  if (table !== null) files[PLAN] = table;
  for (const [rel, text] of Object.entries(files)) {
    mkdirSync(join(root, rel, '..'), { recursive: true });
    writeFileSync(join(root, rel), text);
  }
  return root;
}

const planIn = (root, shot, extra = [], victim = 'thug') => plan({ ...parseArgv([]).flags, out: 'o', tree: root, victim }, shot, extra);

test('the kinds are CLASS_OF rows, in file order, and no other table', () => {
  const root = tree();
  try {
    assert.deepEqual(victimKinds(root), ['ped/head_worker', 'cop/head_helmet', 'cop/head_swat', 'thug']);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test('a known kind reaches the game as --victim=<kind>, after the shot flags', () => {
  const root = tree();
  try {
    const p = planIn(root, 'weapon:pistol', [], 'cop/head_swat');
    assert.equal(p.error, undefined);
    const args = godotArgs(p.shot, p.opts);
    assert.ok(args.indexOf('--victim=cop/head_swat') > args.indexOf('--lone'));
    assert.equal(p.opts.victim, 'cop/head_swat');
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test('an unknown kind, another shot, a tree without the table and a tree without the hook launch nothing', () => {
  const root = tree();
  const noHook = tree({ hook: false });
  const noTable = tree({ table: null });
  try {
    assert.match(planIn(root, 'weapon:pistol', [], 'cop/head_swot').error, /unknown victim cop\/head_swot .*did you mean cop\/head_swat\?/);
    assert.match(planIn(root, 'arena').error, /--victim is for the weapon shot only, not arena/);
    assert.match(planIn(noTable, 'weapon:pistol').error, /no project\/features\/characters\/street_dead_plan.gd CLASS_OF table/);
    assert.match(planIn(noHook, 'weapon:pistol').error, /no script in .* reads --victim: .*gunplay_hook\.gd lone\(\).*lone victim <kind>/);
    assert.match(planIn(root, 'weapon:pistol', ['--victim=thug'], undefined).error, /give --victim=<kind> before the --/);
  } finally { for (const r of [root, noHook, noTable]) rmSync(r, { recursive: true, force: true }); }
});

test('victimSaid reads only the hook line', () => {
  assert.equal(victimSaid('[INFO] gunplay: lone kill 1 at tick 340'), null);
  assert.equal(victimSaid('[INFO] gunplay: lone victim cop/head_helmet\n'), 'cop/head_helmet');
  assert.equal(victimSaid(undefined), null);
});

function judgedVictim(out, victim) {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-film-victim-judge-'));
  const startedAt = Date.now();
  writeFileSync(join(dir, 'probe.json'), JSON.stringify({ rows: [{ tick: 1, fighters: [] }], stills: [], view: [10, 10] }));
  try {
    return judge({ status: 0, out, timedOut: false, durationMs: 1 }, { dir, stills: [], res: '10x10', subject: 'rivet', ticks: 10, victim }, startedAt);
  } finally { rmSync(dir, { recursive: true, force: true }); }
}

test('judge: a victim the run never named, or named otherwise, is unverifiable; the named one passes', () => {
  const silent = judgedVictim('[INFO] gunplay: lone kill 1 at tick 340', 'thug');
  assert.equal(silent.outcome, 'unverifiable');
  assert.match(silent.reasons[0], /never said its victim .*thug is not seen/);
  const other = judgedVictim('[INFO] gunplay: lone victim cop/head_cap', 'thug');
  assert.equal(other.outcome, 'unverifiable');
  assert.match(other.reasons[0], /victim was cop\/head_cap, not the asked thug/);
  assert.equal(judgedVictim('[INFO] gunplay: lone victim thug', 'thug').outcome, 'pass');
  assert.equal(judgedVictim('', null).outcome, 'pass');
});
