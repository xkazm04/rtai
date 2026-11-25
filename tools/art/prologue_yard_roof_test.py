"""The roof cutter crops slabs flush at the sides, splits a plume sheet per plume and keeps fire amber."""
import numpy as np
import pytest
from PIL import Image

import prologue_yard_roof as roof
from prologue_yard_hall import red_share


def _slab_rgba(width=600, height=240):
    """An opaque slab with a ragged gable on the left and a soft tail on the right, set in empty margin."""
    rgba = np.zeros((height + 120, width + 120, 4), np.uint8)
    rgba[60 : 60 + height, 60 : 60 + width] = (90, 70, 55, 255)
    for y in range(height):
        rgba[60 + y, 60 : 60 + y // 6] = 0  # a sloping gable end
    rgba[60 : 60 + height : 2, 60 + width - 20 : 60 + width] = 0  # a striped, half-empty tail
    return rgba


def test_slab_sides_are_flush_and_solid():
    cut = roof.flush_sides(_slab_rgba())
    alpha = cut[..., 3]
    assert (alpha[:, 0] > 200).all() and (alpha[:, -1] > 200).all()
    assert alpha[0].any() and alpha[-1].any()
    assert cut.shape[1] < 600 - 2 * roof.INSET


def test_slab_size_m_keeps_the_bay_width_and_aspect():
    w, h = roof.slab_size_m(np.zeros((200, 500, 4), np.uint8))
    assert w == roof.BAY_WIDTH_M and h == pytest.approx(roof.BAY_WIDTH_M * 200 / 500, abs=0.01)


def test_empty_slab_is_refused():
    with pytest.raises(ValueError):
        roof.flush_sides(np.zeros((50, 50, 4), np.uint8))


def _sheet_rgba():
    rgba = np.zeros((500, 900, 4), np.uint8)
    rgba[300:480, 600:680] = (120, 110, 100, 255)  # second row, right
    rgba[40:240, 50:150] = (120, 110, 100, 255)  # first row, left: a column
    rgba[30:36, 90:110] = (120, 110, 100, 255)  # a loose puff 4 px above it: same plume
    rgba[40:60, 175:195] = (120, 110, 100, 255)  # a detached puff 25 px right of it: same plume
    rgba[60:200, 400:520] = (120, 110, 100, 255)  # first row, right
    rgba[320:470, 80:160] = (120, 110, 100, 255)  # second row, left
    rgba[10:14, 800:804] = (120, 110, 100, 255)  # paper noise: dropped
    return rgba


def test_plumes_split_per_component_in_reading_order():
    plumes = roof.split_plumes(_sheet_rgba())
    assert len(plumes) == 4
    assert plumes[0].shape[0] == 210 + 2 * 4  # the column and its loose puff, with the trim margin
    assert [p.shape[1] for p in plumes] == [153, 128, 88, 88]
    for p in plumes:
        assert not p[..., 3][0].any() and not p[..., 3][-1].any()


def test_plume_scale_makes_the_tallest_plume_the_stated_height():
    plumes = roof.split_plumes(_sheet_rgba())
    scale = roof.plume_scale(plumes)
    assert max(p.shape[0] for p in plumes) * scale == pytest.approx(roof.PLUME_TALLEST_M)


def test_fire_spot_finds_the_biggest_flame():
    rgba = np.zeros((100, 300, 4), np.uint8)
    rgba[..., 3] = 255
    rgba[10:20, 20:30, :3] = (250, 170, 30)
    rgba[50:80, 200:260, :3] = (250, 180, 40)
    x, y = roof.fire_spot(rgba)
    assert 200 <= x < 260 and 50 <= y < 80


def test_cut_writes_slabs_and_plumes_without_red(tmp_path):
    sources = tmp_path / "src"
    sources.mkdir()
    slab = _slab_rgba()
    slab[100:140, 300:360, :3] = (240, 40, 20)  # a red flame the shift moves to amber
    white = np.where(slab[..., 3:] > 0, slab[..., :3], 255).astype(np.uint8)
    Image.fromarray(white).save(sources / "roof-burst.png")
    sheet = _sheet_rgba()
    Image.fromarray(np.where(sheet[..., 3:] > 0, sheet[..., :3], 255).astype(np.uint8)).save(sources / "plumes-a.png")
    out = tmp_path / "out"
    out.mkdir()
    slabs = roof._cut_slabs(sources, out, True)
    plumes, scale = roof._cut_plumes(sources, out, True)
    assert list(slabs) == ["roof-burst"] and (out / "hall_roof_burst.png").exists()
    assert red_share(np.asarray(Image.open(out / "hall_roof_burst.png"))) < 0.01
    assert len(plumes) == 4 and (out / "hall_plume_4.png").exists() and scale > 0


def test_contact_lays_the_slab_above_its_bay(tmp_path):
    for _, _, name, _ in roof.FRONT:
        bay = np.zeros((300, 485, 4), np.uint8)
        bay[...] = (200, 180, 160, 255)
        Image.fromarray(bay).save(tmp_path / f"{name}.png")
    slab = np.zeros((100, 400, 4), np.uint8)
    slab[...] = (90, 70, 55, 255)
    sheet = np.asarray(roof.contact({"roof-burst": slab}, [], 0.01, art=tmp_path))
    column = sheet[:, round((roof.FRONT[1][0] - roof.FRONT[0][0]) * roof.PPM) + 20 + 242, :3]
    slab_rows = np.where((column == (90, 70, 55)).all(axis=1))[0]
    bay_rows = np.where((column == (200, 180, 160)).all(axis=1))[0]
    assert slab_rows.size > 0 and slab_rows.max() < bay_rows.min()


def test_roof_line_skips_the_baked_plumes():
    bay = np.zeros((100, 200, 4), np.uint8)
    bay[10:30, 50:90, 3] = 255  # a plume over the roof
    bay[30:, :, 3] = 255  # the roof strip and the wall
    assert roof.roof_line(bay) == 30
