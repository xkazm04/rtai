// The morning merge's step guard: runs one command with the guard's own stdout/stderr (the step's
// log file), and on its timeout kills the WHOLE process tree. The merge's spawnSync timeout alone
// killed only its direct child; Godot runs as a grandchild of the reel and gate runners
// (tools/lib/godot.mjs), so a timed-out step would have left the engine running.
//
// Usage (by morning.mjs only): node step_guard.mjs <step> <timeoutMs> <shell 0|1> -- <cmd> [args...]
// Exit: the command's own code; GUARD_EXIT when it never ran or was killed for the timeout, after
// writing one `morning: <step>: ...` line. A clean run writes nothing of its own.
import { spawn } from 'node:child_process';
import { writeSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import { killTree } from '../lib/godot.mjs';

export const GUARD_EXIT = 222;
const SETTLE_MS = 3000; // after the kill, a grandchild still holding the log must not hang the guard

export function parseGuardArgs(argv) {
  const sep = argv.indexOf('--');
  const [step, ms, shell] = argv.slice(0, sep);
  const timeoutMs = Number(ms);
  if (sep !== 3 || !step || !(timeoutMs > 0) || !['0', '1'].includes(shell) || sep + 1 >= argv.length) return null;
  return { step, timeoutMs, shell: shell === '1', cmd: argv[sep + 1], args: argv.slice(sep + 2) };
}

const say = (line) => { try { writeSync(1, `\n${line}\n`); } catch { /* the log is gone: the exit code still says it */ } };

export function guard({ step, timeoutMs, shell, cmd, args }, exit = process.exit) {
  let over = false;
  const child = spawn(cmd, args, { stdio: 'inherit', windowsHide: true, shell, detached: process.platform !== 'win32' });
  const timer = setTimeout(() => {
    over = true;
    killTree(child.pid);
    say(`morning: ${step}: timed out after ${+(timeoutMs / 60000).toFixed(4)} min (the process tree was killed)`);
    setTimeout(() => exit(GUARD_EXIT), SETTLE_MS).unref();
  }, timeoutMs);
  child.on('error', (e) => { clearTimeout(timer); say(`morning: ${step}: ${e.message}`); exit(GUARD_EXIT); });
  child.on('exit', (code, signal) => {
    clearTimeout(timer);
    if (over) return exit(GUARD_EXIT);
    if (code === null) say(`morning: ${step}: ended by ${signal}`);
    exit(code ?? GUARD_EXIT);
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const o = parseGuardArgs(process.argv.slice(2));
  if (!o) { process.stderr.write('usage: node step_guard.mjs <step> <timeoutMs> <shell 0|1> -- <cmd> [args...]\n'); process.exit(2); }
  guard(o);
}
