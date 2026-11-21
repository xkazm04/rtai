import { readJson } from '../lib/repo.mjs';
import { PROFILES, validateRun } from './contract.mjs';

// A cap is a legitimate live observation only if the launcher diagnosed the exit and
// attested to a fresh result. Timeouts, script errors and stale files remain failures.
export function capExit(row, verdict) {
  return row.exit === 1 && row.outcome === 'stalled'
    && /^FAIL exit 1 \(fail\); SCRIPT ERROR 0; unknown arg 0; result fresh(?:;|$)/.test(verdict);
}

export function readResult(file, row, checkIdentity = false, capped = false) {
  let result;
  try {
    result = readJson(file);
    if (!checkIdentity) {
      if ([...PROFILES, 'human'].includes(result?.profile)) row.profile = result.profile;
      if (Number.isSafeInteger(result?.seed)) row.seed = result.seed;
    }
    const reason = validateRun(result);
    if (reason) throw new Error(reason);
    if (checkIdentity && (row.profile !== result.profile || row.seed !== result.seed || row.controls !== result.controls))
      throw new Error('result profile, seed or controls do not match the command');
    if (capped) {
      if (result.death) throw new Error('tick-cap result records a death');
      row.outcome = 'capped';
      delete row.reason;
    }
    row.ok = true;
  } catch (err) {
    row.reason = err.message;
    row.ok = false;
  }
  return { row, result: row.ok ? result : null };
}
