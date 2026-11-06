import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, sep } from 'node:path';
import { test } from 'node:test';
import { check, update } from './debt.mjs';

const made = [];
function fixture() {
  const root = mkdtempSync(join(tmpdir(), 'gtai-debt-fixture-'));
  made.push(root);
  const f = {
    root,
    baselinePath: join(root, 'baseline.json'),
    put(path, text) {
      mkdirSync(dirname(join(root, path)), { recursive: true });
      writeFileSync(join(root, path), text);
    },
    gd(path, lines, head = '') {
      f.put(path, `${head}${'var x: int = 0\n'.repeat(Math.max(0, lines - head.split('\n').length + 1))}`);
    },
    save(accept) {
      const r = update({ root, baselinePath: f.baselinePath, accept, now: '2026-01-02' });
      if (r.ok) writeFileSync(f.baselinePath, JSON.stringify(r.baseline));
      return r;
    },
    check: () => check({ root, baselinePath: f.baselinePath }),
  };
  f.gd('project/features/a/big.gd', 275);
  f.gd('project/features/a/mid.gd', 220);
  f.put('project/boot/launch_args.gd', 'func a() -> void:\n\tOS.get_cmdline_user_args()\n');
  f.put('project/features/a/cl.gd', '# OS.get_cmdline_args() in a comment\nfunc a() -> void:\n\tOS.get_cmdline_args()\n');
  f.put('project/dev/tool/tool_run.gd', 'class_name ToolRun\nextends Node\nvar z: int = 0\n');
  f.put('project/dev/tool/other.gd', 'extends Node\n');
  f.put('project/features/a/uses.gd', 'func f() -> void:\n\tToolRun.new()\n\tprint("res://dev/tool/")\n');
  f.put('project/addons/x/skip.gd', 'x\n'.repeat(500));
  return f;
}
const GREEN = (f) => {
  const r = f.save();
  assert.ok(r.ok, r.issues.join('\n'));
  assert.ok(f.check().ok, f.check().issues.join('\n'));
  return f;
};
const fails = (f, ...needles) => {
  const c = f.check();
  assert.equal(c.ok, false, 'expected a regression');
  const text = c.issues.join('\n');
  for (const n of needles) assert.ok(text.includes(n), `missing "${n}" in:\n${text}`);
};

test.after(() => {
  for (const r of made) {
    assert.ok(r.startsWith(tmpdir()) && r.split(sep).some((s) => s.startsWith('gtai-debt-fixture')));
    rmSync(r, { recursive: true, force: true });
  }
});

test('clean fixture is green and counts the expected debt', () => {
  const f = GREEN(fixture());
  assert.equal(f.check().issues.length, 0);
});

test('a listed file growing fails files_near_cap and files_past_soft_cap, naming file and old -> new', () => {
  const f = GREEN(fixture());
  f.gd('project/features/a/big.gd', 280);
  fails(f, 'files_near_cap', 'project/features/a/big.gd grew from 275 to 280', 'files_past_soft_cap');
});

test('a new file crossing 270 and one crossing 200 are named as NEW', () => {
  const f = GREEN(fixture());
  f.gd('project/core/n.gd', 271);
  f.gd('project/core/s.gd', 201);
  fails(f, 'NEW project/core/n.gd (271 lines)', 'NEW project/core/s.gd (201 lines)');
});

test('a new direct cmdline read fails, in a new file and in a listed one; allowlist and comments are ignored', () => {
  const f = GREEN(fixture());
  f.put('project/boot/arena_args.gd', 'OS.get_cmdline_args()\n');
  assert.ok(f.check().ok);
  f.put('project/features/a/cl.gd', 'func a() -> void:\n\tOS.get_cmdline_args()\n\tOS.get_cmdline_user_args()\n');
  fails(f, 'direct_cmdline_reads: 1 -> 2', 'project/features/a/cl.gd grew from 1 to 2 reads');
  const g = GREEN(fixture());
  g.put('project/dev/tool/new.gd', 'OS.get_cmdline_user_args()\n');
  fails(g, 'NEW project/dev/tool/new.gd');
});

test('dev_loc growth fails and names the dir', () => {
  const f = GREEN(fixture());
  f.gd('project/dev/tool/more.gd', 30);
  fails(f, 'dev_loc', 'project/dev/tool grew from 4 to 34 lines');
});

test('a new lane-named or unreferenced dev dir fails', () => {
  const f = GREEN(fixture());
  f.put('project/dev/n7_night/run.gd', 'extends Node\n');
  fails(f, 'lane_named_dev_dirs', 'NEW project/dev/n7_night', 'lane/day-style name');
  const g = GREEN(fixture());
  g.put('project/dev/orphan/a.gd', 'class_name OrphanA\nextends Node\n');
  fails(g, 'NEW project/dev/orphan', 'nothing outside references it');
  g.put('project/features/a/ref.gd', 'var a: OrphanA\n');
  assert.ok(!g.check().issues.join('\n').includes('lane_named_dev_dirs'));
});

test('a new unused class_name fails and names the class', () => {
  const f = GREEN(fixture());
  f.put('project/features/a/lonely.gd', 'class_name Lonely\nextends Node\n');
  fails(f, 'unused_class_names', 'NEW project/features/a/lonely.gd', '[Lonely]');
  f.put('project/features/a/lonely_user.gd', 'var l: Lonely\n');
  assert.ok(f.check().ok);
});

test('an improvement passes with a tighten notice; --update then tightens', () => {
  const f = GREEN(fixture());
  f.gd('project/features/a/big.gd', 150);
  const c = f.check();
  assert.ok(c.ok);
  assert.ok(c.notes.join().includes('tighten: run node tools/debt/debt.mjs --update'));
  assert.ok(f.save().ok);
  assert.equal(f.check().notes.length, 0);
});

test('--update refuses to raise without a reason, and records the reason when given', () => {
  const f = GREEN(fixture());
  f.gd('project/features/a/big.gd', 290);
  const refused = f.save();
  assert.equal(refused.ok, false);
  assert.ok(refused.issues.join('\n').includes('project/features/a/big.gd grew from 275 to 290'));
  assert.equal(f.check().ok, false);
  const ok = f.save('needed for the boss port');
  assert.ok(ok.ok);
  assert.ok(ok.baseline.metrics.files_near_cap.accepted[0].startsWith('2026-01-02: needed for the boss port'));
  assert.ok(f.check().ok);
});

test('the split-to-the-cap pattern warns without failing', () => {
  const f = fixture();
  f.gd('project/features/a/cap.gd', 299);
  GREEN(f);
  f.gd('project/features/a/cap.gd', 297);
  const c = f.check();
  assert.ok(c.ok);
  assert.ok(c.warnings.join().includes('project/features/a/cap.gd went 299 -> 297'));
  f.gd('project/features/a/cap.gd', 200);
  assert.equal(f.check().warnings.length, 0);
});

test('a missing baseline fails with the way out', () => {
  const f = fixture();
  assert.match(f.check().issues[0], /baseline\.json missing/);
});
