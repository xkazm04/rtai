"""Paste req221's two pre-placed p70 profile cells. Pass the placed_163x230 directory."""

import argparse
import hashlib
import json
from pathlib import Path
from tempfile import NamedTemporaryFile

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "art_src/tonnage_walk16_req221.manifest.json"
CELL = (163, 230)


def box(row, col):
    width, height = CELL
    return col * width, row * height, (col + 1) * width, (row + 1) * height


def swap(source_dir):
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    sheet = ROOT / manifest["sheet"]
    with Image.open(sheet) as image:
        assert image.size == (16 * CELL[0], 5 * CELL[1]) and image.mode == "RGBA"
        before = image.copy()
    after = before.copy()
    cells = {}
    for master in manifest["masters"].values():
        path = source_dir / Path(master["file"]).name
        assert hashlib.sha256(path.read_bytes()).hexdigest() == master["sha256"], path
        row, col = (int(v) - 1 for v in path.stem.split("_"))
        with Image.open(path) as cell:
            assert cell.mode == "RGBA" and cell.size == CELL, path
            cells[row, col] = cell.tobytes()
            after.paste(cell, box(row, col))
    assert set(cells) == {(2, 2), (2, 6)}
    with NamedTemporaryFile(dir=sheet.parent, suffix=".tmp", delete=False) as tmp:
        candidate = Path(tmp.name)
    try:
        after.save(candidate, format="PNG")
        with Image.open(candidate) as saved:
            for row in range(5):
                for col in range(16):
                    bounds = box(row, col)
                    expected = cells.get((row, col), before.crop(bounds).tobytes())
                    assert saved.crop(bounds).tobytes() == expected, (row, col)
        candidate.replace(sheet)
    finally:
        candidate.unlink(missing_ok=True)
    print("78/78 non-swapped cells byte-identical (RGBA); 2/2 profile cells match req221.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("placed_cells", type=Path)
    swap(parser.parse_args().placed_cells)
