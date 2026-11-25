// n31 foes: pools gtai.foes-waiting/1 run files (one per profile x seed) into per-wave, per-archetype
// waiting numbers and a markdown table. Pure: no files, no Godot (waiting.mjs does the I/O).
export const SCHEMA = 'gtai.foes-waiting/1';
export const SUMMARY_SCHEMA = 'gtai.foes-waiting-summary/1';
export const SUMMARY_WAVES = [1, 2, 3, 4, 6, 7];
export const STOMP_WAVE = 5;
const ALL_WAVES = [1, 2, 3, 4, 5, 6, 7];

/** Nearest-rank percentile of a list (null when empty). */
export function pct(list, p) {
  if (!list.length) return null;
  const s = [...list].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.max(0, Math.ceil((p / 100) * s.length) - 1))];
}

const mean = (list) => (list.length ? list.reduce((a, b) => a + b, 0) / list.length : null);
const round = (x, d = 2) => (x == null ? null : Math.round(x * 10 ** d) / 10 ** d);

function emptyPool() {
  return { n: 0, react: [], reactAny: [], firedBeforeClear: 0, never: 0, neverClear: 0, neverClearIn: 0,
    rounds: 0, dist: [], clear: 0, clearIdle: 0, clearIn: 0, clearInIdle: 0, token: 0, alive: 0 };
}

function addKind(pool, k) {
  pool.n += k.n;
  pool.react.push(...k.react_s);
  pool.reactAny.push(...k.react_any_s);
  pool.firedBeforeClear += k.fired_before_clear;
  pool.never += k.never_fired;
  pool.neverClear += k.never_fired_clear;
  pool.neverClearIn += k.never_fired_clear_in;
  pool.rounds += k.rounds;
  pool.dist.push(...k.shot_dist_m);
  pool.clear += k.clear_s;
  pool.clearIdle += k.clear_idle_s;
  pool.clearIn += k.clear_in_s;
  pool.clearInIdle += k.clear_in_idle_s;
  pool.token += k.token_s;
  pool.alive += k.alive_s;
}

function finishPool(p) {
  return { n: p.n, react_p50: pct(p.react, 50), react_p90: pct(p.react, 90), react_n: p.react.length,
    react_any_p50: pct(p.reactAny, 50), react_any_p90: pct(p.reactAny, 90),
    fired_before_clear: p.firedBeforeClear, never_fired: p.never, never_fired_clear: p.neverClear,
    never_fired_clear_in: p.neverClearIn, rounds: p.rounds,
    idle_share: p.clear > 0 ? round(p.clearIdle / p.clear, 3) : null,
    idle_share_in_range: p.clearIn > 0 ? round(p.clearInIdle / p.clearIn, 3) : null,
    clear_s: round(p.clear), token_share: p.alive > 0 ? round(p.token / p.alive, 3) : null,
    dist_p10: pct(p.dist, 10), dist_p50: pct(p.dist, 50), dist_p90: pct(p.dist, 90),
    dist_hist_2m: histogram(p.dist) };
}

function histogram(list) {
  const bins = {};
  for (const d of list) {
    const lo = Math.floor(d / 2) * 2;
    bins[lo] = (bins[lo] ?? 0) + 1;
  }
  return bins;
}

function emptyWave() {
  return { reached: 0, kinds: {}, melee: {}, all: emptyPool(), firing: [], alive: [], damage: [], deaths: 0,
    seconds: [], shotsChecked: 0, shotsMismatch: 0 };
}

function addWave(w, row) {
  w.reached += 1;
  w.firing.push(...row.firing_per_s);
  w.alive.push(row.ranged_alive_mean);
  w.damage.push(row.damage_taken);
  w.deaths += row.died ? 1 : 0;
  if (row.seconds >= 0) w.seconds.push(row.seconds);
  w.shotsChecked += 1;
  w.shotsMismatch += row.shots_probe === row.shots_result ? 0 : 1;
  for (const [id, k] of Object.entries(row.archetypes)) {
    const bucket = k.melee ? w.melee : w.kinds;
    bucket[id] ??= emptyPool();
    addKind(bucket[id], k);
    if (!k.melee) addKind(w.all, k);
  }
}

function finishWave(w, runs) {
  const kinds = Object.fromEntries(Object.entries(w.kinds).sort().map(([id, p]) => [id, finishPool(p)]));
  const melee = Object.fromEntries(Object.entries(w.melee).sort().map(([id, p]) => [id, finishPool(p)]));
  return { reached: w.reached, runs, kinds, melee, all_ranged: finishPool(w.all),
    firing_per_s_mean: round(mean(w.firing)), firing_per_s_p50: pct(w.firing, 50),
    firing_per_s_max: w.firing.length ? Math.max(...w.firing) : null, ranged_alive_mean: round(mean(w.alive)),
    damage_taken_mean: round(mean(w.damage), 1), deaths: w.deaths, seconds_mean: round(mean(w.seconds), 1),
    shots_checked: w.shotsChecked, shots_mismatch: w.shotsMismatch };
}

/** {schema, profiles: {<profile>: {runs, seeds, waves: {<n>: wave}, totals}}} from run documents. */
export function aggregate(docs) {
  const byProfile = {};
  for (const doc of docs) {
    if (doc.schema !== SCHEMA) throw new Error('not a ' + SCHEMA + ' file (seed ' + doc.seed + ')');
    const p = (byProfile[doc.profile] ??= { seeds: [], waves: {}, totals: emptyWave(), fails: 0 });
    p.seeds.push(doc.seed);
    for (const row of doc.waves) {
      addWave((p.waves[row.n] ??= emptyWave()), row);
      if (SUMMARY_WAVES.includes(row.n)) addWave(p.totals, row);
    }
  }
  const profiles = {};
  for (const [name, p] of Object.entries(byProfile)) {
    const runs = p.seeds.length;
    const waves = Object.fromEntries(ALL_WAVES.map((n) => [n, p.waves[n] ? finishWave(p.waves[n], runs) : { reached: 0, runs }]));
    const totals = { ...finishWave(p.totals, runs), reached: p.totals.reached ? runs : 0 };
    profiles[name] = { runs, seeds: [...p.seeds].sort((a, b) => a - b), waves, totals };
  }
  return { schema: SUMMARY_SCHEMA, profiles };
}

const f = (x, d = 2) => (x == null ? '-' : String(round(x, d)));
const pair = (a, b) => f(a) + ' / ' + f(b);
const share = (x) => (x == null ? '-' : Math.round(x * 100) + ' %');
const HEAD = '| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | dmg taken mean | deaths |';
const RULE = '|' + ' --- |'.repeat(13);

function kindRow(label, id, k) {
  return `| ${label} | ${id} | ${k.n} | ${pair(k.react_p50, k.react_p90)} | ${pair(k.react_any_p50, k.react_any_p90)} | `
    + `${k.never_fired} (${k.never_fired_clear}, ${k.never_fired_clear_in}) | ${share(k.idle_share)} (${share(k.idle_share_in_range)}) | ${share(k.token_share)} | `
    + `${f(k.dist_p10, 1)} / ${f(k.dist_p50, 1)} / ${f(k.dist_p90, 1)} |`;
}

function waveRows(label, w) {
  if (!w.reached) return [`| ${label} | not reached (0/${w.runs} seeds) |` + ' |'.repeat(11)];
  const reach = w.reached < w.runs ? ` (reached ${w.reached}/${w.runs})` : '';
  const rows = Object.entries(w.kinds).map(([id, k]) => kindRow(label + reach, id, k) + ' | | | |');
  rows.push(kindRow(`**${label}**${reach}`, '**all ranged**', w.all_ranged)
    + ` ${f(w.firing_per_s_mean)} (${f(w.firing_per_s_max, 0)}) | ${f(w.ranged_alive_mean, 1)} | ${f(w.damage_taken_mean, 1)} | ${w.deaths} |`);
  return rows;
}

/** The markdown report for an aggregate() result. */
export function markdown(summary, { title = 'Foes waiting (n31)', note = '' } = {}) {
  const out = ['# ' + title, ''];
  if (note) out.push(note, '');
  out.push('react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; '
    + 'idle share = enemy-seconds with a clear line and no round, wind-up or burst / enemy-seconds with a clear line; '
    + 'token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. '
    + `Wave ${STOMP_WAVE} (the stomp) is measured in waiting.json but left out of this table and the totals.`, '');
  for (const [name, p] of Object.entries(summary.profiles)) {
    out.push(`## ${name} (${p.runs} seeds: ${p.seeds.join(', ')})`, '', HEAD, RULE);
    for (const n of SUMMARY_WAVES) out.push(...waveRows(String(n), p.waves[n]));
    out.push(...waveRows('1-4, 6-7', p.totals).slice(-1));
    const melee = SUMMARY_WAVES.flatMap((n) => Object.entries(p.waves[n].melee ?? {}).map(([id, k]) =>
      `| ${n} | ${id} | ${k.n} | ${k.never_fired} | ${k.rounds} | ${f(k.clear_s, 1)} |`));
    if (melee.length) out.push('', 'Melee (reported apart):', '', '| wave | archetype | n | never swung | swings | clear-line s |', '|' + ' --- |'.repeat(6), ...melee);
    const reach = Object.entries(p.waves).map(([n, w]) => `${n}: ${w.reached}/${p.runs}`).join(', ');
    const mism = Object.values(p.waves).reduce((a, w) => a + (w.shots_mismatch ?? 0), 0);
    const checked = Object.values(p.waves).reduce((a, w) => a + (w.shots_checked ?? 0), 0);
    out.push('', `Waves reached: ${reach}. Rivet shots probe = run result on ${checked - mism}/${checked} wave rows.`, '');
  }
  return out.join('\n') + '\n';
}
