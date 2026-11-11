// The gates step's own evidence, one line per kind, so `morning: gates: green` (or red) says WHAT passed:
// unit counts, scenario count, parity, look goldens. Reads build/evidence/*.json (pof.godot-evidence/1)
// in the integration worktree. A kind written for another commit is named STALE, never shown as this run's.
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

export const SCHEMA = 'pof.godot-evidence/1';
export const SUMMARY_MAX = 200;

/** Lines for the evidence files in `dir` judged against `head` (a full sha). Pure over `read`/`list`. */
export function gateLines(dir, head, { list = (d) => (existsSync(d) ? readdirSync(d) : []), read = (f) => readFileSync(f, 'utf8') } = {}) {
  const lines = [];
  for (const name of list(dir).filter((n) => n.endsWith('.json')).sort()) {
    let j;
    try { j = JSON.parse(read(join(dir, name))); } catch { continue; }
    if (j?.schema !== SCHEMA || typeof j.kind !== 'string') continue;
    const text = String(j.summary ?? '').replace(/\s+/g, ' ').trim();
    const short = text.length > SUMMARY_MAX ? `${text.slice(0, SUMMARY_MAX - 3)}...` : text;
    const stale = head && j.commit && !String(head).startsWith(String(j.commit)) && !String(j.commit).startsWith(String(head));
    lines.push(`morning: gates: ${j.kind} ${stale ? `STALE (written for ${String(j.commit).slice(0, 9)})` : String(j.status ?? '?')}: ${short}`);
  }
  return lines.length ? lines : [`morning: gates: no ${SCHEMA} evidence in ${dir}`];
}
