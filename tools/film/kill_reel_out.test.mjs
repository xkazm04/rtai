import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { main } from './kill_reel.mjs';
import { resheet } from './kill_reel_out.mjs';
import { readPng } from './png.mjs';
import { encodePng } from './sheet.mjs';

/** A reel dir as a two-weapon --quick reel leaves it: reel.json plus each film's kept beat frames. */
function fakeReel(root) {
  const films = ['katana', 'rocket_launcher'].map((weapon, i) => {
    const dir = join(root, weapon, 'after_guard_d90_32');
    mkdirSync(dir, { recursive: true });
    for (const t of [60, 68, 69]) writeFileSync(join(dir, `t${t}.png`), encodePng(8, 6, Buffer.alloc(8 * 6 * 3, 40 + 50 * i)));
    return { weapon, victim: '', dir_deg: 90, ppm: 32, side: 'after', dir, outcome: 'pass', reasons: [], kill: 68, beats: [60, 68, 69],
      box: [0, 0, 8, 6], measured: { hitstop_frames: 6 + 2 * i, aftermath_share: 0.032, settled_by: 148, settled_after_ticks: 80 } };
  });
  const table = { katana: { id: 'katana_split', style: 'split', hitstop_ticks: 6, held_ticks: 6, grind_ticks: 0, stand_ticks: 0, crumble_ticks: 0, flash_ticks: 2 }, rocket_launcher: {} };
  writeFileSync(join(root, 'reel.json'), JSON.stringify({ schema: 'gtai.kill-reel/1', outcome: 'pass', argv: ['--out=x', '--quick'], sides: [], table, sheets: [], films }));
}

test('resheet rebuilds each weapon sheet, the overview and reel.md from reel.json and the kept beats', () => {
  const root = mkdtempSync(join(tmpdir(), 'kreel-resheet-'));
  try {
    fakeReel(root);
    const said = [];
    assert.equal(resheet(root, (s) => said.push(s)), 'pass');
    for (const f of ['katana_32.png', 'rocket_launcher_32.png', 'reel_32.png', 'reel.md']) assert.ok(existsSync(join(root, f)), f);
    const overview = readPng(join(root, 'reel_32.png'));
    assert.equal(overview.height, 2 * (6 + 18 + 4) + 4, 'one row per film, both weapons');
    const md = readFileSync(join(root, 'reel.md'), 'utf8');
    assert.match(md, /\| katana \| after \| guard \| 90 \| 32 \| PASS \| 68 \| 6 \| 6 \(katana_split\) \| \+80 \| 3\.2 % \| - \|/);
    assert.match(md, /\| rocket_launcher \|.*\| 8 \| standard death \|/);
    assert.ok(said.some((l) => /overview .*reel_32\.png/.test(l)));
    assert.equal(JSON.parse(readFileSync(join(root, 'reel.json'), 'utf8')).films.length, 2, 'the films stay as filmed');
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test('--resheet takes nothing else, and a dir without a reel is a usage error', async () => {
  const root = mkdtempSync(join(tmpdir(), 'kreel-resheet-'));
  try {
    const errs = [];
    assert.equal(await main([`--resheet=${root}`], { out: () => {}, err: (s) => errs.push(s) }), 2);
    assert.match(errs[0], /no reel\.json/);
    assert.equal(await main([`--resheet=${root}`, '--quick'], { out: () => {}, err: (s) => errs.push(s) }), 2);
    assert.match(errs[1], /takes nothing else/);
    assert.equal(await main(['--resheet'], { out: () => {}, err: (s) => errs.push(s) }), 2);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});
