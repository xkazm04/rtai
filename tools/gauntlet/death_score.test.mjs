import assert from 'node:assert/strict';
import { test } from 'node:test';
import { deathScore } from './death_score.mjs';
import { pairRuns } from './tune_confirm.mjs';
import { samplesFor } from './tune_metric.mjs';

test('a live wave-limited run contributes a paired lower bound only on reaching its limit', () => {
  const run = { wave_reached: 12, profile: 'average', controls: 'wheel', seed: 1 };
  assert.equal(deathScore(run), null);
  assert.equal(deathScore(run, 13), null);
  assert.equal(deathScore({ ...run, death: { by: 'timeout' } }, 12), null);
  const batch = { results: [run], runs: [{ ...run, ok: true }], args: { waves: 12, pick: 'greedy' } };
  const after = { ...batch, results: [{ ...run, death: { wave: 11 } }] };
  const [s] = samplesFor(pairRuns(batch, after), { type: 'death', profile: 'average' });
  assert.deepEqual([s.a, s.b, s.censoredA, s.censoredB], [12, 11, true, false]);
});
