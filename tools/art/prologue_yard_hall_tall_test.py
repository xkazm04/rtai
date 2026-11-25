"""The tall hall bay cuts exist, have a clean transparent border, a bay-like aspect and no red fire."""
import numpy as np
from PIL import Image

from prologue_yard_hall import OUT, red_share
from prologue_yard_hall_tall import CUTS, HERE

SOURCES = HERE / "prologue_yard_sources/n29"
NAMES = [name for src, name in CUTS.items() if (SOURCES / f"{src}.png").exists()]


def _cuts():
    return [np.asarray(Image.open(OUT / f"{name}.png")) for name in NAMES]


def test_every_source_has_a_cut():
    assert "hall_tall_burst_bay" in NAMES and "hall_tall_collapsed_bay" in NAMES
    for name in NAMES:
        image = Image.open(OUT / f"{name}.png")
        assert image.mode == "RGBA" and min(image.size) > 300


def test_alpha_border_is_clean():
    for rgba in _cuts():
        alpha = rgba[..., 3]
        assert not alpha[0].any() and not alpha[-1].any()


def test_side_ends_are_cut_through_the_piers():
    for rgba in _cuts():
        alpha = rgba[..., 3]
        mid = slice(alpha.shape[0] // 3, alpha.shape[0] * 2 // 3)
        assert (alpha[mid, 0] > 200).mean() > 0.9 and (alpha[mid, -1] > 200).mean() > 0.9


def test_aspect_is_a_bay():
    for rgba in _cuts():
        h, w = rgba.shape[:2]
        assert 1.3 < w / h < 2.6


def test_cuts_have_no_red_fire():
    for rgba in _cuts():
        assert red_share(rgba) < 0.01
