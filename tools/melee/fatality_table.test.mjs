import test from 'node:test';
import assert from 'node:assert/strict';
import { chainsawShare, markdown, parseArgs, plays, runArgs, shareLine, tally, victimKind } from './fatality_table.mjs';

const rec = (o) => ({ weapon: 'chainsaw', archetype: 'patrol_cop', human: true, shield: 'none', kill_kind: 'shot',
  plays: 'chainsaw_grind_patrol_cop:patrol_cop', ...o });

test('plays strips the variant victim, victimKind adds the shield', () => {
  assert.equal(plays(rec({})), 'chainsaw_grind_patrol_cop');
  assert.equal(plays({}), 'generic');
  assert.equal(victimKind(rec({})), 'patrol_cop');
  assert.equal(victimKind(rec({ archetype: 'riot_cop', shield: 'front' })), 'riot_cop (shield front)');
});

test('tally counts weapon x victim kind x plays', () => {
  const t = tally([{ records: [rec({}), rec({}), rec({ plays: 'generic' }), rec({ weapon: 'katana', plays: 'katana_split' })] }]);
  assert.equal(t.chainsaw.patrol_cop.chainsaw_grind_patrol_cop, 2);
  assert.equal(t.chainsaw.patrol_cop.generic, 1);
  assert.equal(t.katana.patrol_cop.katana_split, 1);
  assert.equal(markdown(t).trim().split('\n').length, 4);
});

test('chainsaw share counts only shieldless humans and names each miss', () => {
  const s = chainsawShare([{ seed: 3, records: [rec({}), rec({ plays: 'generic', tick: 9 }),
    rec({ shield: 'front', plays: 'generic' }), rec({ human: false, plays: 'generic' }), rec({ weapon: 'katana', plays: 'generic' })] }]);
  assert.deepEqual([s.n, s.m, s.share], [1, 2, 0.5]);
  assert.equal(s.misses.length, 1);
  assert.equal(s.misses[0].seed, 3);
  assert.match(shareLine(s), /1\/2 \(50\.0 %; bar 100 %\)/);
  assert.equal(chainsawShare([]).share, null);
});

test('parseArgs defaults and refusals; runArgs names the probe', () => {
  assert.equal(parseArgs([]).seeds, 5);
  assert.deepEqual(parseArgs(['--weapons=chainsaw']).weapons, ['chainsaw']);
  assert.throws(() => parseArgs(['--weapons=spoon']));
  assert.throws(() => parseArgs(['--nope=1']));
  assert.throws(() => parseArgs(['--label=a/b']));
  assert.equal(runArgs('katana', 2, 4, 'x.json')[1], 'fatality_probe');
});
