"""Move the saturated red of a HUD art file to another hue, keeping value and shading (n8-hud:
red is only for blood, so the ammo ticket's bullet becomes brass). Pixels whose hue is within
HUE_SPAN of red and whose saturation and value clear the floors are re-hued; the saturation is
scaled by --sat and the value by --val (brass is darker and less saturated than a signal red). Ink and paper are untouched.

usage: python tools/art/hud_recolor.py <in.png> <out.png> [--hue=0.1] [--sat=0.7] [--val=0.8]
"""
import colorsys
import sys
from PIL import Image

HUE_SPAN = 0.06
SAT_MIN = 0.35
VAL_MIN = 0.2


def arg(name: str, default: float) -> float:
    for a in sys.argv:
        if a.startswith(f"--{name}="):
            return float(a.split("=", 1)[1])
    return default


def main() -> None:
    src, dst = sys.argv[1], sys.argv[2]
    hue, sat_k, val_k = arg("hue", 0.1), arg("sat", 0.7), arg("val", 0.8)
    im = Image.open(src).convert("RGBA")
    px = im.load()
    n = 0
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            if a == 0 or s < SAT_MIN or v < VAL_MIN or min(h, 1.0 - h) > HUE_SPAN:
                continue
            r2, g2, b2 = colorsys.hsv_to_rgb(hue, min(1.0, s * sat_k), v * val_k)
            px[x, y] = (round(r2 * 255), round(g2 * 255), round(b2 * 255), a)
            n += 1
    im.save(dst)
    print(f"{dst}: {n} px re-hued to {hue}")


if __name__ == "__main__":
    main()
