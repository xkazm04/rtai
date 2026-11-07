"""n8 vehicles: the traffic card atlas for a view pitch, cut from the art library's vehicle sheets.

Each library sheet (keyed/vehicle/<id>_<pitch>.png) holds five rotations in one row: nose to the
camera, three-quarter toward (nose down-right), side (nose right), three-quarter away (nose
up-right), tail to the camera. This cuts the five, scales each vehicle so its side view is as long
as the car's top-down footprint (the traffic atlas cell, 80 px/m: the collision size), and pastes
every view into a CELL_PX square with the car's GROUND CENTRE at the cell centre (the bbox centre
dropped by half the body's lifted height: a box's projection is centrally symmetric about its
centroid's). Rows = the sim car art id (CitySpawner CAR_ART 0-7, ART_POLICE_CAR 8; row 9 the bike, BIKE), columns = the
five views. Red-orange lamp lenses are turned amber (red is blood only). The mirrored three views are the runtime's (a UV flip about the cell centre).

A redrawn side view (keyed/vehicle/<id>_side_<pitch>.png, one drawing) replaces the sheet's own
side view, scaled to the footprint on its own (SIDE_REDO = False: the sheet's side view).

The 22.5-degree in-betweens (keyed/vehicle/<id>_between_<pitch>.png: four drawings A-D between
views 0-1, 1-2, 2-3, 3-4; <id>_between_c_<pitch>.png, one drawing, replaces C) fill columns 5-8
(BETWEEN = False: five columns, as before). The four-drawing sheet shares the five-view sheet's
canvas and scale family (its raw widths sit between its neighbours'), so A, B, D take the sheet's k;
the one-drawing C redo is scaled to the mean of its neighbours' scaled widths (side, 3/4 away) and
its saturated paint graded to theirs (MATCH_C: the police C redo's blue is ~1.5x brighter). Box
geometry (L |cos| + W |sin|) was tried and rejected: the sheets' own 3/4 views are drawn ~2/3 of it,
so A and D came out half as big again as their neighbours. The runtime's VehicleViews.FINE lists
the rows filled per pitch (printed here).

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
BETWEEN = True
# Grade a C redo's saturated paint to its neighbours' (False: the redo's own grade).
MATCH_C = True
# The bike row (art id 9, after the sim's 0-8): bike_v3 keyed here from the green original (the
# library's keyed side view sits on an opaque black box); False: the nine sim rows only.
BIKE = True
BIKE_SHEET = "bike_{pitch}_v3.png"
BIKE_M = (2.1, 1.1)  # length, height (m): no top-down footprint to measure
COLS = 9 if BETWEEN else 5
# Per sheet id: in-between slot (0-3 = A-D) -> a one-drawing redraw (keyed/vehicle/<name>.png,
# {p} = pitch); None keeps the row sheet's own drawing. An id not listed takes <id>_between_c_{p}
# for C when it exists. The C redos "_v2" (turned ~20-25 deg by a turn reference) replace the
# 2257 ones (under-turned ~8-10): drop "_v2" for the old. The taxi's own row C is the better turned
# (its _c is the spare); the pickup's row C (A, the sheet's design) over its _c (better turned, a
# flatter camera and heavier rust): PICKUP_C_REDO = True takes the _c.
PICKUP_C_REDO = False
TAXI_HUE = 12.0
# True: the taxi's five views from taxi_70_v3 (the asset lane's repaint, a native cab yellow, hue
# ~49: no hue turn on them); its in-betweens (drawn mustard) keep TAXI_HUE (35 + 12 = ~47). False:
# the 2021 sheet, every cell turned TAXI_HUE (the build since iteration 15). 55 has no v3 sheet.
TAXI_SHEET = False
SHEET_PICKS = {"taxi": {70: "taxi_70_v3"}} if TAXI_SHEET else {}
# Rows whose five views come from a SHEET_PICKS sheet this build (their HUE_DEG skips columns 0-4).
_PICKED: set = set()
REDRAWS = {
    "sedan": {2: "sedan_between_c_{p}_v2"},
    "police_car": {2: "police_car_between_c_{p}_v2"},
    "taxi": {2: None},
    "parked_pickup": {2: "parked_pickup_between_c_{p}" if PICKUP_C_REDO else None},
    "ambulance": {1: "ambulance_between_b_{p}", 2: "ambulance_between_c_{p}_v2"},
}
# Row sheets drawn at another scale than their five-view sheet (taxi ~1.6x): every in-between is
# scaled to its neighbours like a redraw, its paint graded to theirs (the brighter yellow).
ROW_FIT = {"taxi"}
FIT_BY = "area"
# Row -> degrees its saturated mid paint turns toward yellow (hue 20-50 deg, saturation >= 0.35; the
# ink, glass and red lamps untouched). The taxi: the city's warm light and grade print the sheet's
# mustard (hue ~37) at ~(160, 75, 5), past the palette's vermilion gate (r - max(g, b) >= 79,
# PaletteTokens): measured 5.7k vermilion px per taxi at 32 px/m in the tilt70 city. 0 = the sheet's.
HUE_DEG = {3: TAXI_HUE}
# The lit amber lenses (value >= 0.7, saturation >= 0.8, hue 20-42) turn LAMP_DEG toward yellow on
# every row (the police bar's too: vehicle_cards.gdshader lens() tests r > g + 0.12 for it): the
# sheets' lens orange (~239, 151, 7) passes the vermilion gate even before the grade. 0 = the sheets'.
LAMP_DEG = 10.0
# The unlit lenses (value 0.3-0.6, saturation >= 0.8, hue 20-42: the rear lamps' inner block, the
# van's and pickup's tail lamps, the ambulance bar) turn DARK_LAMP_DEG toward yellow: the city's grade
# prints the sheets' (155, 90, 6) at ~(97, 34, 0), hue 20, a rust-red tail lamp (red is blood only).
# On the police row value < 0.6 keeps them out of vehicle_cards.gdshader lens() (r > 0.6), so the
# siren finds the same lens pixels (0.7 there would drop 3 of them at 70). 0 = the sheets'.
DARK_LAMP_DEG = 10.0
DARK_LAMP_V = (0.3, 0.7)
DARK_LAMP_V_SIREN = 0.6
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


def green_key(im: Image.Image, tol: float = 24.0) -> Image.Image:
    """A #00B140-ish green screen to alpha: alpha falls from 255 at a green excess (g over max(r, b))
    of `tol` to 0 at 3 `tol`; a spill pixel (green over red and blue) goes neutral grey at its red
    and blue's mean, warm-biased (no teal in the spoke gaps: teal is the souls')."""
    px = np.array(im.convert("RGBA")).astype(np.float32)
    r, g, b = px[:, :, 0], px[:, :, 1], px[:, :, 2]
    rb = np.maximum(r, b)
    ex = g - rb
    a = np.clip(1.0 - (ex - tol) / (2.0 * tol), 0.0, 1.0)
    grey = (r + b) * 0.5
    spill = ex > 0
    for ch, k in ((0, 1.04), (1, 1.0), (2, 0.94)):
        px[:, :, ch] = np.where(spill, grey * k, px[:, :, ch])
    px[:, :, 3] = np.where(a < 0.08, 0.0, a * 255.0)
    return Image.fromarray(np.clip(px, 0, 255).astype(np.uint8))


def rows_of() -> list:
    return ROWS + ([("bike", BIKE_M[1], (1.0, 1.0, 1.0))] if BIKE else [])


def sheet_of(lib: Path, sid: str, pitch: int) -> Image.Image:
    if sid == "bike":
        return green_key(Image.open(lib / "sheets" / "vehicle" / BIKE_SHEET.format(pitch=pitch)))
    name = SHEET_PICKS.get(sid, {}).get(pitch, f"{sid}_{pitch}")
    return Image.open(lib / "keyed" / "vehicle" / f"{name}.png").convert("RGBA")


def footprints(root: Path) -> list[float]:
    """Each art id's top-down length (m) from the traffic atlas (3 x 3 cells of 512 x 256)."""
    a = np.array(Image.open(root / TOPDOWN).convert("RGBA"))[:, :, 3]
    out = []
    for i in range(9):
        c, r = i % 3, i // 3
        xs = np.where((a[r * 256 : (r + 1) * 256, c * 512 : (c + 1) * 512] > 40).any(0))[0]
        out.append((xs.max() - xs.min() + 1) / 80.0)
    return out + ([BIKE_M[0]] if BIKE else [])


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


def runs_of(sheet: Image.Image, n: int) -> list[Image.Image]:
    """`n` drawings in one row, each cropped to its alpha bbox."""
    a = np.array(sheet)[:, :, 3] > 40
    cols = np.concatenate([[False], a.any(0), [False]])
    edges = np.flatnonzero(cols[1:] != cols[:-1]).reshape(-1, 2)
    edges = sorted([e for e in edges if e[1] - e[0] > 40], key=lambda e: e[0])
    if len(edges) != n:
        raise SystemExit(f"expected {n} drawings, found {len(edges)}")
    out = []
    for x0, x1 in edges:
        rows = np.where(a[:, x0:x1].any(1))[0]
        out.append(sheet.crop((x0, rows.min(), x1, rows.max() + 1)))
    return out


def betweens(lib: Path, sid: str, pitch: int) -> tuple[list[Image.Image], set]:
    """The four in-betweens (A-D) ([] when none) and the slots taken from a one-drawing redraw
    (REDRAWS, else the legacy <id>_between_c_<pitch>.png for C)."""
    f = lib / "keyed" / "vehicle" / f"{sid}_between_{pitch}.png"
    if not BETWEEN or not f.exists():
        return [], set()
    out = runs_of(Image.open(f).convert("RGBA"), 4)
    picks = dict(REDRAWS.get(sid, {2: sid + "_between_c_{p}"}))
    done = set()
    for j, name in picks.items():
        g = lib / "keyed" / "vehicle" / (name.format(p=pitch) + ".png") if name else None
        if g is not None and g.exists():
            out[j] = one_view(Image.open(g).convert("RGBA"))
            done.add(j)
    return out, done


def one_view(sheet: Image.Image) -> Image.Image:
    """A one-drawing sheet (a redrawn rotation): the widest alpha column run, cropped."""
    a = np.array(sheet)[:, :, 3] > 40
    cols = np.concatenate([[False], a.any(0), [False]])
    edges = np.flatnonzero(cols[1:] != cols[:-1]).reshape(-1, 2)
    x0, x1 = max(edges, key=lambda e: e[1] - e[0])
    rows = np.where(a[:, x0:x1].any(1))[0]
    return sheet.crop((x0, rows.min(), x1, rows.max() + 1))


def hsv_paint(im: Image.Image) -> tuple:
    """The HSV array (0-1) of `im` and the mask of its saturated paint (opaque, s > 0.4)."""
    hsv = np.array(im.convert("RGB").convert("HSV")).astype(np.float32) / 255.0
    return hsv, (np.array(im)[:, :, 3] > 200) & (hsv[:, :, 1] > 0.4)


def match_paint(v: Image.Image, refs: list) -> Image.Image:
    """`v` with its saturated paint's mean value and saturation moved to the mean of `refs`' (a
    redrawn cell graded brighter than the sheet it sits between); only the paint's own hue (within
    30 deg of the refs' median saturated hue: the lamps and the light bar keep theirs), weighted by
    saturation so the ink, the glass and the cream panels keep theirs."""
    hsv, m = hsv_paint(v)
    want = [hsv_paint(r) for r in refs]
    if m.sum() < 500 or any(w[1].sum() < 500 for w in want):
        return v
    hue = np.median(np.concatenate([w[0][:, :, 0][w[1]] for w in want]))
    near = lambda h: np.abs((h - hue + 0.5) % 1.0 - 0.5) < 30.0 / 360.0  # noqa: E731
    want = [(w[0], w[1] & near(w[0][:, :, 0])) for w in want]
    m = m & near(hsv[:, :, 0])
    if m.sum() < 500 or any(w[1].sum() < 500 for w in want):
        return v
    for ch in (1, 2):
        k = np.mean([w[0][:, :, ch][w[1]].mean() for w in want]) / hsv[:, :, ch][m].mean()
        wt = np.clip((hsv[:, :, 1] - 0.3) / 0.2, 0.0, 1.0) * near(hsv[:, :, 0])
        hsv[:, :, ch] = np.clip(hsv[:, :, ch] * (1.0 - wt + wt * k), 0.0, 1.0)
    rgb = Image.fromarray((hsv * 255.0).round().astype(np.uint8), "HSV").convert("RGB")
    out = rgb.convert("RGBA")
    out.putalpha(v.getchannel("A"))
    return out


def fit_k(v: Image.Image, nbrs: list) -> float:
    """The scale that gives `v` its neighbours' mean size (each (view, its k)): by the inked area's
    square root (FIT_BY = "area": a car's plan area barely changes as it turns, while its screen
    width falls ~30 % from the side view to the 3/4 away, so a width match shrank the C cells), or
    by width ("width", the cut before iteration 14)."""
    if FIT_BY == "width":
        return sum(n.width * k for n, k in nbrs) / len(nbrs) / v.width
    size = lambda im: math.sqrt(float((np.array(im)[:, :, 3] > 40).sum()))  # noqa: E731
    return sum(size(n) * k for n, k in nbrs) / len(nbrs) / size(v)


def paint(im: Image.Image, gain: tuple) -> Image.Image:
    if gain == (1.0, 1.0, 1.0):
        return im
    px = np.array(im).astype(np.float32)
    lum = px[:, :, :3].mean(2, keepdims=True) / 255.0
    w = np.clip((lum - 0.25) / 0.35, 0.0, 1.0)  # the paint, not the ink or the glass
    g = np.array(gain, dtype=np.float32).reshape(1, 1, 3)
    px[:, :, :3] = px[:, :, :3] * (1.0 - w + w * g)
    return Image.fromarray(np.clip(px, 0, 255).astype(np.uint8))


def hue_turn(im: Image.Image, deg: float, min_s: float = 0.35, min_v: float = 0.0, max_h: float = 50.0,
             max_v: float = 2.0) -> Image.Image:
    if deg == 0.0:
        return im
    px = np.array(im).astype(np.float32) / 255.0
    rgb = px[:, :, :3]
    mx, mn = rgb.max(2), rgb.min(2)
    c = mx - mn
    sat = np.where(mx > 0, c / np.maximum(mx, 1e-6), 0.0)
    r, g = rgb[:, :, 0], rgb[:, :, 1]
    # red the maximum: hue = 60 (g - b) / c (b the minimum in the window)
    h = np.where(c > 0, 60.0 * (g - mn) / np.maximum(c, 1e-6), 0.0)
    on = (px[:, :, 3] > 0) & (r >= mx) & (sat >= min_s) & (mx >= min_v) & (mx < max_v) & (h >= 20.0) & (h <= max_h)
    h2 = np.clip(h + deg * np.clip((h - 20.0) / 8.0, 0.0, 1.0), 0.0, 58.0)
    px[:, :, 1] = np.where(on, mn + c * h2 / 60.0, g)
    return Image.fromarray(np.clip(px * 255.0, 0, 255).astype(np.uint8))


def amber(im: Image.Image) -> Image.Image:
    """The colour law: red only for blood. Turns the sheets' red-orange lamp lenses amber
    (r dominant over g and b by 1.8x), keeping their value."""
    px = np.array(im).astype(np.float32)
    r, g, b = px[:, :, 0], px[:, :, 1], px[:, :, 2]
    red = (px[:, :, 3] > 0) & (r > 90) & (r > g * 1.8) & (r > b * 1.8)
    px[:, :, 1] = np.where(red, r * 0.66, g)
    px[:, :, 2] = np.where(red, r * 0.16, b)
    return Image.fromarray(np.clip(px, 0, 255).astype(np.uint8))


def paste(atlas: Image.Image, v: Image.Image, k: float, at: tuple, lift: float) -> None:
    """`v` scaled by `k` into cell (col, row) at `at`, its ground centre at the cell centre."""
    col, row, gain = at
    w, h = max(1, round(v.width * k)), max(1, round(v.height * k))
    turn = 0.0 if (row in _PICKED and col < 5) else HUE_DEG.get(row, 0.0)
    im = amber(hue_turn(paint(v.resize((w, h), Image.LANCZOS), gain), turn))
    im = hue_turn(im, LAMP_DEG, 0.8, 0.7, 42.0)
    top = DARK_LAMP_V_SIREN if rows_of()[row][0] == "police_car" else DARK_LAMP_V[1]
    im = hue_turn(im, DARK_LAMP_DEG, 0.8, DARK_LAMP_V[0], 42.0, top)
    cx = col * CELL_PX + CELL_PX // 2
    cy = row * CELL_PX + CELL_PX // 2
    x, y = round(cx - w / 2), round(cy - lift - h / 2)
    y = max(row * CELL_PX, min(y, (row + 1) * CELL_PX - h))
    atlas.alpha_composite(im, (x, y))


def build(root: Path, lib: Path, pitch: int) -> Image.Image:
    atlas = Image.new("RGBA", (CELL_PX * COLS, CELL_PX * len(rows_of())), (0, 0, 0, 0))
    fine = []
    lengths = footprints(root)
    cos_p = math.cos(math.radians(pitch))
    for row, (sid, height, gain) in enumerate(rows_of()):
        vs = views(sheet_of(lib, sid, pitch))
        if pitch in SHEET_PICKS.get(sid, {}):
            _PICKED.add(row)
        k = lengths[row] * PPM / vs[2].width  # the side view as long as the footprint
        ks = [k] * 5
        redo = lib / "keyed" / "vehicle" / f"{sid}_side_{pitch}.png"
        if SIDE_REDO and redo.exists():  # the side redrawn at the sheet's steeper camera
            vs[2] = one_view(Image.open(redo).convert("RGBA"))
            ks[2] = lengths[row] * PPM / vs[2].width
        drop = height * 0.5 * cos_p * PPM  # bbox centre -> ground centre (screen px)
        for col, v in enumerate(vs):
            paste(atlas, v, ks[col], (col, row, gain), drop)
        bs, redone = betweens(lib, sid, pitch)
        if bs:
            fine.append(row)
        for j, v in enumerate(bs):  # slot j sits between views j and j + 1
            kb = k
            if j in redone or sid in ROW_FIT:  # scaled to its neighbours, its paint graded to theirs
                kb = fit_k(v, [(vs[j], ks[j]), (vs[j + 1], ks[j + 1])])
                v = match_paint(v, [vs[j], vs[j + 1]]) if MATCH_C else v
            paste(atlas, v, kb, (5 + j, row, gain), drop)
    print(f"fine rows (VehicleViews.FINE): {fine}")
    return atlas if fine else atlas.crop((0, 0, CELL_PX * 5, atlas.height))  # no in-betweens: 5


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
