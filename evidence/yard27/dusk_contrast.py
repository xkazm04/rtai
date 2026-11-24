"""n27 contrast at dusk: patrol blue outside and inside the fire pools, rifle round, pellet.

Inputs: the --dusk captures of tools/art/prologue_yard_stills.mjs --dressing=line_fire, one directory
per arm (--day, --dusk): day/ (the same line_fire row with the day grade and no pools) and dusk/ (the
row under test). The light is render only, so both arms run the same sim and every cop is paired with
itself in daylight (n26 compared torn_line with line_fire, two different sims). Each directory holds
t*.png, t*_ground.png and sample_points.json.
Pool centres and radii come from the line_fire row of project/data/tables/prologue_yard_dressings.json.
A patrol cop is INSIDE when it stands within half a radius of a fire pool (the pool core, light level
at least 0.5), OUTSIDE when it stands beyond the full radius of every pool. The uniform mask is the
daylight blue (b > r + 13, b > g + 6) and the same pixels are read in the dusk frame, so a pool that
turns blue into grey cannot hide by shrinking the mask. Hue is the hue of the mean dusk colour of
those pixels. Rounds follow evidence/yard26/dusk_contrast.py (first qualifying frame per arm).
"""

import argparse
import colorsys
import json
from pathlib import Path

import numpy as np
from PIL import Image

ARMS = ("day", "dusk")
ROUNDS = ("rifle", "shotgun")
W, H = 64, 80
TABLE = Path(__file__).resolve().parents[2] / "project/data/tables/prologue_yard_dressings.json"
FLOORS = {"outside": 0.65, "inside": 0.65, "rifle": 1.00, "shotgun": 0.90}


def examples(root, kind):
    """First qualifying exposure, all on-screen examples; overlapping pellet pixels count once."""
    frames = json.loads((root / "sample_points.json").read_text())["frames"]
    for frame in frames:
        points = [p for p in frame["points"] if p["kind"] == kind]
        if not points:
            continue
        label = frame["frame"]
        hero = Image.open(root / f"{label}.png").convert("RGB")
        ground = Image.open(root / f"{label}_ground.png").convert("RGB")
        under = ground if kind == "patrol_cop" else Image.open(root / f"{label}_no_rounds.png")
        counted = np.zeros((hero.height, hero.width), dtype=bool)
        found = False
        for point in points:
            x, y = point["xy"]
            left, top = x - W // 2, y - 64
            box = (left, top, left + W, top + H)
            if left < 0 or top < 0 or box[2] > hero.width or box[3] > hero.height:
                continue
            fg, bg, off = [np.asarray(img.crop(box).convert("RGB"), dtype=int)
                           for img in (hero, ground, under)]
            r, g, b = fg.transpose(2, 0, 1)
            yy, xx = np.mgrid[-64:H-64, -W//2:W//2]
            if kind == "patrol_cop":
                mask = (abs(xx) < 16) & (yy >= -55) & (yy < -15) & (b > r + 13) & (b > g + 6)
            else:
                mask = (abs(xx) <= 6) & (abs(yy) <= 6) & (r > g + 8) & (g > b + 16)
                # Reject intersections with rigs or nameplates under a live round.
                mask &= abs(off - bg).max(axis=2) <= 2
            taken = counted[top:box[3], left:box[2]]
            mask &= (abs(fg - off).max(axis=2) > 6) & ~taken
            if mask.any():
                found = True
                taken |= mask
                yield (label, box), hero.crop(box), ground.crop(box), mask
        if found:
            return
    raise ValueError(f"no measurable {kind} in {root}")


def luminance(rgb):
    srgb = rgb / 255.0
    linear = np.where(srgb <= 0.04045, srgb / 12.92, ((srgb + 0.055) / 1.055) ** 2.4)
    return linear @ [0.2126, 0.7152, 0.0722]


def pools():
    lights = json.loads(TABLE.read_text())["dressings"]["line_fire"]["lights"]
    radius = {k["id"]: k["radius_m"] for k in lights["kinds"]}
    return [(p["id"], p["kind"], np.array(p["at"]), radius[p["kind"]]) for p in lights["pools"]]


def region(pos, pool_list):
    reach = [(np.linalg.norm(pos - at) / r, kind) for _, kind, at, r in pool_list]
    if any(d <= 0.5 and kind.startswith("yard_fire") for d, kind in reach):
        return "inside"
    return "outside" if all(d > 1.0 for d, _ in reach) else "between"


def hue_deg(rgb):
    r, g, b = [float(c) / 255 for c in rgb]
    return colorsys.rgb_to_hsv(r, g, b)[0] * 360


def cops(dirs, pool_list):
    """(region, tick, id, day_ratio, dusk_ratio, hue, blue_kept, n) for every on-screen patrol cop."""
    day, dusk = [dirs[a] for a in ARMS]
    day_frames = json.loads((day / "sample_points.json").read_text())["frames"]
    dusk_frames = {f["tick"]: f for f in json.loads((dusk / "sample_points.json").read_text())["frames"]}
    for frame in day_frames:
        other = dusk_frames.get(frame["tick"])
        if other is None:
            continue
        label = frame["frame"]
        imgs = {a: [np.asarray(Image.open(d / f"{label}{s}.png").convert("RGB"), dtype=int)
                    for s in ("", "_ground")] for a, d in zip(ARMS, (day, dusk))}
        mine = {p["id"]: p for p in other["points"] if p["kind"] == "patrol_cop"}
        for p in frame["points"]:
            if p["kind"] != "patrol_cop" or p["id"] not in mine or "pos_m" not in p:
                continue
            x, y = p["xy"]
            top, left = y - 64, x - W // 2
            if left < 0 or top < 0 or left + W > 1920 or top + H > 1080:
                continue
            crop = lambda a: [im[top:top + H, left:left + W] for im in imgs[a]]
            (dfg, dbg), (nfg, nbg) = crop("day"), crop("dusk")
            r, g, b = dfg.transpose(2, 0, 1)
            yy, xx = np.mgrid[-64:H - 64, -W // 2:W // 2]
            mask = (abs(xx) < 16) & (yy >= -55) & (yy < -15) & (b > r + 13) & (b > g + 6)
            mask &= abs(dfg - dbg).max(axis=2) > 6
            if mask.sum() < 20:
                continue
            ratio = lambda fg, bg: float(np.mean((np.maximum(luminance(fg[mask]), luminance(bg[mask])) + 0.05)
                                                  / (np.minimum(luminance(fg[mask]), luminance(bg[mask])) + 0.05)))
            nr, ng, nb = nfg.transpose(2, 0, 1)
            kept = float(np.mean(((nb > nr + 13) & (nb > ng + 6))[mask]))
            yield (region(np.array(p["pos_m"]), pool_list), frame["tick"], p["id"],
                   ratio(dfg, dbg), ratio(nfg, nbg), hue_deg(nfg[mask].mean(axis=0)), kept, int(mask.sum()))


def rounds(dirs):
    """The round mask comes from the daylight frame; the same pixels are read in the dusk frame."""
    out = {}
    for kind in ROUNDS:
        day, dusk = [], []
        for (label, box), fg, bg, mask in examples(dirs["day"], kind):
            lum = lambda img: luminance(np.asarray(img.convert("RGB"), dtype=int)[mask])
            nfg = Image.open(dirs["dusk"] / f"{label}.png").convert("RGB").crop(box)
            nbg = Image.open(dirs["dusk"] / f"{label}_ground.png").convert("RGB").crop(box)
            for vals, (f, b) in ((day, (lum(fg), lum(bg))), (dusk, (lum(nfg), lum(nbg)))):
                vals.extend((np.maximum(f, b) + 0.05) / (np.minimum(f, b) + 0.05))
        out[kind] = (np.mean(day), np.mean(dusk), len(day), len(dusk))
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--day", type=Path, required=True, help="capture directory, day grade, no pools")
    parser.add_argument("--dusk", type=Path, required=True, help="capture directory of the row under test")
    parser.add_argument("--json", type=Path)
    args = parser.parse_args()
    pool_list = pools()
    dirs = {"day": args.day, "dusk": args.dusk}
    rows = list(cops(dirs, pool_list))
    report, ok = {}, True
    for where in ("outside", "inside", "between"):
        sub = [r for r in rows if r[0] == where]
        if not sub:
            print(f"patrol blue {where:8} no cop samples")
            report[where] = None
            ok &= where == "between"
            continue
        day, dusk = np.mean([r[3] for r in sub]), np.mean([r[4] for r in sub])
        hue, kept = np.mean([r[5] for r in sub]), np.mean([r[6] for r in sub])
        lo, hi = min(r[5] for r in sub), max(r[5] for r in sub)
        retained = dusk / day
        floor = FLOORS.get(where)
        verdict = "" if floor is None else ("PASS" if retained >= floor else "FAIL")
        print(f"patrol blue {where:8} day {day:.3f} dusk {dusk:.3f} retained {retained:.1%} "
              f"hue {hue:.0f} [{lo:.0f}..{hi:.0f}] blue kept {kept:.0%} cops {len({(r[1], r[2]) for r in sub})} {verdict}")
        report[where] = dict(day=day, dusk=dusk, retained=retained, hue=hue, hue_min=lo, hue_max=hi,
                             blue_kept=kept, cops=len(sub))
        if floor is not None:
            ok &= retained >= floor
        if where == "inside":
            ok &= 200 <= lo and hi <= 250
    for kind, (a, b, na, nb) in rounds(dirs).items():
        retained = b / a
        verdict = "PASS" if retained >= FLOORS[kind] else "FAIL"
        ok &= retained >= FLOORS[kind]
        print(f"{kind:12} day {a:.3f} dusk {b:.3f} retained {retained:.1%} ({na}, {nb} px) {verdict}")
        report[kind] = dict(day=a, dusk=b, retained=retained)
    if args.json:
        args.json.write_text(json.dumps(report, indent=2, default=float))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
