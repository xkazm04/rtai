"""Procedural city road marks (d5-city, 2026-11-03; no AI): the target frame's approach zebras
and a plain asphalt junction box (the crossing ring of road_intersection_tone moves onto the
approaches as zebra decals), and a dash eraser that stops the lane dashes ~2 m short of the
zebra. Deterministic (fixed seed); 96 px/m like every ground tile.
    python -I tools/art/city_marks.py
writes project/features/city/art/ground/road_box_plain.png, .../decals/zebra.png and
.../decals/dash_eraser.png."""
import random
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "project" / "features" / "city" / "art"
PPM = 96
PAPER = (237, 227, 206)


def plain_box() -> Image.Image:
    """8 x 8 m of the road tile's clean asphalt band (between the edge line and the dashes),
    stacked with alternate mirror flips so the noise runs on without a seam."""
    src = Image.open(ART / "ground" / "road_straight_tone_c.png").convert("RGBA")
    band = src.crop((0, 60, 768, 300))  # 2.5 m of asphalt, no marks (thumb-checked)
    out = Image.new("RGBA", (768, 768))
    y, flip = 0, False
    while y < 768:
        piece = band.transpose(Image.FLIP_TOP_BOTTOM) if flip else band
        out.paste(piece, (0, y))
        y += band.height
        flip = not flip
    return out


def zebra() -> Image.Image:
    """8 m across the road x 2.4 m deep: 8 stripes 0.45 m wide with 0.45 m gaps, worn edges."""
    rng = random.Random(9)
    w, h = 8 * PPM, int(2.4 * PPM)
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    sw = int(0.45 * PPM)
    x0 = (w - (8 * sw + 7 * sw)) // 2
    for s in range(8):
        left = x0 + s * 2 * sw
        for y in range(6, h - 6):
            for x in range(left, left + sw):
                edge = min(x - left, left + sw - 1 - x, y - 6, h - 7 - y)
                if edge < 2 and rng.random() < 0.35:
                    continue
                if rng.random() < 0.012:
                    continue
                px[x, y] = PAPER + (255,)
    return img


def dash_eraser() -> Image.Image:
    """4 m x 0.6 m of clean asphalt from the road tile's band, feathered 0.12 m on every edge,
    laid over the box-side half of an approach arm (its dashes sit at 0.7-3.8 m from the box)."""
    src = Image.open(ART / "ground" / "road_straight_tone_c.png").convert("RGBA")
    w, h = 4 * PPM, int(0.6 * PPM)
    img = src.crop((96, 150, 96 + w, 150 + h))
    feather = int(0.12 * PPM)
    alpha = Image.new("L", (w, h))
    ap = alpha.load()
    for y in range(h):
        for x in range(w):
            edge = min(x, w - 1 - x, y, h - 1 - y)
            ap[x, y] = 255 if edge >= feather else int(255 * (edge + 0.5) / feather)
    img.putalpha(alpha)
    return img


def main() -> int:
    plain_box().save(ART / "ground" / "road_box_plain.png")
    zebra().save(ART / "decals" / "zebra.png")
    dash_eraser().save(ART / "decals" / "dash_eraser.png")
    return 0


if __name__ == "__main__":
    sys.exit(main())
