import assert from 'node:assert/strict';
import test from 'node:test';
import { mkdirSync, mkdtempSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { deflateSync } from 'node:zlib';
import { decodePng, diffImages } from './png.mjs';
import { IDENTICAL_FRACTION, judgeTick, parseArgv as parseCompare, worst } from './compare.mjs';
import { judge, parseArgv as parseFilm, plan } from './film.mjs';
import { checkFlags, godotArgs, parseShot } from './shots.mjs';
import { subjectRow } from './subject.mjs';

// CRCs are real: corruption tests must not rely on the decoder ignoring invalid fixtures.
function chunk(type, body) {
  const bytes = Buffer.concat([Buffer.from(type), body]);
  let crc = 0xffffffff;
  for (const byte of bytes) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
  }
  const result = Buffer.alloc(body.length + 12);
  result.writeUInt32BE(body.length);
  bytes.copy(result, 4);
  result.writeUInt32BE((crc ^ 0xffffffff) >>> 0, body.length + 8);
  return result;
}

function png({ width = 2, height = 2, channels = 3, depth = 8, compression = 0,
  interlace = 0, raw = Buffer.from([0, 10, 20, 30, 40, 50, 60, 0, 70, 80, 90, 100, 110, 120]) } = {}) {
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width);
  header.writeUInt32BE(height, 4);
  header.set([depth, channels === 4 ? 6 : 2, compression, 0, interlace], 8);
  return Buffer.concat([Buffer.from('89504e470d0a1a0a', 'hex'), chunk('IHDR', header),
    chunk('IDAT', deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

// Hand-calculated residuals, independent of the decoder's predictor implementation.
const filterCases = [
  ['Up', [0, 10, 20, 30, 40, 50, 60, 2, 60, 60, 60, 60, 60, 60]],
  ['Average', [0, 10, 20, 30, 40, 50, 60, 3, 65, 70, 75, 45, 45, 45]],
  ['Paeth', [0, 10, 20, 30, 40, 50, 60, 4, 60, 60, 60, 30, 30, 30]],
  ['Paeth wraparound', [0, 250, 240, 230, 4, 10, 20, 4, 11, 22, 33, 5, 5, 6],
    [250, 240, 230, 4, 10, 20, 5, 6, 7, 9, 11, 13]],
];
for (const [name, raw, expected = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120]] of filterCases) {
  test(`PNG exact pixels: ${name} reconstructs both edge and interior pixels`, () => {
    assert.deepEqual([...decodePng(png({ raw: Buffer.from(raw) })).data], expected);
  });
}

for (const [name, make] of [
  ['bad signature', () => Buffer.from('not a PNG')],
  ['truncated chunk length', () => png().subarray(0, 10)],
  ['wrong bit depth', () => png({ depth: 16 })],
  ['interlaced data', () => png({ interlace: 1 })],
  ['short inflated rows', () => png({ raw: Buffer.from([0, 1, 2]) })],
  ['extra inflated rows', () => png({ raw: Buffer.alloc(30) })],
  ['unknown row filter', () => png({ raw: Buffer.from([5, 10, 20, 30, 40, 50, 60, 0, 70, 80, 90, 100, 110, 120]) })],
  ['corrupt IHDR CRC', () => { const b = png(); b[29] ^= 1; return b; }],
  ['missing IEND', () => png().subarray(0, -12)],
  ['truncated IEND CRC', () => png().subarray(0, -1)],
  ['unsupported compression method', () => png({ compression: 1 })],
  ['zero width', () => png({ width: 0, height: 1, raw: Buffer.from([0]) })],
  ['zero height', () => png({ height: 0, raw: Buffer.alloc(0) })],
]) {
  test(`PNG exact-read refusal: ${name} must throw rather than produce comparison evidence`, () => {
    assert.throws(() => decodePng(make()));
  });
}

test('pixel comparison: RGB and opaque RGBA use their own strides in both directions', () => {
  const rgb = decodePng(png());
  const rgba = decodePng(png({ channels: 4,
    raw: Buffer.from([0, 10, 20, 30, 255, 40, 50, 60, 255, 0, 70, 80, 90, 255, 100, 110, 120, 255]) }));
  assert.equal(diffImages(rgb, rgba).changed, 0);
  rgba.data[12] += 5;
  for (const pair of [[rgb, rgba], [rgba, rgb]]) {
    const d = diffImages(...pair);
    assert.deepEqual([d.changed, d.total, d.fraction, d.box], [1, 4, 0.25, [1, 1, 1, 1]]);
  }
});

const fighter = (overrides = {}) => ({ id: 1, role: 'rivet', alive: true, on_screen: true,
  screen: [1, 1], pos: [0, 0], ...overrides });
const difference = (fraction) => ({ fraction, changed: fraction * 100000, total: 100000 });
const tick = (overrides = {}) => judgeTick({ diff: difference(0.1), subjectA: fighter(),
  subjectB: fighter(), subject: 'rivet', ...overrides });

for (const side of ['subjectA', 'subjectB']) {
  test(`compare observation: missing ${side} cannot pass even when pictures differ`, () => {
    assert.equal(tick({ [side]: null }).outcome, 'unverifiable');
  });
  test(`compare observation: off-screen ${side} without coordinates is unverifiable, not a crash`, () => {
    assert.equal(tick({ [side]: fighter({ on_screen: false, screen: undefined }) }).outcome, 'unverifiable');
  });
}
for (const fraction of [NaN, undefined]) {
  test(`compare observation: ${String(fraction)} pixel fraction cannot prove a difference`, () => {
    assert.equal(tick({ diff: difference(fraction) }).outcome, 'unverifiable');
  });
}
test('compare honesty: identical threshold is inclusive and timeline drift is only a note', () => {
  assert.equal(tick({ diff: difference(IDENTICAL_FRACTION) }).outcome, 'unverifiable');
  const result = tick({ subjectB: fighter({ pos: [10, 0] }) });
  assert.equal(result.outcome, 'pass');
  assert.ok(result.notes.length > 0);
});
test('compare aggregation: fail dominates unverifiable regardless of permutation', () => {
  for (const outcomes of [['pass', 'fail', 'unverifiable'], ['unverifiable', 'pass', 'fail'], ['fail', 'unverifiable', 'pass']]) {
    assert.equal(worst(outcomes), 'fail');
  }
  assert.equal(worst(['pass', 'unverifiable', 'pass']), 'unverifiable');
});

function fixture(t) {
  const root = mkdtempSync(join(tmpdir(), 'gtai-film-break-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const files = {
    'project/project.godot': '', 'project/dev/frames/film_probe.gd': '',
    'project/data/tables/weapons.json': '{"weapons":[{"id":"pistol"}]}',
    'project/data/tables/view.json': '{"views":[{"id":"combo"}]}',
    'project/dev/showcase/reel_chapters.gd': 'Chapter.new(&"pistol")',
    'project/features/flags.gd': 'args.has("--lone")\n',
    'project/addons/vendor.gd': 'args.has("--vendor-only")',
    'project/.godot/cache.gd': 'args.has("--cache-only")',
  };
  for (const [name, contents] of Object.entries(files)) {
    mkdirSync(join(root, name, '..'), { recursive: true });
    writeFileSync(join(root, name), contents);
  }
  return root;
}
function judged(t, probeText, { staleProbe = false, staleStill = false, missingStill = false, noProbe = false } = {}) {
  const dir = fixture(t);
  const startedAt = Date.now() - 100;
  if (probeText !== undefined) writeFileSync(join(dir, 'probe.json'), probeText);
  const name = join(dir, noProbe ? 'still_2_48.png' : 't2.png');
  if (!missingStill) writeFileSync(name, png());
  const old = new Date(startedAt - 60000);
  if (staleProbe) utimesSync(join(dir, 'probe.json'), old, old);
  if (staleStill) utimesSync(name, old, old);
  return judge({ status: 0, out: '', timedOut: false, durationMs: 1 },
    { dir, stills: [2], res: '2x2', subject: 'rivet', ppm: '48', noProbe }, startedAt);
}
const probe = () => ({ view: [2, 2], stills: [2], rows: [{ tick: 2, fighters: [fighter()] }] });
for (const [name, text] of [
  ['truncated JSON', '{"rows":'], ['JSON null', 'null'],
  ['non-array rows', JSON.stringify({ ...probe(), rows: { length: 1 } })],
  ['non-array fighters', JSON.stringify({ ...probe(), rows: [{ tick: 2, fighters: {} }] })],
]) {
  test(`film three-valued judgement: ${name} probe is unverifiable rather than an uncaught exception`, (t) => {
    assert.equal(judged(t, text).outcome, 'unverifiable');
  });
}
for (const option of ['staleProbe', 'staleStill', 'missingStill']) {
  test(`film observation: ${option} cannot borrow a pass from fresh probe numbers`, (t) => {
    assert.equal(judged(t, JSON.stringify(probe()), { [option]: true }).outcome, 'unverifiable');
  });
}
test('film fixture control: fresh probe and valid requested still can pass', (t) => {
  assert.equal(judged(t, JSON.stringify(probe())).outcome, 'pass');
});
test('quest observation: a stale recorder still cannot pass without a probe', (t) => {
  assert.equal(judged(t, undefined, { noProbe: true, staleStill: true }).outcome, 'unverifiable');
});
test('film subject observation: missing off-screen coordinates cannot crash judgement', (t) => {
  const p = probe();
  p.rows[0].fighters[0] = fighter({ on_screen: false, screen: undefined });
  assert.equal(judged(t, JSON.stringify(p)).outcome, 'unverifiable');
});

for (const bad of ['weapon:pistol:ignored', 'arena:ignored:tail', 'toString', '__proto__']) {
  test(`shot refusal: ${bad} cannot resolve to an undocumented shot or discard part of its id`, () => {
    assert.ok(parseShot(bad).error);
  });
}
test('flag validation: dependency and import-cache flags do not authorize game arguments', (t) => {
  const root = fixture(t);
  assert.equal(checkFlags(['--lone'], root).length, 0);
  assert.equal(checkFlags(['--vendor-only', '--cache-only', '--never-read=1'], root).length, 3);
});
test('flag validation: a comment alone cannot prove that any script reads a flag', (t) => {
  const root = fixture(t);
  writeFileSync(join(root, 'project/features/comment.gd'), '# args.has("--only-commented")\n');
  assert.ok(checkFlags(['--only-commented'], root).length > 0);
});
for (const [name, flags] of [
  ['unknown weapon', {}], ['unknown view', { view: 'absent' }],
  ['still at run end', { ticks: '2', stills: '2' }], ['noninteger still', { stills: '1.5' }],
]) {
  test(`film preflight refusal: ${name} returns usage before any launcher is needed`, (t) => {
    const root = fixture(t);
    assert.ok(plan({ ...parseFilm([]).flags, tree: root, out: root, ...flags },
      name === 'unknown weapon' ? 'weapon:absent' : 'arena', []).error);
  });
}
test('film preflight refusal: malformed numeric camera coordinates cannot launch', (t) => {
  const root = fixture(t);
  assert.ok(plan({ ...parseFilm([]).flags, tree: root, out: root, lock: '..,.' }, 'arena', []).error);
});
test('film arguments: unknown and empty flags are refused and passthrough stays literal', () => {
  for (const args of [['arena', '--out='], ['arena', '--no-movie=true'], ['arena', '--unknown=x'], ['arena', 'city']]) {
    assert.ok(parseFilm(args).error);
  }
  assert.deepEqual(parseFilm(['arena', '--out=x', '--', '--lone', '--weapon=pistol']).extra,
    ['--lone', '--weapon=pistol']);
});
test('compare arguments: malformed ticks, subject, clip and unknown flags are refused', () => {
  const base = ['arena', '--a=a', '--b=b', '--out=o', '--at=1'];
  for (const flag of ['--at=NaN', '--at=-1', '--at=1,', '--subject=id:-1', '--clip=1:2', '--unknown=x']) {
    assert.ok(parseCompare([...base, flag]).error, flag);
  }
  assert.deepEqual(parseCompare([...base, '--', '--lone']).extra, ['--lone']);
});
test('Godot argument construction: scene and engine controls precede the separator for every arena shot', () => {
  for (const name of ['arena', 'city', 'weapon:pistol', 'chapter:pistol']) {
    const args = godotArgs(parseShot(name), { res: '2x2', ticks: 10, stills: [2], seed: '123',
      view: 'combo', ppm: '48', lock: 'spawn', dir: 'space dir', extra: [], movie: null });
    const dash = args.indexOf('--');
    assert.equal(args[dash - 1], 'res://dev/arena/arena.tscn');
    assert.equal(args[args.indexOf('--fixed-fps') + 1], '60');
    assert.ok(args.slice(dash + 1).includes('--seed=123'));
    assert.ok(args.slice(dash + 1).includes('--feel=off'));
    assert.ok(args.slice(dash + 1).some((a) => a.startsWith('--bot=')));
  }
});
test('subject selection: a live hostile cannot substitute for the requested corpse', () => {
  assert.equal(subjectRow({ fighters: [fighter({ role: 'hostile' })] }, 'dead'), null);
  assert.equal(subjectRow(undefined, 'id:1'), null);
});
test('subject observation: absent alive data is not evidence of a dead hostile', () => {
  assert.equal(subjectRow({ fighters: [fighter({ role: 'hostile', alive: undefined })] }, 'dead'), null);
});
test('subject selection: visible corpse wins over a hidden corpse and a visible live fighter', () => {
  const fighters = [fighter({ id: 2, role: 'hostile', alive: false, on_screen: false }),
    fighter({ id: 3, role: 'hostile' }), fighter({ id: 4, role: 'hostile', alive: false })];
  assert.equal(subjectRow({ fighters }, 'dead').id, 4);
  assert.equal(subjectRow({ fighters }, 'hostile').id, 3);
  assert.equal(subjectRow({ fighters }, 'id:2').id, 2);
});
