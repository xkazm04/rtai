import { PROFILES } from './contract.mjs';
import { bandLabels } from './compare_metrics.mjs';
import { fmt } from './report_tables.mjs';

const title = 'Gauntlet batch comparison';
const escapeHtml = (s) => String(s).replaceAll('&', '&amp;').replaceAll('<', '&lt;')
  .replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;');
const mdText = (s) => String(s).replaceAll('&', '&amp;').replaceAll('<', '&lt;')
  .replace(/[\\|\[\]*`]/g, '\\$&').replace(/[\r\n]+/g, ' ');

function sections(t) {
  return [
    { key: 'depth', title: 'Death wave', fields: ['Median', 'P25–P75', 'Target', 'Miss'],
      note: 'A live run at its wave or tick limit contributes its last wave. >= marks a lower bound.' },
    { key: 'separation', title: 'Profile separation', fields: ['Observed gap', 'Later / shared seeds', 'Result'],
      note: 'Separation requires a confirmed median gap of ' + t.separation.min_wave_gap + ' waves and a later death on '
        + fmt(100 * t.separation.min_seed_share) + '% of shared, scored seeds with matching controls and picks. '
        + 'Two censored runs count in the denominator.' },
    { key: 'counts', title: 'Run outcomes', fields: ['Runs', 'Lethal deaths', 'Censored', 'Timeouts (no result)', 'Wave timers (result)'],
      note: 'Run counts include every attempt. Only lethal deaths and live runs at a limit enter the death-wave score.' },
    { key: 'timing', title: 'Wave time', fields: [...bandLabels, 'Boss waves'],
      note: 'Median seconds per timed wave. Each band includes its boss waves. The boss column pools waves '
        + [1, 2, 3].map((n) => n * t.boss_every).join(', ') + ', and so on. Ordinary waves target ' + t.wave_seconds.average
        + ' s for average (±20%). Boss waves target ' + t.boss_wave_seconds.join('–') + ' s.' },
    { key: 'health', title: 'Damage and repair', fields: ['Damage taken (HP/s)', 'Repair share', 'Top killers'],
      note: 'Medians use waves with HP telemetry. Damage rate needs elapsed seconds. '
        + 'Repair share is repaired HP divided by damage taken on waves with positive damage. Killers count lethal hits.' }
  ];
}

const rowsFor = (arm, key) => key === 'separation' ? arm.pairs : arm.rows;

function markdownTable(arms, parts, paired = false) {
  const headers = parts.flatMap((s) => s.fields.map((f) => s.key === 'timing' ? f + ' (s)' : f));
  const header = ['Arm', paired ? 'Profiles' : 'Profile', ...headers];
  const line = (cells) => '| ' + cells.map(mdText).join(' | ') + ' |';
  const rows = arms.flatMap((arm) => rowsFor(arm, parts[0].key).map((r) =>
    line([arm.label, r.key, ...parts.flatMap((s) => r[s.key].map((c) => c.text))])));
  return [line(header), line(header.map(() => '---')), ...rows].join('\n');
}

function markdown(parts, arms) {
  const meta = arms.map((arm) => '- **' + mdText(arm.label) + '** · ' + arm.meta.map(mdText).join(' · '));
  const [depth, separation, counts, timing, health] = parts;
  return ['# ' + title, meta.join('\n'), '## Profile results', depth.note.replace('>=', '`>=`'),
    timing.note + ' ' + health.note, markdownTable(arms, [counts, depth, timing, health]),
    '## ' + separation.title, separation.note, markdownTable(arms, [separation], true)].join('\n\n') + '\n';
}

const styles = `
:root {color-scheme:dark; --ink:#f0efe9; --muted:#b4b6bb; --rule:#43454b; --paper:#17181b}
* {box-sizing:border-box}
html {background:var(--paper); color:var(--ink); scroll-padding-top:5rem}
body {margin:0; font:20px/1.35 system-ui,sans-serif; font-variant-numeric:tabular-nums}
main {padding:2rem clamp(1rem,2.5vw,4rem) 4rem}
header {display:flex; flex-wrap:wrap; align-items:baseline; justify-content:space-between; gap:1rem; margin-bottom:1.3rem}
h1,h2,p,dl,dd {margin:0} h1 {font-size:2.7rem; letter-spacing:-.045em}
h2 {font-size:1.75rem; letter-spacing:-.025em; margin-bottom:.15rem}
nav {display:flex; flex-wrap:wrap; gap:1.2rem} a {color:var(--ink); text-underline-offset:.25em}
table {width:100%; min-width:calc(10rem + var(--arms) * 21rem); table-layout:fixed; border-spacing:0}
col:first-child {width:10rem}
th,td {padding:.7rem 1rem; vertical-align:top; text-align:left; overflow-wrap:anywhere}
thead th {position:sticky; top:0; z-index:1; background:#27282d; border-block:2px solid #73757c; vertical-align:middle}
th.arm {font-size:1.65rem; letter-spacing:-.025em}
td,th.arm {border-left:1px solid var(--rule)}
.metadata td {color:var(--muted); line-height:1.5; background:#202125}
.meta-sha {color:var(--ink); font-family:ui-monospace,monospace}
.section th {padding:1.4rem 0 .7rem; border-bottom:1px solid var(--rule)}
.section p {font-weight:400; color:var(--muted); max-width:115ch}
.data th,.data td {border-bottom:1px solid var(--rule)}
.data th {font-weight:600; padding-left:0}
dl {display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:.5rem .8rem}
dt {color:var(--muted); font-size:20px} dd {font-size:1.4rem; font-weight:600}
.depth dd {font-size:1.65rem} .depth dl {grid-template-columns:1.2fr 1.2fr .85fr 1fr}
.separation dl,.counts dl {grid-template-columns:repeat(3,minmax(0,1fr))}
.health dl {grid-template-columns:1fr 1fr 1.7fr}
.health dd,.separation dd {font-size:1.25rem} .miss {color:#ffcb70}
.missing {color:var(--muted); font-size:20px; font-weight:400}
@media print {thead th {position:static} main {padding:0} nav {display:none} tr {break-inside:avoid}}
`;

function htmlCell(row, section) {
  if (!row) return '<td class="missing">not measured</td>';
  const values = row[section.key].map(({ text, miss }, i) => {
    const cls = miss ? 'miss' : text === 'not measured' ? 'missing' : '';
    return '<div><dt>' + escapeHtml(section.fields[i]) + '</dt><dd class="' + cls + '">'
      + escapeHtml(text) + '</dd></div>';
  });
  return '<td><dl>' + values.join('') + '</dl></td>';
}

function htmlSection(section, arms) {
  const { key } = section;
  const groups = arms.map((arm) => new Map(rowsFor(arm, key).map((r) => [r.key, r])));
  const keys = key === 'separation' ? [...groups[0].keys()] : PROFILES.filter((p) => groups.some((g) => g.has(p)));
  const rows = keys.map((name) => '<tr class="data"><th scope="row">' + escapeHtml(name) + '</th>'
    + groups.map((g) => htmlCell(g.get(name), section)).join('') + '</tr>');
  return '<tbody class="' + key + '"><tr class="section"><th colspan="' + (arms.length + 1) + '"><h2 id="' + key
    + '">' + section.title + '</h2><p>' + escapeHtml(section.note) + '</p></th></tr>' + rows.join('\n') + '</tbody>';
}

function html(parts, arms) {
  const names = arms.map((a) => '<th class="arm" scope="col">' + escapeHtml(a.label) + '</th>');
  const meta = arms.map((arm) => '<td><span class="meta-sha" title="' + escapeHtml(arm.sha ?? 'not measured')
    + '">' + escapeHtml(arm.meta[0]) + '</span> · '
    + arm.meta.slice(1).map(escapeHtml).join(' · ') + '</td>');
  const links = parts.map((s) => '<a href="#' + s.key + '">' + s.title + '</a>');
  return '<!doctype html>\n<html lang="en"><head><meta charset="utf-8"><meta name="viewport" '
    + 'content="width=device-width,initial-scale=1"><title>RTAI · ' + title + '</title><style>' + styles
    + '</style></head><body><main><header><h1>' + title + '</h1><nav>' + links.join('') + '</nav></header>'
    + '<table aria-label="Gauntlet batch comparison" style="--arms:' + arms.length + '"><colgroup><col><col span="'
    + arms.length + '"></colgroup><thead><tr><th scope="col">RTAI</th>' + names.join('')
    + '</tr></thead><tbody><tr class="metadata"><th scope="row">Batch settings</th>' + meta.join('') + '</tr></tbody>'
    + parts.map((s) => htmlSection(s, arms)).join('\n') + '</table></main></body></html>\n';
}

export function renderComparison(arms, targets) {
  const parts = sections(targets);
  return { markdown: markdown(parts, arms), html: html(parts, arms) };
}
