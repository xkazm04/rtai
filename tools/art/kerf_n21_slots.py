"""Pack the Ronin's switchable lamp faces from the measured cores in cut.json."""

import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ART = Path(__file__).resolve().parents[2] / "project/features/souls/art"
RONIN = ART / "kerf/ronin"
SHEETS = ["kerf_sp_fly_70", "kerf_sp_act_70", "kerf_sp_fly_55", "kerf_sp_act_55"]
PATCH = 64
HALF = PATCH // 2


def lamp_mask(cell, point, threshold):
    # Keep the printed cutout's angle, rounded ends and occlusions at each facing.
    x, y = (round(v) for v in point)
    crop = np.asarray(cell.crop((x-HALF, y-HALF, x+HALF, y+HALF)))
    bright = np.all(crop[:, :, :3] >= threshold, axis=2) & (crop[:, :, 3] >= 128)
    _, labels, _, centres = cv2.connectedComponentsWithStats(bright.astype("uint8"))
    local = np.array(point) - (x-HALF, y-HALF)
    index = 1 + np.argmin(np.linalg.norm(centres[1:] - local, axis=1))
    if np.linalg.norm(centres[index] - local) > 1.5:
        raise ValueError(f"core at {point} was not isolated")
    core = (labels == index).astype("uint8") * 255
    # Cover the antialiased turquoise rim as well as the near-white core.
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask = cv2.GaussianBlur(cv2.dilate(core, kernel), (3, 3), 0.65)
    return Image.fromarray(np.minimum(crop[:, :, 3], mask))


def main():
    meta = json.loads((RONIN / "cut.json").read_text())
    alpha = Image.new("L", (12 * PATCH, 21 * PATCH))
    for sheet, key in enumerate(SHEETS):
        pitch = key[-2:]
        image = Image.open(ART / "view" / ("p" + pitch) / (key[:-3] + ".png"))
        w, h = meta["sheets"][key]["cell_size"]
        for entry in meta["sheets"][key]["cells"]:
            row, col = entry["facing"], entry["pose"]
            cell = image.crop((col*w, row*h, (col+1)*w, (row+1)*h))
            threshold = (155, 223, 201)
            if key == "kerf_sp_act_70" and row == 1:
                threshold = {0: (80, 207, 165), 3: (115, 215, 189)}.get(col, threshold)
            for i, point in enumerate(entry["slots"]):
                alpha.paste(lamp_mask(cell, point, threshold), ((3*col+i)*PATCH, (5*sheet+row)*PATCH))
    torso = Image.open(RONIN / "torso.png")
    for i, point in enumerate(meta["torso"]["slots"]):
        alpha.paste(lamp_mask(torso, point, (195, 240, 224)), (i*PATCH, 20*PATCH))
    packed = Image.new("RGBA", alpha.size, "white")
    packed.putalpha(alpha)
    packed.save(RONIN / "slot_masks.png", optimize=True)


if __name__ == "__main__":
    main()
