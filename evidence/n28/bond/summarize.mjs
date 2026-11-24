// Join the real rest picks to their street blocks. Several waves can share a block.
// node evidence/n28/bond/summarize.mjs <result directory> <dev log directory> <result prefix> [arm]
// A free mastery is its own run.picks entry (taken master_*) beside the rest's one normal pick.
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { basename, join } from 'node:path';

const [results, logs, prefix, arm = 'arm'] = process.argv.slice(2);
const forms = ['dent', 'kerf', 'ohm', 'tonnage'];
const counts = () => Object.fromEntries(forms.map(f => [f, 0]));
const round = value => Math.round(value * 100) / 100;
const runs = [];
const byResult = new Map();
for (const file of readdirSync(logs).filter(f => /^(gauntlet|bond_measure)-.*\.log$/.test(f)).sort()) {
  const log = readFileSync(join(logs, file), 'utf8');
  const path = log.split('\n', 1)[0].match(/--result=(.+\.json)\s*$/)?.[1];
  if (path && log.includes('# exit 0,') && !log.includes('SCRIPT ERROR')) byResult.set(basename(path), log);
}

for (let seed = 1; seed <= 10; seed++) {
  const file = readdirSync(results).find(f => f === prefix + seed + '.json' || f === prefix + seed + '-15.json');
  const run = JSON.parse(readFileSync(join(results, file), 'utf8'));
  const log = byResult.get(file);
  assert.equal(run.seed, seed);
  assert.equal(run.profile, 'average');
  assert.ok(!run.capped && (run.death || run.wave_reached === 15));
  const starts = [...log.matchAll(/gauntlet: wave (\d+) tick (\d+) block (\d+),/g)]
    .map(m => ({ n: Number(m[1]), tick: Number(m[2]), block: Number(m[3]) }));
  assert.equal(starts.length, run.waves.length);
  // SimLoop increments the clock after sampling the fatal stage tick.
  const stop = Number(log.match(/gauntlet: tick (\d+), segment/)[1]) - 1;
  const trace = log.match(/bond-observer\]?: (\{.*\})/);
  const observer = trace ? JSON.parse(trace[1]) : null;
  const mastery = Object.fromEntries(forms.map(f => [f, null]));
  const waves = run.waves.map(w => {
    const start = starts[w.n - 1];
    assert.equal(start.n, w.n);
    const end = w.seconds == null ? stop : start.tick + Math.round(w.seconds * 60);
    const seconds = (end - start.tick) / 60;
    assert.ok(seconds <= 180, 'FAIL seed ' + seed + ' wave ' + w.n + ' ran ' + seconds + ' s');
    const inWave = event => event.tick > start.tick && event.tick <= end;
    const owned = run.picks.filter(p => starts[p.wave - 1].block < start.block && p.taken.startsWith('ghost_'))
      .map(p => p.taken.slice(6)).sort();
    const here = run.picks.filter(p => p.wave === w.n);
    const pick = here.find(p => !p.taken.startsWith('master_'));
    const masteries = here.filter(p => p.taken.startsWith('master_')).map(p => p.taken);
    for (const id of masteries) mastery[id.slice(7)] = starts.filter(s => s.block === start.block).at(-1).n;
    const report = { wave: w.n, block: start.block, start_tick: start.tick, end_tick: end,
      cleared: w.seconds != null, seconds: round(seconds), owned, bond: w.bond,
      deploys: w.deploys ?? {}, deploy_kills: w.deploy_kills ?? {}, form_seconds: w.form_seconds,
      offered: (pick ?? here[0])?.offered ?? [], taken: pick?.taken ?? null, masteries };
    if (observer) {
      report.entries = observer.entries.filter(inWave);
      const releases = observer.releases.filter(inWave);
      report.stuns = {};
      for (const event of releases) {
        if (event.stuns) report.stuns[event.form] = (report.stuns[event.form] ?? 0) + event.stuns;
      }
      for (const form of forms) {
        assert.equal(releases.filter(e => e.form === form).length, report.deploys[form] ?? 0);
        assert.ok(owned.includes(form) || w.bond[form] === 0);
      }
    }
    return report;
  });
  const actual = Object.values(mastery).filter(Number.isFinite);
  const report = { seed, death: run.death ?? null, mastery_at_rest: mastery,
    first_mastery: actual.length ? Math.min(...actual) : null,
    bond_at_end: waves.at(-1).bond, wave_reached: run.wave_reached, longest_wave_s: Math.max(...waves.map(w => w.seconds)), waves };
  if (observer) {
    report.entries = observer.entries;
    report.base_combat_plan_ticks = observer.planned;
    if (observer.owned_plan_ticks) report.owned_plan_ticks = observer.owned_plan_ticks;
    report.releases = counts();
    report.kills = counts();
    report.boss_cuts = counts();
    report.stuns = counts();
    for (const event of observer.releases) {
      report.releases[event.form]++;
      report.kills[event.form] += event.kills;
      report.boss_cuts[event.form] += event.boss_cuts ?? 0;
      report.stuns[event.form] += event.stuns;
    }
  }
  runs.push(report);
}
const ordered = runs.map(r => r.first_mastery ?? Infinity).sort((a, b) => a - b);
const observed = ordered.filter(Number.isFinite);
function median(values) {
  if (!values.length) return null;
  const mid = Math.floor(values.length / 2);
  const result = (values[mid] + values[Math.floor((values.length - 1) / 2)]) / 2;
  return Number.isFinite(result) ? result : null;
}
console.log(JSON.stringify({ schema: 'gtai.bond-measurement/1', arm, profile: 'average', pick: 'greedy',
  controls: 'wheel', wave_limit: 15, mastered_seeds: observed.length, median_first_all: median(ordered),
  median_first_among_mastered: median(observed), runs }, null, 2));
