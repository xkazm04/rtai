"""Regression checks for the arched_line floor tile cutter."""
import numpy as np
from PIL import Image

from prologue_yard_floor import SOURCE, cut, make_seamless


def _lstar(rgb: np.ndarray) -> float:
	c = rgb.astype(np.float64).mean(axis=(0, 1)) / 255.0
	c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
	y = 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]
	return 116 * y ** (1 / 3) - 16 if y > 0.008856 else 903.3 * y


def _tile(tmp_path) -> np.ndarray:
	out = tmp_path / "t.png"
	cut(SOURCE, out, 768)
	img = Image.open(out)
	assert img.size == (768, 768)
	return np.asarray(img.convert("RGB")).astype(np.float64)


def test_edges_are_continuous_across_the_wrap(tmp_path):
	"""The wrap difference must be no more than the source's own neighbour difference (the texture's
	natural pixel-to-pixel noise) and clearly below the source's own wrap difference."""
	t = _tile(tmp_path)
	src = np.asarray(Image.open(SOURCE).convert("RGB").resize((768, 768), Image.LANCZOS)).astype(np.float64)
	natural = (np.abs(np.diff(src, axis=1)).mean() + np.abs(np.diff(src, axis=0)).mean()) / 2
	for wrap in (np.abs(t[:, 0] - t[:, -1]).mean(), np.abs(t[0] - t[-1]).mean()):
		assert wrap <= natural
	assert np.abs(src[:, 0] - src[:, -1]).mean() > natural * 1.15


def test_mean_colour_stays_within_three_lstar(tmp_path):
	src = np.asarray(Image.open(SOURCE).convert("RGB"))
	assert abs(_lstar(_tile(tmp_path)) - _lstar(src)) <= 3.0


def test_seamless_wraps_a_gradient_exactly_to_its_neighbour():
	ramp = np.tile(np.linspace(0, 255, 64, dtype=np.float32)[None, :, None], (64, 1, 3))
	out = make_seamless(ramp)
	step = abs(float(out[0, 1, 0] - out[0, 0, 0]))
	assert abs(float(out[0, 0, 0] - out[0, -1, 0])) <= step * 1.5
