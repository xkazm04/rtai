"""Cut the n28 arched_line floor tile: make the generated brown floor exactly seamless and resize it.

python tools/art/prologue_yard_floor.py [--source FILE] [--out FILE] [--size 768] [--lift-l dL] [--chroma k]

Seamless method: blend the image with itself rolled by half on each axis, weighted by a cosine window
that is 1 in the middle and 0 at the edges. The edges then come from the rolled copy, whose left and
right columns (top and bottom rows) are neighbours in the source, so the tile wraps with no line.
"""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "tools/art/prologue_yard_sources/n28/floor_brown.png"
OUT = ROOT / Path("project/boot/prologue/art/arched_line/floor_tile.png")


def _window(n: int) -> np.ndarray:
	x = (np.arange(n) + 0.5) / n
	return 0.5 - 0.5 * np.cos(2.0 * np.pi * x)


def make_seamless(img: np.ndarray) -> np.ndarray:
	out = img.astype(np.float32)
	for axis in (1, 0):
		n = out.shape[axis]
		w = _window(n)
		w = w[None, :, None] if axis == 1 else w[:, None, None]
		out = out * w + np.roll(out, n // 2, axis=axis) * (1.0 - w)
	return out


_M = np.array([[0.4124564, 0.3575761, 0.1804375], [0.2126729, 0.7151522, 0.0721750], [0.0193339, 0.1191920, 0.9503041]])
_WHITE = np.array([0.95047, 1.0, 1.08883])


def _f(t: np.ndarray) -> np.ndarray:
	return np.where(t > 216 / 24389, np.cbrt(t), (24389 / 27 * t + 16) / 116)


def _finv(t: np.ndarray) -> np.ndarray:
	return np.where(t**3 > 216 / 24389, t**3, (116 * t - 16) / (24389 / 27))


def grade_lab(rgb: np.ndarray, lift_l: float, chroma: float) -> np.ndarray:
	"""Add lift_l to L*, scale a* and b* by chroma (hue unchanged), clip to sRGB. rgb float 0..255."""
	c = rgb / 255.0
	lin = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
	f = _f((lin @ _M.T) / _WHITE)
	lab_l = 116 * f[..., 1] - 16 + lift_l
	a = 500 * (f[..., 0] - f[..., 1]) * chroma
	b = 200 * (f[..., 1] - f[..., 2]) * chroma
	fy = (lab_l + 16) / 116
	xyz = np.stack([_finv(fy + a / 500), _finv(fy), _finv(fy - b / 200)], axis=-1) * _WHITE
	lin = np.clip(xyz @ np.linalg.inv(_M).T, 0.0, 1.0)
	enc = np.where(lin <= 0.0031308, lin * 12.92, 1.055 * lin ** (1 / 2.4) - 0.055)
	return enc * 255.0


def cut(source: Path, out: Path, size: int, lift_l: float = 0.0, chroma: float = 1.0) -> None:
	rgb = np.asarray(Image.open(source).convert("RGB"))
	seamless = make_seamless(rgb)
	if lift_l != 0.0 or chroma != 1.0:
		seamless = grade_lab(seamless, lift_l, chroma)
	tile = np.clip(seamless + 0.5, 0, 255).astype(np.uint8)
	Image.fromarray(tile).resize((size, size), Image.LANCZOS).save(out, optimize=True)


def main() -> None:
	ap = argparse.ArgumentParser()
	ap.add_argument("--source", type=Path, default=SOURCE)
	ap.add_argument("--out", type=Path, default=OUT)
	ap.add_argument("--size", type=int, default=768)
	ap.add_argument("--lift-l", type=float, default=0.0)
	ap.add_argument("--chroma", type=float, default=1.0)
	args = ap.parse_args()
	cut(args.source, args.out, args.size, args.lift_l, args.chroma)
	print("wrote", args.out)


if __name__ == "__main__":
	main()
