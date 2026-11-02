// The pof.godot-evidence/1 envelope (spark gtai-phase-2, Data & API). Optional keys are
// omitted, never null; every envelope is validated against evidence.schema.json before writing.
import { join } from 'node:path';
import { validate } from '../lib/mini_schema.mjs';
import { ROOT, readJson } from '../lib/repo.mjs';

export const SCHEMA = 'pof.godot-evidence/1';
export const GAME_ID = 'gtai';
const evidenceSchema = readJson(join(ROOT, 'tools', 'evidence', 'evidence.schema.json'));

export function makeEnvelope({ kind, commit, godotVersion, ok, summary, counts, metrics, artifacts }) {
  const env = {
    schema: SCHEMA,
    kind,
    gameId: GAME_ID,
    commit,
    builtAt: new Date().toISOString(),
    godotVersion,
    status: ok ? 'pass' : 'fail',
    summary,
  };
  if (counts) env.counts = counts;
  if (metrics && Object.keys(metrics).length) env.metrics = metrics;
  if (artifacts && artifacts.length) env.artifacts = artifacts;
  const errors = validate(evidenceSchema, env);
  if (errors.length) throw new Error(`evidence envelope invalid: ${errors.join('; ')}`);
  return env;
}
