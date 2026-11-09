import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { deflateSync } from 'node:zlib';
import { IDENTICAL_FRACTION, judgeTick, parseArgv as parseCompare, subjectRow, worst } from './compare.mjs';
import { judge, parseArgv, plan } from './film.mjs';
import { decodePng, diffImages } from './png.mjs';
import { copyRuntime } from '../lib/snapshot.mjs';
import { checkFlags, checkId, godotArgs, parseShot, shotLabel } from './shots.mjs';

function tree(files = {}) {
  const root = mkdtempSync(join(tmpdir(), 'gtai-film-test-'));
  const all = { 'project/project.godot': '', 'project/dev/frames/film_probe.gd': '',
    'project/data/tables/weapons.json': '{"weapons":[{"id":"pistol"},{"id":"gatling"}]}',
    'project/data/tables/view.json': '{"views":[{"id":"combo"},{"id":"top"}]}',
    'project/dev/showcase/reel_chapters.gd': 'Chapter.new(&"pistol", &"pistol")\nChapter.new(\n&"katana", &"katana")\n',
    'project/features/a.gd': 'if args.has("--lone"): pass\nvar x = "--cam=fight"\n', ...files };
  for (const [rel, text] of Object.entries(all)) {
    mkdirSync(join(root, rel, '..'), { recursive: true });
    writeFileSync(join(root, rel), text);
  }
  return root;
}

test('every shot is run with the arena scene, a bot and a fixed seed and step', () => {
  const args = godotArgs(parseShot('weapon:gatling'), { res: '1280x800', movie: null, ticks: 90, stills: [10], seed: '7',
    view: 'combo', ppm: '48', lock: 'spawn', dir: 'D', extra: [] });
  assert.equal(args[args.indexOf('--fixed-fps') + 1], '60');
  assert.equal(args[args.indexOf('--quit-after') + 1], '90');
  const dash = args.indexOf('--');
  assert.equal(args[dash - 1], 'res://dev/arena/arena.tscn');
  assert.ok(args.slice(dash).includes('--bot=gunplay'));
  assert.ok(args.slice(dash).includes('--weapon=gatling'));
  assert.ok(args.slice(dash).includes('--seed=7'));
  assert.ok(args.slice(dash).includes('--film-stills=10'));
});

test('the reel shots always carry the loadout (the omission that broke iteration 3 and 4 films)', () => {
  for (const s of ['arena', 'chapter:pistol']) {
    const args = godotArgs(parseShot(s), { res: 'a', movie: null, ticks: 9, stills: [], seed: '1', view: 'v', ppm: '1', lock: 'off', dir: 'D', extra: [] });
    assert.ok(args.includes('--loadout=pistol'), s);
  }
});

test('quest1 goes through its own recorder and needs even stills', () => {
  const args = godotArgs(parseShot('quest1'), { res: 'a', movie: null, ticks: 9, stills: [10], seed: '1', view: 'combo', ppm: '48', lock: 'off', dir: 'D', extra: [] });
  assert.equal(args[args.indexOf('-s') + 1], 'res://dev/frames/quest1_clip.gd');
  assert.ok(args.includes('--out=D') && args.includes('--stills=10') && !args.includes('--seed=1'));
  const t = tree();
  try {
    const base = { ...parseArgv([]).flags, out: 'o', tree: t };
    assert.match(plan({ ...base }, 'quest1', []).error, /even ticks/);
    assert.match(plan({ ...base, stills: '11' }, 'quest1', []).error, /even ticks/);
    assert.equal(plan({ ...base, stills: '10' }, 'quest1', []).opts.noProbe, true);
  } finally { rmSync(t, { recursive: true, force: true }); }
});

test('locking the camera also turns the camera feel off, since a shake would move the frame', () => {
  const on = godotArgs(parseShot('arena'), { res: 'a', movie: null, ticks: 9, stills: [], seed: '1', view: 'v', ppm: '1', lock: 'spawn', dir: 'D', extra: [] });
  const off = godotArgs(parseShot('arena'), { res: 'a', movie: null, ticks: 9, stills: [], seed: '1', view: 'v', ppm: '1', lock: 'off', dir: 'D', extra: [] });
  assert.ok(on.includes('--cam-lock=spawn') && on.includes('--feel=off'));
  assert.ok(!off.some((a) => a.startsWith('--cam-lock')) && !off.includes('--feel=off'));
});

test('shot names: unknown, missing id and stray id are refused', () => {
  assert.match(parseShot('arenaa').error, /unknown shot/);
  assert.match(parseShot('weapon').error, /needs an id/);
  assert.match(parseShot('arena:x').error, /takes no id/);
  assert.equal(shotLabel(parseShot('chapter:pistol')), 'chapter-pistol');
});

test('ids are checked against the filmed tree, with the nearest id named', () => {
  const t = tree();
  try {
    assert.equal(checkId('weapon', 'gatling', t), null);
    assert.match(checkId('weapon', 'pistl', t), /did you mean pistol/);
    assert.equal(checkId('chapter', 'katana', t), null, 'a chapter on the next line of its Chapter.new( counts');
    assert.match(checkId('view', 'zzzzzzzz', t), /known: combo top/);
  } finally { rmSync(t, { recursive: true, force: true }); }
});

test('an extra flag no script reads is refused with the nearest one', () => {
  const t = tree();
  try {
    assert.deepEqual(checkFlags(['--lone', '--cam=fight'], t), []);
    assert.match(checkFlags(['--loon'], t)[0], /did you mean --lone/);
  } finally { rmSync(t, { recursive: true, force: true }); }
});

test('plan: stills past the end, a bad lock and a tree without the probe launch nothing', () => {
  const t = tree();
  const base = { ...parseArgv([]).flags, out: 'o', tree: t };
  try {
    assert.match(plan({ ...base, ticks: '10', stills: '10' }, 'arena', []).error, /--stills must be ticks below 10/);
    assert.match(plan({ ...base, lock: 'nope' }, 'arena', []).error, /--lock/);
    assert.equal(plan({ ...base }, 'arena', []).error, undefined);
  } finally { rmSync(t, { recursive: true, force: true }); }
  const old = tree();
  try {
    rmSync(join(old, 'project/dev/frames/film_probe.gd'));
    assert.match(plan({ ...parseArgv([]).flags, out: 'o', tree: old }, 'arena', []).error, /older than the kit/);
  } finally { rmSync(old, { recursive: true, force: true }); }
});

function judged(probe, { stills = [], res = { status: 0, out: '', timedOut: false, durationMs: 1 }, stale = false } = {}) {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-film-judge-'));
  const startedAt = Date.now();
  if (probe) writeFileSync(join(dir, 'probe.json'), JSON.stringify(probe));
  if (stale) utimesSync(join(dir, 'probe.json'), new Date(startedAt - 60000), new Date(startedAt - 60000));
  for (const t of stills) writeFileSync(join(dir, `t${t}.png`), 'x');
  try { return judge(res, { dir, stills: [100], res: '10x10', subject: 'rivet' }, startedAt); } finally { rmSync(dir, { recursive: true, force: true }); }
}
const onScreen = { role: 'rivet', on_screen: true, screen: [1, 1] };
const goodProbe = { rows: [{ tick: 100, fighters: [onScreen] }], stills: [100], view: [10, 10] };

test('judge passes only on a fresh probe with the stills it was asked for', () => {
  assert.equal(judged(goodProbe, { stills: [100] }).outcome, 'pass');
});

test('judge: a broken run is a fail, never unverifiable', () => {
  const r = judged(goodProbe, { stills: [100], res: { status: 0, out: 'SCRIPT ERROR: boom', timedOut: false, durationMs: 1 } });
  assert.equal(r.outcome, 'fail');
  assert.equal(judged(goodProbe, { res: { status: 1, out: '', timedOut: false, durationMs: 1 } }).outcome, 'fail');
  assert.equal(judged(goodProbe, { res: { status: -1, out: '', timedOut: true, durationMs: 1 } }).outcome, 'fail');
});

test('judge: a still whose subject is not in frame is unverifiable', () => {
  const off = { ...goodProbe, rows: [{ tick: 100, fighters: [{ ...onScreen, on_screen: false, screen: [5000, 1] }] }] };
  const r = judged(off, { stills: [100] });
  assert.equal(r.outcome, 'unverifiable');
  assert.match(r.reasons[0], /rivet is off screen at tick 100/);
  assert.equal(judged({ ...goodProbe, rows: [{ tick: 100, fighters: [] }] }, { stills: [100] }).outcome, 'unverifiable');
});

test('a movie is only filmed when asked for or when there is no still to take', () => {
  const planned = (extra) => {
    const t = tree();
    try { return plan({ ...parseArgv([]).flags, out: 'o', tree: t, ...extra }, 'arena', []).opts.movie; } finally { rmSync(t, { recursive: true, force: true }); }
  };
  assert.equal(planned({ stills: '10' }), null);
  assert.match(planned({ stills: '10', movie: true }), /arena\.avi$/);
  assert.match(planned({}), /arena\.avi$/);
  assert.equal(planned({ 'no-movie': true }), null);
});

test('a street shot locks at the first tick that matters, the rest at the spawn', () => {
  const planned = (shot, extra) => {
    const t = tree();
    try { return plan({ ...parseArgv([]).flags, out: 'o', tree: t, ...extra }, shot, []); } finally { rmSync(t, { recursive: true, force: true }); }
  };
  assert.equal(planned('weapon:gatling', { stills: '300,250' }).opts.lock, 'at:250');
  assert.equal(planned('weapon:gatling', {}).opts.lock, 'off', 'no tick to freeze at');
  assert.equal(planned('arena', { stills: '300' }).opts.lock, 'spawn');
  assert.equal(planned('arena', { lock: 'at:9' }).opts.lock, 'at:9');
  assert.match(planned('arena', { lock: 'at:x' }).error, /--lock/);
});

test('judge: what it could not observe is unverifiable, never pass', () => {
  assert.equal(judged(null).outcome, 'unverifiable');
  assert.equal(judged(goodProbe, { stale: true, stills: [100] }).outcome, 'unverifiable', 'a previous run\'s probe.json');
  assert.equal(judged({ ...goodProbe, rows: [] }, { stills: [100] }).outcome, 'unverifiable');
  assert.equal(judged({ ...goodProbe, stills: [] }, { stills: [100] }).outcome, 'unverifiable', 'the probe did not save it');
  assert.equal(judged(goodProbe).outcome, 'unverifiable', 'no file on disk');
  assert.equal(judged({ ...goodProbe, view: [640, 400] }, { stills: [100] }).outcome, 'unverifiable', 'drew another size');
});

// A minimal PNG writer for the decoder's tests: filter 0 scanlines.
function png(width, height, pixel, filter = 0) {
  const crcTable = Array.from({ length: 256 }, (_, n) => {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    return c >>> 0;
  });
  const crc = (b) => { let c = 0xffffffff; for (const x of b) c = crcTable[(c ^ x) & 255] ^ (c >>> 8); return (c ^ 0xffffffff) >>> 0; };
  const chunk = (type, body) => {
    const b = Buffer.concat([Buffer.from(type, 'latin1'), body]);
    const out = Buffer.alloc(body.length + 12);
    out.writeUInt32BE(body.length, 0);
    b.copy(out, 4);
    out.writeUInt32BE(crc(b), body.length + 8);
    return out;
  };
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 2;
  const raw = Buffer.alloc((width * 3 + 1) * height);
  for (let y = 0; y < height; y++) {
    raw[y * (width * 3 + 1)] = filter;
    for (let x = 0; x < width; x++) {
      const [r, g, b] = pixel(x, y);
      raw.set([r, g, b], y * (width * 3 + 1) + 1 + x * 3);
    }
  }
  return Buffer.concat([Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]), chunk('IHDR', ihdr), chunk('IDAT', deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

test('decodePng reads the pixels it was given', () => {
  const img = decodePng(png(3, 2, (x, y) => [x * 10, y * 10, 7]));
  assert.deepEqual([img.width, img.height, img.channels], [3, 2, 3]);
  assert.deepEqual([...img.data.subarray(3, 6)], [10, 0, 7]);
});

test('decodePng undoes the Sub filter (Godot writes filtered rows)', () => {
  const img = decodePng(png(2, 1, (x) => (x === 0 ? [5, 6, 7] : [1, 1, 1]), 1));
  assert.deepEqual([...img.data], [5, 6, 7, 6, 7, 8]);
});

test('decodePng refuses what it cannot read exactly', () => {
  assert.throws(() => decodePng(Buffer.from('not a png, not a png')), /not a PNG/);
});

test('diffImages: tolerance, the box round the change and a size mismatch', () => {
  const flat = decodePng(png(4, 4, () => [100, 100, 100]));
  const noise = decodePng(png(4, 4, () => [103, 100, 100]));
  const spot = decodePng(png(4, 4, (x, y) => (x === 2 && y === 1 ? [200, 0, 0] : [100, 100, 100])));
  assert.equal(diffImages(flat, noise).changed, 0, 'within the tolerance');
  const d = diffImages(flat, spot);
  assert.deepEqual([d.changed, d.box], [1, [2, 1, 2, 1]]);
  assert.throws(() => diffImages(flat, decodePng(png(3, 4, () => [0, 0, 0]))), /different sizes/);
});

const row = (on, x = 0) => ({ id: 0, role: 'rivet', alive: true, on_screen: on, screen: [5000, 10], pos: [x, 0] });
const diff = (f) => ({ fraction: f, changed: f * 1000, total: 1000 });

test('identical sides are unverifiable, even with the subject on screen', () => {
  const r = judgeTick({ diff: diff(0), subjectA: row(true), subjectB: row(true), subject: 'rivet' });
  assert.equal(r.outcome, 'unverifiable');
  assert.match(r.reasons[0], /identical/);
  assert.equal(judgeTick({ diff: diff(IDENTICAL_FRACTION), subjectA: row(true), subjectB: row(true), subject: 'rivet' }).outcome, 'unverifiable');
});

test('a subject off screen or absent on either side is unverifiable', () => {
  assert.equal(judgeTick({ diff: diff(0.3), subjectA: row(false), subjectB: row(true), subject: 'rivet' }).outcome, 'unverifiable');
  assert.equal(judgeTick({ diff: diff(0.3), subjectA: row(true), subjectB: row(false), subject: 'rivet' }).outcome, 'unverifiable');
  assert.equal(judgeTick({ diff: diff(0.3), subjectA: row(true), subjectB: null, subject: 'dead' }).outcome, 'unverifiable');
});

test('a real difference with the subject on screen passes; a moved timeline is only a note', () => {
  const r = judgeTick({ diff: diff(0.3), subjectA: row(true), subjectB: row(true, 2), subject: 'rivet' });
  assert.equal(r.outcome, 'pass');
  assert.match(r.notes[0], /moved apart/);
});

test('subjectRow prefers an on-screen fighter and never invents one', () => {
  const list = [{ id: 0, role: 'rivet', alive: true, on_screen: true }, { id: 5, role: 'hostile', alive: true, on_screen: false },
    { id: 6, role: 'hostile', alive: true, on_screen: true }, { id: 7, role: 'hostile', alive: false, on_screen: false }];
  assert.equal(subjectRow({ fighters: list }, 'hostile').id, 6);
  assert.equal(subjectRow({ fighters: list }, 'dead').id, 7);
  assert.equal(subjectRow({ fighters: list }, 'id:5').id, 5);
  assert.equal(subjectRow({ fighters: list }, 'id:99'), null);
  assert.equal(subjectRow(undefined, 'rivet'), null);
});

test('worst keeps the outcome that matters', () => {
  assert.equal(worst(['pass', 'unverifiable']), 'unverifiable');
  assert.equal(worst(['unverifiable', 'fail', 'pass']), 'fail');
  assert.equal(worst(['pass', 'pass']), 'pass');
});

test('copyRuntime takes each ignored dir from the first donor that has it and never overwrites', () => {
  const [a, b, to] = ['a', 'b', 'c'].map(() => mkdtempSync(join(tmpdir(), 'gtai-film-donor-')));
  try {
    mkdirSync(join(a, 'project/native/bin'), { recursive: true });
    writeFileSync(join(a, 'project/native/bin/x.dll'), 'a');
    mkdirSync(join(b, 'project/native/bin'), { recursive: true });
    writeFileSync(join(b, 'project/native/bin/x.dll'), 'b');
    mkdirSync(join(b, 'project/data/generated/city'), { recursive: true });
    writeFileSync(join(b, 'project/data/generated/city/c.gtch'), 'city');
    const copied = copyRuntime([a, b], to);
    assert.deepEqual(copied.sort(), ['project/data/generated/city', 'project/native/bin']);
    assert.equal(readFileSync(join(to, 'project/native/bin/x.dll'), 'utf8'), 'a', 'the first donor wins');
    assert.equal(readFileSync(join(to, 'project/data/generated/city/c.gtch'), 'utf8'), 'city', 'from the sibling');
    assert.deepEqual(copyRuntime([a, b], to), [], 'already there');
  } finally { for (const d of [a, b, to]) rmSync(d, { recursive: true, force: true }); }
});

test('compare needs both sides, ticks, an output and a real subject', () => {
  assert.match(parseCompare(['arena', '--a=x', '--at=1', '--out=o']).error, /--b=/);
  assert.match(parseCompare(['arena', '--a=x', '--b=y', '--at=soon', '--out=o']).error, /--at/);
  assert.match(parseCompare(['arena', '--a=x', '--b=y', '--at=1', '--out=o', '--subject=boss']).error, /--subject/);
  assert.equal(parseCompare(['arena', '--a=x', '--b=y', '--at=1,2', '--out=o']).shotText, 'arena');
});
