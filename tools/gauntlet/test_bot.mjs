#!/usr/bin/env node
import { fileURLToPath } from 'node:url';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const script = fileURLToPath(new URL('./test_bot_moves.gd', import.meta.url)).replaceAll('\\', '/');
const result = await runGodot(['-s', 'res://addons/gut/gut_cmdln.gd', '-gconfig=', '-gtest=' + script, '-gexit']);
process.stdout.write(result.out);
process.exitCode = result.status === 0 && !SCRIPT_ERROR.test(result.out) && result.out.includes('All tests passed') ? 0 : 1;
