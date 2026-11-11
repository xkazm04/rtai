import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { main } from './kill_reel.mjs';
import {
  GONE_SHARE,
  curveText,
  decayOf,
  measureBeats,
  pickBeats,
  reelPlan,
  stopText,
} from './kill_reel_lib.mjs';
import { beatLine } from './kill_reel_out.mjs';
import { encodePng } from './sheet.mjs';

function tempTree(t) {
  const tree = mkdtempSync(join(tmpdir(), 'kill-reel-life-'));
  t.after(() => rmSync(tree, { recursive: true, force: true }));
  return tree;
}

function writeDecay(tree, text) {
  const file = join(tree, 'project/data/tables/corpse_decay.json');
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, text);
}

function image(changed = 0, size = 200) {
  const data = Buffer.alloc(size * 3);
  for (let i = 0; i < changed; i++) data[i * 3] = 255;
  return { width: size, height: 1, channels: 3, data };
}

function fraction(a, b) {
  let changed = 0;
  for (let i = 0; i < a.width; i++) {
    if (a.data[i * 3] !== b.data[i * 3]) changed++;
  }
  return { fraction: changed / a.width };
}

const valueOf = (args, name) => args.find((arg) => arg.startsWith(`${name}=`))?.slice(name.length + 1);
const ticksOf = (text = '') => text.split(',').filter(Boolean).flatMap((part) => {
  const [from, to] = part.split('-').map(Number);
  return Number.isInteger(to) ? Array.from({ length: to - from + 1 }, (_, i) => from + i) : [from];
});

function fakeFilmRunner() {
  const launches = [];
  const png = encodePng(1280, 800, Buffer.alloc(1280 * 800 * 3, 80));
  const runner = async (args, opts) => {
    launches.push({ args: [...args], opts });
    const dir = valueOf(args, '--film-dir');
    const on = valueOf(args, '--film-on');
    const kill = 70;
    const after = Number(/\+(\d+)$/.exec(on ?? '')?.[1] ?? 0);
    const listed = ticksOf(valueOf(args, '--film-stills'));
    const eventTicks = on ? Array.from({ length: after + 1 }, (_, i) => kill + i) : [];
    const stills = [...new Set([...listed, ...eventTicks])].sort((a, b) => a - b);
    const rows = [...new Set([...stills, kill - 1, kill])].map((tick) => ({ tick, frame: tick, cam: [0, 0], fighters: [
      { id: 1, role: 'rivet', alive: true, on_screen: true, pos: [0, 0], screen: [640, 400], draw: [10, 10] },
      { id: 2, role: 'hostile', alive: tick < kill, on_screen: true, pos: [1, 0], screen: [672, 400], draw: [20, 20], row: 'guard' },
    ] }));
    mkdirSync(dir, { recursive: true });
    for (const tick of stills) writeFileSync(join(dir, `t${tick}.png`), png);
    writeFileSync(join(dir, 'probe.json'), JSON.stringify({ rows, view: [1280, 800], stills, events: { fire: [], kill: [kill] } }));
    return { status: 0, out: '', timedOut: false, durationMs: 1 };
  };
  return { runner, launches };
}

test('reelPlan accepts each advertised --after ceiling and rejects non-integers and values outside it with the active bound', () => {
  const plan = (after, clips = false) => reelPlan({ out: 'x', weapons: 'katana', after, ...(clips ? { clips: true } : {}) }, []);
  assert.equal(plan('1200').after, 1200);
  assert.match(plan('1201').error, /--after takes 1-1200 ticks/);
  assert.equal(plan('230', true).after, 230);
  assert.match(plan('231', true).error, /--after takes 1-230 ticks with --clips/);
  assert.match(plan('600.5').error, /1-1200/);
  assert.match(plan('-1').error, /1-1200/);
});

test('pickBeats always starts with tick 60 and adds only aftermath milestones inside the requested window', () => {
  assert.deepEqual(pickBeats(70, 299), [60, 68, 70, 71, 72, 74, 76, 80, 90, 110, 150, 220, 369]);
  assert.deepEqual(pickBeats(70, 300), [60, 68, 70, 71, 72, 74, 76, 80, 90, 110, 150, 220, 370]);
  assert.deepEqual(pickBeats(70, 601), [60, 68, 70, 71, 72, 74, 76, 80, 90, 110, 150, 220, 370, 670, 671]);
  assert.deepEqual(pickBeats(70, 150), [60, 68, 70, 71, 72, 74, 76, 80, 90, 110, 150, 220], 'the default after=150 sheet stays unchanged');
  assert.deepEqual(pickBeats(60, 1), [58, 60, 61], 'tick 60 stays first only when it is chronologically first after sorting');
});

test('measureBeats records every available +20-or-later beat, calls nothing gone when the share rises again, and rounds to four decimals', () => {
  const beats = [60, 120, 140, 160, 180];
  const frames = new Map([[60, image()], [120, image(25)], [140, image(0)], [160, image(3)], [180, image(7)]]);
  const boxes = [];
  const measured = measureBeats(frames, beats, 100, (tick) => {
    boxes.push(tick);
    return [0, 0, 200, 1];
  }, fraction);
  assert.deepEqual(measured.aftermath_curve, [[20, 0.125], [40, 0], [60, 0.015], [80, 0.035]]);
  // Review (n16 s6 all-deaths reel): Codex pinned 40 (the first dip); a street whose marks come back is not gone.
  assert.equal(measured.aftermath_gone_after, null, 'later pixels returning mean the street was never gone');
  assert.equal(measured.aftermath_share, 0.035);
  assert.ok(boxes.includes(60) && boxes.includes(180), 'a tick-sensitive crop function is used for reference and final frames');
});

test('measureBeats treats exactly GONE_SHARE as present, skips missing middle frames, and supports a Map with only reference and last', () => {
  const exact = measureBeats(new Map([[60, image()], [120, image(1)]]), [60, 100, 120], 100, [0, 0, 200, 1], fraction);
  assert.equal(GONE_SHARE, 0.005);
  assert.deepEqual(exact.aftermath_curve, [[20, 0.005]]);
  assert.equal(exact.aftermath_gone_after, null);
  assert.equal(exact.aftermath_share, 0.005);
  assert.equal(measureBeats(new Map([[60, image()]]), [60, 120], 100, [0, 0, 200, 1], fraction), null, 'last frame missing');
  assert.equal(measureBeats(new Map([[60, image()], [100, image()]]), [60, 100], 100, [0, 0, 200, 1], fraction), null, 'last is not after kill');
});

test('curveText and stopText state the measured lifetime and do not call feel-off a zero-frame freeze', () => {
  assert.equal(curveText({ aftermath_curve: [[20, 0.091], [300, 0.004]], aftermath_gone_after: 300 }), '+20 9.1 / +300 0.4 %, gone by +300');
  assert.equal(curveText({ aftermath_curve: [[20, 0.091], [600, 0.03]], aftermath_gone_after: null }), '+20 9.1 / +600 3.0 %, still there at +600');
  assert.equal(curveText({}), '-');
  assert.equal(stopText({ feel_off: true, hitstop_frames: 0 }), 'off (feel off under the lock: --feel=on measures it)');
  assert.equal(stopText({ hitstop_frames: 4 }), '4 frames');
  assert.equal(stopText({}), '? frames');
});

test('decayOf never throws on absent, malformed, BOM-prefixed, string-valued, or partially missing decay data', (t) => {
  const absent = tempTree(t);
  assert.deepEqual(decayOf(absent), {});

  const malformed = tempTree(t);
  writeDecay(malformed, '{ nope');
  assert.deepEqual(decayOf(malformed), {});

  const bom = tempTree(t);
  writeDecay(bom, '\ufeff{"bodies":{"linger_s":6,"fade_s":1.2}}');
  assert.deepEqual(decayOf(bom), {}, 'JSON.parse rejects a BOM and decayOf degrades to no claims');

  const strings = tempTree(t);
  writeDecay(strings, JSON.stringify({ bodies: { linger_s: '6', fade_s: 1 }, stains: { linger_s: 12, fade_s: '4' } }));
  assert.deepEqual(decayOf(strings), {}, 'numeric strings are not table numbers');

  const partial = tempTree(t);
  writeDecay(partial, JSON.stringify({ bodies: { linger_s: 6, fade_s: 1.2 } }));
  assert.deepEqual(decayOf(partial), { body_gone_s: 7.2 });
});

test('beatLine names each corpse-decay lifetime that is present without inventing the missing one', () => {
  const row = { id: 'x', style: 'fall', hitstop_ticks: 0, held_ticks: 0, grind_ticks: 0, stand_ticks: 0, crumble_ticks: 0, flash_ticks: 0 };
  assert.match(beatLine('pistol', { ...row, body_gone_s: 7.2 }), /body and its pieces are gone by 7\.2 s/);
  assert.match(beatLine('pistol', { ...row, stain_gone_s: 16 }), /scorch and spray by 16 s/);
});

test('main accepts a long non-clip aftermath, launches its +150/+300/+600 beat stills, and records feel-off from the film manifest', async (t) => {
  const outDir = tempTree(t);
  const fake = fakeFilmRunner();
  const quiet = { out() {}, err() {} };
  const code = await main([`--out=${outDir}`, '--weapons=katana', '--dirs=0', '--ppm=32', '--after=600', '--feel=off'], {
    ...quiet,
    runner: fake.runner,
    state: () => ({ head: 'same', paths: {} }),
  });
  assert.equal(code, 0);
  assert.equal(fake.launches.length, 2, 'one scout and one beat film');
  const stills = ticksOf(valueOf(fake.launches[1].args, '--film-stills'));
  for (const tick of [220, 370, 670]) assert.ok(stills.includes(tick), `kill 70 + beat ${tick - 70}`);
  const reel = JSON.parse(readFileSync(join(outDir, 'reel.json'), 'utf8'));
  assert.equal(reel.films[0].measured.feel_off, true);
  assert.equal(reel.films[0].measured.hitstop_frames, 0);
});
