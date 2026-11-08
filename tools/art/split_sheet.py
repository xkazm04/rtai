"""Splits a cell-grid card sheet into row bands, each under a byte budget (n9-perf, the owner's p-2 B).

Godot keeps a CPU staging buffer of next_pow2(largest upload) per texture-upload worker for the whole
session (d9-perf L9: the 4032 x 4480 p70 traffic sheet, 69 MB as RGBA8, pinned a 128 MB buffer). Bands
of whole cell rows, each <= --budget-mb as RGBA8, keep every upload under 32 MB with the same pixels.

    python tools/art/split_sheet.py <sheet.png> [--cell 448] [--budget-mb 32] [--out <dir>] [--check]

Writes <stem>_0.png, <stem>_1.png, ... (the bands top to bottom; the first bands take the most rows) and
proves the bands stacked back are byte-identical to the sheet. --check only verifies existing bands.
"""

import argparse
import sys
from pathlib import Path

from PIL import Image


def band_rows(rows: int, row_bytes: int, budget: int) -> list[int]:
    """Rows per band: as few bands as the budget allows, the rows spread evenly (first bands larger)."""
    per = max(1, budget // row_bytes)
    bands = -(-rows // per)
    base, extra = divmod(rows, bands)
    return [base + (1 if i < extra else 0) for i in range(bands)]


def split(sheet: Image.Image, cell: int, budget: int) -> list[Image.Image]:
    w, h = sheet.size
    if h % cell != 0:
        raise SystemExit(f"sheet height {h} is not a whole number of {cell} px rows")
    out = []
    y = 0
    for n in band_rows(h // cell, w * cell * 4, budget):
        out.append(sheet.crop((0, y, w, y + n * cell)))
        y += n * cell
    return out


def stacked(bands: list[Image.Image]) -> Image.Image:
    w = bands[0].size[0]
    full = Image.new("RGBA", (w, sum(b.size[1] for b in bands)))
    y = 0
    for b in bands:
        full.paste(b, (0, y))
        y += b.size[1]
    return full


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("sheet")
    ap.add_argument("--cell", type=int, default=448)
    ap.add_argument("--budget-mb", type=float, default=32.0)
    ap.add_argument("--out", default="")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    src = Path(a.sheet)
    out = Path(a.out) if a.out else src.parent
    sheet = Image.open(src).convert("RGBA")
    budget = int(a.budget_mb * 1024 * 1024)
    if a.check:
        paths = sorted(out.glob(f"{src.stem}_[0-9].png"))
        bands = [Image.open(p).convert("RGBA") for p in paths]
    else:
        bands = split(sheet, a.cell, budget)
        out.mkdir(parents=True, exist_ok=True)
        for i, b in enumerate(bands):
            b.save(out / f"{src.stem}_{i}.png", optimize=True)
    if not bands or stacked(bands).tobytes() != sheet.tobytes():
        print(f"FAIL {src}: the bands do not stack back to the sheet", file=sys.stderr)
        return 1
    for i, b in enumerate(bands):
        mb = b.size[0] * b.size[1] * 4 / 1048576
        print(f"{src.stem}_{i}.png {b.size[0]}x{b.size[1]} rows {b.size[1] // a.cell} {mb:.1f} MB RGBA8")
    big = [b for b in bands if b.size[0] * b.size[1] * 4 > budget]
    return 1 if big else 0


if __name__ == "__main__":
    sys.exit(main())
