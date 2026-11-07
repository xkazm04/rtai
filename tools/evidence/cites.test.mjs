// node --test "tools/evidence/*.test.mjs"
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { main, parseAliases } from './cites.mjs';
import { ROOT } from '../lib/repo.mjs';

/** A fixture tree under os.tmpdir(): files = {relative path: text}. Deletes only what it wrote. */
function fixture(files) {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-cites-'));
  const made = [];
  for (const [rel, text] of Object.entries(files)) {
    const abs = join(dir, rel);
    mkdirSync(dirname(abs), { recursive: true });
    writeFileSync(abs, text);
    made.push(abs);
  }
  const done = () => {
    const dirs = new Set([dir]);
    for (const abs of made) {
      rmSync(abs, { force: true, recursive: false });
      for (let d = dirname(abs); d.length > dir.length; d = dirname(d)) dirs.add(d);
    }
    for (const d of [...dirs].sort((a, b) => b.length - a.length)) rmdirSync(d);
  };
  return { dir, done };
}

/** Runs main over a fixture; tracked defaults to every fixture file except the ones in `untracked`. */
function runCites(files, argv, { untracked = [], tracked } = {}) {
  const fx = fixture(files);
  const lines = [];
  try {
    const list = tracked ?? Object.keys(files).filter((p) => !untracked.includes(p));
    const code = main(argv, { root: fx.dir, tracked: list, write: (s) => lines.push(s) });
    return { code, lines, out: lines.join('\n') };
  } finally {
    fx.done();
  }
}

const atLine = (n, text) => `${'filler\n'.repeat(n - 1)}${text}\n`;
const nLines = (n) => 'x\n'.repeat(n);

test('a stale cite is MISSING with the nearest tracked path suggested, exit 1', () => {
  const r = runCites(
    { 'docs/decisions.md': atLine(137, 'Gate measured (`evidence/cop-gate.json`, riot).'), 'evidence/d5-cast/cop-gate.json': '{}' },
    ['docs/decisions.md'],
  );
  assert.equal(r.code, 1);
  assert.ok(
    r.lines.includes('docs/decisions.md:137 evidence/cop-gate.json MISSING (did you mean evidence/d5-cast/cop-gate.json?)'),
    r.out,
  );
});

test('file:line cites check each line against the file length', () => {
  const report = { 'R.md': 'See `project/dev/showcase/x.gd:7,57`.\n' };
  const short = runCites({ ...report, 'project/dev/showcase/x.gd': nLines(40) }, ['R.md']);
  assert.equal(short.code, 1);
  assert.ok(short.lines.includes('R.md:1 project/dev/showcase/x.gd:7,57 MISSING-LINE (line 57 past end (40 lines))'), short.out);
  assert.equal(short.lines.filter((l) => / line 7 /.test(l)).length, 0);
  const long = runCites({ ...report, 'project/dev/showcase/x.gd': nLines(60) }, ['R.md']);
  assert.equal(long.code, 0, long.out);
  assert.match(long.out, /cites: 1 paths, 1 ok/);
});

test('brace and itN..itM range forms expand and each path is checked alone', () => {
  const files = {
    'R.md': 'A `evidence/d9-seams/director-reel-it1-{top,tilt70,combo}.log`\nB `evidence/held-it1..it4-reel-director.log`\n',
    'evidence/d9-seams/director-reel-it1-top.log': 'x',
    'evidence/d9-seams/director-reel-it1-combo.log': 'x',
    'evidence/held-it1-reel-director.log': 'x',
    'evidence/held-it2-reel-director.log': 'x',
    'evidence/held-it3-reel-director.log': 'x',
    'evidence/held-it4-reel-director.log': 'x',
  };
  const r = runCites(files, ['R.md', '--json']);
  const rows = JSON.parse(r.out);
  assert.equal(rows.length, 7);
  const missing = rows.filter((x) => x.status === 'MISSING');
  assert.deepEqual(missing.map((x) => x.path), ['evidence/d9-seams/director-reel-it1-tilt70.log']);
  assert.equal(r.code, 1);
});

test('zero-padded ranges keep their width', () => {
  const files = { 'R.md': '`docs/patches/0001..0003.patch`\n' };
  for (const n of ['0001', '0002', '0003']) files[`docs/patches/${n}.patch`] = 'x';
  const r = runCites(files, ['R.md']);
  assert.equal(r.code, 0, r.out);
  assert.match(r.out, /cites: 3 paths, 3 ok/);
});

test('a declared root alias resolves; an undeclared one is UNCHECKED, exit 0 unless --strict', () => {
  const fx = fixture({ 'clip.mp4': 'x' });
  try {
    const declared = runCites({ 'R.md': `Paths: \`M/\` = \`${fx.dir}\\\`\n\nClip \`M/clip.mp4\`.\n` }, ['R.md']);
    assert.equal(declared.code, 0, declared.out);
    assert.match(declared.out, /cites: 1 paths, 1 ok/);
    const flag = runCites({ 'R.md': 'Clip `M/clip.mp4`.\n' }, ['R.md', `--root`, `M=${fx.dir}`]);
    assert.equal(flag.code, 0, flag.out);
    assert.match(flag.out, /1 ok/);
    const prose = runCites({ 'R.md': `Masters: \`${fx.dir}\\\` (written \`M/\` below).\nClip \`M/clip.mp4\`.\n` }, ['R.md']);
    assert.match(prose.out, /1 ok/, prose.out);
  } finally {
    fx.done();
  }
  const bare = runCites({ 'R.md': 'Clip `M/clip.mp4`.\n' }, ['R.md']);
  assert.equal(bare.code, 0);
  assert.ok(bare.lines.includes('R.md:1 M/clip.mp4 UNCHECKED (undeclared root M/)'), bare.out);
  assert.doesNotMatch(bare.out, /MISSING/);
  assert.equal(runCites({ 'R.md': 'Clip `M/clip.mp4`.\n' }, ['R.md', '--strict']).code, 1);
});

test('evidence on disk but not tracked is UNTRACKED; exit 1 only with --tracked', () => {
  const files = { 'R.md': 'Board `evidence/look/board.png`.\n', 'evidence/look/board.png': 'x' };
  const r = runCites(files, ['R.md'], { untracked: ['evidence/look/board.png'] });
  assert.equal(r.code, 0, r.out);
  assert.ok(r.lines.includes('R.md:1 evidence/look/board.png UNTRACKED (exists here, vanishes with the worktree)'), r.out);
  assert.equal(runCites(files, ['R.md', '--tracked'], { untracked: ['evidence/look/board.png'] }).code, 1);
});

test('placeholders and globs are PATTERN (skipped, counted), never MISSING', () => {
  const r = runCites({ 'R.md': '`evidence/d9/<view>-top.log` and `evidence/look/*.png`\n' }, ['R.md', '--json']);
  const rows = JSON.parse(r.out);
  assert.deepEqual(rows.map((x) => x.status), ['PATTERN', 'PATTERN']);
  assert.equal(r.code, 0);
  const text = runCites({ 'R.md': '`evidence/d9/<view>-top.log` and `evidence/look/*.png`\n' }, ['R.md']);
  assert.match(text.out, /2 pattern/);
  assert.doesNotMatch(text.out, /MISSING/);
});

test('--json is sorted by line; a clean report prints the one summary line', () => {
  const files = { 'R.md': '' };
  for (let i = 0; i < 43; i += 1) {
    files[`evidence/n8/f${i}.log`] = 'x';
    files['R.md'] += `cite \`evidence/n8/f${i}.log\`\n`;
  }
  const rows = JSON.parse(runCites(files, ['R.md', '--json']).out);
  assert.equal(rows.length, 43);
  assert.deepEqual(rows.map((x) => x.line), [...rows.map((x) => x.line)].sort((a, b) => a - b));
  assert.deepEqual(Object.keys(rows[0]).sort(), ['file', 'line', 'path', 'status']);
  const r = runCites(files, ['R.md']);
  assert.equal(r.code, 0);
  assert.deepEqual(r.lines, ['cites: 43 paths, 43 ok']);
});

test('unknown arguments and no files exit 2', () => {
  assert.equal(runCites({ 'R.md': '' }, ['--bogus', 'R.md']).code, 2);
  assert.equal(runCites({ 'R.md': '' }, []).code, 2);
});

// The live tree: docs/decisions.md:137 has cited the moved cop gate since 2026-11-03. While that
// line stands, it must be the ONE miss the tool reports for decisions.md (skips once it is fixed).
const decisions = join(ROOT, 'docs', 'decisions.md');
const stale = existsSync(decisions) && readFileSync(decisions, 'utf8').includes('`evidence/cop-gate.json`');
test('real docs/decisions.md: exactly one MISSING, the cop gate', { skip: !stale && 'decisions.md:137 fixed' }, () => {
  const lines = [];
  const code = main(['docs/decisions.md'], { root: ROOT, write: (s) => lines.push(s) });
  const missing = lines.filter((l) => / MISSING( |$)/.test(l));
  assert.deepEqual(missing, ['docs/decisions.md:137 evidence/cop-gate.json MISSING (did you mean evidence/d5-cast/cop-gate.json?)']);
  assert.equal(code, 1);
});

test('frames/ resolves under a declared root; with none it is UNCHECKED, not MISSING', () => {
  const fx = fixture({ 'frames/a.png': 'x' });
  try {
    const r = runCites({ 'R.md': `\`M\` = \`${fx.dir}\`\n\`frames/a.png\` and \`frames/b.png\`\n` }, ['R.md']);
    assert.ok(r.lines.includes('R.md:2 frames/b.png MISSING'), r.out);
    assert.match(r.out, /1 ok/);
  } finally {
    fx.done();
  }
  const bare = runCites({ 'R.md': '`frames/a.png`\n' }, ['R.md']);
  assert.ok(bare.lines.includes('R.md:1 frames/a.png UNCHECKED (frames/ under no declared root)'), bare.out);
  assert.equal(bare.code, 0);
});

test('a git-ignored build output that is absent is IGNORED, not MISSING', () => {
  const fx = fixture({ 'R.md': 'Chunks (`project/data/generated/city/`) are output.\n' });
  const lines = [];
  try {
    const ignored = (p) => p.startsWith('project/data/generated/city');
    const code = main(['R.md'], { root: fx.dir, tracked: ['R.md'], ignored, write: (s) => lines.push(s) });
    assert.equal(code, 0, lines.join('\n'));
    assert.ok(lines.includes('R.md:1 project/data/generated/city/ IGNORED (git-ignored output, not on disk here)'), lines.join('\n'));
  } finally {
    fx.done();
  }
});

test('an undeclared <name>/ root is a placeholder (PATTERN), not UNCHECKED', () => {
  const r = runCites({ 'R.md': '`<tmpdir>/gtai-mutate-x/a.gd` and `<Studio>/`\n' }, ['R.md', '--strict']);
  assert.equal(r.code, 0, r.out);
  assert.deepEqual(r.lines, ['cites: 2 paths, 0 ok, 2 pattern']);
});

test('the prose alias forms in the lane reports all declare a root', () => {
  const d = 'C:\\x\\masters\\lane\\';
  const forms = [
    `\`M\` below stands for \`${d}\`.`,
    `in\n\`${d}\`; \`M/\` below means that folder.`,
    `Clips: \`${d}\` (M below), more`,
    `- **Masters dir** (outside git, \`M/\` below): \`${d}\`.`,
    `Paths are relative unless they start with \`M/\`, which means\n\`${d}\`. I checked.`,
  ];
  for (const text of forms) assert.equal(parseAliases(text).get('M'), 'C:\\x\\masters\\lane', text);
  assert.equal(parseAliases('`WT` means this worktree.').get('WT'), '.');
  assert.equal(parseAliases('`evidence/` = `evidence/` in this worktree').size, 0);
  assert.equal(parseAliases(`\`${d}\` (\`frames.json\`, 15 entries)`).size, 0);
});

test('a cite whose whole folder is absent says so and suggests nothing', () => {
  const r = runCites({ 'R.md': '`evidence/weapon-art/unit-it21.log`\n', 'evidence/king/unit-it21.log': 'x' }, ['R.md']);
  assert.ok(r.lines.includes('R.md:1 evidence/weapon-art/unit-it21.log MISSING (no folder evidence/weapon-art/ here)'), r.out);
  assert.equal(r.code, 1);
});

test('a format-patch range names its patches by number; suggestions stay in the cited root', () => {
  const files = { 'R.md': '`evidence/p/0001..0002`\n`evidence/README.md`\n', 'evidence/p/0001-feat-a.patch': 'x', 'evidence/p/0002-test-b.patch': 'x', 'native/README.md': 'x' };
  const r = runCites(files, ['R.md']);
  assert.ok(r.lines.includes('R.md:2 evidence/README.md MISSING'), r.out);
  assert.match(r.out, /cites: 3 paths, 2 ok, 1 missing/);
});

test('a basename with several tracked homes gets no suggestion', () => {
  const files = { 'R.md': '`evidence/scenarios-it7.log`\n', 'evidence/a/scenarios-it7.log': 'x', 'evidence/b/scenarios-it7.log': 'x' };
  assert.ok(runCites(files, ['R.md']).lines.includes('R.md:1 evidence/scenarios-it7.log MISSING'));
});

test('git-ignored output that exists here is IGNORED, not UNTRACKED', () => {
  const fx = fixture({ 'R.md': '`project/native/bin`\n', 'project/native/bin/x.dll': 'x' });
  const lines = [];
  try {
    const code = main(['R.md', '--tracked'], { root: fx.dir, tracked: ['R.md'], ignored: (p) => p === 'project/native/bin', write: (s) => lines.push(s) });
    assert.equal(code, 0, lines.join('\n'));
    assert.ok(lines.includes('R.md:1 project/native/bin IGNORED (git-ignored output)'), lines.join('\n'));
  } finally {
    fx.done();
  }
});
