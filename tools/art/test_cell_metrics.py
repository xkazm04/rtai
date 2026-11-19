import unittest

import numpy as np

from cell_metrics import compare, figure


class CellMetricsTest(unittest.TestCase):
    def test_crown_to_boot_excludes_gear_flare_and_collar(self):
        frame = np.zeros((100, 130, 4), np.uint8)
        frame[45:90, 40:60] = [45, 40, 35, 255]
        frame[20:45, 38:63] = [133, 91, 66, 255]
        frame[45:49, 39:63] = [249, 120, 12, 255]
        frame[5:53, 80:85] = [86, 92, 100, 255]
        frame[49:55, 53:111] = [86, 92, 100, 255]
        frame[10:20, 114:128] = [250, 210, 99, 255]
        height, rgb, _ = figure(frame, 75)
        self.assertEqual(height, 70)
        np.testing.assert_array_equal(rgb, [133, 91, 66])

    def test_height_and_tone_are_independent(self):
        base = [139, 96, 75]
        self.assertEqual(compare(105, base, 100, base)[2], "-")
        self.assertEqual(compare(94, base, 100, base)[2], "H")
        self.assertEqual(compare(100, [185, 125, 85], 100, base)[2], "T")


if __name__ == "__main__":
    unittest.main()
