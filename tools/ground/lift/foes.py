"""n31 ground foe lift: head-top travel, sole lift and drop-shadow gap per enemy kind and gait.

Reads the frames of project/dev/ground_n31/foe_lift_probe.gd (via foes_capture.mjs): per tick
`<stem>_a.png` (full), `_b.png` (drop shadows hidden), `_c.png` (foe hidden) plus frames.jsonl, and
measures them with lift.py's `measure` (body = b vs c, shadow = a darker than b). Unlike Rivet's
rows a kind may have no shadow at all: those rows say `none` and the shadow columns stay empty.
Writes gtai.ground-foe-lift/1.

  python -I tools/ground/lift/foes.py --run 32=<dir> [--run 64=<dir>] --json F --md F [--check D]
"""

import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))
import lift  # noqa: E402

SCHEMA = "gtai.ground-foe-lift/1"


def erode(mask, n=2):
    """3x3 erosion n times: drops the 1-2 px fringe a body edge leaves in the shadow mask."""
    for _ in range(n):
        p = np.pad(mask, 1)
        out = mask.copy()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                out &= p[1 + dy:1 + dy + mask.shape[0], 1 + dx:1 + dx + mask.shape[1]]
        mask = out
    return mask


def measure(a, b, c):
    """lift.measure with the shadow fitted on the eroded mask (radii grown back by the erosion)."""
    m = lift.measure(a, b, c)
    body = lift.body_mask(b, c)
    sh = lift.ellipse_of(erode(lift.shadow_mask(a, b, body)))
    if sh is not None and m["sole_y"] is not None and sh["cy"] <= m["helmet_y"] + 0.3 * (m["sole_y"] - m["helmet_y"]):
        sh = None  # a fit on the upper body is body shading, not a drop shadow
    if sh is not None:
        sh["rx"] += 2.0
        sh["ry"] += 2.0
    m["shadow"] = sh
    return m


def load_run(folder):
    """frames.jsonl rows + measure(); a frame with no body pixels keeps sole_y None."""
    folder = Path(folder)
    frames = []
    for line in (folder / "frames.jsonl").read_text().splitlines():
        meta = json.loads(line)
        imgs = [lift._rgb(Image.open(folder / f"{meta['stem']}_{p}.png")) for p in "abc"]
        frames.append({**meta, **measure(*imgs)})
    return frames


def summarize(frames):
    """One kind/gait/direction series -> a row (crop px = screen px; cm via the screen ppm)."""
    r = lift._r
    body = [f for f in frames if f["sole_y"] is not None]
    row = {"frames": len(frames), "measured": len(body)}
    if len(body) < 2:
        return row
    sole = np.array([f["sole_y"] for f in body], float)
    helm = np.array([f["helmet_y"] for f in body], float)
    ground = np.array([f["ground_y"] for f in body], float)
    ppm = float(np.mean([f["screen_ppm"] for f in body]))
    planted = sole >= sole.max() - 1
    height = float(np.max(sole - helm))
    travel = float(helm.max() - helm.min())
    row.update({
        "planted": int(planted.sum()), "screen_ppm": r(ppm),
        "speed_mps": r(np.mean([f["speed"] for f in body]), 1),
        "phase_cover": len({int((f["phase"] % 1.0) * 10) for f in body}) / 10.0,
        "height_px": r(height), "travel_px": r(travel), "travel_cm": r(travel / ppm * 100, 1),
        "travel_pct": r(travel / height * 100, 1),
        "lift_planted_px": r((ground - sole)[planted].mean()),
        "lift_max_px": r((ground - sole).max()), "lift_min_px": r((ground - sole).min()),
        "sole_range_px": r(sole.max() - sole.min()),
    })
    shad = [f for f in body if f["shadow"] is not None]
    row["shadow"] = "none" if not shad else "yes" if len(shad) == len(body) else "partial"
    row["shadow_frames"] = len(shad)
    if len(shad) < 2:
        return row
    s_sole = np.array([f["sole_y"] for f in shad], float)
    s_helm = np.array([f["helmet_y"] for f in shad], float)
    s_gr = np.array([f["ground_y"] for f in shad], float)
    shy = np.array([f["shadow"]["cy"] for f in shad], float)
    gap = np.abs(shy - s_sole)
    sp = s_sole >= s_sole.max() - 1
    row.update({
        "gap_planted_max_px": r(gap[sp].max()), "gap_planted_mean_px": r(gap[sp].mean()),
        "gap_all_max_px": r(gap.max()), "gap_all_max_cm": r(gap.max() / ppm * 100, 1),
        "shadow_cy_range_px": r(shy.max() - shy.min()),
        "shadow_below_ground_px": r((shy - s_gr).mean()),
        "shadow_rx_px": r(np.mean([f["shadow"]["rx"] for f in shad]), 1),
        "shadow_ry_px": r(np.mean([f["shadow"]["ry"] for f in shad]), 1),
        "corr_shadow_helmet": lift._corr(shy, s_helm),
    })
    return row


def table(runs):
    rows = []
    for label, frames in runs.items():
        keys = sorted({(f["kind"], f["gait"], f["octant"]) for f in frames})
        for kind, gait, octant in keys:
            sub = [f for f in frames if (f["kind"], f["gait"], f["octant"]) == (kind, gait, octant)]
            rows.append({"run": f"{kind}_{label}", "kind": kind, "gait": gait,
                         "dir": lift.OCT_NAMES[octant], "octant": octant, **summarize(sub)})
    return rows


COLS = [("run", "run"), ("gait", "gait"), ("dir", "dir"), ("speed_mps", "m/s"), ("frames", "frames"),
        ("measured", "measured"), ("planted", "planted"), ("phase_cover", "phase cover"),
        ("height_px", "body height px"), ("travel_px", "head travel px"), ("travel_cm", "travel cm"),
        ("travel_pct", "travel % of height"), ("lift_planted_px", "sole lift planted px"),
        ("lift_max_px", "sole lift max px"), ("shadow", "shadow"),
        ("gap_planted_max_px", "gap planted max"), ("gap_planted_mean_px", "gap planted mean"),
        ("gap_all_max_px", "gap all max"), ("gap_all_max_cm", "gap all max cm"),
        ("shadow_cy_range_px", "shadow y range"), ("shadow_below_ground_px", "shadow below ground px"),
        ("corr_shadow_helmet", "corr shadow/head")]


def markdown(rows):
    head = "| " + " | ".join(t for _, t in COLS) + " |"
    sep = "|" + "---|" * len(COLS)
    body = ["| " + " | ".join(str(r.get(k, "-")) for k, _ in COLS) + " |" for r in rows]
    return "\n".join([head, sep, *body]) + "\n"


def draw_check(folder, f, dest, scale=3):
    """Frame a with ground (yellow), sole (red), head top (green), shadow centre + ellipse (blue)."""
    img = Image.open(Path(folder) / f"{f['stem']}_a.png").convert("RGB")
    w, h = img.size
    img = img.resize((w * scale, h * scale), Image.NEAREST)
    d = ImageDraw.Draw(img)
    lines = [(f["ground_y"], (255, 255, 0)), (f["sole_y"], (255, 0, 0)), (f["helmet_y"], (0, 255, 0))]
    s = f["shadow"]
    if s:
        lines.append((s["cy"], (0, 160, 255)))
        box = [s["cx"] - s["rx"], s["cy"] - s["ry"], s["cx"] + s["rx"], s["cy"] + s["ry"]]
        d.ellipse([v * scale for v in box], outline=(0, 160, 255))
    for y, col in lines:
        d.line([(0, y * scale), (w * scale, y * scale)], fill=col)
    img.save(dest)


def checks(folder, frames, out_dir, label):
    """Per kind and gait, on its most-travelling direction: highest head, lowest head, highest sole."""
    out_dir.mkdir(parents=True, exist_ok=True)
    for kind, gait in sorted({(f["kind"], f["gait"]) for f in frames}):
        sub = [f for f in frames if f["kind"] == kind and f["gait"] == gait and f["sole_y"] is not None]
        by_oct = {}
        for f in sub:
            by_oct.setdefault(f["octant"], []).append(f)
        if not by_oct:
            continue
        best = max(by_oct.values(), key=lambda s: max(f["helmet_y"] for f in s) - min(f["helmet_y"] for f in s))
        picks = {"head_hi": min(best, key=lambda f: f["helmet_y"]),
                 "head_lo": max(best, key=lambda f: f["helmet_y"]),
                 "sole_hi": min(best, key=lambda f: f["sole_y"])}
        for tag, f in picks.items():
            draw_check(folder, f, out_dir / f"{kind}_{gait}_{label}_{tag}_{f['stem']}.png")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run", action="append", required=True, help="label=frames dir (label = ppm)")
    ap.add_argument("--json", required=True)
    ap.add_argument("--md", required=True)
    ap.add_argument("--check")
    ap.add_argument("--title", default="Foe lift")
    args = ap.parse_args()
    runs = {}
    for spec in args.run:
        label, folder = spec.split("=", 1)
        runs[label] = load_run(folder)
        if args.check:
            checks(folder, runs[label], Path(args.check), label)
    rows = table(runs)
    Path(args.json).write_text(json.dumps({"schema": SCHEMA, "rows": rows}, indent=1) + "\n")
    Path(args.md).write_text(f"# {args.title}\n\n" + markdown(rows))
    print(f"foes: {len(rows)} rows, {sum(r['frames'] for r in rows)} frames")


if __name__ == "__main__":
    main()
