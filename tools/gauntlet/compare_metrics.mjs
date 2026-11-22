import { median } from '../perf/paired.mjs';
import { quantile } from '../perf/stats.mjs';
import { deathStats } from './analysis.mjs';
import { separation } from './death_report.mjs';
import { profileScores } from './death_score.mjs';
import { fmt, missing } from './report_tables.mjs';
import { damagePerSecond, repairShare } from './survival.mjs';

const bands = [[1, 4], [5, 5], [6, 10], [11, 20], [21, 30], [31, 40]];
export const bandLabels = bands.map(([lo, hi]) => lo === hi ? String(lo) : lo + '–' + hi);
const middle = (values) => median(values.filter(Number.isFinite));
const signed = (n) => (n > 0 ? '+' : '') + fmt(n);
const bounded = (value, lower, format = fmt) => Number.isFinite(value)
  ? (lower ? '>= ' : '') + format(value) : missing;
const cell = (text, miss = false) => ({ text: String(text), miss });
const distinct = (values) => [...new Set(values.filter((v) => v != null))];

function metadata(batch, profiles) {
  const { args, runs, results, git } = batch;
  const seeds = distinct(runs.map((r) => r.seed)).sort((a, b) => a - b);
  const span = seeds.length > 1 && seeds.at(-1) - seeds[0] === seeds.length - 1
    ? seeds[0] + '–' + seeds.at(-1) : seeds.join(', ');
  const caps = distinct(runs.filter((r) => r.outcome === 'capped').map((r) => r.ticks));
  const cap = args.tick_cap ?? (caps.length === 1 ? caps[0] : null);
  const settings = (values, fallback) => distinct(values).join(', ') || fallback || missing;
  const waveLimit = args.waves == null ? 'no wave limit' : '--waves=' + args.waves;
  return [
    (git.sha?.slice(0, 12) ?? missing) + (git.dirty ? ' (dirty)' : ''),
    seeds.length + (seeds.length === 1 ? ' seed' : ' seeds') + (span ? ' (' + span + ')' : ''),
    profiles.join(', ') || missing, waveLimit,
    cap == null ? 'tick cap not recorded' : cap + '-tick cap',
    'pick ' + settings(runs.map((r) => r.pick), args.pick),
    'controls ' + settings([...runs, ...results].map((r) => r.controls), args.controls)
  ];
}

function timing(waves, profile, targets) {
  const seconds = (group) => middle(group.map((w) => w.seconds));
  const isBoss = (w) => w.n % targets.boss_every === 0;
  const timedCell = (group) => {
    const value = seconds(group);
    const boss = group.every(isBoss), ordinary = group.every((w) => !isBoss(w));
    const [low, high] = targets.boss_wave_seconds;
    const normal = targets.wave_seconds.average;
    const miss = boss ? value < low || value > high
      : ordinary && profile === 'average' && (value < normal * 0.8 || value > normal * 1.2);
    return cell(fmt(value), miss);
  };
  const timed = waves.filter((w) => Number.isFinite(w.seconds));
  return [...bands.map(([lo, hi]) => timedCell(timed.filter((w) => w.n >= lo && w.n <= hi))),
    timedCell(timed.filter(isBoss))];
}

function profileRow(batch, score, targets) {
  const { profile, scores, deaths, capped } = score;
  const runs = batch.results.filter((r) => r.profile === profile);
  const attempts = batch.runs.filter((r) => r.profile === profile);
  const stats = deathStats(profile, runs, attempts);
  const noResult = attempts.filter((r) => !r.ok && /\b(?:timeout|timed out)\b/i.test(r.outcome + ' ' + r.reason));
  const target = targets.death_wave[profile], miss = score.median - target;
  const censored = score.upper > score.median;
  const depths = scores.map((s) => s.wave);
  const waves = runs.flatMap((r) => r.waves);
  const hp = waves.filter((w) => w.hp);
  const share = middle(hp.map(repairShare));
  const killers = stats.killers.slice(0, 3).map(([id, n]) => id + ' × ' + n).join(', ');
  return { key: profile,
    depth: [cell(bounded(score.median, censored)),
      cell(depths.length ? fmt(quantile(depths, 0.25)) + '–' + fmt(quantile(depths, 0.75)) : missing),
      cell(target), cell(bounded(miss, censored, signed), miss > 0 || score.upper < target)],
    counts: [attempts.length, deaths, capped, noResult.length, stats.timeouts].map((n) => cell(n)),
    timing: timing(waves, profile, targets),
    health: [cell(fmt(middle(hp.map(damagePerSecond)))), cell(Number.isFinite(share) ? fmt(share) + '%' : missing),
      cell(killers || (runs.length && !deaths ? 'none' : missing))]
  };
}

function separationRow(a, b, targets) {
  const { observedGap, shared, later, verdict } = separation(a, b, targets.separation);
  const fraction = shared ? later + '/' + shared + ' (' + fmt(100 * later / shared) + '%)' : missing;
  const separated = verdict === 'separated';
  return { key: a.profile + ' → ' + b.profile,
    separation: [cell(signed(observedGap)), cell(fraction),
      cell(shared ? (separated ? 'separated' : 'not separated') : missing, shared > 0 && !separated)] };
}

export function compareArm(label, batch, targets) {
  const scores = profileScores(batch);
  const profiles = scores.filter((s) => batch.runs.some((r) => r.profile === s.profile));
  const rows = profiles.map((score) => profileRow(batch, score, targets));
  const pairs = scores.slice(1).map((b, i) => separationRow(scores[i], b, targets));
  return { label, sha: batch.git.sha, meta: metadata(batch, rows.map((r) => r.key)), rows, pairs };
}
