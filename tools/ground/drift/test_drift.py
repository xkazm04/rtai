import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import numpy as np
import drift


def noise(seed, h=128, w=160):
    rng = np.random.default_rng(seed)
    return rng.random((h, w))


class T(unittest.TestCase):
    def test_integer_shift_is_found(self):
        a = noise(1)
        b = np.roll(a, (3, -5), axis=(0, 1))
        dx, dy, peak, _ = drift.phase_peak(a, b)
        self.assertAlmostEqual(dx, -5.0, delta=0.15)
        self.assertAlmostEqual(dy, 3.0, delta=0.15)
        self.assertGreater(peak, 0.3)

    def test_screen_locked_layer_peaks_at_zero(self):
        a = noise(2)
        dx, dy, _, zero = drift.phase_peak(a, a.copy())
        self.assertAlmostEqual(dx, 0.0, delta=0.05)
        self.assertAlmostEqual(dy, 0.0, delta=0.05)
        self.assertGreater(zero, 0.5)

    def test_mask_cuts_the_rivet_box(self):
        m = drift.rivet_mask((540, 960), (480, 300))
        self.assertEqual(m[290, 480], 0.0)
        self.assertEqual(m[10, 10], 1.0)

    def test_summary_reports_magnitudes(self):
        rs = [{"k": 1, "drift_print_vs_floor": [3.0, 4.0], "drift_lock_vs_camera": [0.0, 0.5],
               "drift_print_vs_camera": [0.0, 1.0], "print_zero_peak": 0.1, "camera_shift": [2.0, 0.0]},
              {"k": 1, "drift_print_vs_floor": [9.0, 9.0], "drift_lock_vs_camera": [9.0, 9.0],
               "drift_print_vs_camera": [9.0, 9.0], "print_zero_peak": 1.0, "camera_shift": [0.0, 0.0]}]
        s = drift.summary(rs)
        self.assertEqual(s["k1_drift_print_vs_floor"]["max_px"], 5.0)
        self.assertEqual(s["k1_drift_lock_vs_camera"]["mean_px"], 0.5)
        self.assertEqual(s["k1_print_zero_peak_max"], 0.1)  # a still camera pair is left out


if __name__ == "__main__":
    unittest.main()
