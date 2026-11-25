"""The belt span cuts exist, have a clean transparent border and no red, and each meets its two section ends."""
import json

import numpy as np
from PIL import Image

from prologue_yard_hall import OUT, red_share
from prologue_yard_spans import HERE, SOURCES
from prologue_yard_spans_layout import JOINS, SHEET_AT, span_rows

SHIPPED = [n for n, (sheet, _x, _y) in SHEET_AT.items() if (HERE / f"prologue_yard_sources/n29/{SOURCES[sheet]}.png").exists()]


def _cuts():
    return [np.asarray(Image.open(OUT / f"belt_span_{name}.png")) for name in SHIPPED]


def test_every_source_has_its_cuts():
    assert "door_feed" in SHIPPED
    meta = json.loads((OUT / "belt_spans.json").read_text())
    for name in SHIPPED:
        image = Image.open(OUT / f"belt_span_{name}.png")
        assert image.mode == "RGBA" and min(image.size) > 200
        assert meta[name]["size_px"] == list(image.size)


def test_alpha_border_is_clean():
    for rgba in _cuts():
        alpha = rgba[..., 3]
        assert not alpha[0].any() and not alpha[-1].any()
        assert not alpha[:, 0].any() and not alpha[:, -1].any()


def test_cuts_have_no_red():
    for rgba in _cuts():
        assert red_share(rgba) < 0.01


def test_every_join_is_within_a_third_of_a_metre():
    rows = span_rows()
    assert len(rows) == len(SHIPPED)
    for row, gap_a, gap_b in rows:
        assert row["id"].startswith("span_") and row["rotation_deg"] == 0
        assert gap_a[0] <= 0.3 and gap_b[0] <= 0.3, (row["id"], gap_a, gap_b)


def test_the_joins_alternate_sides_into_the_torn_tail():
    sides = [(sa, sb) for _a, sa, _b, sb in JOINS]
    assert sides[:4] == [("e", "e"), ("w", "w"), ("e", "e"), ("w", "w")]
    assert JOINS[-1][2] == "tail" and JOINS[-1][3] == "w"
