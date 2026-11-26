"""Synthetic frames for foes.py: a shadowless foe says `none`, a shadowed one keeps its gap.

  python -I tools/ground/lift/test_foes.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import foes  # noqa: E402
import lift  # noqa: E402
import test_lift  # noqa: E402

META = {"kind": "x", "gait": "walk", "octant": 0, "ground_y": 256.0, "screen_ppm": 32.0,
        "phase": 0.0, "speed": 2.4}


def _frame(top, bottom, shadow=True, phase=0.0):
    a, b, c = test_lift._frames(top, bottom, 128.0, 255.0, 30.0, 18.6)
    if not shadow:
        a = b
    return {**META, "phase": phase, **foes.measure(a, b, c)}


def test_no_shadow_kind_is_reported_none():
    row = foes.summarize([_frame(130, 256, False), _frame(124, 256, False, 0.5)])
    assert row["shadow"] == "none"
    assert row["travel_px"] == 6
    assert "gap_all_max_px" not in row


def test_shadow_kind_has_gap_and_travel_pct():
    row = foes.summarize([_frame(130, 256), _frame(100, 226, phase=0.5)])
    assert row["shadow"] == "yes"
    assert row["lift_max_px"] == 30
    assert row["gap_all_max_px"] >= 28
    assert row["travel_pct"] == round(30 / 126 * 100, 1)


if __name__ == "__main__":
    test_no_shadow_kind_is_reported_none()
    test_shadow_kind_has_gap_and_travel_pct()
    print("test_foes: 2 passed")
