"""prescale.py <cells dir> <out dir> <k>: every cell resized by k (LANCZOS), so a walk grid can be
packed by ghost_pack.py unscaled (box-centred, as the walk grids are) at its right sheet's scale."""
import sys
from pathlib import Path
from PIL import Image
src, out, k = Path(sys.argv[1]), Path(sys.argv[2]), float(sys.argv[3])
out.mkdir(parents=True, exist_ok=True)
for f in sorted(src.glob("*.png")):
    im = Image.open(f).convert("RGBA")
    im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS).save(out / f.name)
print(out, k)
