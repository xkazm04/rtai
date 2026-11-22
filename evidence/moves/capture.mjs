// Runs the move film through the dev runner's argument, asset, timeout and log checks.
// Godot opens its AVI at the project's viewport size before the scene receives _ready().
// A temporary config gives the writer 1080p. All game directories resolve to this worktree.
import { spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, renameSync,
  rmdirSync, symlinkSync, unlinkSync, writeFileSync } from 'node:fs';
import { isAbsolute, join, resolve } from 'node:path';
import { main } from '../../tools/dev/run.mjs';
import { ROOT } from '../../tools/lib/repo.mjs';
import { ensureImport, runGodot } from '../../tools/lib/godot.mjs';

const [destination, move, ...flags] = process.argv.slice(2);
if (!destination || !isAbsolute(destination) || !/^[a-z_]+$/.test(move ?? '')
    || flags.some((flag) => !/^(--off|--(?:ppm|stills)=.+)$/.test(flag))) {
  throw Error('usage: node evidence/moves/capture.mjs <absolute masters dir> <move id> [--off] [--ppm=64] [--stills=109,110]');
}
const out = resolve(destination);
mkdirSync(out, { recursive: true });
const stills = flags.some((s) => s.startsWith('--stills='));
const basename = move + (flags.includes('--off') ? '-off' : '');
const avi = join(out, basename + '.avi');
const scratch = mkdtempSync(join(out, '.capture-'));
const project = join(scratch, 'project');
const encoded = join(scratch, basename + '.mp4');
mkdirSync(project);
try {
  const original = join(ROOT, 'project');
  for (const item of readdirSync(original, { withFileTypes: true })) {
    const source = join(original, item.name);
    const target = join(project, item.name);
    if (item.isDirectory()) {
      symlinkSync(source, target, process.platform === 'win32' ? 'junction' : 'dir');
    } else if (item.name === 'project.godot') {
      const cfg = readFileSync(source, 'utf8')
        .replace(/^window\/size\/viewport_width=\d+$/m, 'window/size/viewport_width=1920')
        .replace(/^window\/size\/viewport_height=\d+$/m, 'window/size/viewport_height=1080');
      writeFileSync(target, cfg);
    } else {
      copyFileSync(source, target);
    }
  }
  const engine = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440',
    '--resolution', '1920x1080', '--disable-vsync'];
  if (!stills) engine.push('--write-movie', avi);
  const args = ['move_film', '--windowed', '--timeout=1400', '--move=' + move, '--out=' + out,
    '--kerf-glide=off', ...flags];
  process.exitCode = await main(args, {
    runner: async (cmd, opts) => {
      if (opts.headless !== false) return runGodot(cmd, opts);
      const imported = await ensureImport();
      if (imported.status) throw Error('The worktree class-cache import failed');
      return runGodot([...engine, ...cmd], { ...opts, cwd: scratch, ensure: false });
    },
  });
  if (!stills && process.exitCode === 0) {
    // The writer also records the final quit draw. Keep exactly the scene's 960 frames.
    const result = spawnSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi,
      '-t', '16', '-vf', 'scale=in_range=pc:out_range=tv', '-color_range', 'tv',
      '-c:v', 'libx264', '-crf', '18', '-pix_fmt', 'yuv420p', '-c:a', 'aac',
      '-b:a', '192k', '-movflags', '+faststart', encoded], { stdio: 'inherit', windowsHide: true });
    if (result.error?.code === 'ENOENT') console.log('ffmpeg unavailable; kept ' + avi);
    else if (result.status !== 0) throw Error('ffmpeg failed; kept ' + avi);
    else {
      renameSync(encoded, join(out, basename + '.mp4'));
      unlinkSync(avi);
    }
  }
} finally {
  // Unlink the junctions themselves, including the Godot cache. Never descend into them.
  for (const name of readdirSync(project)) {
    const item = join(project, name);
    if (lstatSync(item).isSymbolicLink() || !lstatSync(item).isDirectory()) unlinkSync(item);
  }
  rmdirSync(project);
  if (existsSync(encoded)) unlinkSync(encoded);
  rmdirSync(scratch);
}
