import { PROFILES } from './contract.mjs';
import { timeBounds } from './analysis.mjs';
import { profileScores, targets } from './death_score.mjs';
import { analyze, weaponsOf } from './report.mjs';
import { fmt } from './report_tables.mjs';
import { knobStep, memberIds, occupied } from './tune_groups.mjs';
import { TABLES } from './tune_state.mjs';

export const PLAN_SCHEMA = 'gtai.gauntlet-tune-plan/1';
const ratio = (target, observed) => observed > 0 ? target / observed : 1.25;

function measuredMiss(metric, severity, miss, choices, reason) {
  return { metric, severity, miss, choices, reason };
}

// HP on the production street is read from the archetype only for robot bodies (ArenaSquad.spawn_member).
function robotIn(waves, roster) {
  const timed = waves.filter((w) => w.enemies && Number.isFinite(w.seconds));
  return (roster?.archetypes ?? []).filter((r) => r.body === 'robot').map((r) => ({
    id: r.id, count: timed.filter((w) => w.enemies[r.id] > 0).length, total: timed.length
  })).filter((r) => r.count > 0).sort((a, b) => b.count - a.count || a.id.localeCompare(b.id))[0];
}

function waveMisses(report, runs, roster, { target, profile, street, minN }) {
  const byWave = Map.groupBy(runs.filter((r) => r.profile === profile).flatMap((r) => r.waves), (w) => w.n);
  const timed = report.waves.filter((row) => row.profile === profile && row.timed);
  const midpoint = Math.ceil((timed.at(-1)?.n ?? 0) / 2);
  const fastBudget = timed.some((row) => row.n > midpoint && row.median < timeBounds(row.n, target)[0] && row.timed >= minN)
    ? 'budget.per_wave' : 'budget.base';
  const misses = [];
  for (const row of timed) {
    const [lower, upper] = timeBounds(row.n, target);
    if (row.median >= lower && row.median <= upper) continue;
    const goal = row.n % targets.boss_every === 0 ? (row.median < lower ? lower : upper) : target;
    const factor = ratio(goal, row.median);
    let miss = profile + ' wave ' + row.n + ' median ' + fmt(row.median) + ' s over ' + row.timed
      + ' timed runs against ' + goal + ' s';
    const choices = [];
    if (row.median < lower) {
      miss += ', below the ' + fmt(lower) + ' s lower bound';
      if (street && row.timed >= minN) {
        miss += ', raise ' + fastBudget + ' to add enemies';
        choices.push([fastBudget, factor]);
      }
    } else {
      const robot = robotIn(byWave.get(row.n), roster);
      if (robot) {
        miss += ', ' + robot.id + ' present in ' + robot.count + '/' + robot.total + ' timed rosters';
        choices.push([robot.id + '.hp', factor]);
      }
      if (street) choices.push([row.n === 1 ? 'budget.base' : 'budget.per_wave', factor]);
    }
    const reason = row.timed < minN ? 'too few runs (need ' + minN + ' timed runs)' : undefined;
    misses.push(measuredMiss({ type: 'wave', profile, wave: row.n, target: goal }, Math.abs(row.median / goal - 1), miss, choices, reason));
  }
  return misses;
}

function deathMisses(batch, profile, minN) {
  const observations = [];
  for (const row of profileScores(batch)) {
    if (row.profile !== profile && profile !== 'all') continue;
    const { median, upper, target, scores, capped } = row;
    if (!scores.length || median === target) continue;
    const metric = { type: 'death', profile: row.profile, target };
    const miss = row.profile + ' median death wave ' + fmt(median) + ' against target ' + target
      + ' (' + row.deaths + ' deaths, ' + capped + ' censored as lower bounds)';
    const reason = scores.length < minN ? 'too few runs (need ' + minN + ' scored runs)'
      : median < target && upper >= target ? 'censoring leaves an early death-wave miss unresolved' : undefined;
    const factor = Math.min(1.25, Math.max(0.8, median / target));
    observations.push(measuredMiss(metric, Math.abs(median / target - 1), miss,
      [['enemy_damage', factor], ['budget.per_wave', factor]], reason));
  }
  return observations.sort((a, b) => b.severity - a.severity);
}

function killerMisses(report, runs, roster, threshold) {
  const total = report.deaths.reduce((sum, r) => sum + r.total, 0);
  const misses = [];
  // Tune the recorded cause directly, including the war machine's separate shell and stomp.
  const causes = Map.groupBy(runs.filter((r) => r.death?.by), (r) => r.death.by);
  for (const [id, victims] of causes) {
    const e = { id, kills: victims.length };
    if (!total || e.kills / total <= threshold || e.id === 'timeout') continue;
    const archetype = roster?.archetypes?.find((r) => r.id === e.id);
    const weaponId = archetype?.weapon ?? e.id;
    const weapon = roster?.weapons?.[weaponId];
    const choices = [];
    const factor = threshold / (e.kills / total);
    // Street death.by can be a weapon id. Shared weapon names do not identify a particular shooter.
    const owners = archetype ? [archetype] : (roster?.archetypes ?? []).filter((r) => r.weapon === weaponId);
    if (weapon?.melee && owners.length === 1) choices.push([owners[0].id + '.production_damage', factor]);
    if (weaponId === 'stomp') choices.push(['enemy_weapon.stomp.splash_damage', factor]);
    if (owners.some((r) => r.explicit_spawn) && !weapon?.melee) choices.push(['enemy_weapon.' + weaponId + '.damage', factor]);
    let miss = e.id + ' recorded as killer in ' + e.kills + '/' + total + ' deaths (' + fmt(100 * e.kills / total)
      + '% against ' + fmt(100 * threshold) + '%)';
    const guarded = victims.filter((r) => r.waves.some((w) => w.guard_deflects > 0)).length;
    if (guarded && (weapon || e.id === 'assault-rifle') && weapon?.round !== 'large' && !weapon?.melee) {
      miss += ', ' + guarded + '/' + victims.length + ' victim runs recorded a deflection';
      choices.push(['guard.meter_max', 1 / factor]);
    }
    const reason = total < 5 ? 'too few runs (need 5 recorded deaths)' : undefined;
    misses.push(measuredMiss({ type: 'killer', id: e.id, target: threshold }, e.kills / total / threshold - 1, miss, choices, reason));
  }
  return misses;
}

function bonusMisses(report, weapons, target) {
  const misses = [];
  for (const e of report.effects) {
    if (e.kind !== 'bonus' || !['lower', 'higher'].includes(e.label)) continue;
    const seconds = e.metric === 'seconds';
    const unit = seconds ? ' s' : ' waves survived';
    const severity = Math.abs(e.delta) / (seconds ? target : Math.max(1, e.declineMedian));
    const strong = seconds ? e.delta < 0 : e.delta > 0;
    const factor = strong ? 1 / (1 + severity) : 1 + severity;
    const ref = weapons.get(e.id);
    // Prefer cadence so an established one-hit weapon can keep its damage threshold.
    const choices = ref ? [['weapon.' + ref + '.rof_hz', factor], ['weapon.' + ref + '.damage', factor]] : [];
    const miss = e.id + ' took ' + fmt(e.takeMedian) + ' vs declined ' + fmt(e.declineMedian) + unit
      + ', paired difference ' + fmt(e.delta) + ' (CI95 ' + e.ci.map(fmt).join(' to ') + ', A/A floor '
      + fmt(e.floor) + ', ' + e.pairs + ' pairs)';
    misses.push(measuredMiss({ type: 'offer', id: e.id, outcome: e.metric, target: 0 }, severity, miss, choices));
  }
  return misses;
}

export function deathMetric(value) {
  if (value !== undefined && value !== 'death') throw new Error('--metric must be death');
  return value;
}

function observationsFor(batch, state, { target, profile, killerShare, minN, metric }) {
  if (metric === 'death') {
    if (profile !== 'all' && !PROFILES.includes(profile)) throw new Error('unknown death profile: ' + profile);
    if (batch.args.runner === 'pit') throw new Error('death-wave tuning requires the street');
    return deathMisses(batch, profile, minN);
  }
  const weapons = weaponsOf(batch);
  const report = analyze(batch, null, weapons);
  const roster = state.tables.get(TABLES + 'enemies.json');
  const street = batch.args.runner !== 'pit';
  const observations = [
    ...waveMisses(report, batch.results, roster, { target, profile: profile === 'all' ? 'average' : profile, street, minN }),
    ...killerMisses(report, batch.results, roster, killerShare),
    ...bonusMisses(report, weapons, target)
  ].sort((a, b) => b.severity - a.severity);
  if (street) observations.unshift(...deathMisses(batch, profile, minN));
  return observations;
}

export function propose(batch, state, baseline, { target = targets.wave_seconds.average, profile = 'average', max = 6, killerShare = 0.5, minN = 3,
  used = new Set(), batchHash, night, metric: selection, allowShared = false } = {}) {
  const metricName = deathMetric(selection);
  if (metricName) max = Math.min(max, 1);
  const observations = observationsFor(batch, state, { target, profile, killerShare, minN, metric: metricName });
  const changes = [], misses = [];
  const skipped = new Map();
  const chosen = new Set(used);
  // The two outcomes of one offer can describe the same advantage. Don't turn both knobs for it.
  const selectedOffers = new Set();
  for (const { choices, reason, ...observation } of observations) {
    const { metric, miss } = observation;
    if (reason) {
      misses.push({ ...observation, reason });
      continue;
    }
    const result = { ...observation, reason: 'no eligible numeric change within bounds' };
    for (const [id, factor] of choices) {
      if (!allowShared && memberIds(id, state.entries).some((key) => state.entries.get(key)?.knob.shared)) {
        result.reason = 'shared with quest 1 / replays';
        skipped.set(id, { id, reason: result.reason });
        continue;
      }
      const step = knobStep(id, factor, state.entries, baseline);
      if (!step) {
        const entry = state.entries.get(id);
        result.reason = entry?.knob.kind === 'int' && Math.round(entry.value * factor) === entry.value
          ? id + ' rounds to the current integer ' + entry.value
          : id + ' has no legal ' + (factor > 1 ? 'upward' : 'downward') + ' step within bounds';
        continue;
      }
      if (occupied(id, chosen) || (metric.type === 'offer' && selectedOffers.has(metric.id))) {
        result.reason = 'knob or offer already selected this night';
        if (metric.type === 'death') continue;
        break;
      }
      if (changes.length >= max) { result.reason = 'plan limit'; break; }
      const profiles = metricName && observations.filter((o) => !o.reason && o.choices.some(([knob, f]) =>
        knob === id && Math.sign(f - 1) === Math.sign(factor - 1))).map((o) => o.metric.profile);
      changes.push({ ...step, metric, miss, severity: observation.severity, ...(profiles && { profiles }) });
      chosen.add(id);
      if (metric.type === 'offer') selectedOffers.add(metric.id);
      result.reason = id + (step.members ? ' x ' + step.factor : ' ' + step.before + ' -> ' + step.after);
      break;
    }
    if (metricName && changes[0]?.profiles.includes(metric.profile)) result.reason = 'served by ' + changes[0].id;
    misses.push(result);
  }
  return { schema: PLAN_SCHEMA, night, batch_sha256: batchHash, profile, ...(metricName && { metric: metricName }), target_s: target,
    killer_share: killerShare, min_n: minN, max, changes, misses, skipped: [...skipped.values()] };
}
