#!/usr/bin/env node
// The morning merge in one command, the recipe of docs/day/2026-11-09 and the Director's: lanes merged
// in the order given, each lane's JOURNAL and REPORT moved to docs/day/<date>/<lane>/, the debt
// ratchet with an explicit reason, both DLLs, the bake, the gates, the reel gate, the export. It stops
// at the first red and says what to do; --resume carries on from there.
// It works only on a named integration worktree, never on main, and it never pushes: every git call
// goes through `git()`, which accepts a short list of verbs and throws on anything else.
//   node tools/merge/morning.mjs --worktree=<dir> --lanes=<a,b,c> --date=<yyyy-mm-dd> --debt-reason="<why>"
//     [--steps=merge,debt,native,bake,gates,reels,export] [--resume] [--dry-run] [--timeout=<min per step>]
// Exit: 0 done, 1 stopped at a red step, 2 refused (nothing changed).
import { execFileSync, spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

export const STEPS = ['merge', 'debt', 'native', 'bake', 'gates', 'reels', 'export'];
const SAFE_VERBS = new Set(['status', 'rev-parse', 'symbolic-ref', 'merge', 'add', 'commit', 'mv', 'log', 'worktree', 'show', 'show-ref', 'diff']);
const DOCS = ['JOURNAL.md', 'REPORT.md'];
const STATE = 'build/merge-state.json';
const USAGE = 'usage: node tools/merge/morning.mjs --worktree=<dir> --lanes=<a,b,c> --date=<yyyy-mm-dd> [--debt-reason="<why>"] [--steps=<list>] [--resume] [--dry-run] [--timeout=<min>]';

/** Runs git in `cwd`. Throws on a verb outside the list: there is no way to push from here. */
export function git(cwd, args, spawnGit = spawnSync) {
  if (!SAFE_VERBS.has(args[0])) throw new Error(`morning: refusing git ${args[0]}: not one of the verbs this tool may use`);
  const r = spawnGit('git', ['-C', cwd, ...args], { encoding: 'utf8', windowsHide: true, maxBuffer: 1 << 26 });
  return { ok: r.status === 0, out: `${r.stdout ?? ''}${r.stderr ?? ''}`, stdout: (r.stdout ?? '').trim() };
}

export function parseArgs(argv) {
  const o = { worktree: null, lanes: [], date: null, debtReason: null, steps: STEPS, resume: false, dryRun: false, timeoutMin: 45 };
  for (const a of argv) {
    const m = /^--([a-z-]+)(?:=(.*))?$/.exec(a);
    if (!m) return { error: `morning: bad argument ${a}` };
    const [, k, v] = m;
    if (k === 'worktree') o.worktree = resolve(v);
    else if (k === 'lanes') o.lanes = v.split(',').filter(Boolean);
    else if (k === 'date') o.date = v;
    else if (k === 'debt-reason') o.debtReason = v;
    else if (k === 'steps') o.steps = v.split(',').filter(Boolean);
    else if (k === 'resume') o.resume = true;
    else if (k === 'dry-run') o.dryRun = true;
    else if (k === 'timeout') o.timeoutMin = Number(v);
    else return { error: `morning: bad argument ${a}` };
  }
  if (!o.worktree) return { error: 'morning: --worktree=<the integration worktree> is required' };
  if (!o.lanes.length) return { error: 'morning: --lanes=<a,b,c> (in merge order) is required' };
  if (!o.date || !/^\d{4}-\d{2}-\d{2}$/.test(o.date)) return { error: 'morning: --date=<yyyy-mm-dd> is required (the folder under docs/day/)' };
  const bad = o.steps.filter((s) => !STEPS.includes(s));
  if (bad.length) return { error: `morning: unknown step ${bad.join(', ')}; the steps are ${STEPS.join(', ')}` };
  return o;
}

/** Why this tree may not be worked on, or null. */
export function refusal({ branch, dirty, merging, lanes, known }) {
  if (!branch) return 'the worktree is on no branch (detached): name an integration branch';
  if (branch === 'main' || branch === 'master') return `the worktree is on ${branch}: this tool never touches it, use an integration branch`;
  if (lanes.includes(branch)) return `the worktree is on ${branch}, a lane being merged`;
  if (merging) return 'a merge is in progress: finish or abort it first, or use --resume after you commit it';
  if (dirty) return `the worktree is not clean:\n${dirty}`;
  const missing = lanes.filter((l) => !known.includes(l));
  if (missing.length) return `no such branch: ${missing.join(', ')}`;
  return null;
}

export const laneDocsDir = (date, lane) => `docs/day/${date}/${lane.replace(/^n\d+-/, '')}`;

/** A readable "what to do" for a stopped merge. */
export function conflictAdvice(lane, files) {
  const hints = files.map((f) => {
    if (f === 'tools/debt/baseline.json') return `  ${f}: take either side, then node tools/debt/debt.mjs --update (tools/debt/README.md)`;
    if (/decisions\.md$/.test(f)) return `  ${f}: union-merged by .gitattributes; if it still conflicts, keep both sides`;
    if (/\.uid$/.test(f)) return `  ${f}: keep either side, one id per file`;
    return `  ${f}`;
  });
  return [`STOPPED: merging ${lane} conflicted on ${files.length} file(s):`, ...hints,
    'Resolve them, `git add` each path and `git commit` in the integration worktree, then run this again with --resume.'];
}

const conflicted = (porcelain) => porcelain.split('\n').filter((l) => /^(UU|AA|DD|AU|UA|DU|UD) /.test(l)).map((l) => l.slice(3));

/** Every lane writes a root JOURNAL and REPORT, so a conflict on only those is no decision for a person:
 *  the lane's own copy is the one that goes under its folder. Returns a red result, or null when done. */
function takeTheirDocs(g, cwd, lane, files) {
  for (const f of files) {
    const theirs = g(['show', `MERGE_HEAD:${f}`]);
    if (!theirs.ok) return { ok: false, advice: [`STOPPED: cannot read ${f} from ${lane}: ${theirs.out.trim().slice(0, 300)}`] };
    writeFileSync(join(cwd, f), theirs.stdout);
    g(['add', f]);
  }
  const c = g(['commit', '--no-edit']);
  return c.ok ? null : { ok: false, advice: [`STOPPED: committing ${lane}'s merge failed (often the lint hook): ${c.out.trim().slice(0, 400)}`, 'Fix it, commit, and run again with --resume.'] };
}

function mergeLane(g, cwd, lane, date) {
  const subject = g(['log', '-1', '--format=%s', lane]).stdout.slice(0, 110);
  const merged = g(['merge', '--no-ff', '--no-edit', '-m', `merge ${lane}: ${subject}`, lane]);
  if (!merged.ok) {
    const files = conflicted(g(['status', '--porcelain']).stdout);
    if (!files.length) return { ok: false, advice: [`STOPPED: git merge ${lane} failed: ${merged.out.trim().slice(0, 400)}`, 'Fix it and run again with --resume.'] };
    if (!files.every((f) => DOCS.includes(f))) return { ok: false, advice: conflictAdvice(lane, files) };
    const taken = takeTheirDocs(g, cwd, lane, files);
    if (taken) return taken;
  }
  const moved = [];
  const dir = laneDocsDir(date, lane);
  for (const f of DOCS) {
    if (!existsSync(join(cwd, f))) continue;
    mkdirSync(join(cwd, dir), { recursive: true });
    const mv = g(['mv', f, `${dir}/${f}`]);
    if (!mv.ok) return { ok: false, advice: [`STOPPED: could not move ${f} to ${dir}: ${mv.out.trim()}`, 'Move it yourself, commit, and run again with --resume.'] };
    moved.push(f);
  }
  if (moved.length) {
    const c = g(['commit', '-q', '-m', `docs: ${lane}'s ${moved.join(' and ')} under ${dir}/`]);
    if (!c.ok) return { ok: false, advice: [`STOPPED: committing the moved docs failed (often the lint hook): ${c.out.trim().slice(0, 400)}`, 'Fix it, commit, and run again with --resume.'] };
  }
  return { ok: true, note: `merged ${lane}${moved.length ? `, ${moved.join(', ')} moved` : ''}` };
}

/** A step: {ok, advice?}. Each returns exactly what to do when red. */
export const STEP_RUNNERS = {
  merge: (ctx) => {
    for (const lane of ctx.lanes) {
      if (ctx.done.includes(`merge:${lane}`)) continue;
      const r = mergeLane(ctx.git, ctx.cwd, lane, ctx.date);
      if (!r.ok) return r;
      ctx.mark(`merge:${lane}`);
      ctx.out(`morning: ${r.note}`);
    }
    return { ok: true };
  },
  debt: (ctx) => {
    const check = ctx.run('debt-check', 'node', ['tools/debt/debt.mjs', '--check']);
    if (check.status === 0 && !/tighten/.test(check.out)) return { ok: true };
    if (check.status === 0) {
      const tight = ctx.run('debt-update', 'node', ['tools/debt/debt.mjs', '--update']);
      if (tight.status !== 0) return { ok: false, advice: [`STOPPED: debt --update failed: ${tight.out.slice(-400)}`, 'Fix it and run again with --resume.'] };
    } else {
      if (!ctx.debtReason) return { ok: false, advice: [`STOPPED: the debt ratchet is over the baseline:\n${check.out.trim().slice(-900)}`, 'Shrink what it names, or run again with --debt-reason="<why this is deliberate>" and --resume.'] };
      const u = ctx.run('debt-accept', 'node', ['tools/debt/debt.mjs', '--update', `--accept-regression=${ctx.debtReason}`]);
      if (u.status !== 0) return { ok: false, advice: [`STOPPED: debt --update failed: ${u.out.slice(-400)}`, 'Fix it and run again with --resume.'] };
    }
    ctx.git(['add', 'tools/debt/baseline.json']);
    const c = ctx.git(['commit', '-q', '-m', `debt: baseline after the ${ctx.date} merge`]);
    if (!c.ok && !/nothing to commit/.test(c.out)) return { ok: false, advice: [`STOPPED: the baseline commit failed: ${c.out.slice(-400)}`, 'Fix it and run again with --resume.'] };
    return { ok: true };
  },
  native: (ctx) => {
    for (const target of ['template_debug', 'template_release']) {
      const r = ctx.run(`native-${target}`, 'scons', ['platform=windows', 'arch=x86_64', `target=${target}`, '-j4'], { cwd: join(ctx.cwd, 'native') });
      if (r.status !== 0) return { ok: false, advice: [`STOPPED: the ${target} DLL did not build; log ${r.log}`, 'Fix it and run again with --resume.'] };
      const dll = join(ctx.cwd, `project/native/bin/gtai_sim.windows.${target}.x86_64.dll`);
      if (!existsSync(dll)) return { ok: false, advice: [`STOPPED: scons exited 0 but ${dll} is not there`] };
    }
    return { ok: true };
  },
  bake: (ctx) => {
    const r = ctx.run('bake', 'node', ['tools/dev/run.mjs', 'res://dev/bake_city.gd']);
    if (r.status !== 0) return { ok: false, advice: [`STOPPED: the city bake failed; log ${r.log}`, 'Fix it and run again with --resume.'] };
    const dirty = ctx.git(['status', '--porcelain']).stdout;
    if (dirty) return { ok: false, advice: [`STOPPED: the bake changed tracked files:\n${dirty}`, 'Review them, commit them deliberately (AST-12 hash list), and run again with --resume.'] };
    return { ok: true };
  },
  gates: (ctx) => {
    const r = ctx.run('gates', 'node', ['tools/evidence/run.mjs', '--no-bench']);
    if (r.status !== 0) return { ok: false, advice: [`STOPPED: the gates are red; log ${r.log}`, 'Known flakes: test_noir_shadows and the scenario_city_chase budget: re-run those alone. A real red: fix, commit, run again with --resume.'] };
    return { ok: true };
  },
  reels: (ctx) => {
    const r = ctx.run('reels', 'node', ['tools/reel/run_reels.mjs', '--out=build/merge/reels', '--views=top,tilt70,combo']);
    if (r.status !== 0) return { ok: false, advice: [`STOPPED: the reel gate is red; log ${r.log}`, 'Fix it, commit, run again with --resume.'] };
    return { ok: true };
  },
  export: (ctx) => {
    const r = ctx.run('export', 'node', ['tools/export/export_checked.mjs']);
    if (r.status !== 0) return { ok: false, advice: [`STOPPED: the export refused or failed; log ${r.log}`, 'A bake mismatch means re-run with --steps=bake,export --resume.'] };
    return { ok: true };
  },
};

function defaultRun(cwd, logDir, timeoutMin) {
  return (name, cmd, args, opts = {}) => {
    mkdirSync(logDir, { recursive: true });
    const log = join(logDir, `${name}.log`);
    const shell = process.platform === 'win32' && !['node'].includes(cmd);
    const r = spawnSync(cmd, args, { cwd: opts.cwd ?? cwd, encoding: 'utf8', windowsHide: true, maxBuffer: 1 << 28, timeout: timeoutMin * 60000, shell });
    const out = `${r.stdout ?? ''}${r.stderr ?? ''}`;
    writeFileSync(log, out);
    return { status: r.status ?? -1, out, log };
  };
}

/** {state} or {error}: a damaged or missing record must not quietly become "nothing was done yet". */
function loadState(cwd) {
  const f = join(cwd, STATE);
  if (!existsSync(f)) return { error: `nothing to resume: no ${STATE} in ${cwd}; run without --resume` };
  try {
    const state = JSON.parse(readFileSync(f, 'utf8'));
    if (Array.isArray(state?.done)) return { state };
  } catch { /* falls through to the refusal */ }
  return { error: `${f} is damaged: read what it says, repair or delete it, and start again knowing what already ran` };
}

/** The whole run. {code}. `spawnGit`, `run` and `steps` are injected by tests. */
export function main(argv, { out = console.log, err = console.error, spawnGit = spawnSync, run: runner = null, runners = STEP_RUNNERS } = {}) {
  const o = parseArgs(argv);
  if (o.error) { err(`${o.error}\n${USAGE}`); return { code: 2 }; }
  const cwd = o.worktree;
  const g = (args) => git(cwd, args, spawnGit);
  const inside = g(['rev-parse', '--is-inside-work-tree']);
  if (!inside.ok || inside.stdout !== 'true') { err(`morning: ${cwd} is not a git worktree`); return { code: 2 }; }
  const branch = g(['symbolic-ref', '--short', '-q', 'HEAD']).stdout;
  const known = g(['show-ref', '--heads']).stdout.split('\n').map((l) => l.split(' refs/heads/')[1]).filter(Boolean);
  const merging = g(['rev-parse', '-q', '--verify', 'MERGE_HEAD']).ok;
  const dirty = g(['status', '--porcelain']).stdout;
  if (o.resume && merging) { err('morning: a merge is still in progress: resolve it and commit, then --resume'); return { code: 2 }; }
  const why = refusal({ branch, dirty, merging, lanes: o.lanes, known });
  if (why) { err(`morning: refused: ${why}`); return { code: 2 }; }
  const loaded = o.resume ? loadState(cwd) : { state: { done: [] } };
  if (loaded.error) { err(`morning: refused: ${loaded.error}`); return { code: 2 }; }
  const { state } = loaded;
  const save = () => { mkdirSync(join(cwd, 'build'), { recursive: true }); writeFileSync(join(cwd, STATE), JSON.stringify(state, null, 1)); };
  if (o.dryRun) { for (const s of o.steps) out(`morning: would run ${s}${s === 'merge' ? ` (${o.lanes.join(' -> ')})` : ''}`); return { code: 0 }; }
  const ctx = { cwd, git: g, lanes: o.lanes, date: o.date, debtReason: o.debtReason, out, done: state.done,
    mark: (k) => { state.done.push(k); save(); },
    run: runner ?? defaultRun(cwd, join(cwd, 'build', 'merge', 'logs'), o.timeoutMin) };
  for (const step of o.steps) {
    // Merge progress is per lane: a resumed run with a lane added has to reach it.
    if (step !== 'merge' && state.done.includes(step)) { out(`morning: ${step}: done earlier, skipped`); continue; }
    out(`morning: ${step}: running`);
    const r = runners[step](ctx);
    if (!r.ok) { for (const l of r.advice) out(l); save(); return { code: 1, stoppedAt: step }; }
    ctx.mark(step);
    out(`morning: ${step}: green`);
  }
  const head = g(['rev-parse', 'HEAD']).stdout;
  out(`morning: DONE at ${head.slice(0, 8)} on ${branch}. Nothing was pushed; main was not touched. The owner's verdicts and the push are yours.`);
  return { code: 0 };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main(process.argv.slice(2)).code);
}

export { execFileSync };
