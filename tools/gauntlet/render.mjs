import { targets } from './death_score.mjs';
import { TARGET_S, timeBounds } from './analysis.mjs';
import { fmt, sections } from './report_tables.mjs';

const esc = (s) => String(s).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;').replaceAll("'", '&#39;');
const md = (s) => esc(s).replaceAll('\\', '\\\\').replaceAll('|', '\\|').replace(/[\r\n]+/g, ' ');
const caption = (batch) => (batch.git?.branch || 'detached') + ' @ ' + (batch.git?.sha ?? 'unknown').slice(0, 12)
  + (batch.git?.dirty ? ' (dirty)' : '');

function introduction(batch, model, before) {
  const average = model.waves.filter((w) => w.profile === 'average' && w.timed);
  const misses = average.filter((w) => w.miss).map((w) => w.n + ' (' + fmt(w.median) + ' s)');
  const timing = timeBounds(1).join('–') + ' s for ordinary waves and ' + targets.boss_wave_seconds.join('–') + ' s for boss waves';
  const finding = !average.length ? 'Average-profile wave time was not measured.'
    : misses.length ? 'Average-profile waves ' + misses.join(', ') + ' fell outside ' + timing + '.'
    : 'All measured average-profile wave medians met their timing targets.';
  const lines = [batch.results.length + ' of ' + batch.runs.length + ' runs accepted. ' + finding,
    (batch.args.from ? 'Imported files' : 'Live ' + batch.args.runner + ' batch') + ' · ' + caption(batch)
      + ' · ' + batch.created + '.'];
  lines.push('Stalled runs by profile: ' + model.deaths.map((d) => d.profile + ' ' + d.stalled).join(', ') + '.');
  lines.push('Capped alive by profile: ' + model.deaths.map((d) => d.profile + ' ' + d.capped).join(', ') + '.');
  if (before) lines.push('Baseline ' + caption(before) + ' · ' + before.created + ' · ' + before.results.length + ' accepted runs.');
  return lines;
}

function markdownTable(s) {
  if (!s.rows.length) return s.empty ?? 'No observations.';
  const row = (cells) => '| ' + cells.map(md).join(' | ') + ' |';
  return [row(s.columns), row(s.columns.map(() => '---')), ...s.rows.map(row)].join('\n');
}

function htmlTable(s) {
  if (!s.rows.length) return '<p class="empty">' + esc(s.empty ?? 'No observations.') + '</p>';
  const rows = s.rows.map((row) => '<tr>' + row.map((v, i) => {
    let value = esc(v);
    if (v === 'miss') value = '<strong class="miss">miss</strong>';
    const ghostColumn = /^(dent|kerf|ohm|tonnage) s \(n\)$/.test(s.columns[i]);
    if (s.key === 'telemetry' && ghostColumn && v !== 'not measured') value = '<span class="form">' + value + '</span>';
    if (s.columns[i] === 'Replay command') value = '<code>' + value + '</code>';
    return '<td>' + value + '</td>';
  }).join('') + '</tr>').join('\n');
  return '<div class="scroll"><table><thead><tr>' + s.columns.map((v) => '<th scope="col">' + esc(v) + '</th>').join('')
    + '</tr></thead><tbody>' + rows + '</tbody></table></div>';
}

function timingChart(profile, waves) {
  const rows = waves.filter((w) => w.timed);
  if (!rows.length) return '';
  const width = 520, height = 196, left = 48, right = width - 22, bottom = height - 30;
  const top = 20, max = Math.ceil(Math.max(TARGET_S * 1.2, ...rows.map((w) => w.p75)) / 5) * 5;
  const first = rows[0].n, last = rows.at(-1).n;
  const x = (n) => first === last ? (left + right) / 2 : left + (right - left) * (n - first) / (last - first);
  const y = (s) => bottom - (bottom - top) * s / max;
  const text = (xPos, yPos, value, anchor = 'middle') =>
    '<text x="' + xPos + '" y="' + yPos + '" text-anchor="' + anchor + '">' + esc(value) + '</text>';
  const line = (x1, y1, x2, y2, cls) => '<line class="' + cls + '" x1="' + x1 + '" y1="' + y1
    + '" x2="' + x2 + '" y2="' + y2 + '"/>';
  const elements = [line(left, bottom, right, bottom, 'axis'), line(left, top, left, bottom, 'axis')];
  for (const s of [0, TARGET_S, max]) {
    elements.push(text(left - 6, y(s) + 4, s + ' s', 'end'));
    if (s === TARGET_S) elements.push(line(left, y(s), right, y(s), 'target'));
  }
  const labels = new Set(Array.from({ length: Math.min(7, rows.length) }, (_, index) =>
    Math.round(index * (rows.length - 1) / Math.max(1, Math.min(7, rows.length) - 1))));
  for (const [i, w] of rows.entries()) {
    const cx = x(w.n);
    elements.push(line(cx, y(w.p25), cx, y(w.p75), 'quartiles'));
    elements.push('<circle class="' + (w.miss ? 'outlier' : 'point') + '" cx="' + cx + '" cy="' + y(w.median)
      + '" r="3.5"><title>Wave ' + w.n + ' · ' + fmt(w.median) + ' s · n=' + w.timed + '</title></circle>');
    if (labels.has(i)) elements.push(text(cx, bottom + 17, w.n));
  }
  return '<figure><figcaption>' + esc(profile) + '</figcaption><svg role="img" viewBox="0 0 ' + width + ' ' + height
    + '"><title>' + esc(profile) + ' wave times, median and interquartile range in seconds</title>' + elements.join('')
    + '</svg></figure>';
}

const styles = `
:root {color-scheme: light; font: 16px/1.5 system-ui,sans-serif; color:#192b3b; background:#f8f8f5}
* {box-sizing:border-box}
body {margin:0 auto; max-width:92rem; padding:clamp(1rem,4vw,4rem)}
header {padding-bottom:1rem; border-bottom:2px solid #283d51}
h1,h2,figcaption {line-height:1.2}
h1 {font-size:clamp(2rem,4vw,3.2rem); letter-spacing:-.045em; margin:0 0 .75rem}
h2 {font-size:1.45rem; margin:2.5rem 0 .45rem}
header p,section>p {max-width:90ch; margin:.4rem 0 .9rem}
.meta,.empty,svg text {color:#4f5b64}
.scroll {overflow-x:auto; border:1px solid #d0d6d8; background:#fff}
table {width:100%; border-collapse:collapse; font-size:.9rem; font-variant-numeric:tabular-nums}
td,th {padding:.5rem .7rem; text-align:left; vertical-align:top; border-bottom:1px solid #e2e6e7}
th {background:#e9edef; font-weight:650; white-space:nowrap}
tbody tr:nth-child(even) {background:#fafbfb}
code {font:.84rem/1.4 ui-monospace,monospace; overflow-wrap:anywhere}
.miss {color:#744c00; background:#fff1c9; padding:.12rem .38rem}
.form {color:#006b65}
.charts {display:grid; grid-template-columns:repeat(auto-fit,minmax(min(100%,18rem),1fr)); gap:.85rem; margin:1rem 0}
figure {margin:0; padding:.7rem; border:1px solid #cdd4d8; background:#fff}
figcaption {font-weight:650; text-transform:capitalize}
svg {width:100%; height:auto} svg text {font:12px system-ui,sans-serif; fill:#435360}
.axis {stroke:#aab5bd} .target {stroke:#74644a; stroke-dasharray:5 4}
.quartiles {stroke:#9db5cd; stroke-width:6} .point {fill:#294e73} .outlier {fill:#ab6c00}
@media print {body {padding:0} .scroll {overflow:visible} table {font-size:8pt} figure,tr {break-inside:avoid}}
`;

export function render(batch, model, baseline) {
  const intro = introduction(batch, model, baseline);
  const parts = sections(batch, model, baseline);
  const markdown = ['# Gauntlet run report', ...intro, ...parts.flatMap((s) =>
    ['## ' + s.title, s.note, markdownTable(s)])].join('\n\n') + '\n';
  const charts = [...Map.groupBy(model.waves, (w) => w.profile)].map(([p, rows]) => timingChart(p, rows)).join('');
  const html = '<!doctype html>\n<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">'
    + '<title>Gauntlet run report</title><style>' + styles + '</style></head><body><header><h1>Gauntlet run report</h1>'
    + intro.map((p, i) => '<p' + (i ? ' class="meta"' : '') + '>' + esc(p) + '</p>').join('') + '</header><main>'
    + parts.map((s) => '<section><h2>' + esc(s.title) + '</h2><p>' + esc(s.note) + '</p>'
      + (s.key === 'time' && charts ? '<p>Dots show medians by wave, bars show the middle half, and the dashed line marks the ordinary-wave target.</p><div class="charts">' + charts + '</div>' : '')
      + htmlTable(s) + '</section>').join('\n') + '</main></body></html>\n';
  return { markdown, html };
}
