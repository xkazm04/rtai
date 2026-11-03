// Rewrites the given JSON files in the repo's canonical form (DAT-02). Usage: node tools/audio/canon.mjs <file>...
import { readFileSync, writeFileSync } from 'node:fs';
import { canonicalJson } from '../lib/canonical_json.mjs';
for (const f of process.argv.slice(2)) writeFileSync(f, canonicalJson(JSON.parse(readFileSync(f, 'utf8'))));
