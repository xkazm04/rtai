"""The hall bay cuts exist, have a transparent border and a sane size."""
from PIL import Image

from prologue_yard_hall import CUTS, OUT


def test_cuts_exist_with_transparent_border():
    for name in CUTS.values():
        image = Image.open(OUT / f"{name}.png")
        assert image.mode == "RGBA" and min(image.size) > 100
        alpha = image.getchannel("A")
        w, h = image.size
        assert alpha.getpixel((0, 0)) == 0 and alpha.getpixel((w - 1, h - 1)) == 0


def test_cuts_have_no_red_fire():
    import numpy as np

    from prologue_yard_hall import red_share

    for name in CUTS.values():
        assert red_share(np.asarray(Image.open(OUT / f"{name}.png"))) < 0.01
