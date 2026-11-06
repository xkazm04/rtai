#!/usr/bin/env node
// Autosave crash test: a headless Godot autosaves in a tight loop, is killed (by PID) at a random
// moment, and the two slots are then read with an independent GTSV reader (STANDARDS SAV-02,
// written here from the spec, not from the GDScript). After the first two completed writes,
// at least one slot must always be a valid container, the sequence numbers must never go
// backwards across rounds, and nothing but the two slots, meta.json and a tmp may exist.
//   node tools/tests/save_crash.mjs [rounds=12]
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { runGodot } from '../lib/godot.mjs';

const rounds = Number(process.argv[2] ?? 12);
const dir = join(ROOT, 'build', 'save-crash');
rmSync(dir, { recursive: true, force: true });
mkdirSync(dir, { recursive: true });

function readSlot(path) {
  if (!existsSync(path)) return { kind: 'missing' };
  const b = readFileSync(path);
  if (b.length < 36 || b.subarray(0, 4).toString('latin1') !== 'GTSV') return { kind: 'corrupt', why: 'header' };
  const len = Number(b.readBigUInt64LE(12));
  const payload = b.subarray(36);
  if (len !== payload.length) return { kind: 'corrupt', why: 'length' };
  if (!createHash('sha256').update(payload).digest().subarray(0, 16).equals(b.subarray(20, 36))) {
    return { kind: 'corrupt', why: 'hash' };
  }
  const env = JSON.parse(payload.toString('utf8'));
  return { kind: 'ok', seq: env.seq, point: env.point };
}

function census(root) {
  const out = [];
  for (const e of readdirSync(root, { withFileTypes: true })) {
    if (e.isDirectory()) for (const f of readdirSync(join(root, e.name))) out.push(`${e.name}/${f}`);
    else out.push(e.name);
  }
  return out.sort();
}

const killedAt = [];
const rows = [];
let lastSeq = 0;
let failures = 0;
for (let r = 1; r <= rounds; r++) {
  // the launcher's timeout (process-tree kill) IS the crash, after a random moment
  const wait = 2500 + Math.floor(Math.random() * 2500);
  await runGodot(['-s', 'res://dev/save_crash_writer.gd', '--', `--root=${dir}`], { timeoutMs: wait });
  killedAt.push(wait);
  await new Promise((res) => setTimeout(res, 300));
  const a = readSlot(join(dir, 'auto_a', 'state.sav'));
  const b = readSlot(join(dir, 'auto_b', 'state.sav'));
  const valid = [a, b].filter((s) => s.kind === 'ok');
  const files = census(dir);
  const stray = files.filter((f) => !/^(auto_[ab]\/state\.sav(\.tmp)?|meta\.json(\.tmp)?)$/.test(f));
  const top = valid.length ? Math.max(...valid.map((s) => s.seq)) : 0;
  const problems = [];
  if (r > 1 && valid.length === 0) problems.push('NO valid slot');
  if (top < lastSeq) problems.push(`sequence went backwards ${lastSeq} -> ${top}`);
  if (stray.length) problems.push(`stray files ${stray}`);
  if (problems.length) failures++;
  lastSeq = Math.max(lastSeq, top);
  rows.push({ round: r, killed_after_ms: wait, a, b, files, problems });
  console.log(`round ${r}: a=${a.kind}${a.seq ?? ''} b=${b.kind}${b.seq ?? ''} files=${files.length} ${problems.join('; ') || 'ok'}`);
  // A load pass would quarantine/clean; the next writer start must cope with a leftover tmp itself.
}
const out = join(ROOT, 'evidence', 'autosave', 'save-crash.json');
mkdirSync(join(ROOT, 'evidence', 'autosave'), { recursive: true });
writeFileSync(out, JSON.stringify({ rounds, failures, rows }, null, 2));
console.log(`save-crash: ${rounds} kills, ${failures} failures, final seq ${lastSeq}`);
process.exit(failures ? 1 : 0);
