#!/usr/bin/env node
// The Codex test factory: picks untested pure rule modules, writes the task, dispatches it, grades it
// and leaves a review queue. It never lands anything: a mutation score can only reject, and only
// Claude's review accepts. Generators and tuned tables stay with Claude (tools/codex/pick.mjs).
//   node tools/codex/factory.mjs pick [--explain=<project-relative .gd>] [--all]
//   node tools/codex/factory.mjs run --stems=<a,b> | --take=<n> [--ledger=<file>] [--timeout-min=25]
//   node tools/codex/factory.mjs queue [--ledger=<file>]
//   node tools/codex/factory.mjs review <id> --verdict=accepted|accepted-after-revision|rejected
//     [--changed=<lines>] [--notes=<text>] [--iteration=<n>] [--review-tokens=<n> --review-secs=<n>] [--ledger=<file>]
//     (--review-tokens/--review-secs: the review was done by a subagent and these are the harness's numbers)
//   node tools/codex/factory.mjs ledger [--state=<lane state.json>] [--ledger=<file>]
//   node tools/codex/factory.mjs control <stem> --tokens=<n> --secs=<n> --tests=<n> --killed=<n> --mutants=<n>
//     --changed=<review lines> [--model=<id>] [--notes=<text>] [--ledger=<file>]
// Exit: 0 ok, 1 a run went wrong, 2 usage, 3 refused by the weekly meter (nothing was built).
import { spawn, spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, ownGdFiles, rel, walk } from '../lib/repo.mjs';
import { killTree, resolveGodot } from '../lib/godot.mjs';
import { append, queue, read, rows, totals, vanished } from './ledger.mjs';
import { pick, refusal } from './pick.mjs';

export const LEDGER = join(ROOT, 'build', 'codex', 'ledger.jsonl');
const POF = 'C:/Users/kazda/kiro/pof';
const HOME = 'C:/Users/kazda/kiro/pof-codex';
const BAR = 70;
const MODEL = 'gpt-6.1-sol';
const PREFIX = 'n11t-fac-';
/** Laws from the 2026-11-09 pilot; the two that forbid pinning accidental behaviour are the point. */
export const LAWS = [
  'Do NOT commit, push, create branches, or rewrite git history. Leave changes in the working tree; the overseer reviews and commits.',
  'Change only the files listed under "You may change". Never change the code under test to make a test pass: report the defect in openQuestions instead.',
  'Godot 4.7.2 GDScript, statically typed; GUT tests extend GutTest; a test states behaviour, in the style of project/tests/unit. Warnings are errors.',
  'Native DLLs are already in project/native/bin. Do not rebuild them.',
  'A test states what the code is FOR. Do not pin accidental behaviour (float edge quirks, unclamped inputs, permissive parsing, defaults nobody chose): if behaviour looks like a bug, leave it untested and name it in openQuestions.',
  'Tests use their own fixtures. Never assert a value taken from a real asset, table row or tuned constant that a designer may change; read the constant from the code, or assert a relation.',
  'Do not edit JOURNAL.md, REPORT.md, tools/debt/baseline.json or docs.',
];

export const taskId = (stem) => `${PREFIX}${stem.replace(/_/g, '-')}`;
/** A discarded task keeps its run record, and the dispatcher refuses an id that has one: a re-run needs a new one. */
export function freshId(stem, taken) {
  let id = taskId(stem);
  for (let n = 2; taken(id); n += 1) id = `${taskId(stem)}-r${n}`;
  return id;
}
export const testPath = (stem) => `project/tests/unit/test_${stem}.gd`;

/** The dispatcher's task JSON for one unit. Pure. */
export function buildTask(unit, { repo, base, from, godot, id = taskId(unit.stem) }) {
  const test = testPath(unit.stem);
  const local = unit.path.replace(/^project\//, '');
  return {
    id, tier: 'bulk', access: 'write-verified', model: MODEL, repo, base, laws: LAWS,
    copyIgnored: { from, paths: ['project/.godot', 'project/native/bin'] },
    title: `GUT tests for ${unit.cls}`,
    goal: `${unit.cls} (${unit.path}) has no tests. Write ${test}: GUT tests that pin what this class is FOR, including its boundaries and failure paths, so that a change to a comparison, a constant or a branch in that file makes a test fail. Do not change ${unit.cls}.`,
    context: [unit.path, 'project/tests/unit/test_flamer_sway.gd'],
    scope: [test],
    acceptance: [`node tools/tests/run_unit.mjs --select=test_${unit.stem} --no-rerun (GODOT_BIN=${godot})`],
    outOfScope: [`any change to ${local} or any other game file`],
  };
}

const git = (cwd, ...a) => spawnSync('git', ['-C', cwd, ...a], { encoding: 'utf8', windowsHide: true, maxBuffer: 1 << 26 });

/** Runs a shell command with a tree-kill timeout. Resolves {code, out}. */
function shell(cmd, cwd, env, min = 40) {
  return new Promise((done) => {
    let out = '';
    const c = spawn(cmd, { cwd, env, shell: true, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
    const t = setTimeout(() => killTree(c.pid), min * 60000);
    c.stdout.on('data', (b) => { out += b; });
    c.stderr.on('data', (b) => { out += b; });
    c.on('close', (code) => { clearTimeout(t); done({ code, out }); });
  });
}

/** A dispatch refused at the weekly meter. */
export const refusedByMeter = (out) => /weekly|meter/i.test(out) && /refus|75/i.test(out);

/** Mutation output -> the survivor score, or null when the run did not report one. */
export function scoreOf(out) {
  const all = [...String(out).matchAll(/(\d+(?:\.\d+)?)\s*%/g)].map((x) => Number(x[1]));
  return all.length ? all.at(-1) : null;
}

/** What the machine may conclude. A score only rejects: at or over the bar means Claude reads it. */
export function gradeFrom({ unit, lint, score, extra }) {
  if (extra.length) return { pass: false, why: `outside scope: ${extra.join(', ')}` };
  if (!unit) return { pass: false, why: 'tests red on the real code' };
  if (!lint) return { pass: false, why: 'lint rejected the test' };
  if (score === null) return { pass: false, why: 'the mutation run reported no score' };
  if (score < BAR) return { pass: false, score, why: `mutation score ${score} % under ${BAR} %` };
  return { pass: true, score, why: `mutation score ${score} %: at the bar, which proves nothing yet, Claude reviews` };
}

async function grade(wt, unit, env, log, say = () => {}) {
  const test = testPath(unit.stem);
  const extraFiles = git(wt, 'status', '--porcelain', '--untracked-files=all').stdout.split('\n').filter(Boolean).map((l) => l.slice(3))
    .filter((f) => f !== test && !f.endsWith('.uid') && !f.endsWith('.import'));
  say(`factory: ${unit.stem}: grading: unit tests in ${wt}`);
  const u = await shell(`node tools/tests/run_unit.mjs --select=test_${unit.stem} --no-rerun`, wt, env, 25);
  log(`unit exit ${u.code}\n${u.out}`);
  const unitOk = u.code === 0;
  if (!unitOk || extraFiles.length) return { ...gradeFrom({ unit: unitOk, lint: true, score: null, extra: extraFiles }), detail: u.out.slice(-1400) };
  git(wt, 'add', '--', test, `${test}.uid`);
  const c = git(wt, 'commit', '-q', '-m', `factory grade ${unit.stem}`);
  const lintOk = c.status === 0 || /nothing to commit/.test(`${c.stdout}${c.stderr}`);
  if (!lintOk) return { ...gradeFrom({ unit: true, lint: false, score: null, extra: [] }), detail: `${c.stdout}\n${c.stderr}`.slice(-1400) };
  say(`factory: ${unit.stem}: unit green, lint ok; mutation grade running (15 mutants, up to 45 min)`);
  const m = await shell(`node tools/mutate/mutate.mjs --file=${unit.path.replace(/^project\//, '')} --tests=test_${unit.stem} --max=15 --remove-worktree`, wt, env, 45);
  log(`mutate exit ${m.code}\n${m.out}`);
  const score = m.code === 0 ? scoreOf(m.out) : null;
  return { ...gradeFrom({ unit: true, lint: true, score, extra: [] }), detail: m.out.slice(-1800) };
}

async function runOne(unit, ctx) {
  const { ledger, env, base, outDir, timeoutMin } = ctx;
  const id = freshId(unit.stem, (x) => existsSync(join(HOME, 'runs', x)));
  const task = buildTask(unit, { repo: ctx.repo, base, from: ROOT, godot: env.GODOT_BIN, id });
  mkdirSync(outDir, { recursive: true });
  const file = join(outDir, `${id}.json`);
  writeFileSync(file, JSON.stringify(task, null, 1));
  const t0 = Date.now();
  append(ledger, { type: 'started', id, unit: unit.stem, path: unit.path, at: new Date().toISOString() });
  const log = (s) => { writeFileSync(join(outDir, `${id}.log`), `${s}\n`, { flag: 'a' }); };
  const d = await shell(`npx tsx scripts/codex/dispatch.ts run "${file}" --timeout-min ${timeoutMin}`, POF, env, timeoutMin + 5);
  log(`dispatch exit ${d.code}\n${d.out}`);
  if (refusedByMeter(d.out) && !existsSync(join(HOME, 'wt', id))) {
    append(ledger, { type: 'task', id, unit: unit.stem, path: unit.path, refused: true, why: d.out.slice(-200), at: new Date().toISOString() });
    return { id, refused: true };
  }
  const wt = join(HOME, 'wt', id);
  if (!existsSync(wt)) {
    append(ledger, { type: 'task', id, unit: unit.stem, path: unit.path, machine: { pass: false, why: `dispatch produced no worktree: ${d.out.slice(-160)}` }, at: new Date().toISOString() });
    return { id, pass: false, why: 'dispatch failed' };
  }
  const say = ctx.say ?? (() => {});
  say(`factory: ${unit.stem}: Codex round done in ${Math.round((Date.now() - t0) / 1000)} s (dispatch exit ${d.code}; log ${join(outDir, `${id}.log`)})`);
  let g = await grade(wt, unit, env, log, say);
  let repaired = false;
  if (!g.pass) {
    repaired = true;
    say(`factory: ${unit.stem}: the machine rejected it (${g.why}); Codex repair round`);
    const why = `${g.why}. Output: ${g.detail}`.replace(/\r?\n/g, ' | ').replace(/["%^&<>]/g, ' ').slice(0, 1400);
    const r = await shell(`npx tsx scripts/codex/dispatch.ts resume ${id} "The machine grader rejected this: ${why}. Fix it."`, POF, env, timeoutMin + 5);
    log(`resume exit ${r.code}\n${r.out}`);
    g = await grade(wt, unit, env, log, say);
  }
  const state = JSON.parse(readFileSync(join(HOME, 'runs', id, 'state.json'), 'utf8'));
  append(ledger, { type: 'task', id, unit: unit.stem, path: unit.path, test: testPath(unit.stem), model: state.model, codex_secs: state.secs, codex_rounds: state.rounds,
    tokens_out: state.outputTokens, wall_secs: Math.round((Date.now() - t0) / 1000), machine: { pass: g.pass, score: g.score ?? null, why: g.why, repaired }, wt, at: new Date().toISOString() });
  return { id, pass: g.pass, score: g.score, why: g.why, wt };
}

export function collectFiles(root = ROOT) {
  const tests = walk(join(root, 'project', 'tests'), (n) => /^test_.*\.gd$/.test(n)).map((f) => readFileSync(f, 'utf8'));
  const files = ownGdFiles().map((f) => ({ path: rel(f), text: readFileSync(f, 'utf8') }));
  return { files, tests };
}

function usage(err) { err('usage: node tools/codex/factory.mjs pick|run|queue|review|ledger (see the file header)'); return 2; }

function flags(argv) {
  const o = {};
  const pos = [];
  for (const a of argv) {
    const m = /^--([a-z-]+)(?:=(.*))?$/.exec(a);
    if (m) o[m[1]] = m[2] ?? true;
    else pos.push(a);
  }
  return { o, pos };
}

function cmdPick(o, out, err) {
  const { files, tests } = collectFiles();
  if (o.explain) {
    const f = files.find((x) => x.path === o.explain || x.path === `project/${o.explain}`);
    if (!f) { err(`factory: no such file ${o.explain}`); return 2; }
    out(`${f.path}: ${refusal(f.path, f.text, tests) ?? 'may go to Codex'}`);
    return 0;
  }
  const { ok, no } = pick(files, tests);
  for (const u of ok) out(`${u.path}  (${u.cls}, ${u.lines} lines, ${u.funcs} funcs)`);
  out(`factory: ${ok.length} may go to Codex, ${no.length} refused`);
  if (o.all) for (const r of no) out(`  refused ${r.path}: ${r.why}`);
  return 0;
}

async function cmdRun(o, out, err) {
  const { files, tests } = collectFiles();
  const { ok } = pick(files, tests);
  const want = o.stems ? String(o.stems).split(',') : null;
  const units = want ? ok.filter((u) => want.includes(u.stem)) : ok.slice(0, Number(o.take ?? 0));
  if (want && units.length !== want.length) {
    err(`factory: not eligible: ${want.filter((s) => !units.some((u) => u.stem === s)).join(', ')}; ask pick --explain`);
    return 2;
  }
  if (!units.length) { err('factory: nothing to run: pass --stems= or --take=<n>'); return 2; }
  const env = { ...process.env };
  if (!env.GODOT_BIN) { // the one resolver every runner uses (tools/lib/godot.mjs), so the factory finds what film and unit find
    const g = resolveGodot();
    if (!g.ok) { err(`factory: ${g.message} (the grader needs it)`); return 2; }
    env.GODOT_BIN = g.bin;
  }
  const ledger = o.ledger ?? LEDGER;
  const repo = 'C:/Users/kazda/kiro/gtai';
  const base = spawnSync('git', ['-C', repo, 'rev-parse', 'main'], { encoding: 'utf8', windowsHide: true }).stdout.trim();
  const ctx = { ledger, env, base, repo, outDir: join(ROOT, 'build', 'codex', 'tasks'), timeoutMin: Number(o['timeout-min'] ?? 25), say: out };
  let refused = false;
  for (const unit of units) {
    out(`factory: ${unit.stem}: dispatching`);
    const r = await runOne(unit, ctx);
    if (r.refused) { out(`factory: ${unit.stem}: REFUSED by the weekly meter, stopping`); refused = true; break; }
    out(`factory: ${unit.stem}: ${r.pass ? 'QUEUED FOR REVIEW' : 'REJECTED BY THE MACHINE'}: ${r.why}`);
  }
  return refused ? 3 : 0;
}

function cmdQueue(o, out) {
  const all = rows(read(o.ledger ?? LEDGER));
  const q = queue(all);
  for (const r of q) out(`${r.id}: ${r.task.machine.why}\n   worktree: ${r.task.wt}\n   test: ${r.task.test}`);
  for (const r of vanished(all)) out(`${r.id}: STARTED ${r.started.at} AND NEVER FINISHED: its run died; check \`dispatch.ts list\`, discard it and run it again`);
  out(`factory: ${q.length} awaiting Claude's review; nothing has landed`);
  return 0;
}

function cmdReview(id, o, out, err) {
  const VERDICTS = ['accepted', 'accepted-after-revision', 'rejected'];
  if (!VERDICTS.includes(o.verdict)) { err(`factory: --verdict must be one of ${VERDICTS.join(', ')}`); return 2; }
  const ledger = o.ledger ?? LEDGER;
  const row = rows(read(ledger)).find((r) => r.id === id);
  if (!row?.task) { err(`factory: no task ${id} in ${ledger}`); return 2; }
  if (row.review) { err(`factory: ${id} was already reviewed (${row.review.verdict})`); return 2; }
  const iteration = o.iteration === undefined ? null : Number(o.iteration);
  const given = ['review-tokens', 'review-secs'].filter((k) => o[k] !== undefined);
  if (given.length === 1 || given.some((k) => !/^\d+$/.test(String(o[k])))) {
    err('factory: --review-tokens and --review-secs go together, as whole numbers the harness reported for the review subagent (never estimate them)');
    return 2;
  }
  const measured = given.length ? { review_tokens: Number(o['review-tokens']), review_secs: Number(o['review-secs']) } : {};
  append(ledger, { type: 'review', id, verdict: o.verdict, changed_lines: Number(o.changed ?? 0), notes: o.notes ?? '', iteration, ...measured, at: new Date().toISOString() });
  out(`factory: ${id} ${o.verdict}`);
  return 0;
}

/** Records a control run: Claude alone wrote the same module's tests, so the saving can be measured. */
function cmdControl(stem, o, out, err) {
  const need = ['tokens', 'secs', 'tests', 'killed', 'mutants', 'changed'];
  const bad = need.filter((k) => !/^\d+$/.test(String(o[k] ?? '')));
  if (bad.length) { err(`factory: control needs whole numbers for --${bad.join(', --')} (the harness reports tokens and seconds; never estimate them)`); return 2; }
  const n = (k) => Number(o[k]);
  if (n('killed') > n('mutants')) { err('factory: --killed cannot exceed --mutants'); return 2; }
  const ledger = o.ledger ?? LEDGER;
  append(ledger, { type: 'control', id: `control-${stem.replace(/_/g, '-')}`, unit: stem, model: o.model ?? null, claude_tokens: n('tokens'), secs: n('secs'),
    tests: n('tests'), mutation: { killed: n('killed'), of: n('mutants') }, review_changed: n('changed'), notes: o.notes ?? '', at: new Date().toISOString() });
  out(`factory: control for ${stem} recorded`);
  return 0;
}

function cmdLedger(o, out) {
  const state = o.state ? JSON.parse(readFileSync(o.state, 'utf8')) : null;
  out(JSON.stringify(totals(rows(read(o.ledger ?? LEDGER)), state), null, 1));
  return 0;
}

export async function main(argv, { out = console.log, err = console.error } = {}) {
  const [cmd, ...rest] = argv;
  const { o, pos } = flags(rest);
  if (cmd === 'pick') return cmdPick(o, out, err);
  if (cmd === 'run') return cmdRun(o, out, err);
  if (cmd === 'queue') return cmdQueue(o, out);
  if (cmd === 'review' && pos[0]) return cmdReview(pos[0], o, out, err);
  if (cmd === 'ledger') return cmdLedger(o, out);
  if (cmd === 'control' && pos[0]) return cmdControl(pos[0], o, out, err);
  return usage(err);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}

export { copyFileSync, rmSync };
