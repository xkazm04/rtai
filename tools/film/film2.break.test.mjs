import assert from 'node:assert/strict';
import test from 'node:test';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, relative } from 'node:path';
import { Worker } from 'node:worker_threads';
import { deflateSync } from 'node:zlib';
import { autoLock, parseOn, parseStills, triggeredTicks } from './shots.mjs';
import { judge, main as filmMain, parseArgv as filmArgs, plan } from './film.mjs';
import { main as numbersMain, summarize } from './numbers.mjs';
import { main as sheetMain } from './sheet.mjs';

// All writable fixtures belong to one test; no engine, encoder, worktree or dispatch is used.
function fixture(t) {
  const dir = mkdtempSync(join(tmpdir(), 'film2-break-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  return dir;
}
function put(dir, name, value) {
  const file = join(dir, name);
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, typeof value === 'string' || Buffer.isBuffer(value) ? value : JSON.stringify(value));
  return file;
}
function tree(t) {
  const dir = fixture(t);
  put(dir, 'project/project.godot', '');
  put(dir, 'project/dev/frames/film_probe.gd', '');
  put(dir, 'project/data/tables/view.json', { views: [{ id: 'combo' }] });
  return dir;
}
const quiet = { out() {}, err() {} };
const ok = { status: 0, out: '', timedOut: false, durationMs: 1 };
const fighter = (fields = {}) => ({ role: 'rivet', on_screen: true, feet_y: 20, head_y: 5,
  draw: [10, 15], screen: [30, 20], facing_off: 0, ...fields });
const row = (tick, fields) => ({ tick, fighters: [fighter(fields)] });
function judged(t, probe, overrides = {}) {
  const dir = fixture(t);
  put(dir, 'probe.json', probe);
  for (const tick of overrides.frames ?? [0]) put(dir, `t${tick}.png`, png(tick));
  return judge(overrides.result ?? ok, { dir, res: '80x60', ticks: 5, stills: [0],
    on: [], subject: 'rivet', ...overrides }, 0);
}
const probe = (rows = [row(0)]) => ({ rows, view: [80, 60], stills: [0], events: { fire: [], kill: [] } });

// Independent tiny RGB PNG fixture, including real CRCs; no production renderer/decoder helper.
function png(red = 0) {
  const chunk = (type, body) => {
    const bytes = Buffer.concat([Buffer.from(type), body]);
    let crc = 0xffffffff;
    for (const byte of bytes) {
      crc ^= byte;
      for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ (crc & 1 ? 0xedb88320 : 0);
    }
    const result = Buffer.alloc(body.length + 12);
    result.writeUInt32BE(body.length);
    bytes.copy(result, 4);
    result.writeUInt32BE((crc ^ 0xffffffff) >>> 0, result.length - 4);
    return result;
  };
  const header = Buffer.alloc(13);
  header.writeUInt32BE(1); header.writeUInt32BE(1, 4); header[8] = 8; header[9] = 2;
  return Buffer.concat([Buffer.from('89504e470d0a1a0a', 'hex'), chunk('IHDR', header),
    chunk('IDAT', deflateSync(Buffer.from([0, red % 256, 20, 30]))), chunk('IEND', Buffer.alloc(0))]);
}

test('frame picking preserves zero and equal-ended ranges despite duplicates and whitespace', () => {
  assert.deepEqual(new Set(parseStills('0,0, 1 ,2-2,2')), new Set([0, 1, 2]));
  assert.ok(parseStills('10-9').error);
  assert.ok(parseStills('0-999999999999999999999999999').error);
});

test('frame picking refuses enormous equal-ended ranges without hanging', async (t) => {
  // A worker bounds hostile parser execution without hanging the acceptance command.
  const moduleUrl = new URL('./shots.mjs', import.meta.url).href;
  const worker = new Worker(`const { parentPort } = require('node:worker_threads');
    import(${JSON.stringify(moduleUrl)}).then(({parseStills}) =>
      parentPort.postMessage(parseStills('9007199254740992-9007199254740992')));`,
  { eval: true, resourceLimits: { maxOldGenerationSizeMb: 16 } });
  t.after(() => worker.terminate());
  const result = await new Promise((resolve, reject) => {
    const timer = setTimeout(() => resolve({ hung: true }), 2000);
    worker.once('message', (value) => { clearTimeout(timer); resolve(value); });
    worker.once('error', (error) => { clearTimeout(timer); reject(error); });
  });
  assert.equal(result.hung, undefined, 'an unsafe integer must not trap the range loop');
  assert.ok(result.error, 'ticks beyond exact integer precision must be refused');
});

test('event picking observes fire:1+0 and overlapping or duplicate rules without inventing ticks', () => {
  const rules = parseOn('fire:1+0,fire:1+0,kill:1+2,fire:2+1');
  assert.ok(Array.isArray(rules));
  const result = triggeredTicks(rules, { fire: [0, 2], kill: [1] }, 5);
  assert.deepEqual(new Set(result.ticks), new Set([0, 1, 2, 3]));
  assert.deepEqual(result.reasons, []);
});

for (const events of [undefined, {}, { fire: [] }, { fire: [1] }]) {
  test(`a missing nth event is unverifiable with a reason (${JSON.stringify(events)})`, (t) => {
    const result = judged(t, { ...probe(), events }, { stills: [], on: parseOn('fire:2+0') });
    assert.equal(result.outcome, 'unverifiable');
    assert.ok(result.reasons.some((reason) => reason.includes('fire:2')));
  });
}
for (const at of [-1, 5, 999]) {
  test(`event tick outside the run is named rather than silently accepted (${at})`, () => {
    const result = triggeredTicks(parseOn('fire:1+0'), { fire: [at] }, 5);
    assert.ok(result.reasons.some((reason) => reason.includes(String(at))), 'name the invalid event tick');
    assert.ok(result.ticks.every((tick) => tick >= 0 && tick < 5));
  });
}
test('event picking names a tail outside the run while retaining observable frames', () => {
  const result = triggeredTicks(parseOn('fire:1+3'), { fire: [3] }, 5);
  assert.deepEqual(result.ticks, [3, 4]);
  assert.ok(result.reasons.some((reason) => reason.includes('6')));
});
test('automatic camera locking uses tick zero and the earliest explicit still', (t) => {
  assert.equal(autoLock({ travels: true }, 0, true), 'at:0');
  assert.equal(autoLock({ travels: true }, null, true), 'trigger');
  assert.equal(autoLock({}, 0, true), 'spawn');
  const flags = { ...filmArgs([]).flags, out: join(fixture(t), 'out'), tree: tree(t), stills: '4,0,4' };
  assert.equal(plan(flags, 'city', []).opts.lock, 'at:0');
});

for (const flag of ['--bogus', '--movie=yes', '--stills=', '--stills=1,,2', '--stills=1,',
  '--on=fire:1,', '--on=,', '--ticks=NaN', '--stills=5', '--subject=nobody', '--timeout=NaN', '--ppm=NaN']) {
  test(`unknown or malformed film flags are usage errors and launch nothing (${flag})`, async (t) => {
    let launched = 0;
    const output = join(fixture(t), 'out');
    const code = await filmMain(['arena', `--tree=${tree(t)}`, `--out=${output}`, '--ticks=5',
      '--no-movie', flag], { ...quiet, runner: async () => { launched++; throw new Error('fake launch stopped'); } })
      .catch(() => undefined);
    assert.equal(launched, 0, 'malformed input reached the runner');
    assert.equal(code, 2);
    assert.equal(existsSync(output), false, 'usage must not create run output');
  });
}
for (const rows of [null, {}, 'rows', []]) {
  test(`an unreadable probe never gives film or numbers a pass (rows=${JSON.stringify(rows)})`, (t) => {
    assert.equal(judged(t, probe(rows)).outcome, 'unverifiable');
    const dir = fixture(t);
    put(dir, 'probe.json', probe(rows));
    assert.equal(numbersMain([dir], quiet), 3);
  });
}
test('a claimed saved still is unverifiable when the actual frame is missing', (t) => {
  const result = judged(t, probe(), { frames: [] });
  assert.equal(result.outcome, 'unverifiable');
  assert.ok(result.reasons.some((reason) => reason.includes('0')));
});
test('a stale probe cannot prove that this run observed anything', (t) => {
  const dir = fixture(t);
  const file = put(dir, 'probe.json', probe());
  utimesSync(file, new Date(0), new Date(0));
  assert.equal(judge(ok, { dir }, Date.now()).outcome, 'unverifiable');
});
test('a broken runner is fail even when its probe claims success', (t) => {
  assert.equal(judged(t, probe(), { result: { ...ok, out: 'SCRIPT ERROR: planted failure' } }).outcome, 'fail');
});

// Review: -1 means "no card" on a card's measures and 999 "no rig" on the facing; a feet row of 999
// or a screen position of -1 is a real number, so the sentinels are not fed to the other fields.
for (const invalid of [-1, null, '20', NaN, undefined]) {
  test(`numbers never measure sentinel or nonnumeric fields (${String(invalid)})`, () => {
    const fields = { feet_y: invalid, head_y: invalid, draw: [invalid, invalid],
      screen: Number.isFinite(invalid) ? [30, 20] : [invalid, invalid], facing_off: invalid === -1 ? 999 : invalid };
    const result = summarize([row(0, fields), row(1), row(2, fields)], 'rivet', '0-2');
    assert.deepEqual(result.reasons, []);
    for (const value of Object.values(result.stats.measures)) assert.equal(value.range, 0);
    const empty = summarize([row(0, fields)], 'rivet');
    assert.ok(empty.reasons.length, 'invalid values alone cannot establish a measurement');
  });
}
test('numbers never claim a drawn card from screen position when every card is absent', () => {
  const result = summarize([row(0, { feet_y: -1, head_y: -1, draw: [-1, -1], facing_off: 999 })], 'rivet');
  assert.ok(result.reasons.length, 'README says no card drawn at all is unverifiable');
});
test('numbers return unverifiable rather than crashing on an unreadable null probe row', (t) => {
  const dir = fixture(t);
  put(dir, 'probe.json', probe([null]));
  assert.equal(numbersMain([dir], quiet), 3);
});
test('numbers report chronological window endpoints even when probe rows arrive out of order', () => {
  const result = summarize([row(4), row(1), row(3)], 'rivet', '1-4');
  // Either reject damaged chronology or report the actual extent; ordering itself is not pinned.
  if (!result.reasons.length) assert.deepEqual([result.stats.from, result.stats.to], [1, 4]);
});
test('numbers never invent extrema when probe ticks repeat with conflicting values', () => {
  const result = summarize([row(1, { feet_y: 10 }), row(1, { feet_y: 90 })], 'rivet');
  // The contract does not specify a duplicate policy; rejection or literal extrema are both valid.
  if (!result.reasons.length) assert.deepEqual(result.stats.measures.feet_y, { min: 10, max: 90, range: 80 });
});
for (const flag of ['--bogus', '--json=yes', '--ticks=', '--ticks=4', '--subject=none']) {
  test(`numbers refuse malformed flags before reading a probe (${flag})`, (t) => {
    assert.equal(numbersMain([fixture(t), flag], quiet), 2);
  });
}

test('sheet never trusts a passing manifest instead of missing requested frames', async (t) => {
  const dir = fixture(t);
  put(dir, 'film.json', { outcome: 'pass', stills: [0, 333] });
  put(dir, 't0.png', png());
  const lines = [];
  assert.equal(await sheetMain([dir, `--out=${join(dir, 'sheet.png')}`, '--ticks=0,333'],
    { out: (line) => lines.push(line), err: quiet.err }), 3);
  assert.ok(lines.some((line) => line.includes('333')));
});
test('same sheet input is byte-identical with duplicate ticks, zero and equal-ended ranges', async (t) => {
  const dir = fixture(t);
  put(dir, 't0.png', png()); put(dir, 't2.png', png(2));
  const out = join(dir, 'sheet.PNG');
  const args = [dir, `--out=${out}`, '--ticks=2-2,0,2,0-0'];
  assert.equal(await sheetMain(args, quiet), 0);
  const first = readFileSync(out);
  assert.equal(await sheetMain(args, quiet), 0);
  assert.deepEqual(readFileSync(out), first);
});
for (const spelling of ['relative', 'dotdot', 'uppercase-extension']) {
  test(`sheet refuses its own frame through a different output spelling (${spelling})`, async (t) => {
    const dir = fixture(t);
    const frame = put(dir, 't333.png', png());
    let out = relative(process.cwd(), frame);
    if (spelling === 'dotdot') out = `${dir}/nested/../t333.png`;
    if (spelling === 'uppercase-extension') out = join(dir, 't333.PNG');
    assert.equal(await sheetMain([dir, `--out=${out}`], quiet), 2);
    assert.deepEqual(readFileSync(frame), png());
  });
}
test('sheet refuses case aliases of a film directory before deleting a t333.PNG frame', async (t) => {
  const root = fixture(t);
  const dir = join(root, 'Frames');
  const frame = put(dir, 't333.PNG', png());
  const alias = join(root, 'frames');
  if (!existsSync(alias)) { t.skip('requires a case-insensitive filesystem'); return; }
  const code = await sheetMain([dir, `--out=${join(alias, 't333.PNG')}`], quiet);
  assert.equal(existsSync(frame), true, 'case alias must not delete the source frame');
  assert.deepEqual(readFileSync(frame), png());
  assert.equal(code, 2);
});
test('sheet refuses a directory as output without deleting its contents', async (t) => {
  const dir = fixture(t);
  put(dir, 't0.png', png());
  const output = join(dir, 'directory.png');
  put(output, 'keep', 'untouched');
  const code = await sheetMain([dir, `--out=${output}`], quiet);
  assert.equal(readFileSync(join(output, 'keep'), 'utf8'), 'untouched');
  assert.equal(code, 2);
});
for (const flag of ['--unknown', '--cols=NaN', '--ticks=0, 2', '--ticks=1,', '--crop=0,0,0,1']) {
  test(`bad sheet flags are usage errors and preserve existing output (${flag})`, async (t) => {
    const dir = fixture(t);
    const output = put(dir, 'sheet.png', 'old sheet');
    assert.equal(await sheetMain([dir, `--out=${output}`, flag], quiet), 2);
    assert.equal(readFileSync(output, 'utf8'), 'old sheet');
  });
}
