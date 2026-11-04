"""Append AI-provenance rows for weapon art files (weapon-art lane, 2026-11-04).

    python tools/art/weapon_provenance.py <sheet_ref> <human_edits> <file> [<file> ...]

One row per file in steam/ai-provenance/2026-11.jsonl with its sha256. A file that already has a
row with the same sha256 is skipped, so a re-run is a no-op. `sheet_ref` names the master sheet
and its prompt under gtai-masters/n4/weapon-art/raw/.
"""

import hashlib
import json
import sys
from pathlib import Path

LOG = Path("steam/ai-provenance/2026-11.jsonl")


def main(sheet_ref, edits, files):
    have = set()
    for line in LOG.read_text(encoding="utf-8").splitlines():
        if line.strip():
            r = json.loads(line)
            have.add((r.get("file"), r.get("sha256")))
    rows = []
    for f in files:
        sha = hashlib.sha256(Path(f).read_bytes()).hexdigest()
        rel = f.replace("\\", "/")
        if (rel, sha) in have:
            continue
        rows.append({
            "accepted_by": "agent:weapon-art-lane (owner review pending)",
            "date": "2026-11-04",
            "file": rel,
            "human_edits": edits,
            "model": "gpt-image (Codex CLI built-in image_gen; tier not reported)",
            "prompt_ref": f"masters:n4/weapon-art/raw/{sheet_ref}",
            "references": ["pof:games/gtai/art-direction/trivet/ref-4-rivet-concept.jpg",
                           "project/features/characters/art/d5/cop/forearm_pistol.png"],
            "seed": None,
            "sha256": sha,
            "ships_in": "core.pck",
            "tool": "codex-cli exec image_gen (plan-billed, chatgpt-pro-image-route.md section 8)",
        })
    with LOG.open("ab") as fh:
        for r in rows:
            fh.write((json.dumps(r, sort_keys=True) + "\n").encode())
    print(f"appended {len(rows)} rows")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3:])
