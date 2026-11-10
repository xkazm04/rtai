import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join, parse, resolve } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { errorLines, toRes } from './check.mjs';

// Pure-function probes only: importing check.mjs does not invoke its CLI or checkAll.
const project = fileURLToPath(new URL('../../project/', import.meta.url));
const autoloads = new Set(['Log', 'LaunchArgs', 'Events']);
const noise = (name = 'Log') => `SCRIPT ERROR: Compile Error: Identifier not found: ${name}`;
const frame = '   at: GDScript::reload (res://probe.gd:7)';
const cascades = [
  'SCRIPT ERROR: Compile Error: Failed to compile depended scripts.',
  frame,
  'ERROR: Failed to load script "res://probe.gd" with error "Compilation failed".',
  '   at: load (modules/gdscript/gdscript_resource_format.cpp:46)',
];

// Compare membership and multiplicity, without prescribing diagnostic order or trailing whitespace.
function expectLines(out, expected, names = autoloads) {
  assert.deepEqual(errorLines(out, names).map((line) => line.trimEnd()).sort(),
    expected.map((line) => line.trimEnd()).sort());
}

for (const out of ['', '\n\r\n  \n', 'Godot Engine v4.7.2\nImport complete\n']) {
  test(`promise 4: empty or diagnostic-free output returns [] (${JSON.stringify(out)})`, () => {
    expectLines(out, []);
  });
}

for (const name of autoloads) {
  for (const ending of ['\n', '\r\n']) {
    test(`promise 1: exact autoload ${name} and directly attached frames disappear with ${JSON.stringify(ending)}`, () => {
      expectLines([noise(name) + '  ', frame, '\tat: caller (res://caller.gd:8)', ''].join(ending), []);
    });
  }
}

test('promise 1: default autoload names come from project.godot', () => {
  const config = readFileSync(join(project, 'project.godot'), 'utf8');
  const section = config.split('[autoload]')[1].split(/^\[/m)[0];
  const names = [...section.matchAll(/^(\w+)=/gm)].map((match) => match[1]);
  assert.ok(names.length > 0);
  for (const name of names) assert.deepEqual(errorLines(`${noise(name)}\n${frame}`), []);
});

for (const name of ['Logger', 'Log2', 'Log_extra', 'MyLog', 'CatalogLog', 'log', 'LOG', 'Launchargs', 'Logé']) {
  test(`promise 1: non-exact autoload identifier ${name} remains a real error`, () => {
    expectLines([noise(name), frame].join('\n'), [noise(name), frame]);
  });
}

test('promise 1: an empty autoload set cannot suppress identifiers or their frames', () => {
  expectLines([noise(), frame, ...cascades].join('\n'), [noise(), frame, ...cascades], new Set());
});

for (const separator of ['', 'ordinary progress message']) {
  // Review (05:2x): an `at:` line is context and never decides the verdict, so only the errors are asserted.
  test(`promise 1: a real error after noise and ${JSON.stringify(separator)} is kept`, () => {
    const real = 'ERROR: A different resource is corrupt';
    const got = errorLines([noise(), separator, frame, real].join('\n'), autoloads);
    assert.deepEqual(got.filter((l) => !/^\s+at: /.test(l)), [real]);
  });
}

test('promise 1: only the directly attached frames disappear when noise repeats', () => {
  const real = 'SCRIPT ERROR: Parse Error: Unknown type MissingType';
  expectLines([noise(), frame, real, frame, noise('Events'), frame].join('\n'), [real, frame]);
});

test('promise 2: cascades with an unseen cause and no autoload noise keep every diagnostic', () => {
  expectLines(cascades.join('\n'), cascades);
});

for (const position of [0, 2, 4]) {
  test(`promise 2: autoload-only runs excuse cascades even when noise is at position ${position}`, () => {
    const out = [...cascades];
    out.splice(position, 0, noise(), frame);
    expectLines(out.join('\r\n'), []);
  });
}

test('promise 2: noise from a previous call cannot excuse the next run cascade', () => {
  expectLines([noise(), ...cascades].join('\n'), []);
  expectLines(cascades.join('\n'), cascades);
});

const realErrors = [
  'SCRIPT ERROR: Invalid call to missing method',
  'Parse Error: Expected end of statement',
  'Compile Error: Unknown type MissingType',
  'Failed to load resource res://missing.png',
  'ERROR: Cannot open res://missing.tscn',
  noise('Logger'),
];
for (const real of realErrors) {
  for (const position of ['before', 'between', 'after']) {
    test(`promise 3: ${real} survives ${position} noise, CRLF, spaces, and an unterminated last line`, () => {
      const parts = {
        before: [real, noise(), frame, noise('Events'), frame, ...cascades],
        between: [noise(), frame, real, noise('Events'), frame, ...cascades],
        after: [noise(), frame, noise('Events'), frame, ...cascades, real],
      }[position];
      // The real diagnostic deliberately has no associated at: line.
      expectLines(parts.map((line) => line + ' \t').join('\r\n'), [real, ...cascades]);
    });
  }
}

test('promise 3: a noise-free run keeps each recognized diagnostic and duplicate frame', () => {
  const expected = [...realErrors, frame, frame, '\tat: another_frame (res://other.gd:9)'];
  expectLines(['Godot Engine v4.7.2', ...expected, 'Done'].join('\n'), expected);
});

for (const phrase of ['Failed to load script', 'Failed to compile depended scripts']) {
  test(`promise 2: a real parse error quoting ${JSON.stringify(phrase)} is not a cascade`, () => {
    const real = `SCRIPT ERROR: Parse Error: Unexpected string literal "${phrase}"`;
    expectLines([noise(), frame, real, frame, ...cascades].join('\n'), [real, frame, ...cascades]);
  });
}

for (const res of ['res://boot/main.tscn', 'res://features/a folder/probe.gd']) {
  test(`promise 5: resource spelling ${res} is unchanged`, () => assert.equal(toRes(res), res));
}

for (const path of ['boot/main.tscn', 'features/a folder/probe.gd', '..hidden/probe.gd']) {
  test(`promise 5: project-relative path ${path} maps inside res://`, () => {
    assert.equal(toRes(path), `res://${path}`);
  });
  test(`promise 5: absolute path inside project/${path} maps inside res://`, () => {
    assert.equal(toRes(join(project, path)), `res://${path}`);
  });
}

test('promise 5: internal dot segments normalize without rejecting an inside path', () => {
  assert.equal(toRes(join(project, 'features', '..', 'boot', 'main.tscn')), 'res://boot/main.tscn');
  assert.equal(toRes('features/../boot/main.tscn'), 'res://boot/main.tscn');
});

for (const outside of [
  resolve(project, '..', 'project_backup', 'probe.gd'),
  resolve(project, '..', 'projectile', 'probe.gd'),
  resolve(project, '..', 'tools', 'probe.gd'),
  '../outside_probe.gd',
  'features/../../outside_probe.gd',
]) {
  test(`promise 5: outside path ${outside} is rejected`, () => assert.equal(toRes(outside), null));
}

test('promise 5: an absolute path on another drive is rejected', { skip: process.platform !== 'win32' }, () => {
  const drive = parse(project).root.slice(0, 1).toUpperCase() === 'Z' ? 'Y' : 'Z';
  assert.equal(toRes(`${drive}:\\project\\probe.gd`), null);
});
