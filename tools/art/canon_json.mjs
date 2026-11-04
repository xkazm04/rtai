// Rewrites JSON files in the repo's canonical form (lint json-canonical): node tools/art/canon_json.mjs <file>...
import { readFileSync, writeFileSync } from 'node:fs';
import { canonicalJson } from '../lib/canonical_json.mjs';

for (const f of process.argv.slice(2)) writeFileSync(f, canonicalJson(JSON.parse(readFileSync(f, 'utf8'))));
