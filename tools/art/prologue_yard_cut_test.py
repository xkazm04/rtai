"""Regression checks for yard matte removal, metre scale and both tile seams."""
import numpy as np
import pytest
from PIL import Image

from prologue_yard_cut import cut_job, key_piece, sheet_matte, tile_ground


def test_soft_edge_is_unmixed_before_scaling():
    matte = np.array([240, 230, 220])
    ink = np.array([20, 30, 40])
    rgb = np.full((11, 11, 3), matte, dtype=np.uint8)
    rgb[2:9, 2:9] = (ink + matte) // 2
    rgb[3:8, 3:8] = ink
    image = Image.fromarray(rgb)
    np.testing.assert_array_equal(sheet_matte(image), matte)
    result = key_piece(image, matte)
    assert result.size == (7, 7)
    assert result.getpixel((0, 3)) == (*ink, 128)
    assert result.getpixel((3, 3)) == (*ink, 255)
    # Against black, a half-covered edge should contribute half the ink, with no paper rim.
    black = Image.new("RGBA", result.size, "black")
    black.alpha_composite(result)
    assert black.getpixel((0, 3)) == (10, 15, 20, 255)


def test_piece_boxes_are_independent_and_scaled_to_metres():
    sheet = Image.new("RGB", (20, 10), "ivory")
    sheet.paste("black", (2, 3, 7, 8))
    sheet.paste("brown", (13, 2, 17, 9))
    pieces = [
        {"id": "tank", "box": [0, 0, 10, 10], "size_m": [3, 2]},
        {"id": "shed", "box": [10, 0, 10, 10], "size_m": [1, 2.5]},
    ]
    cut = cut_job(sheet, {"px_per_m": 32, "pieces": pieces})
    assert cut["tank"].size == (96, 64)
    assert cut["shed"].size == (32, 80)
    assert cut["shed"].getpixel((16, 40)) == (165, 42, 42, 255)


def test_uniform_fit_and_isolation_keep_the_ring_hole_and_exclude_its_neighbour():
    sheet = Image.new("RGB", (28, 16), "white")
    sheet.paste("black", (3, 3, 15, 9))
    sheet.paste("white", (6, 5, 12, 7))
    sheet.paste("brown", (21, 2, 26, 6))
    row = {"id": "ring", "box": [0, 0, 28, 16], "size_m": [4, 4], "isolate": [3, 3]}
    piece = cut_job(sheet, {"fit": True, "px_per_m": 3, "pieces": [row]})["ring"]
    assert piece.size == (12, 6)
    assert piece.getpixel((5, 2))[3] == 0
    assert piece.getpixel((0, 0)) == (0, 0, 0, 255)


def test_wide_grey_shadow_is_ink_on_the_ground():
    sheet = Image.new("RGB", (32, 24), "white")
    sheet.paste((144, 144, 144), (4, 3, 28, 20))
    sheet.paste((160, 80, 40), (5, 5, 11, 11))
    cut = key_piece(sheet, (255, 255, 255), (33, 33, 33))
    assert cut.getpixel((16, 8)) == (33, 33, 33, 128)
    assert cut.getpixel((4, 5)) == (160, 80, 40, 255)


@pytest.mark.parametrize("width,height", [(96, 64), (67, 59)])
def test_offset_blend_joins_both_axes_without_a_central_cut(width, height):
    y, x = np.mgrid[:height, :width]
    ramp = ((x / width + y / height) * 125).astype(np.uint8)
    image = Image.fromarray(np.repeat(ramp[..., None], 3, axis=2))
    tile = np.asarray(tile_ground(image), dtype=int)
    for axis in (0, 1):
        wrapped = np.diff(tile, axis=axis, append=np.take(tile, [0], axis=axis))
        assert abs(wrapped).max() < 16
    assert tile.std() > 12


def test_ground_job_crops_to_box_and_keeps_opaque_paper():
    sheet = Image.new("RGB", (20, 10), "blue")
    sheet.paste("ivory", (10, 0, 20, 10))
    row = {"id": "apron", "box": [10, 0, 10, 10], "size_m": [4, 3]}
    tile = cut_job(sheet, {"mode": "ground", "px_per_m": 8, "pieces": [row]})["apron"]
    assert tile.size == (32, 24)
    assert tile.mode == "RGB"
    assert tile.getextrema() == ((255, 255), (255, 255), (240, 240))


def test_out_of_bounds_empty_or_unsafe_pieces_fail():
    sheet = Image.new("RGB", (10, 10), "ivory")
    row = {"id": "body", "box": [0, 0, 10, 10], "size_m": [2, 3]}
    for update, problem in [({}, "only background"), ({"id": "../bad"}, "piece id"),
                            ({"box": [1, 0, 10, 10]}, "beyond")]:
        with pytest.raises(ValueError, match=problem):
            cut_job(sheet, {"px_per_m": 32, "pieces": [row | update]})


def test_enclosed_near_white_is_clear_only_on_ink_marks():
    sheet = Image.new("RGB", (26, 26), "white")
    sheet.paste("#211e1c", (3, 3, 23, 23))
    sheet.paste("#f3f0ed", (7, 7, 19, 19))
    row = {"id": "scorch", "box": [0, 0, 26, 26], "size_m": [2, 2]}
    job = {"px_per_m": 16, "background": "#ffffff", "shadow_ink": "#211e1c",
           "pieces": [row | {"ink_only": True}]}
    mark = cut_job(sheet, job)["scorch"]
    assert mark.getpixel((16, 16))[3] == 0
    assert mark.getpixel((2, 16))[3] == 255
    pixels = np.asarray(mark)
    assert np.all(pixels[..., :3][pixels[..., 3] > 0] == [33, 30, 28])
    solid = cut_job(sheet, job | {"pieces": [row]})["scorch"]
    assert solid.getpixel((16, 16))[3] > 0
