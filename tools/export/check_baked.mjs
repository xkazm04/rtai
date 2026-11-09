// Verify baked city chunks before exporting. Uses Node builtins only.
import { createHash } from 'node:crypto';
import { readFileSync, statSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const DEFAULT_LIST = join(ROOT, 'project/data/generated/city_chunks.sha256');
const DEFAULT_CITY = join(ROOT, 'project/data/generated/city');

/** Check every listed chunk. Malformed rows fail closed; blank/comment rows are ignored. */
export function checkBaked({ list, city }) {
  const result = { ok: false, expected: 0, missing: [], mismatched: [] };
  let text;
  try {
    text = readFileSync(list, 'utf8');
  } catch {
    return result;
  }
  let valid = true;
  let directory = false;
  try {
    directory = statSync(city).isDirectory();
  } catch {
    // An absent city directory makes every listed chunk missing.
  }
  for (const line of text.split(/\r?\n/)) {
    if (!line.trim() || line.trimStart().startsWith('#')) continue;
    // Accept basenames only: a manifest must not read files outside the city directory.
    const row = /^([a-f\d]{64})  ([^/\\:\0]+\.bin)$/i.exec(line);
    if (!row) {
      valid = false;
      continue;
    }
    const [, hash, name] = row;
    result.expected += 1;
    if (!directory) {
      result.missing.push(name);
      continue;
    }
    try {
      const actual = createHash('sha256').update(readFileSync(join(city, name))).digest('hex');
      if (actual !== hash.toLowerCase()) result.mismatched.push(name);
    } catch (error) {
      const absent = error.code === 'ENOENT' || error.code === 'ENOTDIR';
      (absent ? result.missing : result.mismatched).push(name);
    }
  }
  result.ok = valid && directory && result.expected > 0
    && result.missing.length === 0 && result.mismatched.length === 0;
  return result;
}

function main(argv) {
  const options = { list: DEFAULT_LIST, city: DEFAULT_CITY };
  if (argv.includes('--help')) {
    console.log('usage: node tools/export/check_baked.mjs [--list <sha256-list>] [--city <directory>]');
    console.log('defaults: project/data/generated/city_chunks.sha256; project/data/generated/city');
    return 0;
  }
  for (let i = 0; i < argv.length; i += 1) {
    const match = /^--(list|city)(?:=(.*))?$/.exec(argv[i]);
    const value = match && (match[2] ?? argv[++i]);
    if (!match || !value || value.startsWith('--')) {
      console.error(`check_baked: invalid argument ${argv[i] ?? '(missing value)'}`);
      return 1;
    }
    options[match[1]] = value;
  }
  const result = checkBaked(options);
  console.log(`check_baked: ${result.ok ? 'OK' : 'FAIL'}; expected ${result.expected}; missing ${result.missing.length}; mismatched ${result.mismatched.length}`);
  for (const name of result.missing) console.log(`missing: ${name}`);
  for (const name of result.mismatched) console.log(`mismatched: ${name}`);
  return result.ok ? 0 : 1;
}

if (process.argv[1] && fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  process.exitCode = main(process.argv.slice(2));
}
