"""Cut the ghost-form card's chip faces (n8-hud): frame 0 (facing the camera) of each ghost's
shipped p55 card strip, a square crop round the figure, scaled to SIZE px, keeping the figure's
own transparent silhouette (n11: the owner asked for avatars with no background, no disc mask).
GhostChipFace draws them straight on the HUD. No new drawing: the strips are the owner-approved d8
ghosts (their provenance lines stand).

usage: python tools/art/ghost_chip_cut.py [<out_dir>]   (default project/features/hud/art/ghost_chips)
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

SIZE = 84  # the grown chip at 1080p (26 * 1.18 * 2 * 1.35 = 83 px): never drawn above 1:1
FRAMES = 5
# id: (strip, crop box in frame 0's pixels; may run past the frame, padded clear)
CUTS = {
    "tonnage": ("features/souls/art/view/p55/tonnage_card.png", (-6, 6, 178, 190)),
    "dent": ("features/characters/art/view/p55/dent_bust_card.png", (15, 6, 139, 130)),
    "kerf": ("features/souls/art/view/p55/kerf_card.png", (4, 14, 104, 114)),
    "ohm": ("features/souls/art/view/p55/ohm_card.png", (-12, 6, 154, 172)),
}


def frame0(path: str) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    return im.crop((0, 0, im.width // FRAMES, im.height))


def round_foot(im: Image.Image) -> Image.Image:
    """A bust cut flat at the frame's foot gets a rounded base instead of a square end."""
    big = Image.new("L", (SIZE * 4, SIZE * 4), 255)
    r = SIZE * 2
    draw = ImageDraw.Draw(big)
    draw.rectangle((0, r, SIZE * 4, SIZE * 4), fill=0)
    draw.ellipse((0, 0, SIZE * 4 - 1, SIZE * 4 - 1), fill=255)
    mask = big.resize((SIZE, SIZE), Image.LANCZOS)
    im.putalpha(Image.fromarray(np.minimum(np.asarray(im.getchannel("A")), np.asarray(mask))))
    return im


def main() -> None:
    root = os.path.join(os.path.dirname(__file__), "..", "..", "project")
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(root, "features/hud/art/ghost_chips")
    os.makedirs(out, exist_ok=True)
    for gid, (rel, box) in CUTS.items():
        cell = frame0(os.path.join(root, rel))
        sq = Image.new("RGBA", (box[2] - box[0], box[3] - box[1]), (0, 0, 0, 0))
        sq.alpha_composite(cell, (-box[0], -box[1]))
        face = sq.resize((SIZE, SIZE), Image.LANCZOS)
        if gid == "dent":  # the only bust: its chest runs off the frame
            face = round_foot(face)
        face.save(os.path.join(out, gid + ".png"))
        print(gid, rel, box, "->", SIZE)


if __name__ == "__main__":
    main()
