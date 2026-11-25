// yard_frame_probe through tools/dev/run.mjs main() with the display args (as tools/art/prologue_yard_stills.mjs).
import { main } from '../../tools/dev/run.mjs';
import { runGodot } from '../../tools/lib/godot.mjs';
const display = ['--windowed', '--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080'];
const runner = (args, options) => runGodot(options.headless === false ? [...display, ...args] : args, options);
process.exitCode = await main(['res://dev/prologue_yard/yard_frame_probe.tscn', '--windowed', '--timeout=150', ...process.argv.slice(2)], { runner });
