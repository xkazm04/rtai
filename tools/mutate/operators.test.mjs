import assert from 'node:assert/strict';
import { test } from 'node:test';
import { OPS, applyMutant, generateMutants, maskLines, sampleMutants } from './operators.mjs';

const FIXTURE = `class_name Thing
extends RefCounted
## doc: x < y and 5 + 3
const LIMIT: int = 10
const TABLE: Dictionary = {
	"a": 1,
	"b": 2,
}
signal changed(v: int)
@export var speed: float = 2.5

func clamp_it(value: int, lo: int = 3) -> int:
	# comment with a < b and true
	var label: String = "x < y and true # not a comment"
	if value < lo and not _flag:
		value = value + 1
	changed.emit(value)
	Log.info("hi")
	return value * 2

func is_big(v: int) -> bool:
	return v >= LIMIT

func total(v: Vector2) -> float:
	return v.x - 1.0
`;

const find = (ms, op, line) => ms.filter((m) => m.op === op && m.line === line);

test('masking keeps columns and hides strings and comments', () => {
	const [a, b] = maskLines(['var s = "a # b" # tail', 'x = 1 # c']);
	assert.equal(a.length, 'var s = "a # b" # tail'.length);
	assert.ok(!a.includes('#') && !a.includes('a') === false);
	assert.equal(b.trim(), 'x = 1');
});

test('triple-quoted blocks span lines', () => {
	const m = maskLines(['x = """', 'a < b', '"""', 'y < 2']);
	assert.equal(m[1].trim(), '');
	assert.ok(m[3].includes('<'));
});

test('comparison flip and boundary on the if line', () => {
	const ms = generateMutants(FIXTURE);
	assert.deepEqual(find(ms, 'cmp_flip', 15).map((m) => m.lineAfter.trim()),
		['if value >= lo and not _flag:']);
	assert.deepEqual(find(ms, 'boundary', 15).map((m) => m.lineAfter.trim()), ['if value <= lo and not _flag:']);
	assert.equal(find(ms, 'boundary', 22)[0].lineAfter.trim(), 'return v > LIMIT');
	assert.equal(find(ms, 'cmp_flip', 22)[0].lineAfter.trim(), 'return v < LIMIT');
});

test('boolean: and/or and not removal', () => {
	const bs = find(generateMutants(FIXTURE), 'boolean', 15).map((m) => m.lineAfter.trim());
	assert.deepEqual(bs, ['if value < lo or not _flag:', 'if value < lo and _flag:']);
});

test('arithmetic and literal operators', () => {
	const ms = generateMutants(FIXTURE);
	assert.equal(find(ms, 'arith', 16)[0].lineAfter.trim(), 'value = value - 1');
	assert.equal(find(ms, 'literal', 16)[0].lineAfter.trim(), 'value = value + 0');
	assert.equal(find(ms, 'arith', 19)[0].lineAfter.trim(), 'return value / 2');
	assert.equal(find(ms, 'arith', 25)[0].lineAfter.trim(), 'return v.x + 1.0');
	assert.equal(find(ms, 'literal', 19)[0].lineAfter.trim(), 'return value * 3');
	assert.equal(find(ms, 'literal', 25)[0].lineAfter.trim(), 'return v.x - 0.0');
});

test('statement deletion keeps indentation and spares Log and return', () => {
	const ms = generateMutants(FIXTURE);
	assert.equal(find(ms, 'delete', 17)[0].lineAfter, '\tpass');
	assert.equal(find(ms, 'delete', 18).length, 0);
	assert.equal(find(ms, 'delete', 19).length, 0);
});

test('return operator only for bool functions with a boolean expression', () => {
	const ms = generateMutants(FIXTURE);
	assert.equal(find(ms, 'return', 22)[0].lineAfter.trim(), 'return not (v >= LIMIT)');
	assert.equal(find(ms, 'return', 19).length, 0);
	assert.equal(find(ms, 'return', 25).length, 0);
});

test('declarations, comments, strings and docs are untouched', () => {
	const touched = new Set(generateMutants(FIXTURE).map((m) => m.line));
	for (const line of [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14]) assert.ok(!touched.has(line), `line ${line}`);
});

test('unary minus, negative literals and arrows are not arithmetic', () => {
	const ms = generateMutants('func f() -> int:\n\tvar a: int = -1\n\tvar b: int = a -2\n\treturn a\n');
	assert.deepEqual(ms.filter((m) => m.op === 'arith').map((m) => m.line), [3]);
});

test('multi-line signatures and calls: -> bool on the closing line is honoured', () => {
	const src = 'func f(\n\ta: int,\n\tb: int\n) -> bool:\n\treturn a == b\n';
	const ms = generateMutants(src);
	assert.deepEqual(ms.filter((m) => m.op === 'return').map((m) => m.line), [5]);
	assert.ok(ms.every((m) => m.line > 4));
});

test('ops filter and deterministic order and ids', () => {
	const a = generateMutants(FIXTURE);
	const b = generateMutants(FIXTURE);
	assert.deepEqual(a, b);
	assert.deepEqual(a.map((m) => m.id), a.map((_, i) => i + 1));
	const sorted = [...a].sort((x, y) => x.line - y.line || x.col - y.col);
	assert.deepEqual(a.map((m) => `${m.line}:${m.col}`), sorted.map((m) => `${m.line}:${m.col}`));
	assert.ok(generateMutants(FIXTURE, { ops: ['boundary'] }).every((m) => m.op === 'boundary'));
	assert.ok(OPS.every((op) => a.some((m) => m.op === op)), 'fixture exercises every operator');
});

test('applyMutant changes exactly one line; stale lines are refused', () => {
	const m = generateMutants(FIXTURE)[0];
	const out = applyMutant(FIXTURE, m);
	const diff = out.split('\n').filter((l, i) => l !== FIXTURE.split('\n')[i]);
	assert.equal(diff.length, 1);
	assert.throws(() => applyMutant(FIXTURE.replace('value < lo', 'value  < lo'), find(generateMutants(FIXTURE), 'cmp_flip', 15)[0]));
});

test('sampling is deterministic, seeded by the path, source-ordered', () => {
	const all = generateMutants(FIXTURE);
	const s1 = sampleMutants(all, 5, 'core/x.gd');
	assert.deepEqual(s1, sampleMutants(all, 5, 'core/x.gd'));
	assert.equal(s1.length, 5);
	assert.deepEqual(s1.map((m) => m.id), [...s1.map((m) => m.id)].sort((a, b) => a - b));
	assert.notDeepEqual(s1.map((m) => m.id), sampleMutants(all, 5, 'core/other.gd').map((m) => m.id));
	assert.equal(sampleMutants(all, 0, 'x'), all);
});
