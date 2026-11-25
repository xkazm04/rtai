import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import numpy as np
import running_ticks as rt


class T(unittest.TestCase):
    def test_direction_up_is_north(self):
        self.assertEqual(rt.direction(0, -3), "N")
        self.assertEqual(rt.direction(3, 0), "E")
        self.assertEqual(rt.direction(-3, 0), "W")

    def test_runs_group_and_ignore_still(self):
        vel = [(0, 0, 0), (4, 0, -2), (8, 0, -2), (12, 0, 0), (40, 2, 0), (44, 2, 0)]
        r = rt.runs(vel, 0.5)
        self.assertEqual([(x["start"], x["end"], x["dir"]) for x in r], [(4, 8, "N"), (40, 44, "E")])

    def test_shift_finds_translation(self):
        rng = np.random.default_rng(1)
        a = rng.random((rt.H, rt.W)).astype(np.float32)
        b = np.roll(a, (3, 5), axis=(0, 1))
        self.assertEqual(rt.shift(a, b), (5, 3))


if __name__ == "__main__":
    unittest.main()
