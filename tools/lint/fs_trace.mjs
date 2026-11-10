// Lists every file under <TRACE_ROOT>/project/ a Node process touches through node:fs (sync calls),
// one `<path> TAB <script>` line per first touch, appended to TRACE_OUT. It checks the pre-commit lint's
// tool-test inputs (tools/lint/scope.mjs INPUT_PREFIXES):
//   TRACE_ROOT=$PWD TRACE_OUT=<file> node --import ./tools/lint/fs_trace.mjs --test "tools/film/*.test.mjs" ...
// Directories show up too (readdir); the file paths are what matters.
import fs from 'node:fs';
import { syncBuiltinESMExports } from 'node:module';
import { appendFileSync } from 'node:fs';
import { resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const norm = (p) => resolve(p).toLowerCase().split(sep).join('/');
const ROOT = norm(process.env.TRACE_ROOT);
const OUT = process.env.TRACE_OUT;
const seen = new Set();
const log = (p) => {
  try {
    const s = norm(p instanceof URL ? fileURLToPath(p) : String(p));
    if (s.startsWith(`${ROOT}/project/`) && !seen.has(s)) {
      seen.add(s);
      appendFileSync(OUT, `${s.slice(ROOT.length + 1)}\t${process.argv[1] ?? ''}\n`);
    }
  } catch { /* not a path */ }
};
for (const name of ['readFileSync', 'existsSync', 'readdirSync', 'statSync', 'openSync', 'lstatSync']) {
  const orig = fs[name];
  fs[name] = function traced(p, ...rest) { log(p); return orig.call(this, p, ...rest); };
}
syncBuiltinESMExports();
