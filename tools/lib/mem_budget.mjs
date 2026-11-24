// Soft memory budget: when an outer wrapper caps the whole run (a Windows Job Object that writes a
// status JSON every 5 s, path in GTAI_CAP_STATUS), wait until a new heavy launch fits before starting it.
// No status file, a finished run or a stale file means no cap is in force and nothing waits.
import { readFileSync } from 'node:fs';

const STALE_MS = 60_000;
const num = (v, d) => (Number.isFinite(Number(v)) && v !== undefined && v !== '' ? Number(v) : d);

/** Reads the status file; null when no cap is in force (unset, missing, unreadable, done or stale). */
export function readStatus(env = process.env, now = Date.now()) {
  const file = env.GTAI_CAP_STATUS;
  if (!file) return null;
  try {
    const s = JSON.parse(readFileSync(file, 'utf8').replace(/^﻿/, ''));
    if (!s || s.done === true || !Number.isFinite(s.usedMB) || !Number.isFinite(s.capMB)) return null;
    const ts = Date.parse(s.ts);
    if (!Number.isFinite(ts) || now - ts > STALE_MS) return null;
    return s;
  } catch {
    return null;
  }
}

export const godotEstMB = (env = process.env) => num(env.GTAI_GODOT_EST_MB, 1200);

/** Waits until usedMB + estMB fits the budget (GTAI_MEM_BUDGET_MB, default 80 % of capMB). Gives up
 *  after GTAI_MEM_WAIT_MAX_S (default 1800) and starts anyway. Resolves { waitedS }. */
export async function waitForBudget({ estMB, label = 'launch', log = console.error, env = process.env,
  pollMs = 10_000, sleep = (ms) => new Promise((r) => setTimeout(r, ms)), clock = Date.now } = {}) {
  const maxMs = num(env.GTAI_MEM_WAIT_MAX_S, 1800) * 1000;
  const t0 = clock();
  let announced = false;
  for (;;) {
    const s = readStatus(env, clock());
    if (!s) break;
    const budget = num(env.GTAI_MEM_BUDGET_MB, s.capMB * 0.8);
    if (s.usedMB + estMB <= budget) break;
    if (clock() - t0 >= maxMs) {
      log(`mem-budget: waited ${Math.round((clock() - t0) / 1000)} s, starting anyway`);
      break;
    }
    if (!announced) {
      log(`mem-budget: waiting for ${estMB} MB (${s.usedMB}/${Math.round(budget)} MB used) before ${label}`);
      announced = true;
    }
    await sleep(pollMs);
  }
  return { waitedS: Math.round((clock() - t0) / 1000) };
}
