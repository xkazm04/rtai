"""Rebuild the Swarf Ronin HUD portrait from its shipped p55 flight sheet."""

import json
from pathlib import Path

from PIL import Image

from ghost_chip_cut import SIZE


PROJECT = Path(__file__).resolve().parents[2] / "project"


def main() -> None:
    cut = json.loads(Path(__file__).with_suffix(".json").read_text(encoding="utf-8"))
    with Image.open(PROJECT / cut["source"]) as sheet:
        cols, rows = cut["grid_columns_rows"]
        col, row = cut["cell_column_row"]
        w, h = sheet.width // cols, sheet.height // rows
        hover = sheet.crop((col * w, row * h, (col + 1) * w, (row + 1) * h))
        bust = hover.convert("RGBA").crop(cut["bust_xyxy"])
    square = Image.new("RGBA", (bust.width, bust.width))
    square.alpha_composite(bust, (0, (square.height - bust.height) // 2))
    square.resize((SIZE, SIZE), Image.Resampling.LANCZOS).save(PROJECT / cut["output"])


if __name__ == "__main__":
    main()
