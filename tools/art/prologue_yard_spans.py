"""Cut the overhead belt spans (white key, despeckled, trimmed) at the sections' scale.

python -W ignore -I tools/art/prologue_yard_spans.py [--sources DIR] [--out DIR]
(writes <out>/belt_span_<a>_<b>.png and belt_spans.json, prints each span's px and m size; --out defaults
to arched_line, --sources to prologue_yard_sources: the five n29 spans and the n30 mouth span)

The art jobs drew each span over its grey guide band (`prologue_yard_spans_layout.py --guide`), so a
sheet pixel maps straight back to the world: the guide put the span's path box at SHEET_AT, one sheet
px is SCALE metres. Every keyed component goes to the span whose guide band it overlaps most; the cut
keeps that offset as `top_left_m` (world metres of the cut's top-left pixel) in belt_spans.json.
"""

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

import prologue_yard_cut as cut
from prologue_yard_arched import despeckle
from prologue_yard_hall import MARGIN, OUT, SHADOW, WHITE, red_share
from prologue_yard_spans_layout import (BEAM_M, CLIP_HALF_M, MOUTH_LEAD_M, SCALE, SHEET, SHEET_AT, TIP_M,
                                        draw_band, end_gap, end_region, guide_points, spans)

HERE = Path(__file__).resolve().parent
SOURCES = {0: "n29/belt-spans", 1: "n29/belt-spans-b", 2: "n29/belt-spans-c", 3: "n30/belt-span-mouth-deep"}
REACH_PX = 40
RIDGE = 0.3
# The mouth span's art runs MOUTH_LEAD_M past its start (no end plate there): its first end clears that
# whole lead, and its door end plate overshoots the tip, so a second fit measures it again once clipped.
CLIP_REACH_M = {"mouth_door": (MOUTH_LEAD_M + BEAM_M, TIP_M)}
FIT_PASSES = {"mouth_door": 2}
# n30 05d: the mouth span's open end (its start, in the fire) melts out over this many metres along the
# beam instead of ending in a hard cut; the other five spans keep their cut ends.
FADE_FIRST_M = {"mouth_door": 0.5}


def guide_masks(sheet: int) -> dict:
    """{span name: (band mask on the sheet, world metres of sheet px 0,0)} for one guide sheet."""
    out = {}
    radius = BEAM_M / SCALE / 2
    for name, _a, _b, pts in spans():
        index, x0, y0 = SHEET_AT[name]
        if index != sheet:
            continue
        lo = pts.min(axis=0)
        px = (guide_points(name, pts) - lo) / SCALE + [x0, y0] + radius
        img = Image.new("L", SHEET, 0)
        draw_band(ImageDraw.Draw(img), px, 2 * (radius + REACH_PX), 255)
        out[name] = (np.asarray(img) > 0, lo - (np.array([x0, y0]) + radius) * SCALE)
    return out


def assign(rgba: np.ndarray, masks: dict) -> dict:
    """{span name: the sheet's opaque pixels of the components that overlap that span's band most}."""
    labels, count = ndimage.label(rgba[..., 3] > 0)
    keep = {name: np.zeros(labels.shape, bool) for name in masks}
    for i in range(1, count + 1):
        comp = labels == i
        hits = {name: int((comp & m).sum()) for name, (m, _o) in masks.items()}
        best = max(hits, key=hits.get)
        if hits[best] > 0:
            keep[best] |= comp
    return keep


def trimmed(rgba: np.ndarray, mask: np.ndarray) -> tuple:
    """The masked RGBA trimmed to its alpha with MARGIN px, and the sheet px of its top-left."""
    ys, xs = np.where(mask)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    out = np.zeros((y1 - y0 + 2 * MARGIN, x1 - x0 + 2 * MARGIN, 4), np.uint8)
    piece = rgba[y0:y1, x0:x1].copy()
    piece[~mask[y0:y1, x0:x1]] = 0
    out[MARGIN : MARGIN + y1 - y0, MARGIN : MARGIN + x1 - x0] = piece
    return out, (x0 - MARGIN, y0 - MARGIN)


def shifted(piece: np.ndarray, top_left: np.ndarray, ends: tuple, path: np.ndarray) -> np.ndarray:
    """The top-left that puts the piece's two end edges on the section beams' centre lines (least squares
    across both ends, ridge-damped)."""
    alpha = piece[..., 3] > 128
    normals, offsets = [], []
    for (tip, d), first in zip(ends, (True, False)):
        _gap, _along, lateral = end_gap(alpha, top_left, (tip, d), path, first)
        normals.append([-d[1], d[0]])
        offsets.append(-lateral)
    rows = np.vstack([np.array(normals), RIDGE * np.eye(2)])
    return top_left + np.linalg.lstsq(rows, np.concatenate([offsets, [0.0, 0.0]]), rcond=None)[0]


def clipped(piece: np.ndarray, top_left: np.ndarray, ends: tuple, path: np.ndarray, reach: tuple) -> np.ndarray:
    """The piece with what of each end region lies past its section tip cleared (within reach m of the tip)."""
    h, w = piece.shape[:2]
    xs, ys = np.meshgrid(np.arange(w), np.arange(h))
    pts = (top_left + (np.stack([xs, ys], axis=-1) + 0.5) * SCALE).reshape(-1, 2)
    alpha_flat = piece[..., 3].reshape(-1).copy()
    for (tip, d), first, radius in zip(ends, (True, False), reach):
        region = end_region(pts, path, first) & (np.linalg.norm(pts - tip, axis=1) < radius)
        lateral = np.abs((pts - tip) @ np.array([-d[1], d[0]]))
        alpha_flat[region & ((pts - tip) @ d < 0) & (lateral < CLIP_HALF_M)] = 0
    out = piece.copy()
    out[..., 3] = alpha_flat.reshape(h, w)
    return out


def fit(piece: np.ndarray, top_left: np.ndarray, ends: tuple, path: np.ndarray, name: str = "") -> tuple:
    """Shift the piece onto the section ends, then clear past each tip, so the span butts flush on the
    section's end plate. A span in FIT_PASSES re-measures its shift on the clipped piece and clips the
    unclipped piece again at that place. -> (piece, top_left)"""
    reach = CLIP_REACH_M.get(name, (TIP_M, TIP_M))
    top_left = shifted(piece, top_left, ends, path)
    for _ in range(FIT_PASSES.get(name, 1) - 1):
        top_left = shifted(clipped(piece, top_left, ends, path, reach), top_left, ends, path)
    return clipped(piece, top_left, ends, path, reach), top_left


def faded(piece: np.ndarray, top_left: np.ndarray, tip: tuple, length: float) -> np.ndarray:
    """The piece with its alpha ramped (smoothstep) from 0 at the tip to full over length m along the beam."""
    h, w = piece.shape[:2]
    xs, ys = np.meshgrid(np.arange(w), np.arange(h))
    pts = top_left + (np.stack([xs, ys], axis=-1) + 0.5) * SCALE
    t = np.clip(((pts - tip[0]) @ tip[1]) / length, 0.0, 1.0)
    out = piece.copy()
    out[..., 3] = np.round(piece[..., 3] * (t * t * (3 - 2 * t))).astype(np.uint8)
    return out


def cut_sheet(path: Path, sheet: int, out_dir: Path = OUT) -> dict:
    image = Image.open(path).convert("RGB")
    if image.size != SHEET:
        image = image.resize(SHEET, Image.LANCZOS)
    rgba = despeckle(np.asarray(cut.key_full(image, WHITE, SHADOW)))
    masks = guide_masks(sheet)
    meta = {}
    ends = {name: ((a, b), pts) for name, a, b, pts in spans()}
    for name, mask in assign(rgba, masks).items():
        piece, (px, py) = trimmed(rgba, mask)
        piece, top_left = fit(piece, masks[name][1] + np.array([px, py]) * SCALE, *ends[name], name)
        if name in FADE_FIRST_M:
            piece = faded(piece, top_left, ends[name][0][0], FADE_FIRST_M[name])
        file = f"belt_span_{name}"
        Image.fromarray(piece).save(out_dir / f"{file}.png")
        h, w = piece.shape[:2]
        meta[name] = {"art": file, "size_px": [w, h], "top_left_m": [round(float(v), 3) for v in top_left]}
        print(f"{file}: {w}x{h} px = {w * SCALE:.2f} x {h * SCALE:.2f} m; red {red_share(piece) * 100:.2f}%")
    return meta


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, default=HERE / "prologue_yard_sources")
    parser.add_argument("--out", type=Path, default=OUT)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    meta = {}
    for sheet, src in SOURCES.items():
        path = args.sources / f"{src}.png"
        if not path.exists():
            print(f"{src}: no source {path.name}, skipped")
            continue
        meta.update(cut_sheet(path, sheet, args.out))
    (args.out / "belt_spans.json").write_text(json.dumps(meta, indent=1, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
