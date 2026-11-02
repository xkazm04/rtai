#!/usr/bin/env node
// Achievements generator (STANDARDS ACH-04/05, section 22 step 11).
//   node tools/achievements/gen.mjs validate   exit 1 on any ACH-04 failure
//   node tools/achievements/gen.mjs emit       validate, then write AchIds + runtime JSON (+ build/)
//   node tools/achievements/gen.mjs --check    validate, then fail if committed outputs drifted
import { mkdirSync, readFileSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { rel } from '../lib/repo.mjs';
import { checkAll, loadInputs } from './rules.mjs';
import { BUILD_DIR, IDS_PATH, RUNTIME_PATH, achIdsGd, buildOnlyFiles, runtimeJson } from './emit.mjs';

const write = (abs, text) => {
  mkdirSync(dirname(abs), { recursive: true });
  writeFileSync(abs, text, 'utf8');
};

function main(cmd) {
  const { doc, schema, events } = loadInputs();
  const { errors, warnings } = checkAll(doc, schema, events);
  for (const w of warnings) console.log(`warn  ${w}`);
  for (const e of errors) console.error(`ERROR ${e}`);
  if (errors.length) {
    console.error(`achievements: ${errors.length} error(s)`);
    return 1;
  }
  const committed = [[IDS_PATH, achIdsGd(doc)], [RUNTIME_PATH, runtimeJson(doc)]];
  if (cmd === 'validate') {
    console.log(`achievements: valid (${doc.achievements.length} achievements, ${doc.stats.length} stats)`);
    return 0;
  }
  if (cmd === '--check') {
    const drift = committed.filter(([p, text]) => !existsSync(p) || readFileSync(p, 'utf8') !== text);
    for (const [p] of drift) console.error(`DRIFT ${rel(p)}: run node tools/achievements/gen.mjs emit`);
    if (!drift.length) console.log('achievements: generated files up to date');
    return drift.length ? 1 : 0;
  }
  if (cmd === 'emit') {
    for (const [p, text] of committed) write(p, text);
    const { files, todo } = buildOnlyFiles(doc);
    for (const [name, text] of Object.entries(files)) write(join(BUILD_DIR, name), text);
    for (const t of todo) console.log(`todo  ${t}`);
    console.log(`achievements: emitted ${committed.map(([p]) => rel(p)).join(', ')}`);
    return 0;
  }
  console.error('usage: gen.mjs validate | emit | --check');
  return 2;
}

process.exit(main(process.argv[2]));
