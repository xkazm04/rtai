import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { filmTicks, main, planFilm } from './kill_reel.mjs';
import { MOVIE_FRAME_OF_PROCESS_1, anchorShifts, boxAt, cellLabel, killWindow, movieSpan, pickBeats, reelPlan, reelWeapons, tableRows, victimAt } from './kill_reel_lib.mjs';

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

test('a later zoom with a known kill tick saves the beat frames and the hold run only; a scout saves 60 and the kill; a clip run keeps the full window', () => {
  const side = { tree: process.cwd() };
  const reel = { after: 150, timeout: 300, extra: [], clips: false };
  const job = { weapon: 'katana', victim: 'thug', dir_deg: 90, ppm: 64, dir: join(tmpdir(), 'kr') };
  const first = planFilm(job, side, reel);
  assert.deepEqual(first.opts.on, [{ kind: 'kill', nth: 1, after: 150 }]);
  assert.ok(first.opts.extra.includes('--sig-dir=90') && first.opts.extra.includes('--victim=thug'));
  const later = planFilm(job, side, reel, 63);
  assert.deepEqual(later.opts.on, []);
  assert.deepEqual(later.opts.stills, filmTicks(63, 150));
  assert.deepEqual(filmTicks(63, 150), [60, 61, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 83, 103, 143, 213]);
  assert.ok(pickBeats(63, 150).every((t) => filmTicks(63, 150).includes(t)), 'every beat is still filmed');
  assert.deepEqual(filmTicks(63, 4), [60, 61, 63, 64, 65, 66, 67], 'nothing past --after');
  const scout = planFilm(job, side, reel, undefined, true);
  assert.deepEqual([scout.opts.stills, scout.opts.on], [[60], [{ kind: 'kill', nth: 1, after: 0 }]]);
  assert.equal(scout.opts.lock, later.opts.lock, 'the scout and the film share the camera lock, so the pinned aim (and the sim) match');
  assert.deepEqual(scout.opts.extra, later.opts.extra);
  assert.equal(scout.opts.ticks, later.opts.ticks);
  assert.deepEqual(planFilm(job, side, { ...reel, clips: true }, undefined, true).opts.on, first.opts.on, 'a clip run never scouts');
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
    "chainsaw: chainsaw_grind (split) row hit-stop 2 (the pieces wait; the screen freeze is hit_feel.json's, measured per film), held 56 (grind 54, stand 0), crumble 0, flash 0 ticks");
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

test('the measured hit-stop sums the frames the sim held around the kill, from the probe', async () => {
  const { measureStop } = await import('./kill_reel_lib.mjs');
  const rows = (frames) => ({ rows: Object.entries(frames).map(([tick, frame]) => ({ tick: Number(tick), frame })) });
  // s3stop_on (katana --feel=on): tick 70 held for 6 frames, the next row 7 frames on
  assert.equal(measureStop(rows({ 66: 100, 67: 101, 68: 102, 69: 103, 70: 104, 71: 111, 72: 112 }), 68), 6);
  assert.equal(measureStop(rows({ 67: 101, 68: 102, 69: 103, 70: 104, 71: 105, 90: 200, 91: 210 }), 68), 0, 'feel off; a hold past +12 is not this kill');
  assert.equal(measureStop(rows({ 60: 1 }), 68), null, 'no rows at the kill: unmeasured, not zero');
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

test('--quick films play zoom and one side-on direction; named --dirs/--ppm still win', () => {
  const q = reelPlan({ out: 'x', weapons: 'katana', quick: true }, []);
  assert.deepEqual([q.dirs, q.ppm, q.jobs.length], [[90], [32], 1]);
  const named = reelPlan({ out: 'x', weapons: 'katana', quick: true, dirs: '0,wall', ppm: '64' }, []);
  assert.deepEqual([named.dirs, named.ppm], [[0, 'wall'], [64]]);
  assert.deepEqual(reelPlan({ out: 'x', weapons: 'katana' }, []).ppm, [32, 64], 'without --quick: both zooms');
  assert.match(reelPlan({ out: 'x', weapons: 'katana', quick: '1' }, []).error, /--quick takes no value/);
});

test('sheet labels: the tick and its offset; the first cell names the film; the kill cell the measured hit-stop', () => {
  const job = { weapon: 'rocket_launcher', side: 'after', victim: '', dir_deg: 90, ppm: 32 };
  assert.equal(cellLabel(job, { kill: 70 }, 60, 0), '-10 rocket_launcher guard d90 32');
  assert.ok(cellLabel(job, { kill: 70 }, 60, 0).length * 12 <= 384, 'the longest lab weapon fits a 32 px/m cell (12 m; the last glyph ends 2 px short of its advance)');
  assert.equal(cellLabel({ ...job, side: 'before' }, { kill: 70 }, 60, 0), '-10 rocket_launcher before guard d90 32');
  assert.equal(cellLabel(job, { kill: 70, measured: { hitstop_frames: 6 } }, 70, 2), '70 kill hs6');
  assert.equal(cellLabel(job, { kill: 70, measured: { hitstop_frames: 0 } }, 70, 2), '70 kill', 'no hold: nothing claimed');
  assert.equal(cellLabel({ ...job, victim: 'thug', dir_deg: 'wall' }, { kill: 70 }, 74, 0), '+4 rocket_launcher thug dwall 32');
});

test('the movie span keeps every frame of a held tick, so the clip plays the hit-stop at its real length', () => {
  const at = (f) => f - 1 + MOVIE_FRAME_OF_PROCESS_1;
  // tick 70 is held 6 frames (rows 70 at frame 120, 71 at frame 127).
  const probe = { rows: [[68, 118], [69, 119], [70, 120], [71, 127], [72, 128]].map(([tick, frame]) => ({ tick, frame })) };
  assert.deepEqual(movieSpan(probe, 68, 71), [at(118), at(127)], 'tick 71 has no next row: its own frame ends the span');
  assert.deepEqual(movieSpan(probe, 69, 70), [at(119), at(126)], 'the held tick ends on its last frame, not its first');
  assert.equal(movieSpan(probe, 60, 70), null, 'no row at the start: unmeasured');
  assert.equal(movieSpan({ rows: [{ tick: 68 }, { tick: 70 }] }, 68, 70), null, 'rows without frames (an old probe)');
});

test('a victim too far to share the window with Rivet (the mini nuke, ~25 m) gets the window to himself', () => {
  const far = (dy) => ({ rows: [62, 63].map((tick) => ({ tick, fighters: [{ role: 'rivet', alive: true, pos: [10, 10], screen: [640, 100] },
    { id: 7, role: 'hostile', alive: tick === 62, pos: [10, 10 + dy], screen: [0, 0] }] })) });
  // 20 m south at 32 px/m: 640 px apart, the window is 288 px tall: centred on him (y 740), kept inside the view.
  assert.deepEqual(killWindow(far(20), 63, 32), [448, 512, 384, 288]);
  // 6 m south: 192 px apart fits 288 - 2 m (64 px) of margin: between the two as before.
  assert.deepEqual(killWindow(far(6), 63, 32), [448, 52, 384, 288]);
});

test('the window follows the street when the view moves: the nuke drift (s3nuke probe numbers) shifts every cell', () => {
  // s3nuke mini_nuke: the canvas origin y at 60, 127 (the kill), 207; Rivet stood still at 264 -> -10 -> 136 on screen.
  const probe = { rows: [[60, -15493], [127, -15766], [207, -15621]].map(([tick, y]) => ({ tick, cam: [-15802, y] })).concat([{ tick: 300 }]) };
  assert.deepEqual(anchorShifts(probe, 127, [60, 127, 207, 300]), { 60: [0, 273], 127: [0, 0], 207: [0, 145] }, 'no cam at 300: no entry');
  assert.deepEqual(anchorShifts({ rows: [{ tick: 60, cam: [0, 0] }] }, 127, [60]), {}, 'no cam at the kill: nothing anchored');
  assert.deepEqual(boxAt([448, 400, 384, 288], [0, 273]), [448, 512, 384, 288], 'kept inside the 1280 x 800 view');
  assert.deepEqual(boxAt([448, 100, 384, 288], [-10, 20]), [438, 120, 384, 288]);
  assert.deepEqual(boxAt([448, 100, 384, 288], undefined), [448, 100, 384, 288], 'an older reel.json without shifts: fixed on screen');
});
