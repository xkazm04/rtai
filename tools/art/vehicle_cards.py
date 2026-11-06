"""n8 vehicles: the traffic card atlas for a view pitch, cut from the art library's vehicle sheets.

Each library sheet (keyed/vehicle/<id>_<pitch>.png) holds five rotations in one row: nose to the
camera, three-quarter toward (nose down-right), side (nose right), three-quarter away (nose
up-right), tail to the camera. This cuts the five, scales each vehicle so its side view is as long
as the car's top-down footprint (the traffic atlas cell, 80 px/m: the collision size), and pastes
every view into a CELL_PX square with the car's GROUND CENTRE at the cell centre (the bbox centre
dropped by half the body's lifted height: a box's projection is centrally symmetric about its
centroid's). Rows = the sim car art id (CitySpawner CAR_ART 0-7, ART_POLICE_CAR 8), columns = the
five views. Red-orange lamp lenses are turned amber (red is blood only). The mirrored three views are the runtime's (a UV flip about the cell centre).

A redrawn side view (keyed/vehicle/<id>_side_<pitch>.png, one drawing) replaces the sheet's own
side view, scaled to the footprint on its own (SIDE_REDO = False: the sheet's side view).

Usage: python tools/art/vehicle_cards.py <library root> <pitch> [--out=<png>]
Writes project/features/vehicles/art/p<pitch>/traffic_cards.png by default.
"""

import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

PPM = 64.0  # the atlas's px per metre (1:1 at the 64 px/m close-up)
CELL_PX = 448  # 7 m
TOPDOWN = "project/features/city/art/vehicles/traffic_atlas.png"
# art id -> (library sheet id, body height m, paint gain (r, g, b): value variety only, never a hue)
# Use keyed/vehicle/<id>_side_<pitch>.png (the asset lane's redrawn side view) when it exists.
SIDE_REDO = True
ROWS = [
    ("sedan", 1.45, (1.0, 1.0, 1.0)),
    ("sedan", 1.45, (0.93, 0.93, 0.93)),  # sedan_b: the small hatch, a shade darker
    ("sedan", 1.45, (1.04, 1.03, 1.0)),  # sedan_c
    ("taxi", 1.5, (1.0, 1.0, 1.0)),
    ("van", 2.1, (1.0, 1.0, 1.0)),
    ("parked_pickup", 1.8, (1.0, 1.0, 1.0)),
    ("ambulance", 2.3, (1.0, 1.0, 1.0)),
    ("sedan", 1.45, (0.66, 0.65, 0.66)),  # sedan_grey: the mid-wash paint
    ("police_car", 1.5, (1.0, 1.0, 1.0)),
]


def footprints(root: Path) -> list[float]:
    """Each art id's top-down length (m) from the traffic atlas (3 x 3 cells of 512 x 256)."""
    a = np.array(Image.open(root / TOPDOWN).convert("RGBA"))[:, :, 3]
    out = []
    for i in range(9):
        c, r = i % 3, i // 3
        xs = np.where((a[r * 256 : (r + 1) * 256, c * 512 : (c + 1) * 512] > 40).any(0))[0]
        out.append((xs.max() - xs.min() + 1) / 80.0)
    return out


def views(sheet: Image.Image) -> list[Image.Image]:
    """The five rotations, each cropped to its alpha bbox (column runs split the row)."""
    a = np.array(sheet)[:, :, 3] > 40
    cols = a.any(0)
    runs, s = [], None
    for x, v in enumerate(cols):
        if v and s is None:
            s = x
        if not v and s is not None:
            runs.append((s, x))
            s = None
    if s is not None:
        runs.append((s, len(cols)))
    runs = sorted([r for r in runs if r[1] - r[0] > 40], key=lambda r: r[0])
    if len(runs) != 5:
        raise SystemExit(f"expected 5 views, found {len(runs)}")
    out = []
    for x0, x1 in runs:
        rows = np.where(a[:, x0:x1].any(1))[0]
        out.append(sheet.crop((x0, rows.min(), x1, rows.max() + 1)))
    return out


def one_view(sheet: Image.Image) -> Image.Image:
    """A one-drawing sheet (a redrawn rotation): the widest alpha column run, cropped."""
    a = np.array(sheet)[:, :, 3] > 40
    cols = np.concatenate([[False], a.any(0), [False]])
    edges = np.flatnonzero(cols[1:] != cols[:-1]).reshape(-1, 2)
    x0, x1 = max(edges, key=lambda e: e[1] - e[0])
    rows = np.where(a[:, x0:x1].any(1))[0]
    return sheet.crop((x0, rows.min(), x1, rows.max() + 1))


def paint(im: Image.Image, gain: tuple) -> Image.Image:
    if gain == (1.0, 1.0, 1.0):
        return im
    px = np.array(im).astype(np.float32)
    lum = px[:, :, :3].mean(2, keepdims=True) / 255.0
    w = np.clip((lum - 0.25) / 0.35, 0.0, 1.0)  # the paint, not the ink or the glass
    g = np.array(gain, dtype=np.float32).reshape(1, 1, 3)
    px[:, :, :3] = px[:, :, :3] * (1.0 - w + w * g)
    return Image.fromarray(np.clip(px, 0, 255).astype(np.uint8))


def amber(im: Image.Image) -> Image.Image:
    """The colour law: red only for blood. Turns the sheets' red-orange lamp lenses amber
    (r dominant over g and b by 1.8x), keeping their value."""
    px = np.array(im).astype(np.float32)
    r, g, b = px[:, :, 0], px[:, :, 1], px[:, :, 2]
    red = (px[:, :, 3] > 0) & (r > 90) & (r > g * 1.8) & (r > b * 1.8)
    px[:, :, 1] = np.where(red, r * 0.66, g)
    px[:, :, 2] = np.where(red, r * 0.16, b)
    return Image.fromarray(np.clip(px, 0, 255).astype(np.uint8))


def build(root: Path, lib: Path, pitch: int) -> Image.Image:
    atlas = Image.new("RGBA", (CELL_PX * 5, CELL_PX * len(ROWS)), (0, 0, 0, 0))
    lengths = footprints(root)
    cos_p = math.cos(math.radians(pitch))
    for row, (sid, height, gain) in enumerate(ROWS):
        sheet = Image.open(lib / "keyed" / "vehicle" / f"{sid}_{pitch}.png").convert("RGBA")
        vs = views(sheet)
        k = lengths[row] * PPM / vs[2].width  # the side view as long as the footprint
        ks = [k] * 5
        redo = lib / "keyed" / "vehicle" / f"{sid}_side_{pitch}.png"
        if SIDE_REDO and redo.exists():  # the side redrawn at the sheet's steeper camera
            vs[2] = one_view(Image.open(redo).convert("RGBA"))
            ks[2] = lengths[row] * PPM / vs[2].width
        for col, v in enumerate(vs):
            w, h = max(1, round(v.width * ks[col])), max(1, round(v.height * ks[col]))
            im = amber(paint(v.resize((w, h), Image.LANCZOS), gain))
            drop = height * 0.5 * cos_p * PPM  # bbox centre -> ground centre (screen px)
            cx = col * CELL_PX + CELL_PX // 2
            cy = row * CELL_PX + CELL_PX // 2
            x, y = round(cx - w / 2), round(cy - drop - h / 2)
            y = max(row * CELL_PX, min(y, (row + 1) * CELL_PX - h))
            atlas.alpha_composite(im, (x, y))
    return atlas


def main() -> None:
    lib, pitch = Path(sys.argv[1]), int(sys.argv[2])
    root = Path(__file__).resolve().parents[2]
    out = root / f"project/features/vehicles/art/p{pitch}/traffic_cards.png"
    for a in sys.argv[3:]:
        if a.startswith("--out="):
            out = Path(a[6:])
    out.parent.mkdir(parents=True, exist_ok=True)
    build(root, lib, pitch).save(out, optimize=True)
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
