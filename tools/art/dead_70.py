"""Packs the library's corpses DRAWN for the 70-degree camera (round 20261108-1750, five head
directions x two families) into one 5 x 2 sheet per class under
project/features/characters/art/view/p70/ (dead70_<class>.png): 384 px cells, the pelvis (the guide's
slot centre) at the cell centre, one scale per sheet matched to the class's plan poses, so swapping
pose families does not change a body's size. Rows: 0 face down, 1 on the back. Columns: the head
down, down-right, right, up-right, up. The library is only read.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/dead_70.py [--provenance] [--only=a,b]
"""

import hashlib
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

LIB = Path("C:/Users/kazda/kiro/gtai-art/library")
sys.path.insert(0, str(LIB / "tools"))
from sheetlib import key  # noqa: E402

REPO = Path(__file__).resolve().parents[2]
OUT = REPO / "project/features/characters/art/view/p70"
PLAN = REPO / "project/features/characters/art/view/plan"
PROV = REPO / "steam/ai-provenance/2026-11.jsonl"
ROUND = "20261108-1750"
CLASSES = ["cop_patrol", "ped_suit"]
COLS, ROWS, CELL = 5, 2, 384
ACROSS_COL = 2  # the head right: a body lying across the view, not foreshortened
MIN_BLOB = 30
POSES = 5
GREEN_TEXT = "FLAT SOLID #00B140 chroma-green background"  # library tools/sheet.py BGTXT, for its hash


def long_axis(mask: np.ndarray) -> float:
    ys, xs = np.where(mask)
    pts = np.stack([xs, ys], 1).astype(float)
    pts -= pts.mean(0)
    _, vecs = np.linalg.eigh(np.cov(pts.T))
    span = pts @ vecs[:, 1]
    return float(span.max() - span.min())


def plan_median(name: str) -> float:
    """The class's plan poses' median long axis, in cell px (A-D; E is folded)."""
    strip = np.asarray(Image.open(PLAN / f"dead_{name}.png").convert("RGBA"))
    cells = [strip[:, i * CELL : (i + 1) * CELL, 3] > 128 for i in range(POSES - 1)]
    return float(np.median([long_axis(c) for c in cells]))


def slots_of(alpha: np.ndarray, width: int, height: int) -> tuple[np.ndarray, dict]:
    labels, count = ndimage.label(alpha)
    index = list(range(1, count + 1))
    sizes = ndimage.sum(alpha, labels, index)
    centres = ndimage.center_of_mass(alpha, labels, index)
    slots: dict = {}
    for i in range(count):
        if sizes[i] < MIN_BLOB:
            continue
        row = min(ROWS - 1, int(centres[i][0] // (height / ROWS)))
        col = min(COLS - 1, int(centres[i][1] // (width / COLS)))
        slots.setdefault((row, col), []).append(i + 1)
    assert len(slots) == COLS * ROWS, sorted(slots)
    return labels, slots


def pack(name: str) -> Path:
    """Keys the sheet and lays each body in its cell, pelvis at the centre."""
    source = Image.open(LIB / "rounds" / ROUND / "out" / f"corpse_{name}_70.png").convert("RGB")
    rgba, _ = key(source, "green", 14)
    pixels = np.asarray(rgba).copy()
    labels, slots = slots_of(pixels[..., 3] > 128, rgba.width, rgba.height)
    across = [
        long_axis(np.isin(labels, ids)) for (row, col), ids in slots.items() if col == ACROSS_COL
    ]
    scale = plan_median(name) / float(np.median(across))
    sheet = Image.new("RGBA", (CELL * COLS, CELL * ROWS), (0, 0, 0, 0))
    for (row, col), ids in sorted(slots.items()):
        body = pixels.copy()
        body[~np.isin(labels, ids)] = 0
        y_px, x_px = np.where(body[..., 3] > 0)
        box = (int(x_px.min()), int(y_px.min()), int(x_px.max()) + 1, int(y_px.max()) + 1)
        cut = Image.fromarray(body).crop(box)
        slot_x = (col + 0.5) * rgba.width / COLS
        slot_y = (row + 0.5) * rgba.height / ROWS
        size = (max(1, round(cut.width * scale)), max(1, round(cut.height * scale)))
        cut = cut.resize(size, Image.LANCZOS)
        left = round(CELL / 2 + (box[0] - slot_x) * scale)
        top = round(CELL / 2 + (box[1] - slot_y) * scale)
        assert left >= 0 and top >= 0, (name, row, col, left, top)
        assert left + size[0] <= CELL and top + size[1] <= CELL, (name, row, col, left, top, size)
        sheet.paste(cut, (col * CELL + left, row * CELL + top))
    path = OUT / f"dead70_{name}.png"
    sheet.save(path, optimize=True)
    print(f"{path.relative_to(REPO).as_posix()} scale {scale:.3f}")
    return path


def provenance(path: Path, name: str, jobs: dict) -> str:
    job = next(j for j in jobs["jobs"] if j["name"] == f"corpse_{name}_70")
    style = jobs.get("style", "").replace("{BG}", GREEN_TEXT)
    row = {
        "accepted_by": "agent:n10-world lane (the owner's note on the dead, brief item 3)",
        "date": "2026-11-09",
        "file": path.relative_to(REPO).as_posix(),
        "human_edits": "keyed and packed from the sheet by tools/art/dead_70.py, one resize",
        "model": f"Codex image round {ROUND}",
        "prompt_hash": hashlib.sha1((job["prompt"] + "\n\n" + style).encode("utf8")).hexdigest()[:12],
        "round": ROUND,
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
    }
    return json.dumps(row, sort_keys=True)


def main() -> None:
    only = [a.split("=", 1)[1].split(",") for a in sys.argv if a.startswith("--only=")]
    jobs = json.loads((LIB / "rounds" / ROUND / "jobs.json").read_text(encoding="utf-8"))
    lines = [
        provenance(pack(name), name, jobs) for name in CLASSES if not only or name in only[0]
    ]
    if "--provenance" in sys.argv:
        with PROV.open("a", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
