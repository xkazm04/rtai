"""Single-cell packer for Tonnage's drop beats (n31 ghost 03).

  cell  <job.png> <strip.png> <col> <height>   key the green, keep the largest figure, scale it to
        <height> px, paste it bottom-centred (last opaque row 315) into column <col> of a 5 x
        384x320 transparent strip (created when missing), as the spectral sheets are packed.
  decal <job.png> <out.png> <size>             key the green, crop to the art, fit it in a
        <size> px square (centred, transparent) and print its opaque extent.
  strip <job.png> <out.png> [w h]              key the green, crop to the art, fit it (aspect kept,
        centred, transparent pad) in a w x h strip (default 1024x320); prints the art extent.

Run: py -3 -I tools/ghost/drop_pack.py cell|decal|strip ...
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage as ndi

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "art"))
from tonnage_spectral_parts import keyed_image  # noqa: E402

CELL_W, CELL_H, COLS, BASELINE = 384, 320, 5, 315


def largest(img):
    alpha = np.asarray(img)[:, :, 3] > 24
    labels, count = ndi.label(alpha)
    if count == 0:
        raise ValueError("no figure on the key")
    sizes = ndi.sum(alpha, labels, range(1, count + 1))
    keep = labels == (int(np.argmax(sizes)) + 1)
    keep = ndi.binary_dilation(keep, iterations=2)
    arr = np.asarray(img).copy()
    arr[~keep] = 0
    out = Image.fromarray(arr)
    return out.crop(out.getbbox())


def cell(job, strip, col, height):
    fig = largest(keyed_image(job))
    k = height / fig.height
    fig = fig.resize((max(1, round(fig.width * k)), height), Image.LANCZOS)
    if fig.width > CELL_W - 8:
        raise ValueError(f"figure {fig.width} px wide does not fit a {CELL_W} px cell")
    sheet = Image.open(strip).convert("RGBA") if Path(strip).exists() else None
    if sheet is None:
        sheet = Image.new("RGBA", (CELL_W * COLS, CELL_H), (0, 0, 0, 0))
    x0 = col * CELL_W
    sheet.paste((0, 0, 0, 0), (x0, 0, x0 + CELL_W, CELL_H))
    sheet.paste(fig, (x0 + (CELL_W - fig.width) // 2, BASELINE + 1 - height), fig)
    sheet.save(strip)
    print(f"cell {col}: {fig.width}x{fig.height} from {Path(job).name}")


def despill(img):
    """Ground art is world colour only: green left in a rim fades out and greys over."""
    arr = np.asarray(img).astype(np.float32)
    rgb, alpha = arr[:, :, :3], arr[:, :, 3]
    top = np.maximum(rgb[:, :, 0], rgb[:, :, 2])
    green = np.clip(rgb[:, :, 1] - top, 0, None)
    alpha *= np.clip(1 - (green - 20) / 60, 0, 1)
    rgb[:, :, 1] = np.minimum(rgb[:, :, 1], top + 6)
    arr[:, :, 3] = alpha
    return Image.fromarray(np.clip(np.rint(arr), 0, 255).astype(np.uint8))


def decal(job, out, size):
    art = despill(keyed_image(job))
    art = art.crop(art.getbbox())
    k = min(1.0, size / max(art.width, art.height))
    art = art.resize((round(art.width * k), round(art.height * k)), Image.LANCZOS)
    square = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    square.paste(art, ((size - art.width) // 2, (size - art.height) // 2), art)
    square.save(out)
    print(f"decal {Path(out).name}: art {art.width}x{art.height} in {size}x{size}")


def strip(job, out, width=1024, height=320):
    art = despill(keyed_image(job))
    art = art.crop(art.getbbox())
    k = min(width / art.width, height / art.height)
    art = art.resize((max(1, round(art.width * k)), max(1, round(art.height * k))), Image.LANCZOS)
    sheet = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    sheet.paste(art, ((width - art.width) // 2, (height - art.height) // 2), art)
    sheet.save(out)
    print(f"strip {Path(out).name}: art {art.width}x{art.height} in {width}x{height}")


def main():
    mode, args = sys.argv[1], sys.argv[2:]
    if mode == "cell":
        cell(args[0], args[1], int(args[2]), int(args[3]))
    elif mode == "decal":
        decal(args[0], args[1], int(args[2]))
    elif mode == "strip":
        strip(args[0], args[1], *(int(a) for a in args[2:4]))
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
