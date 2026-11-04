"""Cut the reload magazines from the weapons' own held parts (weapon-art, REQUEST 8 from rivet-arsenal, 2026-11-04).

A magazine is a loose part the off claw carries from MAG_OUT to MAG_IN, so it must read as the same gun's metal,
in the same ink. Each one is cut from that gun's held part (the cut Codex art) and re-inked; nothing is
generated. All are drawn top-down at the held part's own px per metre, the FEED end toward +x, grip in the middle
of the base half. The parts are stylised big (about 1.5x a real magazine), like the held parts themselves.

  pistol          the slide plate with two screws, a cream cartridge nose and a dark base pad
  machine_pistol  the long curved side feed box with its tape band (the stub that marks the SMG in the claw)
  plasma_rifle    the cream glass cell with its two metal end caps
  hand_cannon     a speed-loader: a round metal disc with six cream cartridge bases around a knob

    python tools/art/weapon_mags.py <art_dir>      # writes <art_dir>/<weapon>/mag.png, prints the rows
"""

import json
import sys

from PIL import Image, ImageChops, ImageDraw

INK = (27, 21, 23, 255)
PAPER = (242, 232, 213, 255)
BRASS = (214, 176, 112, 255)
INK_W = 5


def held(art, wid):
    return Image.open(f"{art}/{wid}/held.png").convert("RGBA")


def inked_box(tex, size, radius):
    """A rounded box filled with tex (resized), an ink rim INK_W wide."""
    w, h = size
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w - 1, h - 1), radius, fill=255)
    out.paste(tex.resize(size, Image.LANCZOS), (0, 0), mask)
    ImageDraw.Draw(out).rounded_rectangle((0, 0, w - 1, h - 1), radius, outline=INK, width=INK_W)
    return out


def pad(img, px):
    out = Image.new("RGBA", (img.width + 2 * px, img.height + 2 * px), (0, 0, 0, 0))
    out.paste(img, (px, px))
    return out


def pistol(art):
    plate = held(art, "pistol").crop((120, 41, 192, 75))
    body = inked_box(plate, (96, 40), 8)
    out = Image.new("RGBA", (124, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(out)
    d.rounded_rectangle((0, 2, 22, 45), 6, fill=INK)  # the base pad
    out.alpha_composite(body, (12, 4))
    d.ellipse((96, 10, 122, 38), fill=BRASS, outline=INK, width=INK_W)  # the top round
    d.line((100, 24, 118, 24), fill=PAPER, width=3)
    return pad(out, 2), (40, 26)


def machine_pistol(art):
    box = held(art, "machine_pistol").crop((262, 0, 352, 140))
    d = ImageDraw.Draw(box)
    xs = [x for x in range(box.width) if box.getpixel((x, 136))[3] > 128]
    d.rectangle((xs[0], 130, xs[-1], 139), fill=INK)  # the cut end is the base plate
    # Lay it along +x: the cut end (the feed lip, inside the gun) points +x, the base plate -x.
    out = pad(box.rotate(90, expand=True), 2)
    return out, (34, out.height // 2)


def plasma_rifle(art):
    cell = held(art, "plasma_rifle").crop((188, 74, 308, 124))
    mask = Image.new("L", cell.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, cell.width - 1, cell.height - 1), 16, fill=255)
    cell.putalpha(ImageChops.multiply(cell.split()[3], mask))
    ImageDraw.Draw(cell).rounded_rectangle((0, 0, cell.width - 1, cell.height - 1), 16, outline=INK, width=INK_W)
    return pad(cell, 2), (cell.width // 2 - 20 + 2, cell.height // 2 + 2)


def hand_cannon(art):
    metal = held(art, "hand_cannon").crop((200, 30, 260, 90))
    size = 104
    disc = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    disc.paste(metal.resize((size, size), Image.LANCZOS), (0, 0), mask)
    d = ImageDraw.Draw(disc)
    d.ellipse((0, 0, size - 1, size - 1), outline=INK, width=INK_W)
    c = size / 2
    for i in range(6):
        v = [(c - 1, c - 32), (c + 27, c - 16), (c + 27, c + 16), (c - 1, c + 32), (c - 29, c + 16), (c - 29, c - 16)][i]
        d.ellipse((v[0] - 13, v[1] - 13, v[0] + 13, v[1] + 13), fill=BRASS, outline=INK, width=4)
        d.ellipse((v[0] - 4, v[1] - 4, v[0] + 4, v[1] + 4), fill=PAPER)
    d.ellipse((c - 9, c - 9, c + 9, c + 9), fill=INK)  # the knob
    return pad(disc, 2), (size // 2 + 2, size // 2 + 2)


MAKERS = {"hand_cannon": hand_cannon, "machine_pistol": machine_pistol, "pistol": pistol, "plasma_rifle": plasma_rifle}


def main(art):
    rows = {}
    for wid, make in MAKERS.items():
        img, grip = make(art)
        img.save(f"{art}/{wid}/mag.png")
        rows[wid] = {"grip_px": list(grip), "size_px": [img.width, img.height]}
    print(json.dumps(rows, indent=2, sort_keys=True))


if __name__ == "__main__":
    main(sys.argv[1])
