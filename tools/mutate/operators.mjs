// Mutation operators on GDScript source lines. Pure: no file access, no RNG, no clock.
//   generateMutants(source, {ops}) -> [{id, line, col, op, before, after, lineBefore, lineAfter}] in source order.
// Every mutant is ONE change on ONE line. Comments, strings (incl. """ blocks) and ## docs are masked
// before any operator looks at the line, so they can never be touched.
//
// Choices (documented in README):
//  - skipped lines: const / enum / signal / class / func declarations, @export* and other annotation
//    lines, extends / class_name, and any continuation lines of those (balanced-bracket tracking).
//    Tables and signatures are data, not logic; mutating them is noise.
//  - statement deletion only for a balanced single-line call statement at bracket depth 0; never
//    Log./print/push_*/assert (their removal is always an equivalent mutant).
//  - the return operator only inside functions declared `-> bool`, only for an obviously boolean
//    expression (comparison / and / or / not / in / is at top level), so `not (X)` is type-safe.
//  - arithmetic only where the operator is binary (an operand char precedes it); string literals are
//    masked, so `"a" + b` is never mutated.
//  - lines under @warning_ignore are mutated like any other line (a mutant that trips a warning is
//    reported "invalid", not hidden).

export const OPS = ['cmp_flip', 'boundary', 'arith', 'literal', 'boolean', 'delete', 'return'];

const SKIP_HEAD = /^(?:static\s+func\b|func\b|const\b|enum\b|signal\b|class\b|class_name\b|extends\b|@)/;
const RET_BOOL = /->\s*bool\b/;
const FUNC_HEAD =/^(?:static\s+)?func\b/;
const NEVER_DELETE = /^(?:Log\.|print|push_|assert|breakpoint|return\b|var\b|const\b|if\b|elif\b|else\b|for\b|while\b|match\b|pass\b|break\b|continue\b|await\b|super\b)/;
const BRACKETS = { '(': 1, '[': 1, '{': 1, ')': -1, ']': -1, '}': -1 };

/** Masks strings and comments with spaces (same length, same columns); """ blocks span lines. */
export function maskLines(lines) {
  let block = null; // the open triple-quote delimiter
  return lines.map((raw) => {
    let out = '';
    let i = 0;
    while (i < raw.length) {
      const c = raw[i];
      if (block) {
        if (raw.startsWith(block, i)) { out += '   '; i += 3; block = null; } else { out += ' '; i += 1; }
      } else if (c === '#') {
        out += ' '.repeat(raw.length - i);
        break;
      } else if (c === '"' || c === "'") {
        if (raw.startsWith(c.repeat(3), i)) { block = c.repeat(3); out += '   '; i += 3; continue; }
        let j = i + 1;
        while (j < raw.length && raw[j] !== c) j += raw[j] === '\\' ? 2 : 1;
        out += c + ' '.repeat(Math.max(0, Math.min(j, raw.length) - i - 1)) + (j < raw.length ? c : '');
        i = j + 1;
      } else { out += c; i += 1; }
    }
    return out.slice(0, raw.length).padEnd(raw.length, ' ');
  });
}

const depthDelta = (m) => [...m].reduce((d, ch) => d + (BRACKETS[ch] ?? 0), 0);

/** Per line: {skip, startDepth, endDepth, retBool}. */
function classify(masked) {
  let depth = 0;
  let inDecl = false; // inside a skipped declaration's brackets
  let declIsFunc = false;
  let retBool = false;
  return masked.map((m) => {
    const t = m.trim();
    const startDepth = depth;
    const head = t.length > 0 && depth === 0 && SKIP_HEAD.test(t);
    const skip = t === '' || head || inDecl;
    if (head) declIsFunc = FUNC_HEAD.test(t);
    if (head && declIsFunc) retBool = false;
    depth = Math.max(0, depth + depthDelta(m));
    if (head && depth > 0) inDecl = true;
    if (declIsFunc && (head || inDecl) && RET_BOOL.test(t)) retBool = true;
    if (inDecl && depth === 0) inDecl = false;
    if (!inDecl) declIsFunc = false;
    return { skip, startDepth, endDepth: depth, retBool };
  });
}

const NUM = /(?<![\w.$%&^@])(\d+\.\d*|\.\d+|\d+)(e[+-]?\d+)?(?![\w.])/gi;
const CMP = /(?<![<>=!\-])(<=|>=|==|!=|<|>)(?![<>=])/g;
const FLIP = { '<': '>=', '>': '<=', '<=': '>', '>=': '<', '==': '!=', '!=': '==' };
const EDGE = { '<': '<=', '>': '>=', '<=': '<', '>=': '>' };
const ARITH = /(\+=|-=|\*=|\/=|(?<![+\-*/=<>!])[+\-*/](?![+\-*/=>]))/g;
const ARITH_SWAP = { '+': '-', '-': '+', '*': '/', '/': '*', '+=': '-=', '-=': '+=', '*=': '/=', '/=': '*=' };

/** n -> n+1, 1 -> 0 (ints and floats; keeps the decimals). null = leave the literal alone. */
function bump(text, exponent) {
  if (exponent || text.endsWith('.')) return null;
  if (text.includes('.')) {
    const n = Number(text);
    return (n === 1 ? 0 : n + 1).toFixed(text.split('.')[1].length);
  }
  return text === '1' ? '0' : String(Number(text) + 1);
}

const isOperandBefore = (m, idx) => /[\w)\]]/.test(m.slice(0, idx).trimEnd().slice(-1) || ' ');

/** Candidate [{op, col, len, to}] for one masked line. */
function lineCandidates(m, info) {
  const out = [];
  const add = (op, col, len, to) => out.push({ op, col, len, to });
  for (const x of m.matchAll(CMP)) {
    add('cmp_flip', x.index, x[1].length, FLIP[x[1]]);
    if (EDGE[x[1]]) add('boundary', x.index, x[1].length, EDGE[x[1]]);
  }
  for (const x of m.matchAll(ARITH)) {
    const sym = x[1];
    if (sym.length === 1 && !isOperandBefore(m, x.index)) continue; // unary sign
    if (sym === '/' && /\$[\w/.%]*$/.test(m.slice(0, x.index))) continue; // $Node/Path
    add('arith', x.index, sym.length, ARITH_SWAP[sym]);
  }
  for (const x of m.matchAll(NUM)) {
    const to = bump(x[1], x[2]);
    if (to !== null) add('literal', x.index, x[1].length + (x[2]?.length ?? 0), to);
  }
  for (const x of m.matchAll(/\b(true|false)\b/g)) add('boolean', x.index, x[1].length, x[1] === 'true' ? 'false' : 'true');
  for (const x of m.matchAll(/\bnot\s+/g)) add('boolean', x.index, x[0].length, '');
  for (const x of m.matchAll(/(?<![!=<>])!(?!=)/g)) add('boolean', x.index, 1, '');
  for (const x of m.matchAll(/\b(and|or)\b/g)) add('boolean', x.index, x[1].length, x[1] === 'and' ? 'or' : 'and');
  return out.concat(stmtCandidates(m, info));
}

function stmtCandidates(m, info) {
  const out = [];
  const t = m.trim();
  const col = m.length - m.trimStart().length;
  if (info.startDepth === 0 && info.endDepth === 0 && /^[A-Za-z_][\w.]*\s*\(.*\)$/.test(t) && !NEVER_DELETE.test(t)) {
    out.push({ op: 'delete', col, len: t.length, to: 'pass' });
  }
  const r = /^return\s+(.+)$/.exec(t);
  if (r && info.retBool && info.startDepth === 0 && info.endDepth === 0 && boolish(r[1])) {
    out.push({ op: 'return', col: col + 7, len: r[1].length, to: `not (${r[1]})` });
  }
  return out;
}

/** True for an obviously boolean top-level expression that is not a bare literal or a ternary. */
function boolish(x) {
  if (/^(true|false)$/.test(x) || /\bif\b.*\belse\b/.test(x) || /\bfunc\b/.test(x)) return false;
  let d = 0;
  let top = '';
  for (const ch of x) {
    if (ch in BRACKETS) { d += BRACKETS[ch]; top += ' '; } else top += d === 0 ? ch : ' ';
  }
  return /^\s*not\b/.test(top) || /==|!=|<=|>=|(?<![<>-])[<>](?![<>])|\b(?:and|or|in|is)\b/.test(top);
}

/** All mutants of `source` in source order (line, then column, then OPS order). */
export function generateMutants(source, { ops = OPS } = {}) {
  const lines = source.split('\n');
  const masked = maskLines(lines);
  const info = classify(masked);
  const found = [];
  const seen = new Set();
  masked.forEach((m, i) => {
    if (info[i].skip) return;
    const cands = lineCandidates(m, info[i]).filter((c) => ops.includes(c.op))
      .sort((a, b) => a.col - b.col || OPS.indexOf(a.op) - OPS.indexOf(b.op));
    for (const c of cands) {
      const raw = lines[i];
      const del = c.op === 'delete';
      const after = del ? `${raw.slice(0, c.col)}pass${raw.endsWith('\r') ? '\r' : ''}`
        : raw.slice(0, c.col) + c.to + raw.slice(c.col + c.len);
      const key = `${i}:${after}`;
      if (after === raw || seen.has(key)) continue;
      seen.add(key);
      found.push({ line: i + 1, col: c.col + 1, op: c.op, before: del ? raw.trim() : raw.slice(c.col, c.col + c.len),
        after: c.to, lineBefore: raw, lineAfter: after });
    }
  });
  return found.map((f, n) => ({ id: n + 1, ...f }));
}

/** The mutated source text for one mutant (replaces exactly its line). */
export function applyMutant(source, mutant) {
  const lines = source.split('\n');
  if (lines[mutant.line - 1] !== mutant.lineBefore) throw new Error(`mutant ${mutant.id}: line ${mutant.line} changed`);
  lines[mutant.line - 1] = mutant.lineAfter;
  return lines.join('\n');
}

/** Deterministic sample of `max` mutants (source order kept), seeded by `seedText` (the file path). */
export function sampleMutants(mutants, max, seedText) {
  if (!max || max >= mutants.length) return mutants;
  let h = 2166136261;
  for (const ch of seedText) h = Math.imul(h ^ ch.charCodeAt(0), 16777619) >>> 0;
  const rnd = () => { // mulberry32
    h = (h + 0x6D2B79F5) >>> 0;
    let t = h;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  const idx = mutants.map((_, i) => i);
  for (let i = idx.length - 1; i > 0; i--) {
    const j = Math.floor(rnd() * (i + 1));
    [idx[i], idx[j]] = [idx[j], idx[i]];
  }
  return idx.slice(0, max).sort((a, b) => a - b).map((i) => mutants[i]);
}
