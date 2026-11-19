#!/usr/bin/env node
// Run the dev entry with the film station's D3D12 and secondary-monitor settings.
// node tools/art/crowd_pop.mjs crowd_pop_audit --windowed --check --out=<absolute json path>
import { main } from '../dev/run.mjs';
import { runGodot } from '../lib/godot.mjs';

const windowArgs = ['--rendering-driver', 'd3d12', '--position', '0,1440'];
process.exitCode = await main(process.argv.slice(2), {
  runner(args, options) {
    return runGodot(options.headless === false ? [...windowArgs, ...args] : args, options);
  },
});
