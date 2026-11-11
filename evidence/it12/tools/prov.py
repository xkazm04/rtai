"""prov.py <file> <accepted_by> <human_edits> <prompt_ref> <reference>: append one provenance line."""
import hashlib, json, sys
f, acc, edits, ref, refs = sys.argv[1:6]
sha = hashlib.sha256(open(f, "rb").read()).hexdigest()
row = {"accepted_by": acc, "date": "2026-11-11", "file": f, "human_edits": edits,
       "model": "codex-cli built-in image_gen (ChatGPT Pro plan; image model not reported)",
       "prompt_ref": ref, "references": [refs], "seed": None, "sha256": sha, "ships_in": "core.pck", "tool": "codex-image"}
open("steam/ai-provenance/2026-11.jsonl", "a", encoding="utf8", newline="\n").write(json.dumps(row) + "\n")
print(f, sha[:12])
