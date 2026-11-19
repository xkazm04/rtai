// Run from a clean project at the gameplay commit. Only the build/ copy receives faults.
import { execFileSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { runGodot, SCRIPT_ERROR } from '../../tools/lib/godot.mjs';
import { generateMutants, applyMutant } from '../../tools/mutate/operators.mjs';
import { formatReport } from '../../tools/mutate/report.mjs';
import { parseJunit } from '../../tools/tests/junit.mjs';

const git = (...args) => execFileSync('git', args, { encoding: 'utf8' }).trim();
if (git('status', '--porcelain', '--', 'project')) throw Error('Commit the gameplay project first');
const out = resolve('build/a10');
mkdirSync(out, { recursive: true });
const scratch = mkdtempSync(join(out, 'mutation-'));
const file = 'features/combat/guard_brain.gd';
const target = join(scratch, 'project', file);
const tests = ['unit/test_arena_station_spacing', 'integration/test_arena_guard_wall',
  'unit/test_guard_tell', 'unit/test_dock_waves', 'unit/test_fight_probe'];
const testsConfig = join(scratch, 'gut.json');
const xml = join(scratch, 'report.xml');
const results = [];
const head = git('rev-parse', 'HEAD');
const start = Date.now();
const cfg = JSON.parse(readFileSync('project/.gutconfig.json'));
cfg.dirs = [];
cfg.tests = tests.map(name => 'res://tests/' + name + '.gd');
writeFileSync(testsConfig, JSON.stringify(cfg));

async function run(source) {
  writeFileSync(target, source);
  rmSync(xml, { force: true });
  const args = ['-s', 'res://addons/gut/gut_cmdln.gd', '-gconfig=' + testsConfig,
    '-gjunit_xml_file=' + xml];
  const r = await runGodot(args, { cwd: scratch, timeoutMs: 60000, name: 'station-mutation' });
  const cases = existsSync(xml) ? parseJunit(readFileSync(xml, 'utf8')).cases : [];
  const failed = cases.filter(c => c.status === 'fail').map(c => c.name);
  let verdict;
  if (r.timedOut) verdict = 'timeout';
  else if (/Parse Error|Compile Error|Failed to load script/.test(r.out)) verdict = 'invalid';
  else if (failed.length || SCRIPT_ERROR.test(r.out)) verdict = 'killed';
  else if (r.status === 0 && cases.length > 0) verdict = 'survived';
  else throw Error(r.out.slice(-3000));
  return { verdict, failed, cases: cases.length };
}

try {
  cpSync('project', join(scratch, 'project'), { recursive: true });
  const original = readFileSync(target, 'utf8');
  const control = await run(original);
  if (control.verdict !== 'survived') throw Error(JSON.stringify(control));
  const noPush = original.replace(/static func space_partner\([\s\S]*?(?=\n\nstatic func trigger)/,
    'static func space_partner(_g: Fighter, _hostiles: Array[Fighter]) -> void:\n\tpass\n');
  const negative = await run(noPush);
  if (!negative.failed.includes('test_coincident_partners_separate_on_the_guard_path')) {
    throw Error('Removing the push escaped the overlap assertion');
  }
  for (const mutant of generateMutants(original)) {
    const result = await run(applyMutant(original, mutant));
    if (result.verdict === 'survived' && result.cases !== control.cases) throw Error('Incomplete run');
    results.push({ ...mutant, ...result });
    console.log(mutant.id, mutant.line, mutant.op, result.verdict);
  }
  console.log(formatReport({ file, tests, results, totalMs: Date.now() - start }));
  writeFileSync(join(out, 'mutation.json'), JSON.stringify({ head, tests, control, negative, results }, null, 2));
} finally {
  if (dirname(scratch) === out) rmSync(scratch, { recursive: true, force: true });
}
