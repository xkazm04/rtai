import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parse, runs } from './rule_stills.mjs';

test('parse needs --rev and --out and checks --only', () => {
  assert.ok(parse(['--rev=live']).error);
  assert.ok(parse(['--rev=live', '--out=/x', '--only=city']).error);
  assert.equal(parse(['--rev=HEAD', '--out=/x']).f.rev, 'HEAD');
});

test('every run is windowed on the secondary display at 1080p with d3d12', () => {
  for (const [, args] of runs('/o')) {
    assert.equal(args[args.indexOf('--position') + 1], '0,1440');
    assert.equal(args[args.indexOf('--rendering-driver') + 1], 'd3d12');
  }
  assert.deepEqual(runs('/o', 'gauntlet').map(([n]) => n), ['gauntlet']);
  assert.ok(runs('/o', 'gauntlet')[0][2].GTAI_GAUNTLET_STILLS.endsWith('gauntlet'));
});
