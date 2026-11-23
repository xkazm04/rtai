#!/usr/bin/env node
// The dev CLI exposes fixed-fps and quit-after as engine arguments. Use its normal
// resolution, asset preflight, timeout and verdict, adding the display arguments before the scene.
import { main } from '../dev/run.mjs';
import { runGodot } from '../lib/godot.mjs';

const display = ['--windowed', '--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080'];
const runner = (args, options) => runGodot(options.headless === false ? [...display, ...args] : args, options);
process.exitCode = await main(['res://dev/prologue_yard/yard_stills.tscn', '--windowed', ...process.argv.slice(2)], { runner });
