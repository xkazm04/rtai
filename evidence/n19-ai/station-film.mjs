import { execFileSync } from 'node:child_process';
import { main } from '../../tools/film/film.mjs';
import { SHOTS } from '../../tools/film/shots.mjs';
import { runGodot } from '../../tools/lib/godot.mjs';

// Film the clean, pinned project in this worktree. Keep both the bot and the monitor fixed.
const [revision, output] = process.argv.slice(2);
const git = (...args) => execFileSync('git', args, { encoding: 'utf8' }).trim();
SHOTS.city.flags = () => ['--arena=city', '--bot=pit'];
process.exitCode = await main([
  'city', '--rev=' + revision, '--out=' + output, '--ticks=701', '--stills=697',
  '--ppm=32', '--lock=530,535', '--seed=20261103', '--feel=off', '--no-movie', '--',
  '--enemy-brain=squad', '--film-ticks=697-697',
], {
  resolveSide(rev) {
    const head = git('rev-parse', 'HEAD');
    if (git('rev-parse', rev) !== head || git('status', '--porcelain', '--', 'project')) {
      throw Error('Capture requires the specified revision checked out with a clean project');
    }
    return { tree: process.cwd(), label: head, snapshot: false };
  },
  runner(args, opts) {
    const display = args.includes('--rendering-driver') ? ['--windowed', '--position', '0,1440'] : [];
    return runGodot([...display, ...args], opts);
  },
});
