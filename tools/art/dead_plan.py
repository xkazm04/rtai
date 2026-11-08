"""Packs the library's dead_plan_v1 cells (5 plan-view lying poses A-E per body class, 384 px cells,
the pelvis at the cell centre, the still strip's 192 px standing height) into one 1920 x 384 strip per
class under project/features/characters/art/view/plan/, and appends the provenance lines.

    python tools/art/dead_plan.py [--provenance]
"""

import hashlib
import json
import sys
from pathlib import Path

from PIL import Image

LIB = Path("C:/Users/kazda/kiro/gtai-art/library")
REPO = Path(__file__).resolve().parents[2]
OUT = REPO / "project/features/characters/art/view/plan"
PROV = REPO / "steam/ai-provenance/2026-11.jsonl"
POSES = "ABCDE"
CELL = 384
# class -> (keyed folder, catalog ids whose round/prompt_hash made the cells)
CLASSES = {
    "ped_suit": ("street", ["dead_plan_v1_ped_suit", "dead_plan_v1_ped_suit_e2"]),
    "ped_worker": ("street", ["dead_plan_v1_ped_worker", "dead_plan_v1_ped_worker_e2"]),
    "ped_hood": ("street", ["dead_plan_v1_ped_hood", "dead_plan_v1_ped_hood_e2"]),
    "ped_shopper": ("street", ["dead_plan_v1_ped_shopper", "dead_plan_v1_ped_shopper_e2"]),
    "cop_patrol": ("street", ["dead_plan_v1_cop_patrol"]),
    "cop_riot": ("street", ["dead_plan_v1_cop_riot"]),
    "swat": ("street", ["dead_plan_v1_swat"]),
    "thug": ("street", ["dead_plan_v1_thug"]),
}


def pack(name: str, folder: str) -> Path:
    strip = Image.new("RGBA", (CELL * len(POSES), CELL), (0, 0, 0, 0))
    cells = LIB / "keyed" / folder / f"dead_plan_v1_{name}_cells"
    for i, pose in enumerate(POSES):
        cell = Image.open(cells / f"{pose}.png").convert("RGBA")
        assert cell.size == (CELL, CELL), (name, pose, cell.size)
        strip.paste(cell, (i * CELL, 0))
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"dead_{name}.png"
    strip.save(path, optimize=True)
    return path


def provenance(path: Path, ids: list[str], catalog: dict) -> dict:
    rows = [catalog[i] for i in ids]
    refs = [f"gtai-art/library/catalog.json {r['id']} round {r['round']} grade {r.get('grade')}" for r in rows]
    hashes = "; ".join(f"rounds/{r['round']}/jobs.json prompt_hash {r['prompt_hash']} {r['id']}" for r in rows)
    return {
        "accepted_by": "agent:n9-world lane (the owner's verdict on the dead, 2026-11-07; REQUEST dead_plan_v1)",
        "date": "2026-11-08",
        "file": path.relative_to(REPO).as_posix(),
        "human_edits": "n9 world it4 packed the library's cut cells (deliveries/dead_plan_v1_it121.md, "
        "tools/dead_plan_cut.py keyed + one scale per sheet) A-E into one strip, no resample (tools/art/dead_plan.py)",
        "model": "codex-cli built-in image_gen (ChatGPT Pro plan; image model not reported)",
        "prompt_ref": "gtai-art/library/" + hashes,
        "references": refs,
        "seed": None,
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "ships_in": "core.pck",
        "tool": "codex-image",
    }


def main() -> None:
    catalog = {r["id"]: r for r in json.loads((LIB / "catalog.json").read_text(encoding="utf-8"))}
    lines = []
    for name, (folder, ids) in CLASSES.items():
        path = pack(name, folder)
        lines.append(json.dumps(provenance(path, ids, catalog), sort_keys=True))
        print(path.relative_to(REPO).as_posix())
    if "--provenance" in sys.argv:
        with PROV.open("a", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
