"""d8 chars: cut a street-cast head card strip (helmet/head + collar, 5 facings) from a keyed 55 game
view sheet of the assets library (gtai-art/library/keyed/street/<id>_55.png: alpha-keyed, five
standing facings in the top row, action poses below).

usage: python -I tools/art/street_head.py <sheet.png> <out.png> [band=0.3] [cell_h=128] [wcap=0]
    [fix=-]

Finds the five figures in the top row (the widest alpha column runs above the sheet's middle),
crops each from its top down `band` of its own height (head and collar), bottom-aligns every crop in
a common cell and scales the cells to cell_h px tall: one strip, frame i at x = i * cell_w. Prints
each crop's head width (the widest run in its top fifth) so the card row's width can be set.
wcap > 0 keeps only wcap x the head width around the head's centre (drops a riot shield beside it,
the cut sides feathered over 8 px);
fix is a comma list: `orange` moves saturated orange (reserved: vermilion is danger only) to the
street slate; `navy` darkens the sheet's police blue to the game uniform's navy (value x0.62,
saturation x0.8: the cut-rig uniform measured 53,63,92 against the sheet's 74,101,166).
Raw art (no print). Deterministic.
"""

import sys

import numpy as np
from PIL import Image

sys.path.insert(0, __file__.rsplit("\\", 1)[0].rsplit("/", 1)[0])
import cut_facings as cf  # noqa: E402


def _knock_orange(px: np.ndarray) -> int:
    """Saturated orange/red-orange (hue 5-40 deg) -> street slate at the pixel's own value."""
    rgb = px[:, :, :3].astype(np.float32) / 255.0
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    hue = np.degrees(np.arctan2(np.sqrt(3) * (g - b), 2 * r - g - b)) % 360
    mask = (sat > 0.55) & (mx > 0.35) & (hue >= 5) & (hue <= 40) & (px[:, :, 3] > 0)
    slate = np.array([0.42, 0.46, 0.52], np.float32)
    px[mask, :3] = (
        (slate[None, :] * mx[mask][:, None] / 0.52 * 255).clip(0, 255).astype(np.uint8)
    )
    return int(mask.sum())


def _navy(px: np.ndarray) -> int:
    """Police blue -> the game uniform navy: value x0.62, saturation x0.8, hue kept."""
    rgb = px[:, :, :3].astype(np.float32) / 255.0
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    mask = (b > r + 0.08) & (b > g + 0.04) & (sat > 0.25) & (px[:, :, 3] > 0)
    v = mx[mask][:, None]
    grey = v * (1 - 0.8 * sat[mask][:, None])
    c = rgb[mask]
    # keep the hue: lerp each channel from the value towards the new grey floor, then scale
    norm = np.where(
        v - mn[mask][:, None] > 1e-6,
        (c - mn[mask][:, None]) / np.maximum(v - mn[mask][:, None], 1e-6),
        0,
    )
    out = (grey + norm * (v - grey)) * 0.62
    px[mask, :3] = (out * 255).clip(0, 255).astype(np.uint8)
    return int(mask.sum())


def main() -> None:
    args = sys.argv[1:]
    band = float(args[2]) if len(args) > 2 else 0.3
    cell_h = int(args[3]) if len(args) > 3 else 128
    wcap = float(args[4]) if len(args) > 4 else 0.0
    fixes = args[5].split(",") if len(args) > 5 else []
    rgba = np.asarray(Image.open(args[0]).convert("RGBA"))
    top = rgba[: int(rgba.shape[0] * 0.47)]
    solid = top[:, :, 3] > 128
    spans = sorted(
        cf.runs(solid.sum(axis=0) > 2), key=lambda s: s[1] - s[0], reverse=True
    )[:5]
    spans.sort()
    if len(spans) != 5:
        sys.exit(f"found {len(spans)} figures, wanted 5")
    crops = []
    for x0, x1 in spans:
        rows = np.where(solid[:, x0:x1].sum(axis=1) > 0)[0]
        y0, y1 = rows[0], rows[-1] + 1
        yb = y0 + int((y1 - y0) * band)
        head_rows = solid[y0 : y0 + (y1 - y0) // 5, x0:x1]
        head = head_rows.sum(axis=1).max()
        if wcap > 0:
            hx = x0 + int(np.where(head_rows.any(axis=0))[0].mean())
            half = int(head * wcap / 2)
            x0, x1 = max(x0, hx - half), min(x1, hx + half)
        sub = solid[y0:yb, x0:x1]
        cols = np.where(sub.sum(axis=0) > 0)[0]
        crops.append(top[y0:yb, x0 + cols[0] : x0 + cols[-1] + 1].copy())
        if wcap > 0:
            ramp = np.minimum(
                1.0,
                (
                    np.minimum(
                        np.arange(crops[-1].shape[1]),
                        np.arange(crops[-1].shape[1])[::-1],
                    )
                    + 1
                )
                / 8.0,
            )
            crops[-1][:, :, 3] = (crops[-1][:, :, 3] * ramp[None, :]).astype(np.uint8)
        if "orange" in fixes:
            print(f"  knocked {_knock_orange(crops[-1])} px orange")
        if "navy" in fixes:
            print(f"  navy {_navy(crops[-1])} px")
        print(
            f"figure {len(crops)}: crop {crops[-1].shape[1]}x{crops[-1].shape[0]}, head {head}px"
        )
    cw = max(c.shape[1] for c in crops) + 4
    ch = max(c.shape[0] for c in crops) + 4
    w = round(cw * cell_h / ch)
    strip = Image.new("RGBA", (w * 5, cell_h), (0, 0, 0, 0))
    for i, c in enumerate(crops):
        cell = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        cell.paste(Image.fromarray(c), ((cw - c.shape[1]) // 2, ch - 2 - c.shape[0]))
        strip.paste(cell.resize((w, cell_h), Image.LANCZOS), (i * w, 0))
    strip.save(args[1])
    print(f"{args[1]}: 5 frames of {w}x{cell_h} (crop cell {cw}x{ch})")


if __name__ == "__main__":
    main()
