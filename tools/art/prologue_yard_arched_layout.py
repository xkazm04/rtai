"""Place the arched belt sections of `arched_line` and measure its lanes.

python -W ignore -I tools/art/prologue_yard_arched_layout.py [--scale=0.0112] [--foot-in=0.1] [--write] [--lanes=<txt>] [--search]

Each of the six conveyor cover boxes keeps its collision. Its arched drawing (a non-blocking debris row,
`arch_<id>`, drawn over the world print) stands with its footing line `foot-in` metres inside the box's
south edge, centred on the box in x; beams and arches rise north. `scale` is metres per source pixel.
The cover row's own art becomes a dark footing shadow. The solid lower band (feet, arches, appliances) of a
drawing is the opaque pixels of the bottom BAND_M above its footing line (the leg feet; the rest is overhead); lanes are the distances between those
bands (and the other cover boxes), checked wherever the collision gap is 2.5 m or more.
"""

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[2]
TABLE = ROOT / "project/data/tables/prologue_yard_dressings.json"
ART = ROOT / "project/boot/prologue/art/arched_line"
RES = "res://boot/prologue/art/arched_line/"
CELL = 0.05
BAND_M = 0.6
LANE_M = 2.5
SECTION = {
    "conveyor_door": ("straight_a", "belt_straight_a"),
    "conveyor_feed": ("curve", "belt_curve"),
    "conveyor_turn": ("straight_b", "belt_straight_b"),
    "conveyor_return": ("curve", "belt_curve_mirror"),
    "conveyor_bend": ("straight_a", "belt_straight_a_mirror"),
    "conveyor_tail": ("torn", "belt_torn"),
}
SHADOW = RES + "footing_shadow.png"


def sections() -> dict:
    return json.loads((ART / "belt_sections.json").read_text())


def drawing(cover: dict, scale: float, foot_in: float) -> dict:
    meta = sections()[SECTION[cover["id"]][0]]
    w_px, h_px = meta["size_px"]
    south = cover["at"][1] + cover["size_m"][1] / 2
    top = south - foot_in - meta["footing_y_px"] * scale
    size = [round(w_px * scale, 3), round(h_px * scale, 3)]
    return {
        "art": RES + SECTION[cover["id"]][1] + ".png",
        "at": [cover["at"][0], round(top + size[1] / 2, 3)],
        "id": "arch_" + cover["id"].removeprefix("conveyor_"),
        "rotation_deg": 0,
        "size_m": size,
        "tint": "ffffffff",
    }


def band(row: dict, cover_id: str, grid: np.ndarray, origin: np.ndarray, scale: float) -> np.ndarray:
    name = SECTION[cover_id][1]
    meta = sections()[SECTION[cover_id][0]]
    alpha = np.asarray(Image.open(ART / (name + ".png")).convert("RGBA"))[:, :, 3] > 128
    alpha[: meta["footing_y_px"] - round(BAND_M / scale)] = False
    alpha[meta["footing_y_px"] :] = False
    w, h = row["size_m"]
    nx, ny = max(1, round(w / CELL)), max(1, round(h / CELL))
    small = np.asarray(Image.fromarray(alpha.astype(np.uint8) * 255).resize((nx, ny), Image.BILINEAR)) > 100
    x0 = round((row["at"][0] - w / 2 - origin[0]) / CELL)
    y0 = round((row["at"][1] - h / 2 - origin[1]) / CELL)
    mask = np.zeros(grid.shape, bool)
    mask[y0 : y0 + ny, x0 : x0 + nx] = small
    return mask


def rect_mask(cover: dict, grid: np.ndarray, origin: np.ndarray) -> np.ndarray:
    mask = np.zeros(grid.shape, bool)
    x0 = round((cover["at"][0] - cover["size_m"][0] / 2 - origin[0]) / CELL)
    y0 = round((cover["at"][1] - cover["size_m"][1] / 2 - origin[1]) / CELL)
    mask[y0 : y0 + round(cover["size_m"][1] / CELL), x0 : x0 + round(cover["size_m"][0] / CELL)] = True
    return mask


def rect_gap(a: dict, b: dict) -> float:
    dx = max(0.0, abs(a["at"][0] - b["at"][0]) - (a["size_m"][0] + b["size_m"][0]) / 2)
    dy = max(0.0, abs(a["at"][1] - b["at"][1]) - (a["size_m"][1] + b["size_m"][1]) / 2)
    return float(np.hypot(dx, dy))


def lanes(covers: list, rows: dict, scale: float) -> list:
    origin = np.array([-10.0, -10.0])
    grid = np.zeros((int(75 / CELL), int(75 / CELL)), bool)
    masks = {}
    for c in covers:
        masks[c["id"]] = band(rows[c["id"]], c["id"], grid, origin, scale) if c["id"] in rows else rect_mask(c, grid, origin)
    out = []
    for i, a in enumerate(covers):
        if a["id"] not in rows:
            continue
        dist = ndimage.distance_transform_edt(~masks[a["id"]]) * CELL
        for b in covers:
            if b["id"] == a["id"] or (b["id"] in rows and covers.index(b) < i):
                continue
            cg = rect_gap(a, b)
            if cg >= 15:
                continue
            dg = float(dist[masks[b["id"]]].min())
            out.append((a["id"], b["id"], round(cg, 2), round(dg, 2), cg < LANE_M or dg >= LANE_M))
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--scale", type=float, default=0.011)
    ap.add_argument("--foot-in", type=float, default=0.1)
    ap.add_argument("--write", action="store_true")
    ap.add_argument("--lanes")
    ap.add_argument("--search", action="store_true")
    args = ap.parse_args()
    data = json.loads(TABLE.read_text())
    row = data["dressings"]["arched_line"]
    covers = row["layout"]["cover"]
    belts = [c for c in covers if c["id"] in SECTION]

    def build(scale: float) -> dict:
        return {c["id"]: drawing(c, scale, args.foot_in) for c in belts}

    if args.search:
        for k in range(120, 40, -1):
            s = k / 10000
            bad = [r for r in lanes(covers, build(s), s) if not r[4]]
            print(f"scale {s:.4f} m/px: appliance {138 * s:.2f} m, section {788 * s:.2f} m, failing pairs {len(bad)}")
            if not bad:
                break
        return
    rows = build(args.scale)
    table = lanes(covers, rows, args.scale)
    text = [f"scale {args.scale} m/px, footing {args.foot_in} m inside the box south edge, solid lower band = the opaque pixels of the bottom {BAND_M} m above the footing line (the leg feet; beam, arches above and hanging appliances are overhead and do not close a lane)",
            "pair | collision gap m | drawn gap m | lane ok (needs >= 2.5 where collision gap >= 2.5)"]
    text += [f"{a} - {b} | {cg} | {dg} | {'ok' if ok else 'FAIL'}" for a, b, cg, dg, ok in table]
    print("\n".join(text))
    if args.lanes:
        Path(args.lanes).write_text("\n".join(text) + "\n")
    if args.write:
        for c in belts:
            c["art"] = SHADOW
        debris = [d for d in row["layout"]["debris"] if not d["id"].startswith(("hang_", "arch_", "conveyor_"))]
        debris += list(rows.values())
        row["layout"]["debris"] = debris
        keep = [i for i in row["over_print"] if not i.startswith(("hang_", "arch_", "conveyor_"))]
        row["over_print"] = keep + [r["id"] for r in rows.values()]
        TABLE.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")


main()
