// lint.mjs can be imported from `node -e` (no script path in argv[1]) without running or crashing.
// Run: node --test tools/lint/lint_import.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';
import { join } from 'node:path';
import { ROOT } from '../lib/repo.mjs';

test('importing lint.mjs from node -e neither throws nor runs the checks (tools lane n11)', { timeout: 60_000 }, () => {
  const url = pathToFileURL(join(ROOT, 'tools', 'lint', 'lint.mjs')).href;
  const r = spawnSync(process.execPath, ['-e', `import(${JSON.stringify(url)}).then(() => console.log('imported'))`],
    { cwd: ROOT, encoding: 'utf8', timeout: 60_000 });
  assert.equal(r.status, 0, r.stderr);
  assert.match(r.stdout, /imported/);
  assert.doesNotMatch(r.stdout, /lint: /, 'the checks must not run on import');
});
