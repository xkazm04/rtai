import { resolve } from 'node:path';
import { median } from '../perf/paired.mjs';
import { quantile, mean } from '../perf/stats.mjs';
import { entryArgs, commandLine } from './commands.mjs';
import { killerEnemy } from './enemy_weapons.mjs';
import { offerEffects } from './offers.mjs';

export const TARGET_S = 15;
const vals = (rows, key) => rows.map((r) => r[key]).filter(Number.isFinite);
const total = (rows) => rows.reduce((s, n) => s + n, 0);
const frequency = (rows) => new Map([...Map.groupBy(rows, (v) => v)].map(([id, hits]) => [id, hits.length]));

function measured(values) {
  return { n: values.length, median: median(values) };
}

function waveStats(profile, n, waves, before) {
  const times = vals(waves, 'seconds');
  const time = median(times);
  const forms = new Map();
  for (const w of waves) {
    for (const [id, seconds] of Object.entries(w.form_seconds ?? {})) {
      if (!forms.has(id)) forms.set(id, []);
      forms.get(id).push(seconds);
    }
  }
  const baseline = measured(vals(before, 'seconds'));
  return { n, profile, observed: waves.length, timed: times.length, median: time, baseline,
    p25: quantile(times, 0.25), p75: quantile(times, 0.75), min: quantile(times, 0), max: quantile(times, 1),
    miss: profile === 'average' && (time < TARGET_S * 0.8 || time > TARGET_S * 1.2),
    guard: measured(vals(waves, 'guard_deflects')), rolls: measured(vals(waves, 'rolls')),
    shots: measured(vals(waves, 'shots')), hits: measured(vals(waves, 'hits')),
    forms: [...forms].sort(([a], [b]) => a.localeCompare(b)).map(([id, v]) => ({ id, ...measured(v) })) };
}

function enemyStats(runs, catalog) {
  const waves = runs.flatMap((r) => r.waves);
  const ids = new Set(waves.flatMap((w) => Object.keys(w.enemies ?? {})));
  const attributed = new Map();
  for (const run of runs) {
    const id = killerEnemy(run, catalog, ids);
    if (!id) continue;
    ids.add(id);
    if (!attributed.has(id)) attributed.set(id, []);
    attributed.get(id).push(run.death.by);
  }
  const timed = waves.filter((w) => w.enemies && Number.isFinite(w.seconds));
  const elapsed = total(vals(timed, 'seconds'));
  return [...ids].sort().map((id) => {
    const withEnemy = vals(timed.filter((w) => w.enemies[id] > 0), 'seconds');
    const without = vals(timed.filter((w) => !(w.enemies[id] > 0)), 'seconds');
    const causes = attributed.get(id) ?? [];
    const weapons = [...frequency(causes.filter((weapon) => weapon !== id))].sort();
    return { id, kills: causes.length, weapons, share: elapsed ? total(withEnemy) / elapsed : NaN,
      present: measured(withEnemy), absent: measured(without) };
  });
}

function deathStats(profile, runs, attempts) {
  const deaths = runs.filter((r) => r.death).map((r) => r.death);
  const by = frequency(deaths.map((d) => d.by).filter(Boolean));
  const stalled = attempts.filter((r) => r.outcome === 'stalled').length;
  const capped = attempts.filter((r) => r.outcome === 'capped').length;
  const timeouts = by.get('timeout') ?? 0;
  by.delete('timeout');
  return { profile, runs: attempts.length, accepted: runs.length, capped, stalled, timeouts, total: deaths.length, unknown: deaths.filter((d) => !d.by).length,
    waves: [...frequency(deaths.map((d) => d.wave))].sort(([a], [b]) => a - b),
    killers: [...by].sort(([a, n], [b, m]) => m - n || a.localeCompare(b)) };
}

// Within each profile compare the full ordered card sequence, weapon set and most-used measured form.
function signatures(run, weapons) {
  const picks = [...run.picks].sort((a, b) => a.wave - b.wave).map((p) => p.taken);
  const refs = [...new Set(picks.map((id) => weapons.get(id)).filter(Boolean))].sort();
  const forms = new Map();
  for (const w of run.waves) {
    for (const [id, seconds] of Object.entries(w.form_seconds ?? {}))
      forms.set(id, (forms.get(id) ?? 0) + seconds);
  }
  const positive = [...forms].filter(([, s]) => s > 0).sort(([a, n], [b, m]) => m - n || a.localeCompare(b));
  const dominant = positive[0]?.[0] ?? (forms.size ? '(no positive measured time)' : null);
  return { sequence: JSON.stringify(picks), weapons: weapons.size ? JSON.stringify(refs) : null,
    form: dominant, picks, refs };
}

function unusual(runs, batch, weapons) {
  const candidates = runs.map((run) => ({ run, signature: signatures(run, weapons) }));
  const features = ['sequence', 'weapons', 'form'];
  const frequencies = features.map((key) => {
    const v = candidates.map((c) => c.signature[key]).filter((item) => item !== null);
    return { n: v.length, count: frequency(v) };
  });
  const deepest = runs.reduce((max, r) => Math.max(max, r.wave_reached), 0);
  const scores = [];
  for (const { run, signature } of candidates) {
    if (!deepest || run.wave_reached !== deepest) continue;
    const bits = features.flatMap((key, i) => signature[key] === null ? []
      : [Math.log2(frequencies[i].n / frequencies[i].count.get(signature[key]))]);
    const score = mean(bits);
    if (!(score > 0)) continue;
    const recorded = batch.runs.find((r) => r.ok && r.seed === run.seed && r.profile === run.profile
      && (!r.controls || r.controls === run.controls));
    const runner = batch.args.runner ?? 'gauntlet';
    const result = runner === 'pit' ? resolve('build/gauntlet/replay', run.profile + '-' + run.seed + '.json') : null;
    const replay = entryArgs({ runner, profile: run.profile, seed: run.seed, controls: run.controls,
      pick: recorded?.pick ?? batch.args.pick, waves: batch.args.waves }, result);
    scores.push({ run, score, signature, command: commandLine(replay) });
  }
  return scores.sort((a, b) => b.score - a.score || a.run.seed - b.run.seed).slice(0, 3);
}

export function analyze(batch, baseline = null, weapons = new Map(Object.entries(batch.weapon_refs ?? {}))) {
  const profiles = new Set([...batch.runs, ...(baseline?.runs ?? [])].map((r) => r.profile));
  const waves = [], deaths = [], winners = [];
  for (const p of profiles) {
    const runs = batch.results.filter((r) => r.profile === p);
    const current = Map.groupBy(runs.flatMap((r) => r.waves), (w) => w.n);
    const before = Map.groupBy((baseline?.results ?? []).filter((r) => r.profile === p).flatMap((r) => r.waves), (w) => w.n);
    const ordinals = [...new Set([...current.keys(), ...before.keys()])].sort((a, b) => a - b);
    for (const n of ordinals) waves.push(waveStats(p, n, current.get(n) ?? [], before.get(n) ?? []));
    deaths.push(deathStats(p, runs, batch.runs.filter((r) => r.profile === p)));
    winners.push(...unusual(runs, batch, weapons));
  }
  return { waves, deaths, enemies: enemyStats(batch.results, batch.enemy_weapons ?? {}), effects: offerEffects(batch.results, weapons), winners };
}
