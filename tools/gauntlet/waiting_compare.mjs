// n31 foes (b4a): the headline of several waiting.json summaries side by side (main | HEAD | ...).
// Pure: summaries in, markdown out (waiting.mjs --compare does the I/O).
import { SUMMARY_SCHEMA } from './waiting_agg.mjs';

export const DAMAGE_WAVES = [1, 2, 3, 4];
const f = (x, d = 2) => (x == null ? '-' : String(Math.round(x * 10 ** d) / 10 ** d));
const share = (x) => (x == null ? '-' : Math.round(x * 100) + ' %');

/** Sum of the per-wave damage means over waves 1-4 (null when one is missing). */
export function damageSum(p) {
  const means = DAMAGE_WAVES.map((n) => p.waves[n]?.damage_taken_mean ?? null);
  return means.includes(null) ? null : Math.round(means.reduce((a, b) => a + b, 0) * 10) / 10;
}

/** [label, value] rows for one profile of a summary (ranged kinds, waves 1-4 + 6-7). */
export function headline(p) {
  const t = p.totals.all_ranged ?? {};
  const deaths = Object.values(p.waves).reduce((a, w) => a + (w.deaths ?? 0), 0);
  return [
    ['react in range p50 / p90 s', `${f(t.react_p50)} / ${f(t.react_p90)}`],
    ['react any distance p50 / p90 s', `${f(t.react_any_p50)} / ${f(t.react_any_p90)}`],
    ['idle share (engaged rule, in range)', share(t.idle_share)],
    ['idle strict (any distance / in range)', `${share(t.idle_strict)} / ${share(t.idle_strict_in_range)}`],
    ['pressing share', share(p.totals.pressing_share)],
    ['enemies firing / s (ranged alive)', `${f(p.totals.firing_per_s_mean)} (${f(p.totals.ranged_alive_mean, 1)})`],
    ['never fired / ranged foes', `${t.never_fired ?? '-'} / ${t.n ?? '-'}`],
    ['token share', share(t.token_share)],
    ...DAMAGE_WAVES.map((n) => [`damage taken w${n} mean`, f(p.waves[n]?.damage_taken_mean, 1)]),
    ['damage taken w1-4 sum', f(damageSum(p), 1)],
    ['deaths, all waves incl. 5 (runs) / waves 6, 7 reached', `${deaths} (${p.runs}) / ${p.waves[6]?.reached ?? 0}, ${p.waves[7]?.reached ?? 0}`],
  ];
}

/** One markdown table per profile, a column per summary. `labels` name the columns. */
export function compareMarkdown(summaries, labels, { title = 'Foes waiting: compare (n31)', note = '' } = {}) {
  for (const s of summaries) if (s.schema !== SUMMARY_SCHEMA) throw new Error('not a ' + SUMMARY_SCHEMA + ' summary');
  const out = ['# ' + title, ''];
  if (note) out.push(note, '');
  const revs = summaries.map((s, i) => `${labels[i]} = ${s.meta?.rev ?? '?'}`).join('; ');
  out.push(`Columns: ${revs}. Ranged kinds, waves 1-4 + 6-7 unless the row names waves.`, '');
  const profiles = [...new Set(summaries.flatMap((s) => Object.keys(s.profiles)))].sort();
  for (const name of profiles) {
    const cols = summaries.map((s) => (s.profiles[name] ? headline(s.profiles[name]) : null));
    const rows = (cols.find(Boolean) ?? []).map(([label]) => label);
    out.push(`## ${name}`, '', `| metric | ${labels.join(' | ')} |`, '|' + ' --- |'.repeat(labels.length + 1));
    rows.forEach((label, i) => out.push(`| ${label} | ${cols.map((c) => (c ? c[i][1] : '-')).join(' | ')} |`));
    out.push('');
  }
  return out.join('\n');
}
