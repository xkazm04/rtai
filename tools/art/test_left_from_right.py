import tempfile
import unittest
from pathlib import Path

import numpy as np
from PIL import Image

from left_from_right import build, mirror_cell


class LeftFromRightTest(unittest.TestCase):
    def test_local_reflection_preserves_silhouette_and_every_unmasked_pixel(self):
        source = np.arange(8*7*4, dtype=np.uint8).reshape(7, 8, 4)
        source[:, :, 3] = 255
        source[2, 1, 3] = 0
        out = mirror_cell(Image.fromarray(source), [
            {"band": [[1, 2, 3], [4, 3, 4]]}, {"hide": [[6, 4], [7, 4], [7, 5]]}])
        before = np.asarray(out)[:, ::-1]
        np.testing.assert_equal(before[:2], source[:2])
        np.testing.assert_equal(before[2, 1], source[2, 1])
        np.testing.assert_equal(before[3, 1], source[4, 4])
        np.testing.assert_equal(before[4, 7], 0)
        np.testing.assert_equal(before[:, 5], source[:, 5])

    def test_octant_order_and_source_padding(self):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d)
            src = np.arange(4*32*4, dtype=np.uint16).reshape(4, 32, 4).astype(np.uint8)
            Image.fromarray(src).save(path/"eq.png")
            build(path/"eq.png", path/"left.png", [[], [], []])
            with Image.open(path/"left.png") as out:
                expected = np.concatenate([src[:, i*4:(i+1)*4][:, ::-1] for i in (1, 2, 3)], axis=1)
                np.testing.assert_equal(np.asarray(out), expected)
