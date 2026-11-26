"""Unit check for contact_ink.py: a dark pad under a point reads as core darkening and a soft edge."""
import sys
import unittest
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
import contact_ink  # noqa: E402


class ContactInkTest(unittest.TestCase):
    def _img(self, core_value, soft):
        img = np.full((1080, 1920, 3), 100, np.uint8)
        yy, xx = np.mgrid[0:1080, 0:1920]
        d = np.hypot((xx - 961) / (60.0 if soft else 20.0), (yy - 549) / (30.0 if soft else 10.0))
        k = np.clip(1.0 - d, 0, 1) if soft else (d < 1).astype(float)
        v = 100 - (100 - core_value) * k
        img[...] = v[..., None].astype(np.uint8)
        return img

    def test_dark_core_is_measured_against_the_floor(self):
        r = contact_ink.measure(self._img(40, True), 961, 549)
        self.assertGreater(r["dark40_pct"], 35)
        self.assertLess(r["edge_step_pct"], 6)

    def test_hard_disc_edge_is_flagged(self):
        r = contact_ink.measure(self._img(40, False), 961, 549)
        self.assertGreater(r["edge_x_step_pct"], 6)


if __name__ == "__main__":
    unittest.main()
