"""Regression checks on the cut reloads at native resolution."""
import unittest

import numpy as np
from PIL import Image

from reload_composite import VIEW


def poses(pitch, gun, base, index):
    def cell(name):
        with Image.open(VIEW / pitch / ("rivet_reload_" + name + ".png")) as strip:
            width = strip.width // 8
            return strip.crop((index * width, 0, (index + 1) * width, strip.height))
    source = cell(base)
    box = source.getbbox()
    return np.asarray(source.crop(box)), np.asarray(cell(gun).crop(box))


class ReloadCompositeTest(unittest.TestCase):
    def test_exposed_mounts_are_ink_from_the_native_base(self):
        mounts = [
            ("p55", "hand_cannon", "pistol", 1, (49, 67, 58, 75), (0, 12)),
            ("p55", "machine_pistol", "pistol", 1, (49, 67, 58, 75), (0, 12)),
            ("p55", "machine_pistol", "pistol", 7, (57, 56, 66, 66), (0, 12)),
            ("p70", "electro_gun", "plasma_rifle", 7, (92, 85, 102, 96), (-74, 0)),
        ]
        for pitch, gun, base, index, (x, y, r, b), (dx, dy) in mounts:
            with self.subTest(gun=gun, index=index):
                source, cut = poses(pitch, gun, base, index)
                donor = source[y+dy:b+dy, x+dx:r+dx]
                result = cut[y:b, x:r]
                exact = np.all(donor == result, axis=2) & (donor[:, :, 3] >= 220)
                old_slide = np.any(result != source[y:b, x:r], axis=2)
                self.assertGreaterEqual(np.count_nonzero(exact & old_slide), 12)

    def test_release_cell_keeps_the_native_empty_claw(self):
        for gun in ("machine_pistol", "hand_cannon"):
            source, cut = poses("p55", gun, "pistol", 5)
            np.testing.assert_array_equal(source[87:103, 66:82], cut[87:103, 66:82])
