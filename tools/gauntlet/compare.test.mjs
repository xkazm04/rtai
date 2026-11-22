import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { test } from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { compare } from './compare.mjs';
import { BATCH_SCHEMA } from './contract.mjs';
import { targets } from './death_score.mjs';

const fixture = JSON.parse(readFileSync(new URL('./fixtures/average-1.json', import.meta.url)));
const hp = { start: 80, min: 60, end: 65, max: 100, repaired: 5 };

function result(profile, seed, wave, by) {
  const { death, ...run } = fixture;
  return { ...run, profile, seed, wave_reached: wave, waves: [], picks: [],
    ...(by && { death: { by, wave } }) };
}

function manifest(results, args = {}) {
  return { schema: BATCH_SCHEMA, git: { sha: '12345678901234567890', dirty: true },
    args: { controls: 'legacy', pick: 'greedy', waves: 40, ...args }, results,
    runs: results.map(({ profile, seed }) => ({ profile, seed, ok: true })) };
}

function workspace(t) {
  const parent = join(ROOT, 'build/n23');
  mkdirSync(parent, { recursive: true });
  const dir = mkdtempSync(join(parent, 'compare-test-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const save = (file, data) => {
    const path = join(dir, file);
    writeFileSync(path, JSON.stringify(data));
    return path;
  };
  const out = join(dir, 'out', 'comparison');
  const render = (before, after = before, options = []) => {
    compare(['--arm=before=' + save('before.json', before), '--arm=after=' + save('after.json', after),
      '--out=' + out, ...options]);
    return { md: readFileSync(out + '.md', 'utf8'), html: readFileSync(out + '.html', 'utf8') };
  };
  return { dir, save, out, render };
}

test('wave-limit and historic tick-cap scores retain their median and miss lower bounds', (t) => {
  const batch = manifest([result('average', 1, 6, 'stomp'), result('average', 2, 40), result('average', 3, 40)]);
  const capped = manifest([result('expert', 1, 31)], { waves: null });
  Object.assign(capped.runs[0], { outcome: 'capped', ticks: 72000 });
  const { md, html } = workspace(t).render(batch, capped);
  assert.match(md, /before \| average \| 3 \| 1 \| 2 \| 0 \| 0 \| >= 40 \| 6–40 \| 12 \| >= \+28/);
  assert.match(md, /after \| expert \| 1 \| 0 \| 1 \| 0 \| 0 \| >= 31 \| 31–31 \| 20 \| >= \+11/);
  assert.match(html, /no wave limit · 72000-tick cap/);
  assert.match(html, /&gt;= 40/);
});

test('HP medians use measured per-wave ratios, including genuine zero repair', (t) => {
  const a = result('average', 1, 10, 'stomp');
  a.waves = [{ n: 1, damage_taken: 30, seconds: 3 }, { n: 5, seconds: 25 }, { n: 10, seconds: 35 }];
  const b = { ...a, waves: [...a.waves, { n: 2, seconds: 4, damage_taken: 20, hp },
    { n: 3, seconds: 2, damage_taken: 4, hp: { ...hp, repaired: 0 } },
    { n: 4, hp, damage_taken: 0 }] };
  const { md } = workspace(t).render(manifest([a]), manifest([b]));
  assert.match(md, /before \| average .*\| 3 \| 25 \| 35 \| not measured \| not measured \| not measured \| 30 \| not measured \| not measured \| stomp × 1/);
  assert.match(md, /after \| average .*\| 30 \| 3.5 \| 12.5% \| stomp × 1/);
});

test('two censored runs are not separated and unmatched seeds do not enter the denominator', (t) => {
  const batch = manifest([result('novice', 1, 4, 'rocket'), result('average', 1, 40),
    result('average', 2, 40), result('expert', 1, 40)]);
  const { md } = workspace(t).render(batch);
  assert.match(md, /before \| novice → average \| \+36 \| 1\/1 \(100%\) \| separated/);
  assert.match(md, /before \| average → expert \| 0 \| 0\/1 \(0%\) \| not separated/);
});

test('a censored upper tail leaves an exact median and only the three leading killers are listed', (t) => {
  const depths = [2, 3, 4, 5, 6, 7, 8, 9, 10, 40];
  const killers = ['a', 'b', 'b', 'c', 'c', 'c', 'd', 'd', 'd'];
  const batch = manifest(depths.map((wave, i) => result('novice', i + 1, wave, killers[i])));
  const { md } = workspace(t).render(batch);
  assert.match(md, /before \| novice \| 10 \| 9 \| 1 \| 0 \| 0 \| 6.5 \| 4–9 \| 6 \| \+0.5/);
  assert.match(md, /\| c × 3, d × 3, b × 2 \|/);
  assert.doesNotMatch(md, /a × 1/);
});

test('only launcher timeouts without a result enter the timeout column', (t) => {
  const batch = manifest([result('novice', 1, 4, 'timeout'), result('novice', 2, 4, 'rocket')]);
  batch.runs.push({ profile: 'novice', seed: 3, ok: false, reason: 'FAIL timeout after 602 s; result missing' },
    { profile: 'novice', seed: 4, ok: false, reason: 'parse error' });
  const { md } = workspace(t).render(batch);
  assert.match(md, /before \| novice \| 4 \| 1 \| 0 \| 1 \| 1 \| 4 \| 4–4/);
});

test('two arms produce two ordered HTML columns with their own settings and safe labels', (t) => {
  const { save, out } = workspace(t);
  const path = save('batch=1.json', manifest([result('expert', 1, 20, 'rocket')]));
  compare(['--arm=A & B=' + path, '--arm=<after>=' + path, '--out=' + out]);
  const html = readFileSync(out + '.html', 'utf8');
  const headers = [...html.matchAll(/<th class="arm" scope="col">([^<]*)<\/th>/g)].map((m) => m[1]);
  assert.deepEqual(headers, ['A &amp; B', '&lt;after&gt;']);
  assert.match(html, /123456789012 \(dirty\).*1 seed \(1\) · expert · --waves=40 · pick greedy · controls legacy/);
  assert.match(html, /<tr class="data"><th scope="row">expert<\/th><td>.*?<\/td><td>.*?<\/td><\/tr>/);
  assert.doesNotMatch(html, /<script|<img|<link|https?:\/\//i);
});

test('a custom targets file controls death misses, boss ordinals and the separation verdict', (t) => {
  const { render, save } = workspace(t);
  const a = result('average', 1, 6, 'stomp');
  a.waves = [{ n: 2, seconds: 31 }, { n: 5, seconds: 20 }];
  const batch = manifest([result('novice', 1, 4, 'rocket'), a]);
  const path = save('targets.json', { ...targets, death_wave: { ...targets.death_wave, average: 6 },
    boss_every: 2, separation: { min_seed_share: 1, min_wave_gap: 2 } });
  const { md } = render(batch, batch, ['--targets=' + path]);
  assert.match(md, /before \| average .*\| 6 \| 6–6 \| 6 \| 0 \| 31 \| 20 .*\| 31 \| not measured/);
  assert.match(md, /before \| novice → average \| \+2 \| 1\/1 \(100%\) \| separated/);
});

test('malformed and missing arm inputs exit 2 with one diagnostic and no page', (t) => {
  const { dir, out, save } = workspace(t);
  const valid = save('valid.json', manifest([result('average', 1, 6, 'stomp')]));
  for (const [arm, error] of [['--arm=unlabelled', /expected --arm=/],
    ['--arm=after=' + join(dir, 'absent.json'), /absent\.json/]]) {
    const r = spawnSync(process.execPath, [join(ROOT, 'tools/gauntlet/compare.mjs'),
      '--arm=before=' + valid, arm, '--out=' + out], { encoding: 'utf8' });
    assert.equal(r.status, 2);
    assert.equal(r.stdout, '');
    assert.equal(r.stderr.trimEnd().split(/\r?\n/).length, 1);
    assert.match(r.stderr, error);
    assert.ok(!existsSync(out + '.md') && !existsSync(out + '.html'));
  }
});
