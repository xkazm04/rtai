// Locked, paired cost of the visible ghost in the review arena. CPU covers the engine's full life.
// node tools/perf/polish_ghost_cost.mjs --rounds=6 --until=<ISO deadline>
import { openSync, closeSync, writeFileSync, readFileSync, existsSync, statSync, futimesSync,
  unlinkSync, mkdirSync, mkdtempSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { setTimeout as sleep } from 'node:timers/promises';
import { ROOT, git } from '../lib/repo.mjs';
import { resolveGodot, runProcess, SCRIPT_ERROR } from '../lib/godot.mjs';
import { godotProcesses, register } from '../lib/run_ledger.mjs';
import { START, FRAMES } from '../film/ghost_films_plan.mjs';
import { order, summarise } from './fight_gate.mjs';
import { frameStats } from './stats.mjs';

const LOCK = 'C:/Users/kazda/kiro/gtai-n21/bench.lock';
const OUT = 'C:/Users/kazda/kiro/gtai-masters/n21/polish/cost';
const ENTRY = join(ROOT, 'project/dev/ghost-powers/ghost_review.gd');
const SCENE = 'res://dev/ghost-powers/ghost_review.tscn';
const GHOSTS = ['tonnage', 'dent', 'ohm'];
const ARMS = [{ name: 'legacy' }, { name: 'spectral' }, { name: 'legacy-aa', twin: true }];
const END = START + FRAMES - 1;
const METRICS = ['p50', 'p99', 'worst', 'over25', 'cpu'];
const read = file => readFileSync(file, 'utf8');
const numeric = value => Number.isFinite(value) ? value.toFixed(3) : 'not measured';

export function argumentsFor(ghost, look, path, trace) {
  const output = path.replaceAll('\\', '/');
  return ['--path', 'project', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
    '--rendering-driver', 'd3d12', '--disable-vsync', '--fixed-fps', '60', '--quit-after', '402',
    SCENE, '--', '--ghost=' + ghost, '--take=move', '--view=tilt70', '--ppm=32', '--clean',
    '--ghost-look=' + look, ...(trace ? ['--shot=' + output + '.png', '--shot-tick=' + (END + 1)] : []),
    (trace ? '--film-trace=' : '--frames=') + output];
}

// The dev arena reports these two disposal messages after its last frame. Retain them in evidence.
export function engineErrors(log) {
  return log.split(/\r?\n/).filter(line => SCRIPT_ERROR.test(line) || /SHADER ERROR|\[ERROR\]|^ERROR:/.test(line))
    .filter(line => !/^ERROR: (\d+ resources still in use at exit\b|Pages in use exist at exit in PagedAllocator:)/.test(line));
}

// FightFrames timestamps the interval ending at tick t. Keep exactly the same active ticks in all looks.
export function frameWindow(doc) {
  if (doc.schema !== 'gtai.fight-frames/1' || doc.tick?.length !== doc.wall_ms?.length) {
    throw Error('invalid FightFrames log');
  }
  const selected = doc.tick.flatMap((tick, i) => tick >= START && tick <= END ? [[tick, doc.wall_ms[i]]] : []);
  if (selected.length !== FRAMES || selected.some(([tick, ms], i) =>
    tick !== START + i || !Number.isFinite(ms) || ms <= 0)) throw Error('incomplete fixed-tick frame window');
  return frameStats(selected.map(([, ms]) => ms));
}

export function checkTrace(text, ghost) {
  const [header, ...rows] = text.trim().split(/\r?\n/).map(JSON.parse);
  const col = name => header.columns.indexOf(name);
  if (header.schema !== 'gtai.ghost-review/1' ||
      ['tick', 'form', 'px_per_m', 'screen_x', 'screen_y'].some(k => col(k) < 0)) throw Error('invalid review trace');
  const active = rows.filter(r => r[col('tick')] >= START && r[col('tick')] <= END);
  if (active.length !== FRAMES || active.some((r, i) => r[col('tick')] !== START + i ||
    r[col('form')] !== ghost || !(Math.abs(r[col('px_per_m')] - 32) <= 0.01) ||
    !(r[col('screen_x')] >= 0 && r[col('screen_x')] < 1920 &&
      r[col('screen_y')] >= 0 && r[col('screen_y')] < 1080))) throw Error('form, tick, framing or scale mismatch');
  return active.length;
}

// Only the frame flag declaration is missing. Restore the original bytes after the locked session.
function permitFrames() {
  const before = read(ENTRY);
  const after = before.replace(/(const KNOWN_FLAGS: PackedStringArray = \[\r?\n)/, '$1\t"--frames",\n');
  if (/^\s*"--frames",?\s*$/m.test(before)) return () => {};
  if (before === after) throw Error('could not locate ghost_review KNOWN_FLAGS');
  writeFileSync(ENTRY, after);
  return () => {
    if (read(ENTRY) !== after) throw Error('scene changed during the run, review the temporary --frames declaration');
    writeFileSync(ENTRY, before);
  };
}

async function acquire(until) {
  const token = 'polish ' + process.pid + ' ' + Date.now();
  while (Date.now() < until) {
    let fd;
    try { fd = openSync(LOCK, 'wx'); } catch (e) {
      if (e.code !== 'EEXIST') throw e;
      let state;
      try { state = statSync(LOCK); } catch (s) { if (s.code === 'ENOENT') continue; throw s; }
      if (Date.now() - state.mtimeMs > 1200000) { unlinkSync(LOCK); continue; }
      console.log('Bench lock held. Next attempt in five minutes.');
      await sleep(Math.min(300000, Math.max(0, until - Date.now())));
      continue;
    }
    try { writeFileSync(fd, token); } catch (e) { closeSync(fd); unlinkSync(LOCK); throw e; }
    const owned = () => existsSync(LOCK) && read(LOCK) === token;
    const pulse = setInterval(() => { const now = new Date(); futimesSync(fd, now, now); }, 30000);
    return { token, owned, release() {
      clearInterval(pulse);
      closeSync(fd);
      if (owned()) unlinkSync(LOCK);
    } };
  }
  throw Error('deadline waiting for bench.lock');
}

async function launch(ctx, ghost, arm, round, trace = false) {
  const look = arm === 'legacy-aa' ? 'legacy' : arm;
  const stem = join(ctx.raw, [ghost, arm, trace ? 'verify' : round].join('-'));
  const file = stem + (trace ? '.jsonl' : '.json');
  const args = argumentsFor(ghost, look, file, trace);
  // cpu_run.ps1 passes ArgLine to ProcessStartInfo; all arguments here are paths or fixed tokens.
  if (args.some(a => a.includes('"'))) throw Error('unexpected quote in engine argument');
  const argLine = args.map(a => /\s/.test(a) ? '"' + a + '"' : a).join(' ');
  let waiting = false;
  while (godotProcesses().length && Date.now() < ctx.until) {
    if (!waiting) console.log('Waiting for other Godot processes to finish.');
    waiting = true;
    await sleep(1000);
  }
  const timeout = Math.min(90, Math.floor((ctx.until - Date.now()) / 1000) - 3);
  if (timeout < 1 || !ctx.lock.owned()) throw Error('deadline or lock lost before launch');
  const entry = register({ kind: 'polish-ghost-cost' });
  let result;
  const meter = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', join(ROOT, 'tools/perf/cpu_run.ps1'),
    '-Exe', ctx.exe, '-ArgLine', argLine, '-Cwd', ROOT, '-Log', stem + '.log', '-TimeoutS', String(timeout)];
  try {
    result = await runProcess('powershell', meter, { timeoutMs: (timeout + 3) * 1000,
      onLine(line) { const pid = /^PID (\d+)$/.exec(line); if (pid) entry.setChild(Number(pid[1])); } });
  } finally { entry.release(); }
  if (!ctx.lock.owned()) throw Error('lost bench.lock during ' + stem);
  const cpu = JSON.parse(result.out.split(/\r?\n/).find(s => s.startsWith('{')) ?? '{}');
  const log = existsSync(stem + '.log') ? read(stem + '.log') : '';
  const errors = engineErrors(log);
  if (result.status !== 0 || cpu.exit !== 0 || !(cpu.total_s > 0) || !Number.isFinite(cpu.others_cores) ||
      errors.length || (trace && !existsSync(file + '.png')) ||
      !log.includes(ghost + ' move uses ' + look + ' look') || !/D3D12|Direct3D 12/i.test(log)) {
    throw Error('invalid engine run ' + stem + ': ' + (errors[0] ?? cpu.error ?? result.out.slice(-300)));
  }
  const command = '& "' + ctx.exe + '" ' + argLine;
  const common = { ghost, arm, round, file, command, locked: true, otherGodotAfter: godotProcesses().length,
    exitDiagnostics: log.split(/\r?\n/).filter(line => /^(ERROR|WARNING):/.test(line)) };
  if (trace) return { ...common, verifiedFrames: checkTrace(read(file), ghost) };
  const stats = frameWindow(JSON.parse(read(file)));
  console.log(ghost, arm, 'r' + round, 'p50', numeric(stats.p50), 'ms, other cores', numeric(cpu.others_cores));
  return { ...common, ...stats, cpu: cpu.total_s, load: cpu.others_cores, wallSeconds: cpu.wall_s };
}

function save(doc) {
  const lines = ['# Spectral body cost', '', 'Movement in ghost_review at tilt70, 32 px/m, windowed D3D12, 1920×1080. ' +
    'Each run lasts 402 engine frames. Frame statistics use the 300 consecutive intervals ending at ticks ' +
    START + '–' + END + '. CPU covers process startup through exit. Verification traces run separately.', '',
    'The table shows the median of each per-run metric. Other cores are system busy CPU less engine CPU, divided by elapsed time.', '',
    '| Ghost | Look | Runs | p50 ms | p99 ms | Worst ms | Frames >25 ms | CPU s | Other cores |',
    '|---|---|---:|---:|---:|---:|---:|---:|---:|'];
  const comparisons = ['| Ghost | Metric | Spectral − legacy | Paired CI95 | A/A floor (±) | Call |',
    '|---|---|---:|---|---:|---|'];
  doc.summary = {};
  for (const ghost of GHOSTS) {
    const runs = doc.runs.filter(r => r.ghost === ghost);
    const s = summarise(runs, ARMS);
    doc.summary[ghost] = s;
    for (const { name } of ARMS) {
      const row = s.medians[name];
      lines.push('| ' + [ghost, name, runs.filter(r => r.arm === name).length,
        ...[...METRICS, 'load'].map(m => numeric(row[m]))].join(' | ') + ' |');
    }
    for (const m of METRICS) {
      const d = s.vsBase.spectral[m];
      comparisons.push('| ' + [ghost, m, numeric(d.median), d.ci95.map(numeric).join(' to '),
        numeric(s.floor[m].halfWidth), d.n ? d.call : 'not measured'].join(' | ') + ' |');
    }
  }
  lines.push('', 'Paired median differences and bootstrap 95% intervals use the fight gate method. ' +
    'The floor is the larger absolute endpoint of the legacy twin’s paired interval. Frame times are in ms and CPU in s.',
    '', ...comparisons, '', 'Commit `' + doc.commit + '`. Measured runs holding the exclusive lock: ' +
      doc.runs.filter(r => r.locked).length + '/' + doc.runs.length + '. Other Godot processes visible at exit: ' +
      doc.runs.filter(r => r.otherGodotAfter > 0).length + ' runs. All launches waited for a clear process scan. ' +
      'Per-run logs retain the arena’s exit-time resource and allocator messages.',
    '', doc.error ? 'Incomplete: ' + doc.error : 'Completed ' + doc.rounds + ' paired rounds per ghost.',
    '', '## Commands', '', '```powershell', 'Set-Location "' + ROOT + '"',
    '$env:APPDATA = "' + process.env.APPDATA + '"', '$env:GODOT_BIN = "' + process.env.GODOT_BIN + '"',
    doc.driver, '```', '', 'Engine invocations in run order. The driver calls cpu_run.ps1 with the engine executable directly to measure its process CPU.', '',
    '```powershell', ...[...doc.checks, ...doc.runs].map(r => r.command), '```', '');
  writeFileSync(join(OUT, 'cost.json'), JSON.stringify(doc, null, 2) + '\n');
  writeFileSync(join(OUT, 'cost.md'), lines.join('\n'));
}

async function main() {
  const { values } = parseArgs({ options: { rounds: { type: 'string', default: '6' }, until: { type: 'string' } } });
  const rounds = Number(values.rounds);
  const until = Date.parse(values.until);
  if (![4, 6].includes(rounds) || !(until > Date.now())) throw Error('use --rounds=4|6 and --until=<future ISO deadline>');
  if (!process.env.GODOT_BIN || !process.env.APPDATA) throw Error('set GODOT_BIN and APPDATA');
  mkdirSync(OUT, { recursive: true });
  const raw = mkdtempSync(join(OUT, 'runs-'));
  const doc = { schema: 'gtai.polish-ghost-cost/1', commit: git('rev-parse', 'HEAD'), rounds, raw,
    until: values.until, driver: 'node tools/perf/polish_ghost_cost.mjs ' + process.argv.slice(2).join(' '),
    checks: [], runs: [] };
  let lock, restore;
  try {
    lock = await acquire(until);
    doc.lock = { path: LOCK, token: lock.token };
    const engine = resolveGodot({ main: null });
    if (!engine.ok) throw Error(engine.message);
    const exe = engine.bin.replace(/_console\.exe$/i, '.exe');
    if (!existsSync(exe)) throw Error('missing engine executable beside the console launcher');
    doc.version = engine.version;
    restore = permitFrames();
    const ctx = { until, lock, exe, raw };
    for (const ghost of GHOSTS) for (const look of ['legacy', 'spectral']) {
      doc.checks.push(await launch(ctx, ghost, look, 0, true));
    }
    for (let r = 0; r < rounds; r++) for (const ghost of GHOSTS) for (const arm of order(ARMS, r)) {
      doc.runs.push(await launch(ctx, ghost, arm.name, r + 1));
    }
  } catch (e) { doc.error = e.message; throw e; }
  finally {
    try { restore?.(); } finally { lock?.release(); save(doc); }
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(e => { console.error(e.message); process.exitCode = 1; });
}
