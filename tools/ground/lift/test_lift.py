"""Synthetic frames: a known body and contact ellipse come back within 1 px.

  python -I -m pytest tools/ground/lift/test_lift.py   (or: python -I tools/ground/lift/test_lift.py)
"""

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
import lift  # noqa: E402

H, W = 320, 256
FLOOR = (90, 96, 88)


def _frames(body_top, body_bottom, cx, cy, rx, ry):
    c = np.zeros((H, W, 3), np.int16) + np.array(FLOOR, np.int16)
    yy, xx = np.mgrid[0:H, 0:W]
    inside = ((xx + 0.5 - cx) / rx) ** 2 + ((yy + 0.5 - cy) / ry) ** 2 <= 1.0
    shadowed = c.copy()
    shadowed[inside] = (shadowed[inside] * 0.75).astype(np.int16)
    body = (yy >= body_top) & (yy < body_bottom) & (abs(xx - cx) < 9)
    body |= (yy >= body_top) & (yy < body_top + 14) & (abs(xx - cx) < 12)  # helmet
    b = c.copy()
    b[body] = (200, 60, 40)
    a = shadowed.copy()
    a[body] = (200, 60, 40)
    return a, b, c


def test_planted_body_and_ellipse():
    a, b, c = _frames(130, 256, 128.0, 255.0, 30.0, 18.6)
    m = lift.measure(a, b, c)
    assert abs(m["sole_y"] - 256) <= 1
    assert abs(m["helmet_y"] - 130) <= 1
    assert abs(m["shadow"]["cy"] - 255.0) <= 1
    assert abs(m["shadow"]["cx"] - 128.0) <= 1
    assert abs(m["shadow"]["rx"] - 30.0) <= 1
    assert abs(m["shadow"]["ry"] - 18.6) <= 1


def test_lifted_body_keeps_shadow_on_ground():
    a, b, c = _frames(100, 226, 128.0, 255.0, 30.0, 18.6)
    m = lift.measure(a, b, c)
    assert abs(m["sole_y"] - 226) <= 1
    assert abs(m["shadow"]["cy"] - 255.0) <= 1
    meta = {"gait": "sprint", "octant": 0, "ground_y": 256.0, "screen_ppm": 64.0,
            "code_cy": 255.0, "phase": 0.0, "card_up": 30.0}
    planted = {**meta, **lift.measure(*_frames(130, 256, 128.0, 255.0, 30.0, 18.6))}
    row = lift.summarize([planted, {**meta, **m, "phase": 0.5}])
    assert row["travel_px"] == 30
    assert row["lift_max_px"] == 30
    assert row["lift_planted_px"] == 0
    assert row["gap_all_max_px"] >= 28


if __name__ == "__main__":
    test_planted_body_and_ellipse()
    test_lifted_body_keeps_shadow_on_ground()
    print("test_lift: 2 passed")
