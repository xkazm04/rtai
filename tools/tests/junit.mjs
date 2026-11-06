// GUT JUnit parsing shared by run_unit.mjs and flakes.mjs: counts, per-test cases, failure digest.

const decode = (s) => s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"')
  .replace(/&apos;/g, "'").replace(/&amp;/g, '&');
const attrOf = (tag, name) => {
  const m = new RegExp(`\\b${name}="([^"]*)"`).exec(tag);
  return m ? decode(m[1]) : '';
};

/** -> {counts: {passed, failed, skipped}, cases: [{file, name, time, status, line, message}]}.
 *  `file` is res://tests/...gd; `line` is GUT's "at line N" (0 when absent); `message` is the
 *  first line of the failure text. */
export function parseJunit(xml) {
  const cases = [];
  for (const suite of xml.split('<testsuite ').slice(1)) {
    const sname = attrOf(suite.slice(0, suite.indexOf('>')), 'name');
    const file = `res://${sname.replace(/(\.gd)\..*$/, '$1')}`;
    for (const block of suite.split('<testcase ').slice(1)) {
      const head = block.slice(0, block.indexOf('>'));
      const status = attrOf(head, 'status') || 'pass';
      const c = { file, name: attrOf(head, 'name'), time: Number(attrOf(head, 'time')) || 0, status, line: 0, message: '' };
      const body = /<(?:failure|error)\b[^>]*>(?:<!\[CDATA\[([\s\S]*?)\]\]>)?/.exec(block.split('</testcase>')[0]);
      if (body) {
        const text = decode(body[1] ?? '');
        c.status = 'fail';
        c.message = text.split('\n')[0].trim() || attrOf(body[0], 'message');
        const at = /at line (\d+)/.exec(text);
        c.line = at ? Number(at[1]) : 0;
      }
      cases.push(c);
    }
  }
  const failed = cases.filter((c) => c.status === 'fail').length;
  const skipped = cases.filter((c) => c.status === 'pending' || c.status === 'skipped').length;
  return { counts: { passed: cases.length - failed - skipped, failed, skipped }, cases };
}

/** One line per failing test: `res://f.gd:<line> name - message`. */
export const digestLines = (cases) => cases.filter((c) => c.status === 'fail')
  .map((c) => `${c.file}:${c.line} ${c.name} - ${c.message || 'failed'}`);

/** The n slowest cases as `  1.234 s  res://f.gd name`. */
export const slowest = (cases, n = 10) => [...cases].sort((a, b) => b.time - a.time).slice(0, n)
  .map((c) => `  ${c.time.toFixed(3)} s  ${c.file} ${c.name}`);
