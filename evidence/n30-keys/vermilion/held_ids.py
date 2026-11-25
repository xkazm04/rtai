"""Debug: numbered-component crops of the held_55 file and the Rivet cell, stacked, to Temp (name parts by eye)."""
import sys
from PIL import Image, ImageDraw
from held_lib import *
TMP = "C:/Users/kazda/AppData/Local/Temp/"


def numbered(path, cell, k):
    a, m, lab = labelled(path, cell)
    bg = Image.new("RGBA", (a.shape[1], a.shape[0]), (40, 40, 48, 255))
    bg.alpha_composite(Image.fromarray(a))
    ys, xs = np.nonzero(a[..., 3] > 0)
    x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    im = bg.crop((x0, y0, x1, y1)).resize(((x1 - x0) * k, (y1 - y0) * k), Image.NEAREST)
    dr = ImageDraw.Draw(im)
    for c in comps(lab):
        if c["px"] < 15:
            continue
        bx0, by0, bx1, by1 = c["bbox"]
        dr.rectangle([(bx0 - x0) * k - 2, (by0 - y0) * k - 2, (bx1 - x0) * k + k + 2, (by1 - y0) * k + k + 2], outline=(255, 255, 255, 255))
        dr.text(((bx0 - x0) * k, max(0, (by0 - y0) * k - 12)), f'{c["id"]}:{c["px"]}', fill=(255, 255, 0, 255))
    return im


for w in sys.argv[1:]:
    parts = [numbered(held_path(w), False, 2)]
    if w not in EXTRA:
        parts.append(numbered(cell_path(w), True, 3))
    W = max(p.width for p in parts)
    out = Image.new("RGB", (W, sum(p.height for p in parts) + 6), (10, 10, 10))
    y = 0
    for p in parts:
        out.paste(p.convert("RGB"), (0, y))
        y += p.height + 6
    out.save(TMP + f"hid_{w}.png")
    print(w, out.size)
