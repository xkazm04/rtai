import { test } from 'node:test';
import assert from 'node:assert/strict';
import { digestLines, parseJunit, slowest } from './junit.mjs';

const XML = `<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="GutTests" failures="1" tests="3" >
  <testsuite name="tests/unit/test_x.gd" tests="3" failures="1" skipped="1" time="0.5" >
      <testcase name="test_ok" assertions="1" status="pass" classname="tests/unit/test_x.gd" time="0.015" >
      </testcase>
      <testcase name="test_pending" assertions="0" status="pending" classname="tests/unit/test_x.gd" time="0.001" >
      </testcase>
      <testcase name="test_bad" assertions="1" status="fail" classname="tests/unit/test_x.gd" time="0.4" >
      <failure message="failed"><![CDATA[[1] expected to equal [2]:  a &lt; b
            at line 10]]></failure></testcase>
  </testsuite>
</testsuites>`;

test('counts, cases and the digest line', () => {
  const r = parseJunit(XML);
  assert.deepEqual(r.counts, { passed: 1, failed: 1, skipped: 1 });
  assert.deepEqual(digestLines(r.cases), ['res://tests/unit/test_x.gd:10 test_bad - [1] expected to equal [2]:  a < b']);
});

test('slowest sorts by time', () => {
  const r = parseJunit(XML);
  assert.match(slowest(r.cases, 1)[0], /0\.400 s .*test_bad/);
});

const ENGINE = `<testsuites><testsuite name="tests/unit/test_vehicle_view.gd" tests="1" failures="1" >
      <testcase name="test_glow_is_lit" assertions="0" status="fail" classname="tests/unit/test_vehicle_view.gd" time="0.1" >
      <failure message="failed"><![CDATA[Unexpected Errors:
[1] <engine>!actions.custom_samplers.has(tex_builtin)
[2] <engine>Parameter "t" is null]]></failure></testcase>
  </testsuite></testsuites>`;

test('an engine-error failure keeps its numbered error lines as cause, and the digest line carries them', () => {
  const [c] = parseJunit(ENGINE).cases;
  assert.equal(c.message, 'Unexpected Errors:');
  assert.deepEqual(c.cause, ['[1] <engine>!actions.custom_samplers.has(tex_builtin)', '[2] <engine>Parameter "t" is null']);
  const [line] = digestLines([c]);
  assert.ok(line.includes('[1] <engine>!actions.custom_samplers.has(tex_builtin)') && line.includes('[2] <engine>Parameter "t" is null'), line);
});

test('an assertion failure has no cause beyond its message (the "at line" is the line, not a cause)', () => {
  const bad = parseJunit(XML).cases.find((c) => c.name === 'test_bad');
  assert.deepEqual(bad.cause, []);
  assert.deepEqual(parseJunit(XML).cases.find((c) => c.name === 'test_ok').cause, []);
});
