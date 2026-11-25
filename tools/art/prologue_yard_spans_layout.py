"""Join the six arched belt sections of `arched_line` into one snaking line with five overhead spans.

python -W ignore -I tools/art/prologue_yard_spans_layout.py [--out=<txt>] [--guide=<png>] [--preview=<png>] [--write]

Each section end is measured on its cut (the beam band's centre at the outermost opaque column, its
direction from the band 15 and 70 px in), placed by the section's `at` and `size_m`. A span is a cubic
Bezier from one end to the next, leaving and entering along the section's own beam direction, so the
line alternates sides: door E-feed E, feed W-turn W, turn E-return E, return W-bend W, bend E-tail W
(the tail's east end is the torn end). A sixth span (n30) rises out of the burst bay's fire mouth into
the door section's free west end: it starts at MOUTH_AT inside the opening heading south. `--guide`
draws those paths as grey beam bands on white sheets (the art jobs' layout guides, one file per sheet).
Without `--write` the span rows and their join gaps are only printed; with it the `span_<a>_<b>` debris
rows the cutter has written go into `arched_line` (over_print, no cover, no collision).
"""

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
TABLE = ROOT / "project/data/tables/prologue_yard_dressings.json"
ART = ROOT / "project/boot/prologue/art/arched_line"
RES = "res://boot/prologue/art/arched_line/"
SCALE = 0.011
BEAM_M = 1.25
END_M = 1.6
TIP_M = 1.0
CLIP_HALF_M = 1.0
JOINS = [("door", "e", "feed", "e"), ("feed", "w", "turn", "w"), ("turn", "e", "return", "e"),
         ("return", "w", "bend", "w"), ("bend", "e", "tail", "w")]
# Guide sheet: where each span's path bounding box sits (top-left px) on which 1774x887 sheet.
SHEET = (1774, 887)
SHEET_AT = {"door_feed": (0, 90, 70), "feed_turn": (0, 1150, 110), "bend_tail": (2, 650, 140),
            "turn_return": (1, 140, 140), "return_bend": (1, 1000, 110), "mouth_door": (3, 500, 260)}
SHEETS = 4
# n30: the burst bay (factory_front at x 11.8, 15.15 m wide, ground line y -0.26) has its fire opening at
# floor level from about x 9.6 to 14.7 (art px 485..940 of 1355). The span starts in its middle 2.24 m
# north of the ground line (05c: inside the opening's fire, not at its threshold), leaving south (out of
# the hall), and its guide band runs MOUTH_LEAD_M further north so the art has no end plate there (the cut
# clips it at MOUTH_AT).
MOUTH_AT = (12.2, -2.5)
MOUTH_DIR = (0.0, 1.0)
MOUTH_OPENING_X = (9.6, 14.7)
FACADE_Y = -0.26
MOUTH_LEAD_M = 0.6
# The deeper start needs a longer leaving handle so the beam drops out of the opening past the ground line
# (dip about 0.5 m south of it, as n30's first start) before it turns east, instead of crossing the brick.
MOUTH_HANDLE_M = 6.5
# The bend's east end to the tail's west end is too tight for a tangent U (sheet 0's piece curled into a
# hook): that span leaves the bend at a 45 degree elbow, drawn again alone on sheet 2.
LEAVE_TURN_DEG = {"bend_tail": 45.0}


def arch_rows() -> dict:
    row = json.loads(TABLE.read_text())["dressings"]["arched_line"]
    return {d["id"].removeprefix("arch_"): d for d in row["layout"]["debris"] if d["id"].startswith("arch_")}


def band_centre(alpha: np.ndarray, col: int) -> float:
    """The centre row of the first opaque run from the top of one column (the beam band)."""
    ys = np.where(alpha[:, col])[0]
    run_end = ys[0]
    while run_end + 1 < alpha.shape[0] and alpha[run_end + 1, col]:
        run_end += 1
    return (ys[0] + run_end) / 2


def section_ends(row: dict) -> dict:
    """{'w': (point, outward unit dir), 'e': ...} in metres for one placed section."""
    alpha = np.asarray(Image.open(ART / Path(row["art"]).name).convert("RGBA"))[..., 3] > 128
    h, w = alpha.shape
    sx, sy = row["size_m"][0] / w, row["size_m"][1] / h
    left = np.array([row["at"][0] - row["size_m"][0] / 2, row["at"][1] - row["size_m"][1] / 2])
    cols = np.where(alpha.any(axis=0))[0]
    out = {}
    for side, edge, step in (("w", cols.min(), 1), ("e", cols.max(), -1)):
        near = np.array([edge + step * 15, band_centre(alpha, edge + step * 15)])
        far = np.array([edge + step * 70, band_centre(alpha, edge + step * 70)])
        tip = near + (near - far) * 15 / 55
        d = (near - far) * [sx, sy]
        out[side] = (left + (tip + 0.5) * [sx, sy], d / np.linalg.norm(d))
    return out


def turned(end: tuple, deg: float) -> tuple:
    """A section end with its outward direction turned by deg (clockwise on screen: an elbow joint)."""
    c, s = np.cos(np.radians(deg)), np.sin(np.radians(deg))
    d = end[1]
    return (end[0], np.array([c * d[0] - s * d[1], s * d[0] + c * d[1]]))


def span_path(a: tuple, b: tuple, n: int = 80, leave_m: float = 0.0) -> np.ndarray:
    """A cubic Bezier from end a to end b, leaving a and entering b along their outward directions
    (leave_m > 0 sets a's handle length, else both handles are 0.55 of the chord, at least 2.5 m)."""
    (p0, d0), (p3, d3) = a, b
    k = max(2.5, 0.55 * float(np.linalg.norm(p3 - p0)))
    p1, p2 = p0 + d0 * (leave_m or k), p3 + d3 * k
    t = np.linspace(0, 1, n)[:, None]
    return (1 - t) ** 3 * p0 + 3 * (1 - t) ** 2 * t * p1 + 3 * (1 - t) * t**2 * p2 + t**3 * p3


def spans() -> list:
    """[(name, end a, end b, path)]; an elbow span's end a carries its turned (leaving) direction."""
    rows = arch_rows()
    ends = {k: section_ends(r) for k, r in rows.items()}
    out = []
    for a, sa, b, sb in JOINS:
        name = f"{a}_{b}"
        start = turned(ends[a][sa], LEAVE_TURN_DEG.get(name, 0.0))
        out.append((name, start, ends[b][sb], span_path(start, ends[b][sb])))
    mouth = (np.array(MOUTH_AT), np.array(MOUTH_DIR))
    out.append(("mouth_door", mouth, ends["door"]["w"], span_path(mouth, ends["door"]["w"], leave_m=MOUTH_HANDLE_M)))
    return out


def guide_points(name: str, pts: np.ndarray) -> np.ndarray:
    """The path the guide draws: the mouth span gets a straight lead MOUTH_LEAD_M back into the opening."""
    if name != "mouth_door":
        return pts
    lead = pts[0] - np.array(MOUTH_DIR) * np.linspace(MOUTH_LEAD_M, 0, 12, endpoint=False)[:, None]
    return np.vstack([lead, pts])


def draw_band(draw: ImageDraw.ImageDraw, pts: np.ndarray, width: float, fill, centre=None) -> None:
    flat = [tuple(map(float, p)) for p in pts]
    r = width / 2
    for i in range(len(pts) - 1):
        for t in np.linspace(0, 1, 8, endpoint=False):
            x, y = pts[i] + (pts[i + 1] - pts[i]) * t
            draw.ellipse((x - r, y - r, x + r, y + r), fill=fill)
    if centre:
        draw.line(flat, fill=centre, width=3)


def guide(path: Path) -> None:
    """SHEETS white sheets (one file each) with each span's path as a grey beam band at SCALE."""
    sheets = [Image.new("RGB", SHEET, "white") for _ in range(SHEETS)]
    for name, _a, _b, pts in spans():
        sheet, x0, y0 = SHEET_AT[name]
        px = (guide_points(name, pts) - pts.min(axis=0)) / SCALE + [x0, y0] + BEAM_M / SCALE / 2
        draw_band(ImageDraw.Draw(sheets[sheet]), px, BEAM_M / SCALE, (150, 150, 150), (90, 90, 90))
    for i, s in enumerate(sheets):
        s.save(path.with_name(f"{path.stem}_{i + 1}{path.suffix}"))


def preview(path: Path, ppm: float = 24.0) -> None:
    """The burst bay, the six sections and the span paths at their world places (a plan check, not art)."""
    origin = np.array([4.0, -10.0])
    img = Image.new("RGBA", (round(40 * ppm), round(34 * ppm)), (200, 190, 170, 255))
    placed = [r for r, _a, _b in span_rows()]
    front = json.loads(TABLE.read_text())["dressings"]["arched_line"]["factory_front"]
    bays = [r for r in front if "burst_bay" in r["art"]]
    for row in bays + list(arch_rows().values()) + placed:
        art = Image.open(ART / Path(row["art"]).name).convert("RGBA")
        size = (round(row["size_m"][0] * ppm), round(row["size_m"][1] * ppm))
        top = (np.array(row["at"]) - np.array(row["size_m"]) / 2 - origin) * ppm
        img.alpha_composite(art.resize(size), tuple(int(v) for v in top))
    draw = ImageDraw.Draw(img)
    for name, _a, _b, pts in spans():
        if "span_" + name not in [r["id"] for r in placed]:
            draw_band(draw, (pts - origin) * ppm, BEAM_M * ppm, (60, 60, 60, 160))
    img.save(path)


def end_region(pts: np.ndarray, path: np.ndarray, first: bool) -> np.ndarray:
    """The points whose nearest path sample lies within END_M of arc length of the path's first or last end."""
    arc = np.concatenate([[0.0], np.cumsum(np.linalg.norm(np.diff(path, axis=0), axis=1))])
    keep = arc <= END_M if first else arc >= arc[-1] - END_M
    nearest = np.empty(len(pts), bool)
    for k in range(0, len(pts), 20000):
        chunk = pts[k : k + 20000]
        dist = np.linalg.norm(chunk[:, None, :] - path[None, :, :], axis=2)
        nearest[k : k + 20000] = keep[dist.argmin(axis=1)]
    return nearest


def end_gap(alpha: np.ndarray, top_left: np.ndarray, end: tuple, path: np.ndarray, first: bool) -> tuple:
    """(gap m, along m, lateral m): the span's terminal edge at one end vs that section end's tip.

    The edge is the centroid of the span's end-region pixels (end_region, within TIP_M of the tip and
    CLIP_HALF_M of the section's centre line, so a hook's own curl beside the tip does not count) least far along the
    section's outward direction (within 0.08 m of the minimum). along < 0 = the span overlaps the beam."""
    tip, d = end
    ys, xs = np.where(alpha)
    pts = top_left + (np.stack([xs, ys], axis=1) + 0.5) * SCALE
    lateral = np.abs((pts - tip) @ np.array([-d[1], d[0]]))
    near = pts[end_region(pts, path, first) & (np.linalg.norm(pts - tip, axis=1) < TIP_M) & (lateral < CLIP_HALF_M)]
    if not len(near):
        return (99.0, 99.0, 99.0)
    proj = (near - tip) @ d
    edge = near[proj < proj.min() + 0.08].mean(axis=0) - tip
    along = float(edge @ d)
    lateral = float(edge @ np.array([-d[1], d[0]]))
    return (round(float(np.hypot(along, lateral)), 3), round(along, 3), round(lateral, 3))


def span_rows() -> list:
    """[(debris row, gap at a, gap at b)] for every span the cutter has written."""
    path = ART / "belt_spans.json"
    meta = json.loads(path.read_text()) if path.exists() else {}
    out = []
    for name, a, b, pts in spans():
        if name not in meta:
            continue
        m = meta[name]
        alpha = np.asarray(Image.open(ART / (m["art"] + ".png")).convert("RGBA"))[..., 3] > 128
        top_left = np.array(m["top_left_m"])
        size = np.array(m["size_px"]) * SCALE
        row = {"art": RES + m["art"] + ".png", "at": [round(float(v), 3) for v in top_left + size / 2],
               "id": "span_" + name, "rotation_deg": 0, "size_m": [round(float(v), 3) for v in size], "tint": "ffffffff"}
        out.append((row, end_gap(alpha, top_left, a, pts, True), end_gap(alpha, top_left, b, pts, False)))
    return out


def write(rows: list) -> None:
    """The span rows into arched_line: debris rows drawn over the print, listed after the sections."""
    data = json.loads(TABLE.read_text())
    row = data["dressings"]["arched_line"]
    row["layout"]["debris"] = [d for d in row["layout"]["debris"] if not d["id"].startswith("span_")] + rows
    row["over_print"] = [i for i in row["over_print"] if not i.startswith("span_")] + [r["id"] for r in rows]
    TABLE.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out")
    ap.add_argument("--guide")
    ap.add_argument("--preview")
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    text = []
    for name, a, b, pts in spans():
        lo, hi = pts.min(axis=0), pts.max(axis=0)
        text.append(f"span_{name}: {a[0].round(2).tolist()} -> {b[0].round(2).tolist()}, path box {lo.round(2).tolist()}..{hi.round(2).tolist()}")
    rows = span_rows()
    text.append("row | at m | size m | join gap at first end (gap, along, lateral) m | at second end m | ok (<= 0.3)")
    for row, ga, gb in rows:
        ok = "ok" if max(ga[0], gb[0]) <= 0.3 else "FAIL"
        text.append(f"{row['id']} | {row['at']} | {row['size_m']} | {ga} | {gb} | {ok}")
    print("\n".join(text))
    if args.write:
        write([r for r, _a, _b in rows])
    if args.out:
        Path(args.out).write_text("\n".join(text) + "\n")
    if args.guide:
        guide(Path(args.guide))
    if args.preview:
        preview(Path(args.preview))


if __name__ == "__main__":
    main()
