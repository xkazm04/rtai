"""Identify the load-bearing shoe in each finished Mulroney cell and emit its registration."""
import hashlib
from statistics import mean

import numpy as np
from PIL import Image

from cast_soles import ROOT, VIEW, band, body_point

# Percent of the opaque width. Drawings 4 and 8 finish on the trailing toe.
WINDOWS = {
    70: [
        [(44,64),(44,64),(45,65),(22,43),(22,52),(22,52),(22,42),(25,43)],
        [(45,78),(45,75),(18,46),(7,34),(41,75),(30,56),(15,42),(0,16)],
        [(49,80),(49,78),(21,49),(0,22),(48,80),(34,67),(17,46),(0,23)],
        [(39,66),(5,40),(25,43),(6,26),(34,70),(26,61),(12,30),(8,33)],
        [(52,72),(52,72),(50,68),(43,66),(49,68),(46,70),(26,44),(39,67)],
    ],
    55: [
        [(48,75),(48,74),(28,47),(24,46),(23,48),(23,48),(21,48),(25,47)],
        [(48,81),(45,74),(19,44),(7,29),(45,73),(34,62),(17,43),(9,30)],
        [(58,94),(42,76),(11,41),(0,22),(60,95),(31,70),(10,38),(0,24)],
        [(45,77),(30,59),(30,56),(0,35),(37,69),(31,63),(28,46),(0,28)],
        [(51,73),(46,72),(48,67),(33,67),(22,46),(29,47),(25,43),(28,50)],
    ],
}
STRIP = "sergeant_mulroney_planted8_armed_walk.png"


def sole(mask, pitch, col, row):
    return band(mask, WINDOWS[pitch][col][row])


def generate():
    lines = ["class_name StreetMulroneyAnchors", "extends RefCounted",
             "## DO NOT EDIT. Generated from shipped alpha by tools/art/cast_mulroney_soles.py.",
             f'const EIGHT: String = "{STRIP}"',
             'const FOUR: String = "sergeant_mulroney_armed_walk.png"',
             '## Select FOUR to restore the shipped four-drawing walk on both hosts and pitches.',
             'const WALK: String = EIGHT']
    advances = []
    for pitch, height in [(70, 1.7), (55, 2.0)]:
        path = VIEW / f"p{pitch}" / STRIP
        alpha = np.asarray(Image.open(path))[:, :, 3] > 128
        lines += [f"## p{pitch} SHA-256 " + hashlib.sha256(path.read_bytes()).hexdigest(),
                  f"const WALK{pitch}: Array[Vector4] = ["]
        for col, strip in enumerate(np.hsplit(alpha, 5)):
            offsets = []
            for row, mask in enumerate(np.vsplit(strip, 8)):
                foot = sole(mask, pitch, col, row)
                body = body_point(mask)
                offsets.append(body[0] - foot[0])
                pivot = [mask.shape[1] / 2, mask.shape[0] * .875]
                x, y = foot - pivot
                u, v = body - pivot
                lines.append(f"\tVector4({x:g}, {y:g}, {u:g}, {v:g}),")
            if col == 2:
                for start in (0, 4):
                    advances.append((offsets[start + 2] - offsets[start]) * height * 1.11 / 192 / 2)
        lines.append("]")
    step = mean(advances)
    print("profile advances (m/drawing)", advances, "mean", step)
    lines.append(f"const STEP_M: float = {step:.4f}")
    path = ROOT / "project/features/characters/street_mulroney_anchors.gd"
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    generate()
