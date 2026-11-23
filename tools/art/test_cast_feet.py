import unittest

import numpy as np
from cast_feet import contact_stats, passes


class ContactTest(unittest.TestCase):
    def contact(self, positions, cells):
        # Rows 0 and 1 are the SAME boot. Rows 2 and 3 belong to the other boot.
        series = [{str(cell//2): np.asarray(point)} for cell, point in zip(cells, positions)]
        return contact_stats([{}, *series, {}])[:2]

    def test_body_jump_gates_even_with_fixed_sole(self):
        self.assertFalse(passes(0, 12.01))
        self.assertTrue(passes(2, 12))
        self.assertFalse(passes(2.01, 0))

    def test_slide(self):
        self.assertEqual(self.contact([(0, 0), (0, 2), (0, 4)], [0, 0, 0]), (4, False))

    def test_planted_and_switch(self):
        self.assertEqual(self.contact([(1, 2), (1, 2), (11, 2)], [0, 1, 2]), (0, True))

    def test_jump_at_drawing_change(self):
        self.assertEqual(self.contact([(0, 0), (0, 0), (3, 4), (3, 4)], [0, 0, 1, 1]), (5, False))

    def test_excursion_between_nonadjacent_frames(self):
        self.assertEqual(self.contact([(0, 0), (1, 0), (3, 0), (0, 0)], [0, 0, 1, 1]), (3, False))


if __name__ == '__main__':
    unittest.main()
