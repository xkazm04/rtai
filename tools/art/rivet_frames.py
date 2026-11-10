"""d9 rivet: cut a library Rivet sheet (keyed, transparent) into one game strip of whole figures.

usage: python -I tools/art/rivet_frames.py <keyed.png> <out.png> <counts> [--left=<keyed_left.png>] [--cc=<band,..>]
       [--fig_h=110] [--json=<out.json>]

<counts> = figures per band, top to bottom, e.g. 5,6 (the base sheet: five facings, then walk,
sprint, roll, claw strike, hit, death) or 5,3 (an equipped sheet: five facings, then the fire or
swing toward camera-right, toward the camera, at rest). --left appends a one-band sheet of three
drawn left facings (3/4 left toward, left profile, 3/4 left away) after the first band, so the
strip is: facings 0-4, left 0-2, actions (the left row is matched on figure height: the library
drew it width-matched to the turned views, rivet_70_left_v4's notes).

python -I tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json cuts every strip the
manifest names (the owner-judged picks) into project/features/characters/art/view/<art>/;
--only=<name prefix> as a second argument cuts only those rows; a row's fig_h overrides the manifest's.
n13: a row's "ink_rim" ({"px", "reach"}) then cuts treatment B (a heavier ink rim round the blade,
tools/art/blade_ink_rim.py) into the strip; --no-ink-rim (or the key removed) cuts the strip without it.
A row's "windup" (tools/art/blade_windup.py options) also cuts <name>_windup.png from the cut strip.

Each band's figures are the <count> column clusters of its alpha (cut at the count-1 widest gaps:
a spark or a slash trail stays with its figure). Each figure's anchor is its helmet's centre (the
alpha centre of its top quarter) and its lowest alpha row (the feet). A band is scaled so its
median helmet width matches the first band's (the action rows are drawn larger), then everything
so the first band's median figure height is fig_h px. A row's feet_up (one fraction per first-band figure:
the part of its alpha height below its feet) stands a figure whose weapon hangs below them on
the feet: the printed pad is then the feet's height above the cell bottom (RivetStrips.FOOT_PX). One common cell over all figures, the anchor
on the cell's centre column and PAD px above its bottom. Raw art, premultiplied resampling.
Deterministic.
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

PAD = 2
JUMP = 1.12
MIN_W = 80
## The action row's scale over the facings' (the helmet ratio); a measure outside ACT_OK (a claw
## or a blade read as the dome) takes the manifest's act_k, else ACT_K (the sheets' typical 0.75).
ACT_OK = (0.55, 1.0)
ACT_K = 0.75


def _runs(mask: np.ndarray) -> list:
    out, start = [], None
    for i, v in enumerate(mask):
        if v and start is None:
            start = i
        elif not v and start is not None:
            out.append((start, i))
            start = None
    if start is not None:
        out.append((start, len(mask)))
    return out


def _bands(solid: np.ndarray, n: int) -> list:
    spans = [s for s in _runs(solid.sum(axis=1) > 2) if s[1] - s[0] > 24]
    if len(spans) < n:
        sys.exit(f"found {len(spans)} bands, wanted {n}")
    while len(spans) > n:  # merge across the narrowest gap
        gaps = [spans[i + 1][0] - spans[i][1] for i in range(len(spans) - 1)]
        i = int(np.argmin(gaps))
        spans[i : i + 2] = [(spans[i][0], spans[i + 1][1])]
    return spans


def _components(solid: np.ndarray, y0: int, y1: int, n: int) -> list:
    """--cc bands: figures whose blades overlap in x. The n largest alpha components are the
    figures; every other piece joins the figure whose centroid is nearest in x. Each figure keeps
    its own mask, so a neighbour's blade inside its box is not drawn."""
    lab, k = ndimage.label(solid[y0:y1])
    sizes = ndimage.sum(np.ones_like(lab), lab, range(1, k + 1))
    cx = [c[1] for c in ndimage.center_of_mass(np.ones_like(lab), lab, range(1, k + 1))]
    seeds = sorted(np.argsort(sizes)[::-1][:n], key=lambda i: cx[i])
    owner = [min(range(n), key=lambda j: abs(cx[i] - cx[seeds[j]])) for i in range(k)]
    out = []
    for j in range(n):
        full = np.zeros_like(solid)
        full[y0:y1] = np.isin(lab, [i + 1 for i in range(k) if owner[i] == j])
        rows, cols = np.where(full.any(axis=1))[0], np.where(full.any(axis=0))[0]
        f = _measure(full, cols[0], rows[0], cols[-1] + 1, rows[-1] + 1)
        f["mask"] = full[rows[0] : rows[-1] + 1, cols[0] : cols[-1] + 1]
        out.append(f)
    return out


def _figures(solid: np.ndarray, y0: int, y1: int, n: int, cc: bool = False) -> list:
    if cc:
        return _components(solid, y0, y1, n)
    sub = solid[y0:y1]
    prof = sub.sum(axis=0)
    runs = _runs(prof > 1)
    while len(runs) < n:  # two figures touch in x: split the widest run at its thinnest column
        i = max(range(len(runs)), key=lambda j: runs[j][1] - runs[j][0])
        a, b = runs[i]
        lo, hi = a + (b - a) // 5, b - (b - a) // 5
        c = lo + int(np.argmin(prof[lo:hi]))
        runs[i : i + 1] = [(a, c), (c, b)]
    gaps = sorted(range(len(runs) - 1), key=lambda i: runs[i + 1][0] - runs[i][1], reverse=True)
    cuts = sorted(gaps[: n - 1])
    groups, start = [], 0
    for c in cuts + [len(runs) - 1]:
        groups.append((runs[start][0], runs[c][1]))
        start = c + 1
    out = []
    for x0, x1 in groups:
        rows = np.where(sub[:, x0:x1].any(axis=1))[0]
        out.append(_measure(solid, x0, y0 + rows[0], x1, y0 + rows[-1] + 1))
    return out


def _measure(solid: np.ndarray, x0: int, y0: int, x1: int, y1: int) -> dict:
    """The helmet: from the figure's topmost pixel down a third of its height, the alpha run on
    each row that holds the dome's centre column (a raised blade beside it is its own run). The
    scan stops where that run jumps wider by JUMP at once (an arm or claw joining the dome); its
    widest row before that is the helmet width, that row's centre the anchor."""
    cx = int(np.median(np.where(solid[y0, x0:x1])[0]))
    best, prev = (0, cx, cx + 1), 0
    for y in range(y0, y0 + max(4, (y1 - y0) // 3)):
        run = next(((a, b) for a, b in _runs(solid[y, x0:x1]) if a <= cx < b), None)
        if run is None:
            break
        w = run[1] - run[0]
        if prev >= MIN_W and w > prev * JUMP:
            break
        prev = w
        if w > best[0]:
            best = (w, run[0], run[1])
    return {"box": (x0, y0, x1, y1), "ax": x0 + 0.5 * (best[1] + best[2]),
            "head_w": float(best[0]), "h": y1 - y0}


def _sheet(path: str, counts: list, cc: tuple = ()) -> tuple:
    rgba = Image.open(path).convert("RGBA")
    solid = np.asarray(rgba)[:, :, 3] > 128
    bands = _bands(solid, len(counts))
    return rgba, [_figures(solid, b[0], b[1], n, i in cc) for i, (b, n) in enumerate(zip(bands, counts))]


def _feet_up(figs: list, fracs: list) -> None:
    """A figure whose weapon hangs below its feet: `h` becomes helmet top to feet, fracs[i] of the
    figure's alpha height (measured on the strip) being the part below them; `feet_h` keeps it."""
    for f, up in zip(figs, fracs):
        f["feet_h"] = round((f["box"][3] - f["box"][1]) * (1.0 - up))
        f["h"] = f["feet_h"]


def _ink_rim(path: str, rim: dict) -> None:
    """n13: a row's "ink_rim" ({"px", "reach"}) cuts treatment B into the strip (blade_ink_rim.py)."""
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from blade_ink_rim import ink_rim  # noqa: E402

    ink_rim(path, path, float(rim["px"]), float(rim["reach"]))
    print(f"ink rim px {rim['px']} reach {rim['reach']}: {path}")


def _windup(path: str, opts: dict) -> None:
    """n13: a row's "windup" (blade_windup.py options) cuts <name>_windup.png from the cut strip."""
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from blade_windup import cut  # noqa: E402

    dst = path[: -len(".png")] + "_windup.png"
    cut(path, 8, {k: str(v) for k, v in opts.items()}).save(dst, optimize=True)
    print(f"windup {opts}: {dst}")


def _manifest(path: str, only: str = "", no_rim: bool = False) -> None:
    with open(path, encoding="utf-8") as fh:
        man = json.load(fh)
    lib, out = man["library"], man["out"]
    for art, rows in man["strips"].items():
        for name, row in rows.items():
            if not name.startswith(only):
                continue
            argv = [f"{lib}/{row['sheet']}", f"{out}/{art}/{name}.png", row["counts"]]
            if "cc" in row:
                argv.append(f"--cc={row['cc']}")
            if "act_k" in row:
                argv.append(f"--act_k={row['act_k']}")
            if "feet_up" in row:
                argv.append(f"--feet_up={row['feet_up']}")
            if "left" in row:
                argv.append(f"--left={lib}/{row['left']}")
            sys.argv = [sys.argv[0]] + argv + [f"--fig_h={row.get('fig_h', man['fig_h'])}"]
            main()
            if "ink_rim" in row and not no_rim:
                _ink_rim(f"{out}/{art}/{name}.png", row["ink_rim"])
            if "windup" in row:
                _windup(f"{out}/{art}/{name}.png", row["windup"])


def main() -> None:
    if len(sys.argv) >= 2 and sys.argv[1].startswith("--manifest="):
        rest = [a for a in sys.argv[2:] if a != "--no-ink-rim"]
        only = rest[0].split("=", 1)[1] if rest else ""
        _manifest(sys.argv[1].split("=", 1)[1], only, "--no-ink-rim" in sys.argv)
        return
    opts = {a.split("=")[0][2:]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--")}
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    counts = [int(c) for c in args[2].split(",")]
    fig_h = float(opts.get("fig_h", 110))
    cc = tuple(int(c) for c in opts["cc"].split(",")) if "cc" in opts else ()
    rgba, bands = _sheet(args[0], counts, cc)
    if "feet_up" in opts:
        _feet_up(bands[0], [float(v) for v in opts["feet_up"].split(",")])
    ref_w = float(np.median([f["head_w"] for f in bands[0]]))
    k0 = fig_h / float(np.median([f["h"] for f in bands[0]]))
    items = [(rgba, f, k0) for f in bands[0]]
    if "left" in opts:
        lrgba, lbands = _sheet(opts["left"], [3])
        lk = float(np.median([f["h"] for f in bands[0]]))
        lk /= float(np.median([f["h"] for f in lbands[0]]))  # turned helmets are narrower
        items += [(lrgba, f, k0 * lk) for f in lbands[0]]
    for band in bands[1:]:
        bk = ref_w / float(np.median([f["head_w"] for f in band]))
        if "act_k" in opts or not ACT_OK[0] <= bk <= ACT_OK[1]:
            print(f"act_k: measured {bk:.2f}, using {opts.get('act_k', ACT_K)}", file=sys.stderr)
            bk = float(opts.get("act_k", ACT_K))
        items += [(rgba, f, k0 * bk) for f in band]
    half = max(max(f["ax"] - f["box"][0], f["box"][2] - f["ax"]) * k for _, f, k in items)
    up = max(f.get("feet_h", f["box"][3] - f["box"][1]) * k for _, f, k in items)
    below = max((f["box"][3] - f["box"][1] - f.get("feet_h", f["box"][3] - f["box"][1])) * k for _, f, k in items)
    below = int(np.ceil(below))
    cw, ch = int(np.ceil(2 * half)) + 4, int(np.ceil(up)) + PAD + 2 + below
    out = Image.new("RGBA", (cw * len(items), ch), (0, 0, 0, 0))
    for i, (src, f, k) in enumerate(items):
        x0, y0, x1, y1 = f["box"]
        fig = src.crop((x0, y0, x1, y1))
        if "mask" in f:  # a --cc figure: only its own pieces
            alpha = np.asarray(fig)[:, :, 3] * f["mask"]
            fig.putalpha(Image.fromarray(alpha.astype(np.uint8)))
        fig = fig.convert("RGBa")
        size = (max(1, round((x1 - x0) * k)), max(1, round((y1 - y0) * k)))
        fig = fig.resize(size, Image.LANCZOS).convert("RGBA")
        px = i * cw + round(cw / 2 - (f["ax"] - x0) * k)
        py = ch - PAD - below - round(f.get("feet_h", y1 - y0) * k)
        out.alpha_composite(fig, (px, py))
    out.save(args[1], optimize=True)
    meta = {"cells": len(items), "cell": [cw, ch], "fig_h": fig_h, "pad": PAD + below, "src": args[0]}
    meta["scales"] = [round(k, 4) for _, _, k in items]
    if "json" in opts:
        with open(opts["json"], "w", encoding="utf-8") as fh:
            json.dump(meta, fh, indent=1, sort_keys=True)
    print(json.dumps(meta))


if __name__ == "__main__":
    main()
