#!/usr/bin/env node
// Reads a film's per-tick numbers: the range of each measure for one fighter over a window, so a
// bounce or a pop is one command instead of Python pasted over probe.json (hero's REQUEST, n11).
//   node tools/film/numbers.mjs <film-dir> [--subject=rivet|hostile|dead|id:<n>] [--ticks=<a-b>] [--json]
// Exit: 0 pass, 2 usage (nothing read), 3 unverifiable (the numbers do not exist for that window).
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { subjectRow } from './subject.mjs';

export const EXIT = { pass: 0, usage: 2, unverifiable: 3 };
export const NO_DRAW = -1;
const USAGE = 'usage: node tools/film/numbers.mjs <film-dir> [--subject=rivet|hostile|dead|id:<n>] [--ticks=<a-b>] [--json]';
const VALUE = new Set(['subject', 'ticks']);
const SWITCH = new Set(['json']);
const MEASURES = [['feet_y', (f) => f.feet_y], ['head_y', (f) => f.head_y], ['draw_h', (f) => f.draw?.[1]], ['draw_w', (f) => f.draw?.[0]],
  ['screen_x', (f) => f.screen?.[0]], ['screen_y', (f) => f.screen?.[1]], ['facing_off', (f) => f.facing_off]];

/** {dir, flags} or {error}. */
export function parseArgv(argv) {
  const flags = { subject: 'rivet' };
  let dir = null;
  for (const a of argv) {
    const m = /^--([a-z]+)(?:=(.*))?$/.exec(a);
    if (m && SWITCH.has(m[1]) && m[2] === undefined) flags[m[1]] = true;
    else if (m && VALUE.has(m[1]) && m[2]) flags[m[1]] = m[2];
    else if (!a.startsWith('-') && dir === null) dir = a;
    else return { error: `numbers: bad argument ${a}` };
  }
  if (!dir) return { error: 'numbers: name a film directory' };
  if (flags.ticks && !/^\d+-\d+$/.test(flags.ticks)) return { error: `numbers: --ticks must be a-b, got ${flags.ticks}` };
  if (!/^(rivet|hostile|dead|id:\d+)$/.test(flags.subject)) return { error: `numbers: --subject must be rivet, hostile, dead or id:<n>, got ${flags.subject}` };
  return { dir, flags };
}

/** {reasons, stats}. A value of -1 (no card that tick) is counted, never measured as a height. */
export function summarize(rows, subject, ticks) {
  const [from, to] = ticks ? ticks.split('-').map(Number) : [0, Infinity];
  const window = rows.filter((r) => r.tick >= from && r.tick <= to);
  if (!window.length) return { reasons: [`no ticks ${ticks ?? ''} in probe.json`.replace('  ', ' ')], stats: null };
  const seen = window.map((r) => ({ tick: r.tick, f: subjectRow(r, subject) })).filter((x) => x.f);
  if (!seen.length) return { reasons: [`no ${subject} in the numbers over ${window[0].tick}-${window.at(-1).tick}`], stats: null };
  const measures = {};
  for (const [name, read] of MEASURES) {
    const values = seen.map((x) => read(x.f)).filter((v) => Number.isFinite(v) && v !== NO_DRAW && v !== 999);
    if (values.length) measures[name] = { min: Math.min(...values), max: Math.max(...values), range: Math.max(...values) - Math.min(...values) };
  }
  const reasons = Object.keys(measures).length ? [] : [`no card was drawn for ${subject} in those ticks`];
  const noCard = seen.filter((x) => x.f.feet_y === NO_DRAW || x.f.feet_y === undefined).length;
  return { reasons, stats: { from: seen[0].tick, to: seen.at(-1).tick, ticks: seen.length, no_card_ticks: noCard, measures } };
}

const fmt = (v) => (Number.isInteger(v) ? String(v) : v.toFixed(1));

export function main(argv, { out = console.log, err = console.error } = {}) {
  const parsed = parseArgv(argv);
  if (parsed.error) { err(`${parsed.error}\n${USAGE}`); return EXIT.usage; }
  const file = join(parsed.dir, 'probe.json');
  if (!existsSync(parsed.dir)) { err(`numbers: no such film directory: ${parsed.dir}\n${USAGE}`); return EXIT.usage; }
  let probe = null;
  try { probe = JSON.parse(readFileSync(file, 'utf8')); } catch { /* reported below */ }
  if (!Array.isArray(probe?.rows)) { out(`numbers: UNVERIFIABLE: no readable probe.json in ${parsed.dir}`); return EXIT.unverifiable; }
  const { reasons, stats } = summarize(probe.rows, parsed.flags.subject, parsed.flags.ticks);
  if (reasons.length) { out(`numbers: UNVERIFIABLE: ${reasons.join('; ')}`); return EXIT.unverifiable; }
  if (parsed.flags.json) out(JSON.stringify({ subject: parsed.flags.subject, ...stats }));
  else {
    out(`numbers: ${parsed.flags.subject} ticks ${stats.from}-${stats.to} (${stats.ticks} rows, ${stats.no_card_ticks} with no card)`);
    for (const [name, m] of Object.entries(stats.measures)) out(`  ${name.padEnd(10)} ${fmt(m.min)} .. ${fmt(m.max)}  range ${fmt(m.range)}`);
  }
  return EXIT.pass;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main(process.argv.slice(2)));
}
