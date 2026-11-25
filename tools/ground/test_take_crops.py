import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import numpy as np
import take_crops as tc


def crop(h, k):
    """A grey h x h crop with an orange body (rows 100..180 at k=1) scaled by k."""
    c = np.full((h, h, 3), 150, np.uint8)
    c[int(100 * k):int(180 * k), int(110 * k):int(130 * k)] = (200, 120, 60)
    return c


class T(unittest.TestCase):
    def test_body_rows_scale_with_crop_height(self):
        for h in (240, 480):
            k = h / 240
            r = tc.body_rows(crop(h, k))
            self.assertEqual(r["top"], int(100 * k))
            self.assertEqual(r["bottom"], int(180 * k) - 1)

    def test_body_above_the_mask_band_is_ignored(self):
        c = crop(480, 2)
        c[:, :] = 150
        c[10:80, 220:260] = (200, 120, 60)
        self.assertIsNone(tc.body_rows(c))


if __name__ == "__main__":
    unittest.main()
