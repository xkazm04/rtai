"""Cut the n28 arched_line floor tile: make the generated brown floor exactly seamless and resize it.

python tools/art/prologue_yard_floor.py [--source FILE] [--out FILE] [--size 768]

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


def cut(source: Path, out: Path, size: int) -> None:
	rgb = np.asarray(Image.open(source).convert("RGB"))
	tile = np.clip(make_seamless(rgb) + 0.5, 0, 255).astype(np.uint8)
	Image.fromarray(tile).resize((size, size), Image.LANCZOS).save(out, optimize=True)


def main() -> None:
	ap = argparse.ArgumentParser()
	ap.add_argument("--source", type=Path, default=SOURCE)
	ap.add_argument("--out", type=Path, default=OUT)
	ap.add_argument("--size", type=int, default=768)
	args = ap.parse_args()
	cut(args.source, args.out, args.size)
	print("wrote", args.out)


if __name__ == "__main__":
	main()
