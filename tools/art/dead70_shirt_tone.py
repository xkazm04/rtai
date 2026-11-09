"""Brings the shirt of the 70-degree patrol corpse sheet to the tone of the falling and living cop
(n11): dead70_cop_patrol.png was drawn lighter and greyer (median 72,97,119 against 51,65,97), so
the shirt jumped a shade when the fall frame handed over to the lying pose. Only uniform-blue pixels
move, skin and trousers stay. The factors come from the sheets as they are, so a second run is a
no-op.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/dead70_shirt_tone.py
"""

from pathlib import Path

import numpy as np
from PIL import Image

P70 = Path(__file__).resolve().parents[2] / "project/features/characters/art/view/p70"
TARGET = P70 / "cop_patrol_long_fall.png"
SHEET = P70 / "dead70_cop_patrol.png"
# Blue over red by this much, and bright enough to be cloth in light: the shirt and the cap.
BLUE_OVER_RED = 1.25
MIN_BLUE = 70.0
SOFT = 0.15


def shirt(a: np.ndarray) -> np.ndarray:
    """A 0..1 weight of how much a pixel is uniform shirt, soft at the edge of the test."""
    ratio = a[..., 2] / np.maximum(a[..., 0], 1.0)
    w = np.clip((ratio - BLUE_OVER_RED) / SOFT, 0.0, 1.0)
    w *= np.clip((a[..., 2] - MIN_BLUE) / 12.0, 0.0, 1.0)
    return w * (a[..., 3] > 200)


def main() -> None:
    target = np.asarray(Image.open(TARGET).convert("RGBA"), dtype=float)
    sheet = np.asarray(Image.open(SHEET).convert("RGBA"), dtype=float).copy()
    want = np.median(target[shirt(target) > 0.5][:, :3], axis=0)
    mask = shirt(sheet)
    have = np.median(sheet[mask > 0.5][:, :3], axis=0)
    gain = want / have
    if np.abs(gain - 1.0).max() < 0.02:
        print(f"already at the target: gain {gain.round(3)}")
        return
    for c in range(3):
        sheet[..., c] = sheet[..., c] * (1.0 + (gain[c] - 1.0) * mask)
    Image.fromarray(np.clip(sheet, 0, 255).astype("uint8"), "RGBA").save(SHEET)
    print(f"shirt {have.round()} -> {want.round()}, gain {gain.round(3)}, on {int((mask > 0.5).sum())} px")


if __name__ == "__main__":
    main()
