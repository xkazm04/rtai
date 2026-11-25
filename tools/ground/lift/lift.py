"""n31 ground lift: Rivet's body travel, sole lift and drop-shadow gap from delivered frames.

Reads the probe's frames (project/dev/ground_n31/lift_probe.gd via capture.mjs): for each tick
`<stem>_a.png` (full), `_b.png` (drop shadows hidden), `_c.png` (Rivet hidden), plus
frames.jsonl (the sim's ground point and the code's contact ellipse, crop px). Body pixels are
where b differs from c; shadow pixels are where a is darker than b. Writes gtai.ground-lift/1.

  python -I tools/ground/lift/lift.py --run p70_hands=<dir> [--run ...] --json F --md F [--check D]
"""

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

SCHEMA = "gtai.ground-lift/1"
BODY_T = 12  # max channel |b - c| for a body pixel
SHADOW_T = 2.0  # luminance drop a -> b for a shadow pixel
MIN_ROW_PX = 2  # a row needs this many pixels to count (antialias flecks)
OCT_NAMES = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]
LUM = np.array([0.299, 0.587, 0.114])


def _rgb(img):
    return np.asarray(img.convert("RGB"), dtype=np.int16)


def body_mask(b, c):
    return np.abs(b - c).max(axis=2) > BODY_T


def shadow_mask(a, b, body):
    drop = (b * LUM).sum(axis=2) - (a * LUM).sum(axis=2)
    return (drop > SHADOW_T) & ~body


def _rows(mask):
    return np.flatnonzero(mask.sum(axis=1) >= MIN_ROW_PX)


def ellipse_of(mask):
    """Centre y from the widest rows (robust to feet covering its top), radii, bbox."""
    rows = _rows(mask)
    if not len(rows):
        return None
    ends = {}
    for y in rows:
        xs = np.flatnonzero(mask[y])
        ends[int(y)] = (int(xs[0]), int(xs[-1]))
    span = {y: b - a + 1 for y, (a, b) in ends.items()}
    widest = max(span.values())
    best = [y for y, w in span.items() if w >= widest - 1]
    cy = float(np.mean(best)) + 0.5
    left = min(ends[y][0] for y in best)
    right = max(ends[y][1] for y in best)
    return {
        "cx": (left + right + 1) / 2.0, "cy": cy, "rx": widest / 2.0,
        "ry": float(rows[-1] + 1 - cy), "top": int(rows[0]), "bottom": int(rows[-1] + 1),
        "px": int(mask.sum()),
    }


def measure(a, b, c):
    """One frame: helmet top (top edge px), lowest sole (bottom edge px), shadow ellipse."""
    body = body_mask(b, c)
    rows = _rows(body)
    out = {"body_px": int(body.sum()), "helmet_y": None, "sole_y": None, "shadow": None}
    if len(rows):
        out["helmet_y"] = int(rows[0])
        out["sole_y"] = int(rows[-1] + 1)
    out["shadow"] = ellipse_of(shadow_mask(a, b, body))
    return out


def load_run(folder):
    folder = Path(folder)
    frames = []
    for line in (folder / "frames.jsonl").read_text().splitlines():
        meta = json.loads(line)
        imgs = [_rgb(Image.open(folder / f"{meta['stem']}_{p}.png")) for p in "abc"]
        frames.append({**meta, **measure(*imgs)})
    return frames


def _corr(x, y):
    if len(x) < 3 or np.std(x) == 0 or np.std(y) == 0:
        return None
    return round(float(np.corrcoef(x, y)[0, 1]), 3)


def _r(v, n=2):
    return round(float(v), n)


def summarize(frames):
    """Per gait/octant series -> one table row (crop = screen px; cm via the sim's ppm)."""
    ok = [f for f in frames if f["sole_y"] is not None and f["shadow"] is not None]
    row = {"frames": len(frames), "measured": len(ok)}
    if len(ok) < 2:
        return row
    sole = np.array([f["sole_y"] for f in ok], float)
    helm = np.array([f["helmet_y"] for f in ok], float)
    shy = np.array([f["shadow"]["cy"] for f in ok], float)
    ground = np.array([f["ground_y"] for f in ok], float)
    ppm = float(np.mean([f["screen_ppm"] for f in ok]))
    planted = sole >= sole.max() - 1
    lift = ground - sole
    gap = np.abs(shy - sole)
    travel = helm.max() - helm.min()
    row.update({
        "planted": int(planted.sum()), "screen_ppm": _r(ppm),
        "speed_mps": _r(np.mean([f.get("speed", 0.0) for f in ok]), 1),
        "phase_cover": len({int((f["phase"] % 1.0) * 10) for f in ok}) / 10.0,
        "travel_px": _r(travel), "travel_cm": _r(travel / ppm * 100, 1),
        "height_px": _r(np.max(sole - helm)),
        "lift_planted_px": _r(lift[planted].mean()),
        "lift_max_px": _r(lift.max()), "lift_min_px": _r(lift.min()),
        "sole_range_px": _r(sole.max() - sole.min()),
        "gap_planted_max_px": _r(gap[planted].max()),
        "gap_planted_mean_px": _r(gap[planted].mean()),
        "gap_all_max_px": _r(gap.max()),
        "shadow_cy_range_px": _r(shy.max() - shy.min()),
        "shadow_rx_px": _r(np.mean([f["shadow"]["rx"] for f in ok]), 1),
        "shadow_ry_px": _r(np.mean([f["shadow"]["ry"] for f in ok]), 1),
        "corr_shadow_helmet": _corr(shy, helm),
        "code_shadow_err_px": _r(np.mean([abs(f["code_cy"] - f["shadow"]["cy"]) for f in ok])),
        "card_up_max_px": _r(max(f.get("card_up", 0.0) for f in ok)),
        "card_up_min_px": _r(min(f.get("card_up", 0.0) for f in ok)),
    })
    return row


def table(runs):
    rows = []
    for label, frames in runs.items():
        for gait, octant in sorted({(f["gait"], f["octant"]) for f in frames}):
            sub = [f for f in frames if f["gait"] == gait and f["octant"] == octant]
            rows.append({"run": label, "gait": gait, "dir": OCT_NAMES[octant], "octant": octant,
                         **summarize(sub)})
    return rows


COLS = [("run", "run"), ("gait", "gait"), ("dir", "dir"), ("speed_mps", "m/s"), ("frames", "frames"),
        ("measured", "measured"), ("planted", "planted"), ("phase_cover", "phase cover"),
        ("travel_px", "helmet travel px"), ("travel_cm", "travel cm"),
        ("lift_planted_px", "sole lift planted px"), ("lift_max_px", "sole lift max px"),
        ("gap_planted_max_px", "shadow-sole gap planted max"),
        ("gap_planted_mean_px", "gap planted mean"), ("gap_all_max_px", "gap all max"),
        ("shadow_cy_range_px", "shadow y range"), ("corr_shadow_helmet", "corr shadow/helmet"),
        ("shadow_rx_px", "shadow rx"), ("shadow_ry_px", "shadow ry"),
        ("card_up_max_px", "card lift max px (code)"), ("code_shadow_err_px", "code vs frame shadow y")]


def markdown(rows):
    head = "| " + " | ".join(t for _, t in COLS) + " |"
    sep = "|" + "---|" * len(COLS)
    body = ["| " + " | ".join(str(r.get(k, "-")) for k, _ in COLS) + " |" for r in rows]
    return "\n".join([head, sep, *body]) + "\n"


def draw_check(folder, frame, dest, scale=3):
    """Frame a with ground (yellow), sole (red), helmet (green), shadow centre + ellipse (blue)."""
    img = Image.open(Path(folder) / f"{frame['stem']}_a.png").convert("RGB")
    w, h = img.size
    img = img.resize((w * scale, h * scale), Image.NEAREST)
    d = ImageDraw.Draw(img)
    s = frame["shadow"]
    lines = [(frame["ground_y"], (255, 255, 0)), (frame["sole_y"], (255, 0, 0)),
             (frame["helmet_y"], (0, 255, 0)), (s["cy"], (0, 160, 255))]
    for y, col in lines:
        d.line([(0, y * scale), (w * scale, y * scale)], fill=col)
    box = [s["cx"] - s["rx"], s["cy"] - s["ry"], s["cx"] + s["rx"], s["cy"] + s["ry"]]
    d.ellipse([v * scale for v in box], outline=(0, 160, 255))
    img.save(dest)


def checks(folder, frames, out_dir, label):
    """Three frames per gait: highest helmet, lowest helmet, highest sole (most lift)."""
    out_dir.mkdir(parents=True, exist_ok=True)
    for gait in sorted({f["gait"] for f in frames}):
        ok = [f for f in frames if f["gait"] == gait and f["shadow"] and f["sole_y"] is not None]
        if not ok:
            continue
        picks = {"helm_hi": min(ok, key=lambda f: f["helmet_y"]),
                 "helm_lo": max(ok, key=lambda f: f["helmet_y"]),
                 "sole_hi": min(ok, key=lambda f: f["sole_y"])}
        for tag, f in picks.items():
            draw_check(folder, f, out_dir / f"{label}_{gait}_{tag}_{f['stem']}.png")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run", action="append", required=True, help="label=frames dir")
    ap.add_argument("--json", required=True)
    ap.add_argument("--md", required=True)
    ap.add_argument("--check")
    ap.add_argument("--title", default="Rivet lift")
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
    print(f"lift: {len(rows)} rows, {sum(r['frames'] for r in rows)} frames")


if __name__ == "__main__":
    main()
