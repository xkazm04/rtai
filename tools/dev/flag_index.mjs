// The project's flag literals: every "--name" / "--name=value" string in our GDScript, so the dev
// runner can refuse a flag NOTHING reads when the entry declares no list of its own (hero n15
// FRICTION 05:06: `--ohm-hand=sim` was launched "flags unchecked" while CastFlags reads only
// `--ghost-ohm-hand=sim`, and the before/after came out 0.0 %).
//   name known  <- some literal "--name" (a bare read: LaunchArgs.value("--name"), args[i] == "--name")
//                  or "--name=" (a prefix read: begins_with("--name=")) or "--name=<v>" (an exact read)
//   value known <- the name has a bare or prefix literal (any value), or the passed "--name=<v>" is
//                  itself a literal (an exact read: `arg == "--ghost-ohm-hand=sim"`).
// A literal ending in "-" ("--ghost-") is a family prefix: it never makes a longer name known, so a
// typo inside a family is still caught. A literal in a comment proves nothing. Read statically,
// nothing is run. tools/film checks its game flags (after its --) with the same index.
import { readFileSync } from 'node:fs';
import { PROJECT, walk } from '../lib/repo.mjs';
import { stripComment } from '../style/check_gd.mjs';
import { didYouMean } from './entries.mjs';

const LITERAL = /"(--[A-Za-z0-9][A-Za-z0-9_-]*)(=[^"\\]*)?"/g;

/** Map name -> {any: bool, values: Set} from GDScript source texts (comments do not count). */
export function indexTexts(texts) {
  const names = new Map();
  for (const text of texts) {
    for (const m of text.split('\n').map(stripComment).join('\n').matchAll(LITERAL)) {
      const e = names.get(m[1]) ?? { any: false, values: new Set() };
      if (m[2] === undefined || m[2] === '=') e.any = true;
      else e.values.add(m[2].slice(1));
      names.set(m[1], e);
    }
  }
  return names;
}

/** Unit and integration tests hand fake args to the code under test, and GUT's docs name "--foo":
 *  neither is a flag a dev entry reads (GUT's own options are single-dash). */
const FAKE_ARGS = /[\\/](tests[\\/](unit|integration)|addons)[\\/]/;

/** The index of every .gd under the project but unit/integration tests and addons. */
export function projectIndex(projectDir = PROJECT) {
  const files = walk(projectDir, (n, abs) => n.endsWith('.gd') && !FAKE_ARGS.test(abs));
  return indexTexts(files.map((f) => readFileSync(f, 'utf8')));
}

/** Each passed flag no literal can read: [{arg, flag, suggestion}]. `args` are the entry's own. */
export function unreadFlags(args, index) {
  const known = [...index.keys()];
  const problems = [];
  for (const arg of args.filter((a) => a.startsWith('--') && a !== '--')) {
    const eq = arg.indexOf('=');
    const name = eq < 0 ? arg : arg.slice(0, eq);
    const e = index.get(name);
    if (!e) { problems.push({ arg, flag: name, suggestion: didYouMean(name, known) ?? closest(name, known) }); continue; }
    if (e.any || (eq >= 0 && e.values.has(arg.slice(eq + 1)))) continue;
    const exact = [...e.values].map((v) => `${name}=${v}`);
    problems.push({ arg, flag: arg, suggestion: didYouMean(arg, exact) ?? exact.join(' | ') });
  }
  return problems;
}

/** A known name that ends with the passed one or contains it (`--ohm-hand` -> `--ghost-ohm-hand`). */
function closest(name, known) {
  const stem = name.slice(2);
  const hits = known.filter((k) => k.length > name.length && k.endsWith(`-${stem}`));
  return hits.length === 1 ? hits[0] : null;
}

export const FLAG_INDEX_NOTE = 'flags checked against the project\'s flag literals (no declared spec)';

/** The literal index's verdict on an entry's flags (entries.resolve calls it when no spec is declared). */
export function checkAgainstProject(args, { projectDir = PROJECT } = {}) {
  return unreadFlags(args, projectIndex(projectDir));
}

