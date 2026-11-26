import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import world_still as w  # noqa: E402


class WorldStill(unittest.TestCase):
    def test_frame_index_skips_the_pre_step_frames(self):
        self.assertEqual(w.frame_index(2150, 2150, 1450, 1452), 2)
        self.assertEqual(w.frame_index(2180, 2150, 1450, 1452), 32)

    def test_box_shift_is_the_render_px_floor_move(self):
        a = {"canvas_origin": [-100.0, -50.0], "stretch": [1.35, 1.35, 0.0, 0.0]}
        b = {"canvas_origin": [-120.0, -50.0], "stretch": [1.35, 1.35, 0.0, 0.0]}
        self.assertEqual(w.box_shift(a, b).tolist(), [-27.0, 0.0])


if __name__ == "__main__":
    unittest.main()
