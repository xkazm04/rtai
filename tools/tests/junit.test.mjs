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
