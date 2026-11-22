import { isAbsolute, win32 } from 'node:path';
import { parseArgs as parseOptions } from 'node:util';
import { parseArgs as parseBatch } from './commands.mjs';

function parseEdit(arg) {
  const match = /^([^#]+)#(\/.*)=(true|false|-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)$/.exec(arg);
  if (!match) throw new Error('expected --set=<repo-relative.json>#<pointer>=<number|true|false>');
  const [, file, pointer, raw] = match;
  const parts = file.split(/[\\/]/);
  if (isAbsolute(file) || win32.isAbsolute(file) || /[:\0]/.test(file) || !file.endsWith('.json')
    || parts.some((p) => !p || p === '.' || p === '..' || p.toLowerCase() === '.git'))
    throw new Error('unsafe JSON path: ' + file);
  if (/~(?![01])/.test(pointer)) throw new Error('invalid JSON pointer: ' + pointer);
  const value = JSON.parse(raw);
  if (typeof value === 'number' && !Number.isFinite(value)) throw new Error('nonfinite number: ' + raw);
  return { file: parts.join('/'), pointer, value };
}

export function parseAblation(argv) {
  const split = argv.indexOf('--');
  if (split < 0) throw new Error('expected -- followed by batch arguments');
  const { values } = parseOptions({ args: argv.slice(0, split), options: {
    name: { type: 'string' }, set: { type: 'string', multiple: true }, 'pick-filter': { type: 'string' }
  } });
  if (!/^[a-z0-9][a-z0-9_-]*$/.test(values.name ?? '')) throw new Error('expected --name=<id>');
  const batchArgs = argv.slice(split + 1);
  if (!batchArgs.some((a) => a.startsWith('--out=') || a === '--out')) throw new Error('a batch --out is required');
  if (batchArgs.some((a) => a.split('=')[0] === '--pick-filter')) throw new Error('place --pick-filter before --');
  if (values['pick-filter'] !== undefined) batchArgs.push('--pick-filter=' + values['pick-filter']);
  const batch = parseBatch(batchArgs);
  if (batch.from || batch.dryRun) throw new Error('ablation requires a live batch');
  const forwarded = batchArgs.filter((arg, i) => arg.split('=')[0] !== '--out' && batchArgs[i - 1] !== '--out');
  return { name: values.name, edits: (values.set ?? []).map(parseEdit), pickFilter: batch.pickFilter ?? null,
    out: batch.out, batchArgs: [...forwarded, '--out=' + batch.out] };
}

/** Resolve only existing object members or array indices. Never create a slot. */
export function editScalar(doc, { pointer, value }) {
  const keys = pointer.slice(1).split('/').map((key) => key.replaceAll('~1', '/').replaceAll('~0', '~'));
  let parent = doc;
  for (const [i, key] of keys.entries()) {
    if (!parent || typeof parent !== 'object' || !Object.hasOwn(parent, key)
      || (Array.isArray(parent) && !/^(?:0|[1-9]\d*)$/.test(key)))
      throw new Error('missing JSON pointer: ' + pointer);
    if (i === keys.length - 1) {
      const before = parent[key];
      if (typeof before !== typeof value || !(typeof before === 'boolean' || (Number.isFinite(before) && Number.isFinite(value))))
        throw new Error('expected a value matching the numeric or boolean field: ' + pointer);
      parent[key] = value;
      return before;
    }
    parent = parent[key];
  }
}

// Existing numeric callers use the same pointer resolver.
export function editNumber(doc, edit) {
  if (!Number.isFinite(edit.value)) throw new Error('expected numeric edit');
  return editScalar(doc, edit);
}
