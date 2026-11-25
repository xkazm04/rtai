"""n30: recolour the nose band of Rivet's rocket and nuke_shell rounds to amber #EDAB42.

Mask = the n29 is_red gate plus the dark red-tinted ink pixels (hue <= 30 or >= 340, s > 0.25, any value) touching it
(the band's anti-aliased edge). Value and alpha kept; every other pixel is untouched. The source is always the PNG of SRC_REV
PNG (git show + git lfs smudge, never written into the tree), so a re-run gives the same result.
Usage: python -I recolour_band.py [--dry]
"""
import colorsys
import io
import subprocess
import sys
from PIL import Image

REPO = "C:/Users/kazda/kiro/gtai-wt/n23-street"
SRC_REV = "fde0b1f4c"  # the commit before the recolour (HEAD now holds the amber band)

ROOT = "C:/Users/kazda/kiro/gtai-wt/n23-street/project/features/combat/weapons/art/fx/"
NAMES = ("rocket", "nuke_shell")


def is_red(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    h *= 360
    return (h <= 24 or h >= 345) and s > 0.5 and v > 0.45


def is_edge(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    h *= 360
    return (h <= 30 or h >= 340) and s > 0.25


def head_png(name: str) -> Image.Image:
    rel = "project/features/combat/weapons/art/fx/" + name + ".png"
    blob = subprocess.run(["git", "-C", REPO, "show", SRC_REV + ":" + rel], capture_output=True, check=True).stdout
    data = subprocess.run(["git", "-C", REPO, "lfs", "smudge"], input=blob, capture_output=True, check=True).stdout
    return Image.open(io.BytesIO(data)).convert("RGBA")


def in_mask(src, x: int, y: int, w: int, h: int) -> bool:
    if is_red(*src[x, y]):
        return True
    if not is_edge(*src[x, y]):
        return False
    return any(is_red(*src[x + dx, y + dy]) for dx in (-1, 0, 1) for dy in (-1, 0, 1)
               if 0 <= x + dx < w and 0 <= y + dy < h)


def sat_for(p: tuple[int, int, int, int], amber_s: float) -> float:
    """Core px take the amber saturation. Edge px keep their own (blend) saturation, and the dark ones lose most of it:
    the FX print snaps each px to the nearest ink, and a saturated orange-brown blend of amber and ink lands on
    vermilion, a grey-brown one on steel/ink."""
    if is_red(*p):
        return amber_s
    h, s, v = colorsys.rgb_to_hsv(p[0] / 255, p[1] / 255, p[2] / 255)
    return min(s, amber_s) if v >= 0.45 else s * 0.3


def recolour(img: Image.Image) -> tuple[Image.Image, int, int]:
    out = img.copy()
    px, src = out.load(), img.load()
    ah, as_, _ = colorsys.rgb_to_hsv(0xED / 255, 0xAB / 255, 0x42 / 255)
    n = 0
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = src[x, y]
            if in_mask(src, x, y, out.width, out.height):
                nr, ng, nb = colorsys.hsv_to_rgb(ah, sat_for(src[x, y], as_), max(r, g, b) / 255)
                px[x, y] = (round(nr * 255), round(ng * 255), round(nb * 255), a)
                n += 1
    changed = sum(1 for y in range(out.height) for x in range(out.width) if px[x, y] != src[x, y])
    return out, n, changed


def main() -> None:
    dry = "--dry" in sys.argv
    for name in NAMES:
        img = head_png(name)
        out, masked, changed = recolour(img)
        outside = 0
        a, b = img.load(), out.load()
        for y in range(img.height):
            for x in range(img.width):
                if a[x, y] != b[x, y] and not in_mask(a, x, y, img.width, img.height):
                    outside += 1
        print(name, img.size, "mask px", masked, "changed", changed, "outside mask", outside)
        if not dry:
            out.save(ROOT + name + ".png")


main()
