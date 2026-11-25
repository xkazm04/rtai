"""The belt span cuts exist, have a clean transparent border and no red, and each meets its two section ends."""
import json

import numpy as np
import pytest
from PIL import Image

from prologue_yard_hall import OUT, red_share
from prologue_yard_spans import HERE, SOURCES, cut_sheet
from prologue_yard_spans_layout import (BEAM_M, FACADE_Y, JOINS, MOUTH_OPENING_X, SCALE, SHEET_AT, end_gap,
                                        span_rows, spans)

META = json.loads((OUT / "belt_spans.json").read_text())
# A source whose span is not in the repo's belt_spans.json yet (n30 mouth_door until part B cuts it) is
# checked by test_the_mouth_span_cuts_onto_both_ends instead.
SHIPPED = [n for n, (sheet, _x, _y) in SHEET_AT.items()
           if (HERE / f"prologue_yard_sources/{SOURCES[sheet]}.png").exists() and n in META]
MOUTH_SOURCE = HERE / f"prologue_yard_sources/{SOURCES[SHEET_AT['mouth_door'][0]]}.png"


def _cuts():
    return [np.asarray(Image.open(OUT / f"belt_span_{name}.png")) for name in SHIPPED]


def test_every_source_has_its_cuts():
    assert {"door_feed", "feed_turn", "turn_return", "return_bend", "bend_tail"} <= set(SHIPPED)
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


def test_the_mouth_span_rises_out_of_the_opening_not_the_wall():
    name, (p0, d0), _b, pts = spans()[-1]
    assert name == "mouth_door" and d0[1] > 0.99 and SHEET_AT[name][0] == 3
    assert all(SHEET_AT[n][0] < 3 for n in SHEET_AT if n != name)
    north = pts[pts[:, 1] <= FACADE_Y + BEAM_M / 2]
    inside = (north[:, 0] > MOUTH_OPENING_X[0] + BEAM_M / 2) & (north[:, 0] < MOUTH_OPENING_X[1] - BEAM_M / 2)
    crossing = north[: np.argmin(inside) or len(north)]
    assert len(crossing) >= 3 and crossing[-1][1] > FACADE_Y, "the band leaves the hall through the opening"
    assert FACADE_Y - 2.5 <= p0[1] <= FACADE_Y - 2.0, "the span starts 2.0 to 2.5 m inside the opening"
    assert MOUTH_OPENING_X[0] + 1.9 <= p0[0] <= MOUTH_OPENING_X[1] - 2.2, "in the opening's middle"


@pytest.mark.skipif(not MOUTH_SOURCE.exists(), reason="no n30 mouth source yet")
def test_the_mouth_span_cuts_onto_both_ends(tmp_path):
    meta = cut_sheet(MOUTH_SOURCE, SHEET_AT["mouth_door"][0], tmp_path)
    assert list(meta) == ["mouth_door"]
    rgba = np.asarray(Image.open(tmp_path / "belt_span_mouth_door.png"))
    assert red_share(rgba) < 0.01 and not rgba[0, :, 3].any() and not rgba[:, -1, 3].any()
    _name, a, b, pts = spans()[-1]
    top_left = np.array(meta["mouth_door"]["top_left_m"])
    assert end_gap(rgba[..., 3] > 128, top_left, a, pts, True)[0] <= 0.3
    assert end_gap(rgba[..., 3] > 128, top_left, b, pts, False)[0] <= 0.3
    ys, xs = np.where(rgba[..., 3] > 128)
    pts = top_left + (np.stack([xs, ys], axis=1) + 0.5) * SCALE
    lead = (np.abs(pts[:, 0] - a[0][0]) < BEAM_M) & (pts[:, 1] < a[0][1] - 0.05)
    assert not lead.any(), "nothing of the guide's lead is left north of the mouth"
