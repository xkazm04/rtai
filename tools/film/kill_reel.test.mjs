import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { main, planFilm } from './kill_reel.mjs';
import { killWindow, pickBeats, reelPlan, reelWeapons, tableRows, victimAt } from './kill_reel_lib.mjs';

function tree() {
  const root = mkdtempSync(join(tmpdir(), 'kill-reel-'));
  mkdirSync(join(root, 'project/data/tables'), { recursive: true });
  const put = (name, body) => writeFileSync(join(root, 'project/data/tables', name), JSON.stringify(body));
  put('weapons.json', { weapons: [{ id: 'pistol' }, { id: 'rocket_launcher' }, { id: 'flamethrower' }] });
  put('melee_weapons.json', { weapons: { katana: {}, electro_baton: {} } });
  put('signature_kills.json', { kills: [
    { id: 'rocket_gib', weapon: 'rocket_launcher', style: 'gib', hitstop_ticks: 0 },
    { id: 'katana_split', weapon: 'katana', style: 'split', hitstop_ticks: 6, grind_ticks: 2 },
    { id: 'burn_char', weapon: 'burn', style: 'burn', hitstop_ticks: 2, stand_ticks: 55, crumble_ticks: 75 },
    { id: 'electro_shock', weapon: 'electro_gun', also_weapons: ['pistol'], style: 'shock', hitstop_ticks: 3 },
    { id: 'tonnage_crush', weapon: 'stomp', style: 'crush', hitstop_ticks: 4 },
  ] });
  return root;
}

test('all = every lab weapon with a signature row (also_weapons too); burn films with the fire weapons; ghost rows are skipped', () => {
  const root = tree();
  try {
    assert.deepEqual(reelWeapons(root), ['rocket_launcher', 'katana', 'flamethrower', 'pistol']);
    assert.deepEqual(tableRows(root, ['flamethrower', 'katana', 'electro_baton']), {
      flamethrower: { id: 'burn_char', style: 'burn', hitstop_ticks: 2, grind_ticks: 0, stand_ticks: 55, crumble_ticks: 75, flash_ticks: 0, held_ticks: 57 },
      katana: { id: 'katana_split', style: 'split', hitstop_ticks: 6, grind_ticks: 2, stand_ticks: 0, crumble_ticks: 0, flash_ticks: 0, held_ticks: 8 },
      electro_baton: {} });
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test('the plan is weapons x victims x dirs x zooms, and refuses what the reel sets itself', () => {
  const root = tree();
  try {
    const p = reelPlan({ out: 'o', weapons: 'katana', victims: 'thug,cop/head_swat', dirs: '0,90,180' }, [], root);
    assert.equal(p.jobs.length, 2 * 3 * 2);
    assert.deepEqual(p.jobs[0], { weapon: 'katana', victim: 'thug', dir_deg: 0, ppm: 32 });
    assert.match(reelPlan({ out: 'o', dirs: '360' }, [], root).error, /--dirs/);
    assert.match(reelPlan({ out: 'o', ppm: '32,x' }, [], root).error, /--ppm/);
    assert.match(reelPlan({ out: 'o', after: '999' }, [], root).error, /--after/);
    assert.match(reelPlan({ out: 'o' }, ['--sig-dir=90'], root).error, /use --dirs/);
    assert.deepEqual(reelPlan({ out: 'o', weapons: 'katana', dirs: '90,wall' }, [], root).jobs.map((j) => j.dir_deg), [90, 90, 'wall', 'wall']);
    assert.match(reelPlan({ out: 'o' }, ['--sig-wall'], root).error, /use --dirs/);
    assert.match(reelPlan({ out: 'o', feel: 'loud' }, [], root).error, /--feel/);
    assert.match(reelPlan({ out: 'o', bogus: true }, [], root).error, /unknown option --bogus/);
    assert.match(reelPlan({}, [], root).error, /--out/);
    assert.match(reelPlan({ out: 'o', native: 'donor' }, [], root).error, /--native/);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test('beats: the trigger tick, the kill and its frames, the aftermath; nothing past --after', () => {
  assert.deepEqual(pickBeats(63, 150), [60, 61, 63, 64, 65, 67, 69, 73, 83, 103, 143, 213]);
  assert.deepEqual(pickBeats(63, 5), [60, 61, 63, 64, 65, 67, 68]);
});

const probe = {
  rows: [
    { tick: 62, fighters: [{ role: 'rivet', alive: true, pos: [10, 10], screen: [640, 400] }, { id: 7, role: 'hostile', alive: true, pos: [13, 10], screen: [9010, 8368] },
      { id: 8, role: 'hostile', alive: false, screen: [10, 10] }] },
    { tick: 63, fighters: [{ role: 'rivet', alive: true, pos: [10, 10], screen: [640, 400] }, { id: 7, role: 'hostile', alive: false, pos: [13, 10], screen: [9010, 8368] },
      { id: 8, role: 'hostile', alive: false, screen: [10, 10] }] },
  ],
};

test('the victim is the hostile alive the tick before and dead on the kill, not an older body', () => {
  assert.deepEqual(victimAt(probe, 63), { id: 7, pos: [13, 10], screen: [9010, 8368] });
  assert.equal(victimAt(probe, 62), null);
});

test('the kill window is 12 x 9 m at the zoom, centred between Rivet and the victim placed from the sim (not the probe screen), kept inside the view', () => {
  assert.deepEqual(killWindow(probe, 63, 32), [496, 256, 384, 288]);
  assert.deepEqual(killWindow(probe, 63, 64), [352, 112, 768, 576]);
  assert.deepEqual(killWindow(probe, 63, 96), [128, 0, 1152, 800]);
});

test('a later zoom with a known kill tick saves the beat frames only; a clip run keeps the full window', () => {
  const side = { tree: process.cwd() };
  const reel = { after: 150, timeout: 300, extra: [], clips: false };
  const job = { weapon: 'katana', victim: 'thug', dir_deg: 90, ppm: 64, dir: join(tmpdir(), 'kr') };
  const first = planFilm(job, side, reel);
  assert.deepEqual(first.opts.on, [{ kind: 'kill', nth: 1, after: 150 }]);
  assert.ok(first.opts.extra.includes('--sig-dir=90') && first.opts.extra.includes('--victim=thug'));
  const later = planFilm(job, side, reel, 63);
  assert.deepEqual(later.opts.on, []);
  assert.deepEqual(later.opts.stills, pickBeats(63, 150));
  assert.deepEqual(planFilm(job, side, { ...reel, clips: true }, 63).opts.on, first.opts.on);
  assert.equal(planFilm(job, side, { ...reel, feel: 'on' }).opts.feel, 'on', '--feel=on: the hit-stop and punch are filmed');
  assert.equal(first.opts.feel, 'auto');
  const wall = planFilm({ ...job, dir_deg: 'wall' }, side, reel);
  assert.ok(wall.opts.extra.includes('--sig-wall') && !wall.opts.extra.some((a) => a.startsWith('--sig-dir')), 'dir wall: the lab finds the wall');
});

test('a dry run plans every film against the tree and launches nothing; a bad weapon is usage', async () => {
  const lines = [];
  const runner = () => { throw new Error('launched'); };
  assert.equal(await main(['--out=x', '--weapons=katana,rocket_launcher', '--dirs=0,180', '--dry-run'], { out: (l) => lines.push(l), err: (l) => lines.push(l), runner }), 0);
  assert.match(lines.join('\n'), /8 film\(s\): katana rocket_launcher x victims \[guard\] x dirs \[0 180\] x ppm \[32 64\]/);
  assert.equal(await main(['--out=x', '--weapons=katanna', '--dry-run'], { out: () => {}, err: (l) => lines.push(l), runner }), 2);
  assert.match(lines.at(-1), /did you mean katana/);
});

test('the beat line names the row and its timings, or says the weapon has the standard death', async () => {
  const { beatLine } = await import('./kill_reel.mjs');
  assert.equal(beatLine('pistol', {}), 'pistol: no signature row (the standard death)');
  assert.equal(beatLine('chainsaw', { id: 'chainsaw_grind', style: 'split', hitstop_ticks: 2, held_ticks: 56, grind_ticks: 54, stand_ticks: 0, crumble_ticks: 0, flash_ticks: 0 }),
    'chainsaw: chainsaw_grind (split) hit-stop 2, held 56 (grind 54, stand 0), crumble 0, flash 0 ticks');
  assert.match(beatLine('katana', { id: 'k', style: 'split', hitstop_ticks: 6, held_ticks: 6, grind_ticks: 0, stand_ticks: 0, crumble_ticks: 0, flash_ticks: 2, leftover_kills: 12 }),
    /scorch and spray stay until 12 later kills recycle them/);
});

test('gore check: whole when the victim still lies drawn as a card after the kill; a consumed body is named', async () => {
  const { goreWhole } = await import('./kill_reel_lib.mjs');
  const film = (after) => ({ rows: [
    { tick: 62, fighters: [{ id: 7, role: 'hostile', alive: true, draw: [20, 30] }] },
    { tick: 63, fighters: [{ id: 7, role: 'hostile', alive: false, draw: [20, 30] }] },
    { tick: 83, fighters: [{ id: 7, role: 'hostile', alive: false, draw: after }] }] });
  assert.equal(goreWhole(film([30, 14]), 63), null);
  assert.match(goreWhole(film([-1, -1]), 63), /not drawn whole 20 ticks after/);
  const unseen = film([30, 14]);
  unseen.rows[0].fighters[0].draw = [-1, -1];
  assert.match(goreWhole(unseen, 63), /had no card the tick before/);
  assert.match(goreWhole(film([30, 14]), 70), /no victim died/);
});

test('--gore-check passes --gore=reduced to every film and refuses a second --gore', () => {
  const p = reelPlan({ out: 'o', weapons: 'katana', 'gore-check': true }, ['--feel=on']);
  assert.equal(p.goreCheck, true);
  assert.deepEqual(p.extra, ['--feel=on', '--gore=reduced']);
  assert.match(reelPlan({ out: 'o', weapons: 'katana', 'gore-check': true }, ['--gore=full']).error, /passes --gore=reduced itself/);
  assert.equal(reelPlan({ out: 'o', weapons: 'katana' }, []).goreCheck, false);
});

test('measured beats: what stays on the street, and the first beat the window stops changing', async () => {
  const { measureBeats } = await import('./kill_reel_lib.mjs');
  const { diffImages } = await import('./png.mjs');
  const img = (v) => ({ width: 4, height: 4, channels: 3, data: Buffer.from(v) });
  const plain = Array(48).fill(100);
  const marked = plain.map((x, i) => (i < 12 ? 200 : x)); // the top row (a quarter) stained
  const frames = new Map([[60, img(plain)], [63, img(plain.map(() => 250))], [65, img(marked)], [213, img(marked)]]);
  const m = measureBeats(frames, [60, 63, 65, 213], 63, [0, 0, 4, 4], diffImages);
  assert.deepEqual(m, { aftermath_share: 0.25, settled_by: 65, settled_after_ticks: 2 });
  assert.equal(measureBeats(new Map([[60, img(plain)]]), [60, 213], 63, [0, 0, 4, 4], diffImages), null);
});

test('the measured hold counts the still frames after the kill, and needs consecutive frames', async () => {
  const { measureHold } = await import('./kill_reel_lib.mjs');
  const { diffImages } = await import('./png.mjs');
  const img = (v) => ({ width: 4, height: 4, channels: 3, data: Buffer.from(Array(48).fill(v)) });
  const frozen = new Map([[63, img(100)], [64, img(100)], [65, img(100)], [66, img(100)], [67, img(200)], [68, img(200)]]);
  assert.equal(measureHold(frozen, 63, [0, 0, 4, 4], diffImages), 3, '64 65 66 hold, 67 moves');
  const moving = new Map([[63, img(100)], [64, img(140)], [65, img(180)]]);
  assert.equal(measureHold(moving, 63, [0, 0, 4, 4], diffImages), 0);
  assert.equal(measureHold(new Map([[63, img(100)], [65, img(100)]]), 63, [0, 0, 4, 4], diffImages), null, 'beats only');
});
