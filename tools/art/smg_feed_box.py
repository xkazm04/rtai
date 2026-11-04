"""Lengthen the machine pistol's side feed box in its held (top-down) part (weapon-art, 2026-11-04).

In Rivet's claw the pistol and the machine pistol had one shape (the SMG's wire stock hides under the
forearm, its feed box was a small tab). This repeats the tab's middle section, adds a cream tape band and
curves it toward the muzzle, so the held part has its own silhouette. Deterministic; the source is the
cut Codex part. Writes the new held.png and prints the rows added on top (grip/muzzle y move down by it).

    python tools/art/smg_feed_box.py <held_in.png> <held_out.png>
"""

import sys

from PIL import Image, ImageDraw

X0, X1 = 262, 336  # the tab's columns in the cut part
CAP, MID, BASE = (5, 22), (22, 50), 50  # rows: end cap, repeated body, where it meets the gun
REP = 4
CURVE_PX = 22
INK = (27, 21, 23, 255)
PAPER = (242, 232, 213, 255)


def tab_strip(src):
    cap = src.crop((X0, CAP[0], X1, CAP[1]))
    mid = src.crop((X0, MID[0], X1, MID[1]))
    tab = Image.new("RGBA", (X1 - X0, cap.height + mid.height * REP), (0, 0, 0, 0))
    tab.paste(cap, (0, 0))
    for i in range(REP):
        tab.paste(mid, (0, cap.height + i * mid.height))
    d = ImageDraw.Draw(tab)
    alpha = tab.split()[3]
    by = cap.height + mid.height * REP // 2 - 10
    for y in range(by, by + 20):
        xs = [x for x in range(tab.width) if alpha.getpixel((x, y)) > 128]
        if xs:
            edge = y - by < 3 or y - by > 16
            d.line((xs[0] + 3, y, xs[-1] - 3, y), fill=INK if edge else PAPER)
    return tab, mid.height * (REP - 1)


def main(src_path, out_path):
    src = Image.open(src_path).convert("RGBA")
    tab, pad = tab_strip(src)
    out = Image.new("RGBA", (src.width, src.height + pad), (0, 0, 0, 0))
    body = src.copy()
    body.paste(Image.new("RGBA", (X1 - X0, BASE), (0, 0, 0, 0)), (X0, 0))
    out.paste(body, (0, pad))
    for y in range(tab.height):
        t = (tab.height - y) / tab.height
        out.alpha_composite(tab.crop((0, y, tab.width, y + 1)), (X0 + int(round(CURVE_PX * t * t)), y + CAP[0]))
    out.save(out_path)
    print(pad)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
