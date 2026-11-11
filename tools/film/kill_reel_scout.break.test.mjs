import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { filmTicks, filmTimeout, main, olderTreeHint, planFilm, stillCount } from './kill_reel.mjs';
import { pickBeats, tableRows } from './kill_reel_lib.mjs';
import { encodePng } from './sheet.mjs';

const OK = { status: 0, out: '', timedOut: false, durationMs: 1 };
const arg = (args, name) => args.find((value) => value.startsWith(`${name}=`))?.slice(name.length + 1);
const ticksOf = (text = '') => text.split(',').filter(Boolean).flatMap((part) => {
  const [from, to] = part.split('-').map(Number);
  return Number.isInteger(to) ? Array.from({ length: to - from + 1 }, (_, i) => from + i) : [from];
});

function temp(t, stem = 'kill-reel-scout-') {
  const dir = mkdtempSync(join(tmpdir(), stem));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  return dir;
}

function filmRunner(choose) {
  const launches = [];
  const png = encodePng(1280, 800, Buffer.alloc(1280 * 800 * 3, 80));
  const runner = async (args, opts) => {
    const launch = { args: [...args], opts };
    launches.push(launch);
    const decided = choose?.(launch, launches.length - 1) ?? {};
    if (decided.timeout) return { status: -1, out: '', timedOut: true, durationMs: 1 };
    const dir = arg(args, '--film-dir');
    const on = arg(args, '--film-on');
    const victim = arg(args, '--victim');
    const kill = decided.kill ?? 63;
    const listed = ticksOf(arg(args, '--film-stills'));
    const after = on ? Number(/\+(\d+)$/.exec(on)?.[1] ?? 0) : -1;
    const eventTicks = on && decided.emptyKill !== true
      ? Array.from({ length: after + 1 }, (_, i) => kill + i) : [];
    const stills = [...new Set([...listed, ...eventTicks])].sort((a, b) => a - b);
    const rowTicks = [...new Set([...stills, kill - 1, kill])].filter((tick) => tick >= 0);
    const rows = rowTicks.map((tick) => ({ tick, cam: [0, 0], fighters: [
      { id: 1, role: 'rivet', alive: true, on_screen: true, pos: [0, 0], screen: [640, 400], draw: [10, 10] },
      { id: 2, role: 'hostile', alive: tick < kill, on_screen: true, pos: [1, 0], screen: [672, 400], draw: [20, 20], row: victim ?? 'guard' },
    ] }));
    mkdirSync(dir, { recursive: true });
    for (const tick of stills) writeFileSync(join(dir, `t${tick}.png`), png);
    writeFileSync(join(dir, 'probe.json'), JSON.stringify({
      rows, view: [1280, 800], stills, events: { fire: [], kill: decided.emptyKill ? [] : [kill] },
    }));
    return { ...OK, out: victim ? `gunplay: lone victim ${victim}\n` : '' };
  };
  return { runner, launches };
}

const quiet = { out() {}, err() {} };
const stableState = () => ({ head: 'same', paths: {} });
const isScout = ({ args }) => arg(args, '--film-on') === 'kill:1';

// Review (n16 s5): tick 60 is the lab's trigger column, pickBeats' fixed reference frame before the kill (lab kills
// come at 63 or later), so it is exempt from the kill+after bound; Codex kept this red on the overseer's looser wording.
test('filmTicks includes every beat and hold tick once, sorted, without crossing kill plus a short after', () => {
  for (const [kill, after] of [[0, 1], [59, 1], [63, 4], [63, 12], [63, 150]]) {
    const actual = filmTicks(kill, after);
    assert.deepEqual(actual, [...new Set(actual)].sort((a, b) => a - b));
    assert.ok(pickBeats(kill, after).every((tick) => actual.includes(tick)), `${kill}+${after}: every beat`);
    assert.ok(actual.every((tick) => tick <= kill + after || tick === 60), `${kill}+${after}: no tick past the window but the trigger column`);
    for (let tick = kill; tick <= kill + Math.min(12, after); tick++) assert.ok(actual.includes(tick));
  }
});

test('planFilm keeps clips full, scouts minimal, known kills trigger nothing, and all deterministic settings match', () => {
  const dir = join(tmpdir(), 'kill-reel-plan');
  const job = { weapon: 'katana', victim: 'thug', dir_deg: 90, ppm: 64, dir };
  const side = { tree: process.cwd() };
  const reel = { after: 1, timeout: null, extra: ['--gore=reduced'], clips: false };
  const scout = planFilm(job, side, reel, undefined, true);
  const known = planFilm(job, side, reel, 0);
  assert.deepEqual([scout.opts.stills, scout.opts.on], [[60], [{ kind: 'kill', nth: 1, after: 0 }]]);
  assert.deepEqual(known.opts.on, []);
  assert.deepEqual(known.opts.stills, filmTicks(0, 1));
  for (const key of ['seed', 'lock', 'ticks', 'view', 'ppm', 'res']) assert.deepEqual(scout.opts[key], known.opts[key], key);
  assert.deepEqual(scout.opts.extra, known.opts.extra);
  for (const knownTick of [undefined, 0, 63]) {
    const clip = planFilm(job, side, { ...reel, clips: true }, knownTick, true);
    assert.deepEqual(clip.opts.stills, Array.from({ length: 17 }, (_, i) => 54 + i));
    assert.deepEqual(clip.opts.on, [{ kind: 'kill', nth: 1, after: 1 }]);
  }
});

test('stillCount and filmTimeout count singleton and ranged windows and preserve explicit timeout including zero', () => {
  assert.equal(stillCount({ stills: '54-70', on: 'kill:1+2' }), 20);
  assert.equal(stillCount({ stills: '4,9' }), 2);
  assert.equal(stillCount({ stills: '7' }), 1);
  assert.equal(stillCount({ on: 'kill:1' }), 1);
  assert.equal(filmTimeout({ timeout: null }, { stills: '7' }), '300');
  assert.equal(filmTimeout({ timeout: undefined }, { stills: '54-70', on: 'kill:1+150' }), '540');
  assert.equal(filmTimeout({ timeout: 41 }, { stills: '7' }), '41');
  assert.equal(filmTimeout({ timeout: 0 }, { stills: '7' }), '0');
});

test('olderTreeHint recognizes only the exact three read flags and gives the flag-specific recovery', () => {
  assert.match(olderTreeHint('tree reads --sig-dir'), /--dirs=0/);
  assert.match(olderTreeHint('tree reads --sig-wall'), /--dirs=0/);
  assert.match(olderTreeHint('tree reads --victim'), /drop --victims/);
  for (const error of ['tree reads --victims', 'tree reads --sig-direction', 'tree reads --sig-dirt', 'other']) {
    assert.equal(olderTreeHint(error), '', error);
  }
});

test('tableRows chooses each weapon own or also_weapons row before an earlier burn fallback', (t) => {
  const tree = temp(t, 'kill-reel-table-');
  const file = join(tree, 'project/data/tables/signature_kills.json');
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, JSON.stringify({ leftover_budget: 9, kills: [
    { id: 'burn', weapon: 'burn', style: 'burn' },
    { id: 'molotov_own', weapon: 'molotov', style: 'torch' },
    { id: 'shared', weapon: 'laser', also_weapons: ['flamethrower'], style: 'split' },
  ] }));
  const rows = tableRows(tree, ['molotov', 'flamethrower', 'molotov']);
  assert.deepEqual(Object.keys(rows), ['molotov', 'flamethrower']);
  assert.equal(rows.molotov.id, 'molotov_own');
  assert.equal(rows.flamethrower.id, 'shared');
});

test('main scouts exactly once per side weapon victim direction combo across two zooms', async (t) => {
  const out = temp(t);
  const fake = filmRunner();
  const code = await main([`--out=${out}`, '--weapons=katana', '--victims=thug,cop/head_cap', '--dirs=0,90', '--ppm=32,64', '--after=1'],
    { ...quiet, runner: fake.runner, state: stableState });
  assert.equal(code, 0);
  assert.equal(fake.launches.length, 12);
  assert.equal(fake.launches.filter(isScout).length, 4);
  const groups = new Map();
  for (const launch of fake.launches) {
    const dir = arg(launch.args, '--film-dir').replace(/_(32|64)$/, '');
    groups.set(dir, [...(groups.get(dir) ?? []), launch]);
  }
  assert.equal(groups.size, 4);
  for (const launches of groups.values()) assert.deepEqual(launches.map(isScout), [true, false, false]);
});

test('main marks a changed first beat unverifiable and the second zoom reuses that first zoom kill', async (t) => {
  const out = temp(t);
  const fake = filmRunner((_launch, index) => ({ kill: [10, 11, 11][index] }));
  const code = await main([`--out=${out}`, '--weapons=katana', '--dirs=0', '--ppm=32,64', '--after=1'],
    { ...quiet, runner: fake.runner, state: stableState });
  assert.equal(code, 3);
  assert.equal(fake.launches.length, 3);
  assert.equal(arg(fake.launches[0].args, '--film-on'), 'kill:1');
  assert.ok(ticksOf(arg(fake.launches[1].args, '--film-stills')).includes(10), 'first beat uses scout tick');
  assert.ok(ticksOf(arg(fake.launches[2].args, '--film-stills')).includes(11), 'second zoom uses first zoom tick');
  const reel = JSON.parse(readFileSync(join(out, 'reel.json'), 'utf8'));
  assert.match(reel.films[0].reasons.join(' '), /in its scout run/);
});

test('main prefixes scout timeout and empty-kill reasons and never launches their beat film', async (t) => {
  for (const [name, decision, expected] of [
    ['timeout', { timeout: true }, 1],
    ['empty', { emptyKill: true }, 3],
  ]) {
    const out = temp(t, `kill-reel-${name}-`);
    const fake = filmRunner(() => decision);
    const code = await main([`--out=${out}`, '--weapons=katana', '--ppm=32', '--after=1'],
      { ...quiet, runner: fake.runner, state: stableState });
    assert.equal(code, expected, name);
    assert.equal(fake.launches.length, 1, `${name}: no beat film`);
    const reel = JSON.parse(readFileSync(join(out, 'reel.json'), 'utf8'));
    assert.ok(reel.films[0].reasons.length > 0);
    assert.ok(reel.films[0].reasons.every((reason) => reason.startsWith('scout: ')), name);
  }
});

test('main with clips never scouts and passes its explicit timeout to the full-window launch', async (t) => {
  const out = temp(t);
  const fake = filmRunner();
  const code = await main([`--out=${out}`, '--weapons=katana', '--ppm=32', '--after=1', '--clips', '--timeout=17'],
    { ...quiet, runner: fake.runner, state: stableState });
  assert.equal(code, 0);
  assert.equal(fake.launches.length, 1);
  assert.equal(fake.launches[0].opts.timeoutMs, 17000);
  assert.equal(isScout(fake.launches[0]), false);
  assert.equal(arg(fake.launches[0].args, '--film-on'), 'kill:1+1');
  assert.equal(ticksOf(arg(fake.launches[0].args, '--film-stills')).length, 17);
});
