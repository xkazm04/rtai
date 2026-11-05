"""An orange rim inside a flash cell's ink outline (look lane, n5 iteration 14): r2_w4's muzzle
flashes grade white-hot core -> hot yellow -> orange tips at the outline. rim() moves every
non-ink fill pixel within `px` of the ink or the cell edge to `colour`, keeping its grain offset
from the fill colour `base`; the white-hot core (every channel above core_min) is left as it is.
Deterministic (no randomness)."""

from PIL import Image, ImageFilter


def rim(path, colour, px, base, ink_max=60, core_min=150):
    img = Image.open(path).convert("RGBA")
    pix = img.load()
    w, h = img.size
    fill = Image.new("L", (w, h), 0)
    fp = fill.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = pix[x, y]
            if a > 0 and max(r, g, b) > ink_max:
                fp[x, y] = 255
    core = fill.filter(ImageFilter.MinFilter(2 * px + 1))
    cp = core.load()
    for y in range(h):
        for x in range(w):
            if fp[x, y] and not cp[x, y]:
                r, g, b, a = pix[x, y]
                if min(r, g, b) > core_min:
                    continue
                pix[x, y] = tuple(
                    max(0, min(255, c + (k - t))) for c, k, t in zip(colour, (r, g, b), base)
                ) + (a,)
    img.save(path, optimize=True)
