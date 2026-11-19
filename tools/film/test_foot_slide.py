"""py -3 -I tools/film/test_foot_slide.py"""
import importlib.util
import unittest
from pathlib import Path

import numpy as np

spec = importlib.util.spec_from_file_location("foot_slide", Path(__file__).with_name("foot_slide.py"))
tracker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tracker)


def film(slide):
    samples = []
    for tick in range(96):
        image = np.full((48, 128, 3), 144, dtype=np.uint8)
        for x in range(-tick, 128, 32):
            if x >= 0:
                image[-8:-2, x:x+2] = 255
        # The 24..47 stance starts planted, slides over one drawing, then holds its new position.
        x = 110 - tick + min(5, max(0, tick - 30)) * slide
        image[12:34, x:x+7] = 12
        col = (tick // 6) % 8
        samples.append((col, *tracker.landmarks(image, 32, False)))
    return tracker.measure(samples, 32, 8, False)


class PlantedBoot(unittest.TestCase):
    def test_perfect_plant_on_scrolling_ground(self):
        result = film(0)
        self.assertEqual(result["ground_px_tick"], -1)
        self.assertEqual(result["hold"]["max_px"], 0)
        self.assertEqual(result["step"]["max_cm"], 0)

    def test_five_pixel_slide_while_the_drawing_is_held(self):
        result = film(1)
        hold = next(h for h in result["holds"] if h["ticks"] == [30, 35])
        self.assertEqual(hold["px"], 5)
        self.assertEqual(hold["cm"], 15.625)
        self.assertEqual(result["hold"]["max_px"], 5)
        step = next(s for s in result["planted_steps"] if s["ticks"] == [24, 47])
        self.assertEqual(step["px"], 5)
        self.assertEqual(step["range_cm"], 15.625)


if __name__ == "__main__":
    unittest.main()
