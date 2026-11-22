import { targets } from './death_score.mjs';
import { moveSection } from './move_stats.mjs';
import { TARGET_S } from './analysis.mjs';
import { scoreSections } from './death_report.mjs';
import { survivalSection } from './survival.mjs';

export const missing = 'not measured';
export function fmt(n) {
  return Number.isFinite(n) ? String(Number(n.toFixed(2))) : missing;
}
const counted = (m) => m.n ? fmt(m.median) + ' (' + m.n + ')' : missing;
const pct = (n) => Number.isFinite(n) ? fmt(n * 100) + '%' : missing;
const range = (a, b) => Number.isFinite(a) ? fmt(a) + '…' + fmt(b) : missing;
const listCounts = (rows) => rows.map(([id, count]) => id + ' × ' + count).join(', ');
const method = 'Each run contributes once per item. Takers start at their first take and never-takers at their first offer. '
  + 'Post-pick seconds are a median within each run. Waves survived count confirmed completions. '
  + 'The final wave counts only with a recorded clear or post-wave offer and no death. '
  + 'Within the same profile, controls and pick wave, pair runs by seed rank without replacement. '
  + 'The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. '
  + 'The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. '
  + 'A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. '
  + 'These observational comparisons can reflect the rest of the loadout.';

export function sections(batch, report, baseline) {
  const formIds = [...new Set(report.waves.flatMap((w) => w.forms.map((f) => f.id)))].sort();
  const timing = {
    title: 'Wave time', key: 'time',
    note: 'Seconds per observed wave. The target is ' + TARGET_S + ' s ±20% for ordinary average-profile waves. Every '
      + targets.boss_every + 'th wave targets ' + targets.boss_wave_seconds.join('–') + ' s. '
      + 'Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.',
    columns: ['Profile', 'Wave', 'Timed / observed', ...(baseline ? ['Before s (n)', 'After s', 'Change s'] : ['Median s']),
      'P25…P75 s', 'Min…max s', 'Target'],
    rows: report.waves.map((w) => [w.profile, w.n, w.timed + ' / ' + w.observed,
      ...(baseline ? [counted(w.baseline), fmt(w.median), fmt(w.median - w.baseline.median)] : [fmt(w.median)]),
      range(w.p25, w.p75), range(w.min, w.max),
      w.profile !== 'average' ? '—' : !w.timed ? missing : w.miss ? 'miss' : 'within target']),
    empty: 'No wave rows were recorded.'
  };
  const deaths = {
    title: 'Deaths by profile', note: 'Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.',
    columns: ['Profile', 'Runs', 'Deaths', 'Stalled', 'Capped alive', 'Other accepted without death', 'Death wave × count', 'Top killers × count', 'Unattributed deaths'],
    rows: report.deaths.map((d) => [d.profile, d.runs, d.total, d.stalled, d.capped, d.accepted - d.total - d.capped, listCounts(d.waves) || '—',
      listCounts(d.killers) || (d.total ? missing : '—'), d.unknown])
  };
  const timeouts = {
    title: 'Timeouts', note: 'Runs that reached the wave time limit.',
    columns: ['Outcome', ...report.deaths.map((d) => d.profile)],
    rows: [['timeout', ...report.deaths.map((d) => d.timeouts)]]
  };
  const enemies = {
    title: 'Enemy presence and wave time',
    note: 'Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves '
      + 'with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.',
    columns: ['Enemy', 'Confirmed kills', 'Killer weapon × count', 'Share of wave time', 'Present median s (n)', 'Absent median s (n)'],
    rows: report.enemies.map((e) => [e.id, e.kills, listCounts(e.weapons) || '—', pct(e.share), counted(e.present), counted(e.absent)]),
    empty: 'No enemy rosters or killer ids were recorded.'
  };
  const effects = ['bonus', 'weapon'].map((kind) => ({
    title: kind === 'bonus' ? 'Offered bonuses' : 'Offered weapons by ref',
    note: kind === 'bonus' ? method : 'Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.',
    columns: [kind === 'bonus' ? 'Bonus' : 'Weapon ref', 'After pick', 'Took median (n)', 'Declined median (n)',
      'Pairs', 'Paired Δ', 'CI95', 'A/A floor (pairs, source)', 'Result'],
    rows: report.effects.filter((e) => e.kind === kind).map((e) => [e.id,
      e.metric === 'seconds' ? 'wave s' : 'waves survived', counted({ n: e.took, median: e.takeMedian }),
      counted({ n: e.declined, median: e.declineMedian }), e.pairs, fmt(e.delta), range(...e.ci),
      fmt(e.floor) + ' (' + e.aaPairs + ', ' + e.aaSource + ')', e.label]),
    empty: kind === 'bonus' ? 'No bonus offers were recorded.' : 'No offers mapped to a weapon ref.'
  }));
  const telemetry = {
    title: 'Combat telemetry', key: 'telemetry',
    note: 'Values are per-wave medians, with measured observations in parentheses. '
      + 'There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.',
    columns: ['Profile', 'Wave', 'Guard deflects (n)', 'Rolls (n)', 'gun rounds', 'damaging contacts (all sources)',
      ...(formIds.length ? formIds.map((id) => id + ' s (n)') : ['Ghost form s (n)'])],
    rows: report.waves.filter((w) => w.observed).map((w) => [w.profile, w.n, counted(w.guard), counted(w.rolls), counted(w.shots),
      counted(w.hits),
      ...(formIds.length ? formIds.map((id) => {
        const form = w.forms.find((f) => f.id === id);
        return form ? counted(form) : missing;
      }) : [missing])]),
    empty: 'No combat telemetry was recorded.'
  };
  const winners = {
    title: 'Unusual winning runs',
    note: 'At the deepest observed wave per profile, rank up to three runs with positive rarity. '
      + 'Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons '
      + 'and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls '
      + 'and batch settings. Replaying a human trajectory also requires its recorded inputs.',
    columns: ['Profile', 'Seed', 'Wave', 'Rarity (bits)', 'Picks in order', 'Weapon refs', 'Dominant form', 'Replay command'],
    rows: report.winners.map(({ run, score, signature, command }) => [run.profile, run.seed, run.wave_reached, fmt(score),
      signature.picks.join(' → ') || 'none', signature.refs.join(', ') || 'none', signature.form ?? missing, command]),
    empty: 'No deepest run had a measured signature that differed within its profile.'
  };
  const failed = batch.runs.filter((r) => !r.ok);
  return [...scoreSections(batch, fmt), timing, deaths, timeouts, survivalSection(batch, fmt), enemies, moveSection(batch, fmt), ...effects, telemetry, winners, ...(failed.length ? [{
    title: 'Excluded runs', note: 'These inputs are retained in the batch manifest.',
    columns: ['File', 'Profile', 'Seed', 'Reason'],
    rows: failed.map((r) => [r.file, r.profile, r.seed ?? 'unknown', r.reason ?? 'run failed'])
  }] : [])];
}
