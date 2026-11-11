"""n15 combat (brief item 4, impacts by surface): the asset lane's drawn impact cells (it317
fx_impacts_70 take a, `_cells_rim/`: 1_2 concrete dust; 1_1 metal sparks is not taken until a round
is filmed hitting metal; drawn travelling RIGHT,
the debris thrown toward +x) cut to the alpha bbox and scaled so the longest side is SIDE px, into
project/features/combat/weapons/art/fx/impact_<name>.png. GunFxMarks draws them turned so +x points
back along the round (the debris flies toward the shooter). Raw art, premultiplied resampling.
Deterministic.

    PYTHONDONTWRITEBYTECODE=1 python -I tools/art/impact_cells.py [--lib=<library>/keyed/fx]
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "project/features/combat/weapons/art/fx"
LIB = Path("C:/Users/kazda/kiro/gtai-art/library/keyed/fx")
SIDE = 160
CELLS = {"dust": "fx_impacts_70_cells_rim/1_2.png"}


def cut(path: Path) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    a = np.array(im)[:, :, 3]
    ys, xs = np.where(a > 8)
    im = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    k = SIDE / max(im.size)
    size = (max(1, round(im.width * k)), max(1, round(im.height * k)))
    pre = np.array(im).astype(np.float32)
    pre[:, :, :3] *= pre[:, :, 3:4] / 255.0
    small = np.stack(
        [np.array(Image.fromarray(pre[:, :, c]).resize(size, Image.LANCZOS)) for c in range(4)], axis=2
    )
    al = np.clip(small[:, :, 3:4], 0.0, 255.0)
    rgb = np.where(al > 0.5, small[:, :, :3] * 255.0 / np.maximum(al, 0.5), 0.0)
    return Image.fromarray(np.clip(np.concatenate([rgb, al], axis=2), 0, 255).round().astype(np.uint8))


def main() -> None:
    lib = LIB
    for arg in sys.argv[1:]:
        if arg.startswith("--lib="):
            lib = Path(arg[6:])
    for name, rel in CELLS.items():
        out = OUT / f"impact_{name}.png"
        cut(lib / rel).save(out, optimize=True)
        print(f"{out.name}: {Image.open(out).size}")


if __name__ == "__main__":
    main()
