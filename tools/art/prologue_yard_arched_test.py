"""Regression checks for the arched belt cutter's grouping and footing helpers."""
import numpy as np

from prologue_yard_arched import column_groups, cream_mask, footing_y


def test_cream_is_bright_and_unsaturated_but_rust_is_not():
    rgba = np.zeros((1, 3, 4), np.uint8)
    rgba[0, 0] = (225, 200, 160, 255)  # enamel
    rgba[0, 1] = (190, 100, 40, 255)  # rust
    rgba[0, 2] = (225, 200, 160, 60)  # faint shadow
    assert cream_mask(rgba).tolist() == [[True, False, False]]


def test_column_groups_bridge_small_gaps_and_drop_slivers():
    mask = np.zeros((40, 300), bool)
    mask[:, 10:100] = True
    mask[:, 103:150] = True  # a 3 px gap is one appliance
    mask[:, 200:210] = True  # a sliver
    mask[:, 230:320] = True
    assert column_groups(mask) == [[10, 150], [230, 300]]


def test_footing_ignores_appliance_columns_and_the_far_end():
    rgba = np.zeros((100, 400, 4), np.uint8)
    rgba[..., 3] = 0
    rgba[20:60, 10:60] = (150, 80, 30, 255)  # first leg foot ends at row 60
    rgba[20:90, 150:300] = (150, 80, 30, 255)  # appliance outline reaching row 90
    rgba[20:95, 350:390] = (150, 80, 30, 255)  # far end debris
    cream = np.zeros((100, 400), bool)
    assert footing_y(rgba, cream, [[160, 290]]) == 60
