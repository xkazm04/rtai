"""Silhouette heights from project/dev/cast/cast_size_beside.gd (brief n29-cast-01).

For each shot in <dir>/shots.json: mask = pixels that change between <tag>_body.png (shadow hidden,
everyone standing) and <tag>_gone_<who>.png (that figure parked), inside a column band around the
figure's screen point. Height = top mask row to lowest mask row (screen px, shadow excluded because
the shadow layer is hidden in both shots). Rows are kept only as one run (gaps <= GAP rows), the run
with the most changed pixels, so stray diffs elsewhere in the band do not count.

usage: python tools/art/cast_size_measure.py <dir> [--crops] [--json=<out>] [--contact=<stem>]
--contact writes <stem>_64.png and <stem>_32.png: 1920x1080, 3x3 tiles (patrol_only first, then each
foe beside the cop and Rivet, shadow on), 1:1 at 64 px/m and 2x nearest at 32 px/m, labelled.
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

THRESHOLD = 40
MIN_ROW_PX = 2
GAP = 3
HALF_BAND_M = 1.5
LINEUP_HALF_BAND_M = 3.0
SHADOW_RATIO = (0.3, 0.95)
SHADOW_SPREAD = 0.12


def load(path: Path) -> np.ndarray:
    return np.asarray(Image.open(path).convert("RGB"), dtype=np.int16)


def changed(body: np.ndarray, gone: np.ndarray, ground: int) -> np.ndarray:
    """Changed pixels minus a robot's own ground shadow (the rig shadow layer is hidden already):
    an even darkening of the street (every channel scaled by the same SHADOW_RATIO factor), only at
    or below the ground row, so dark boots and armour above it stay in. Outline ink is darker."""
    moved = np.abs(body - gone).max(axis=2) > THRESHOLD
    ratio = (body.astype(np.float32) + 1.0) / (gone.astype(np.float32) + 1.0)
    even = (ratio.max(axis=2) - ratio.min(axis=2)) < SHADOW_SPREAD
    mean = ratio.mean(axis=2)
    shadow = even & (mean > SHADOW_RATIO[0]) & (mean < SHADOW_RATIO[1])
    shadow[:ground] = False
    return moved & ~shadow


def band_of(shot: dict) -> tuple[int, int]:
    half = (LINEUP_HALF_BAND_M if shot["tag"].startswith("lineup_") else HALF_BAND_M) * shot["ppm"]
    x = shot["x"]
    return int(round(x - half)), int(round(x + half))


def rows_run(counts: np.ndarray) -> tuple[int, int] | None:
    """The run of active rows (gaps <= GAP) holding the most changed pixels: the figure."""
    idx = np.flatnonzero(counts >= MIN_ROW_PX)
    if idx.size == 0:
        return None
    runs = []
    start = prev = idx[0]
    for r in idx[1:]:
        if r - prev > GAP + 1:
            runs.append((start, prev))
            start = r
        prev = r
    runs.append((start, prev))
    return max(runs, key=lambda ab: int(counts[ab[0] : ab[1] + 1].sum()))


def measure(folder: Path, shot: dict) -> dict:
    body = load(folder / f"{shot['tag']}_body.png")
    gone = load(folder / f"{shot['tag']}_gone_{shot['who']}.png")
    x0, x1 = band_of(shot)
    x0, x1 = max(0, x0), min(body.shape[1], x1)
    diff = changed(body[:, x0:x1], gone[:, x0:x1], int(round(shot["y"])))
    run = rows_run(diff.sum(axis=1))
    if run is None:
        return {**shot, "height": None}
    top, bottom = run
    cols = np.flatnonzero(diff[top : bottom + 1].any(axis=0))
    edge = bool(cols.size and (cols[0] == 0 or cols[-1] == x1 - x0 - 1))
    return {
        **shot,
        "height": int(bottom - top + 1),
        "top": int(top),
        "bottom": int(bottom),
        "left": int(x0 + cols[0]) if cols.size else None,
        "right": int(x0 + cols[-1]) if cols.size else None,
        "touches_band_edge": edge,
    }


def crop(folder: Path, row: dict) -> None:
    img = Image.open(folder / f"{row['tag']}_body.png").convert("RGB")
    pad = 12
    box = (row["left"] - pad, row["top"] - pad, row["right"] + pad, row["bottom"] + pad)
    out = img.crop(box).resize(((box[2] - box[0]) * 3, (box[3] - box[1]) * 3), Image.NEAREST)
    out.save(folder / f"crop_{row['tag']}_{row['who']}.png")


def contact(folder: Path, rows: list[dict], stem: str) -> None:
    from PIL import ImageDraw

    tags = [r["tag"] for r in rows if r["who"] != "rivet" and not r["tag"].startswith("lineup_")]
    for ppm in (64, 32):
        sheet = Image.new("RGB", (1920, 1080), "white")
        draw = ImageDraw.Draw(sheet)
        mine = [t for t in tags if t.endswith(f"_{ppm}")]
        for i, tag in enumerate(mine[:9]):
            img = Image.open(folder / f"{tag}.png").convert("RGB")
            box = (640, 300, 1280, 660) if ppm == 64 else (800, 450, 1120, 630)
            tile = img.crop(box).resize((640, 360), Image.NEAREST)
            sheet.paste(tile, ((i % 3) * 640, (i // 3) * 360))
            text = " ".join(f"{r['who']} {r['height']}px" for r in rows if r["tag"] == tag)
            draw.rectangle(((i % 3) * 640, (i // 3) * 360, (i % 3) * 640 + 639, (i // 3) * 360 + 18), "black")
            draw.text(((i % 3) * 640 + 4, (i // 3) * 360 + 3), f"{tag}: {text}", fill="white")
        sheet.save(f"{stem}_{ppm}.png")


def main(argv: list[str]) -> int:
    if not argv:
        print(__doc__)
        return 2
    folder = Path(argv[0])
    shots = json.loads((folder / "shots.json").read_text(encoding="utf8"))["shots"]
    rows = [measure(folder, s) for s in shots]
    for row in rows:
        flag = " BAND-EDGE" if row.get("touches_band_edge") else ""
        print(f"{row['tag']:28s} {row['who']:18s} h={row['height']} rows {row.get('top')}-{row.get('bottom')}"
              f" cols {row.get('left')}-{row.get('right')} rig={row['full_rig']} card={row['far_card']}{flag}")
        if "--crops" in argv and row["height"]:
            crop(folder, row)
    stem = next((a.split("=", 1)[1] for a in argv if a.startswith("--contact=")), None)
    if stem:
        contact(folder, rows, stem)
    out = next((a.split("=", 1)[1] for a in argv if a.startswith("--json=")), None)
    if out:
        Path(out).write_text(json.dumps(rows, indent=2), encoding="utf8")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
