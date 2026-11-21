import { median } from '../perf/paired.mjs';
import { analyze, weaponsOf } from './report.mjs';
import { fmt } from './report_tables.mjs';
import { clamped, TABLES } from './tune_state.mjs';

export const PLAN_SCHEMA = 'gtai.gauntlet-tune-plan/1';
const ratio = (target, observed) => observed > 0 ? target / observed : 1.25;

function measuredMiss(metric, severity, miss, choices) {
  return { metric, severity, miss, choices };
}

// HP on the production street is read from the archetype only for robot bodies (ArenaSquad.spawn_member).
function robotIn(waves, roster) {
  const timed = waves.filter((w) => w.enemies && Number.isFinite(w.seconds));
  return (roster?.archetypes ?? []).filter((r) => r.body === 'robot').map((r) => ({
    id: r.id, count: timed.filter((w) => w.enemies[r.id] > 0).length, total: timed.length
  })).filter((r) => r.count > 0).sort((a, b) => b.count - a.count || a.id.localeCompare(b.id))[0];
}

function waveMisses(report, runs, roster, { target, profile, street }) {
  const byWave = Map.groupBy(runs.filter((r) => r.profile === profile).flatMap((r) => r.waves), (w) => w.n);
  const misses = [];
  for (const row of report.waves) {
    if (row.profile !== profile || !row.timed || (row.median >= target * 0.8 && row.median <= target * 1.2)) continue;
    const robot = robotIn(byWave.get(row.n), roster);
    const factor = ratio(target, row.median);
    let miss = profile + ' wave ' + row.n + ' median ' + fmt(row.median) + ' s over ' + row.timed
      + ' timed runs against ' + target + ' s';
    const choices = [];
    if (robot) {
      miss += ', ' + robot.id + ' present in ' + robot.count + '/' + robot.total + ' timed rosters';
      choices.push([robot.id + '.hp', factor]);
    }
    if (street) choices.push([row.n === 1 ? 'budget.base' : 'budget.per_wave', factor]);
    misses.push(measuredMiss({ type: 'wave', profile, wave: row.n, target }, Math.abs(row.median / target - 1), miss, choices));
  }
  return misses;
}

function spreadMiss(runs, roster, street) {
  const depth = (profile) => median(runs.filter((r) => r.profile === profile).map((r) => r.wave_reached));
  const novice = depth('novice'), expert = depth('expert');
  if (!(expert <= novice)) return [];
  const profiles = runs.filter((r) => ['novice', 'expert'].includes(r.profile));
  // Ease a shared bottleneck when both profiles die. Increase pressure when they both survive.
  const blocked = ['novice', 'expert'].every((p) => profiles.some((r) => r.profile === p && r.death));
  const factor = blocked ? 0.8 : 1.25;
  const choices = street ? [['budget.per_wave', factor], ['budget.base', factor]] : [];
  const waves = profiles.flatMap((r) => r.waves.filter((w) => w.n === r.wave_reached));
  const robot = robotIn(waves, roster);
  if (robot) choices.push([robot.id + '.hp', factor]);
  const miss = 'novice median wave ' + fmt(novice) + ', expert ' + fmt(expert)
    + ' against a gap of at least 1 wave, ' + profiles.filter((r) => r.death).length + '/' + profiles.length
    + ' runs ended in death' + (robot ? ', ' + robot.id + ' in ' + robot.count + '/' + robot.total + ' timed final rosters' : '');
  return [measuredMiss({ type: 'spread', target: 1 }, 1 - (expert - novice), miss, choices)];
}

function killerMisses(report, runs, roster, threshold) {
  const total = report.deaths.reduce((sum, r) => sum + r.total, 0);
  const misses = [];
  for (const e of report.enemies) {
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
    const victims = runs.filter((r) => r.death?.by === e.id);
    const guarded = victims.filter((r) => r.waves.some((w) => w.guard_deflects > 0)).length;
    if (guarded && (weapon || e.id === 'assault-rifle') && weapon?.round !== 'large' && !weapon?.melee) {
      miss += ', ' + guarded + '/' + victims.length + ' victim runs recorded a deflection';
      choices.push(['guard.meter_max', 1 / factor]);
    }
    misses.push(measuredMiss({ type: 'killer', id: e.id, target: threshold }, e.kills / total / threshold - 1, miss, choices));
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

export function propose(batch, state, baseline, { target = 15, profile = 'average', max = 6, killerShare = 0.5,
  used = new Set(), batchHash, night } = {}) {
  const weapons = weaponsOf(batch);
  const report = analyze(batch, null, weapons);
  const roster = state.tables.get(TABLES + 'enemies.json');
  const street = batch.args.runner !== 'pit';
  const observations = [
    ...waveMisses(report, batch.results, roster, { target, profile, street }),
    ...spreadMiss(batch.results, roster, street),
    ...killerMisses(report, batch.results, roster, killerShare),
    ...bonusMisses(report, weapons, target)
  ].sort((a, b) => b.severity - a.severity);
  const changes = [], misses = [];
  const chosen = new Set(used);
  // The two outcomes of one offer can describe the same advantage. Don't turn both knobs for it.
  const selectedOffers = new Set();
  for (const { choices, ...observation } of observations) {
    const { metric, miss } = observation;
    const result = { ...observation, reason: 'no eligible numeric change within bounds' };
    for (const [id, factor] of choices) {
      const entry = state.entries.get(id);
      if (!entry) continue;
      const before = entry.value;
      const first = baseline.values[id];
      const after = clamped(entry.knob, before, first, before * factor);
      if (after === before || Math.sign(after - before) !== Math.sign(factor - 1)) continue;
      if (chosen.has(id) || (metric.type === 'offer' && selectedOffers.has(metric.id))) {
        result.reason = 'knob or offer already selected this night';
        break;
      }
      if (changes.length >= max) { result.reason = 'plan limit'; break; }
      changes.push({ id, file: entry.knob.file, pointer: entry.knob.pointer, before, after, baseline: first,
        metric, miss, severity: observation.severity });
      chosen.add(id);
      if (metric.type === 'offer') selectedOffers.add(metric.id);
      result.reason = id + ' ' + before + ' -> ' + after;
      break;
    }
    misses.push(result);
  }
  return { schema: PLAN_SCHEMA, night, batch_sha256: batchHash, profile, target_s: target,
    killer_share: killerShare, max, changes, misses };
}
