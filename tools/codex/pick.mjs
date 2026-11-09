// Chooses what the Codex test factory may work on: pure rule modules with no test yet. The pilot's
// record (pof research/codex-engine-plan.md) is the rule: pure logic with clear rules scored well, a
// generator with tuned tables scored 86.7 % by copying its constants and was rejected. Every module
// this refuses gets the reason, because a heuristic you cannot question is one you stop believing.
const SCENE = /\b(get_tree|get_node|add_child|Engine\.|OS\.|FileAccess|DirAccess|ResourceLoader|RenderingServer|Texture2D|Sprite2D|Image\.|Node2D|CanvasLayer|SceneTree)\b|\b(load|preload)\(/;
const GENERATOR = /RandomNumberGenerator|\.stream\(|\bctx\.rng\b/;
const DRAWING = /\bdraw_[a-z_]+\(|\bColor\(|Polygon2D|Line2D|\bArrayMesh\b/;
const NUMERIC_CONST = /^const\s+\w+\s*(?::[^=]+)?=\s*-?\d/gm;
/** More numeric constants than this reads as a tuned table, not a rule. */
export const MAX_TUNED_CONSTS = 8;
export const MIN_LINES = 30;
export const MAX_LINES = 200;

const code = (text) => text.split('\n').map((l) => l.replace(/#.*$/, '')).join('\n');

/** Why `path` must not go to Codex, or null when it may. text: the file; tests: test file texts. */
export function refusal(path, text, tests) {
  if (!/^project\/(features|core)\//.test(path)) return 'only features/ and core/ are in scope';
  if (/\/(gen|generated)\/|generator|_tables?\.gd$/.test(path)) return 'a generator or table: tests pin its numbers (keep with Claude)';
  const body = code(text);
  const lines = text.split('\n').length;
  if (lines < MIN_LINES) return `too small (${lines} lines)`;
  if (lines > MAX_LINES) return `too big (${lines} lines)`;
  if (!/^extends\s+RefCounted\b/m.test(body)) return 'not a RefCounted logic class';
  const cls = /^class_name\s+(\w+)/m.exec(body)?.[1];
  if (!cls) return 'no class_name, a test cannot name it';
  const scene = SCENE.exec(body);
  if (scene) return `not pure: touches ${scene[0]}`;
  if (GENERATOR.test(body)) return 'draws random numbers: a generator (keep with Claude)';
  if (/_(art|glyph|mesh)\.gd$/.test(path) || DRAWING.test(body)) return 'drawing code: what it should do is how it looks (keep with Claude)';
  const tuned = (body.match(NUMERIC_CONST) ?? []).length;
  if (tuned > MAX_TUNED_CONSTS) return `tuned table: ${tuned} numeric constants (keep with Claude)`;
  const named = new RegExp(`\\b${cls}\\b`);
  if (tests.some((t) => named.test(t))) return `already tested (a test names ${cls})`;
  if (!/^(static )?func \w+/m.test(body)) return 'no functions to test';
  return null;
}

/** [{path, cls, lines, funcs}] may-go, and [{path, why}] refused; sorted by path so a run repeats. */
export function pick(files, tests) {
  const ok = [];
  const no = [];
  for (const { path, text } of [...files].sort((a, b) => (a.path < b.path ? -1 : 1))) {
    const why = refusal(path, text, tests);
    if (why) { no.push({ path, why }); continue; }
    ok.push({ path, cls: /^class_name\s+(\w+)/m.exec(text)[1], lines: text.split('\n').length,
      funcs: (text.match(/^(static )?func /gm) ?? []).length, stem: path.split('/').pop().replace(/\.gd$/, '') });
  }
  return { ok, no };
}
