"""n30 c23: a soot seam between the nuke shell's amber nose band and its two black stripes.

The FX item print snaps every sampled colour to its nearest ink; amber->ink blends between ~25 % and ~70 % ink land on
VERM (evidence/n30/floor/specks.md). A soot grey (128,118,118) between them splits the blend: amber->soot snaps
AMBER/STEEL, soot->ink snaps INK. Seam texels = band-mask texels (recolour_band.py's mask on its source rev) within
`width` texels (8-neighbour rings) of a stripe-ink texel. Stripe ink = dark (v < 0.2) opaque texels (the mask's dark edge px count as ink, never seam) with
mask texels left AND right of them in the same row within 6 texels (so the band's top/bottom ink rim is not a stripe).
Nothing outside the band mask changes.
Usage: python -I seam.py <in.png | HEAD> <out.png> [width] [--alpha=N] [--rim | --rim-ink] [--four]
  HEAD = git show HEAD:<nuke_shell.png> (+ lfs smudge if it is a pointer); --alpha=N sets the seam alpha (default: kept);
  --rim also seams the band's top/bottom ink rim (amber side); --rim-ink turns the rim's ink texels touching the band
  soot instead (ink side: no amber lost there); --four grows the seam over the 4 orthogonal neighbours only (a texel
  touching ink only diagonally keeps its amber).
"""
import colorsys
import io
import subprocess
import sys
from PIL import Image

REPO = "C:/Users/kazda/kiro/gtai-wt/n23-street"
SRC_REV = "fde0b1f4c"  # recolour_band.py's source rev (red band); its mask is the band (copied: that script runs on import)


def _hsv(r: int, g: int, b: int) -> tuple[float, float, float]:
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    return h * 360, s, v


def is_red(r: int, g: int, b: int, a: int) -> bool:
    h, s, v = _hsv(r, g, b)
    return a > 0 and (h <= 24 or h >= 345) and s > 0.5 and v > 0.45


def is_edge(r: int, g: int, b: int, a: int) -> bool:
    h, s, _ = _hsv(r, g, b)
    return a > 0 and (h <= 30 or h >= 340) and s > 0.25


def in_mask(src, x: int, y: int, w: int, h: int) -> bool:
    if is_red(*src[x, y]):
        return True
    return is_edge(*src[x, y]) and any(is_red(*src[x + dx, y + dy]) for dx in (-1, 0, 1) for dy in (-1, 0, 1)
                                       if 0 <= x + dx < w and 0 <= y + dy < h)


REL = "project/features/combat/weapons/art/fx/nuke_shell.png"
SOOT = (128, 118, 118)
STEPS8 = tuple((dx, dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1))
STEPS4 = ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1))


def git_png(rev: str) -> Image.Image:
    blob = subprocess.run(["git", "-C", REPO, "show", rev + ":" + REL], capture_output=True, check=True).stdout
    if blob.startswith(b"version https://git-lfs"):
        blob = subprocess.run(["git", "-C", REPO, "lfs", "smudge"], input=blob, capture_output=True, check=True).stdout
    return Image.open(io.BytesIO(blob)).convert("RGBA")


def band_mask(w: int, h: int) -> set:
    src = git_png(SRC_REV).load()
    return {(x, y) for y in range(h) for x in range(w) if in_mask(src, x, y, w, h)}


def ink_texels(px, mask: set, w: int, h: int, rim: bool) -> set:
    out = set()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 128 or max(r, g, b) / 255 >= 0.2:
                continue
            left = any((x - d, y) in mask for d in range(1, 7))
            right = any((x + d, y) in mask for d in range(1, 7))
            near = any((x + dx, y + dy) in mask for dx in (-1, 0, 1) for dy in (-1, 0, 1))
            if (left and right) or (rim and near):
                out.add((x, y))
    return out


def rim_ink(img: Image.Image, mask: set, stripes: set) -> set:
    """--rim-ink: the rim's ink texels touching a light band texel (the seam on the ink side: the amber stays)."""
    light = {p for p in mask if max(img.getpixel(p)[:3]) / 255 >= 0.2}
    rim = ink_texels(img.load(), mask, img.width, img.height, True) - stripes
    return {(x, y) for x, y in rim if any((x + dx, y + dy) in light for dx in (-1, 0, 1) for dy in (-1, 0, 1))}


def seam(img: Image.Image, width: int, alpha: int | None, rim: str, four: bool = False) -> tuple[Image.Image, int]:
    out = img.copy()
    px = out.load()
    mask = band_mask(img.width, img.height)
    ring = ink_texels(img.load(), mask, img.width, img.height, rim == "amber")
    n = 0
    if rim == "ink":
        for x, y in rim_ink(img, mask, ring):
            px[x, y] = SOOT + (px[x, y][3],)
            n += 1
    for _ in range(width):
        grown = {(x + dx, y + dy) for x, y in ring for dx, dy in (STEPS4 if four else STEPS8)}
        new = {p for p in grown - ring if p in mask and max(img.getpixel(p)[:3]) / 255 >= 0.2}
        for x, y in new:
            px[x, y] = SOOT + (px[x, y][3] if alpha is None else min(alpha, px[x, y][3]),)
        n += len(new)
        ring |= new
    near = {(x + dx, y + dy) for x, y in mask for dx in (-1, 0, 1) for dy in (-1, 0, 1)}
    outside = sum(1 for y in range(img.height) for x in range(img.width)
                  if px[x, y] != img.load()[x, y] and (x, y) not in near)
    print("seam texels", n, "outside mask + its 1-texel ring", outside)
    return out, n


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    alpha = next((int(a.split("=")[1]) for a in sys.argv if a.startswith("--alpha=")), None)
    img = git_png("HEAD") if args[0] == "HEAD" else Image.open(args[0]).convert("RGBA")
    out, _ = seam(img, int(args[2]) if len(args) > 2 else 1, alpha,
                  "amber" if "--rim" in sys.argv else "ink" if "--rim-ink" in sys.argv else "", "--four" in sys.argv)
    out.save(args[1])


if __name__ == "__main__":
    main()
