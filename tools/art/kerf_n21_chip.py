"""Rebuild the Swarf Ronin HUD portrait from its shipped p55 flight sheet."""

from pathlib import Path

from PIL import Image

from ghost_chip_cut import SIZE


PROJECT = Path(__file__).resolve().parents[2] / "project"
# Source manifest. Four columns × five facings, HOVER toward camera in row 0, column 0.
SOURCE = PROJECT / "features/souls/art/view/p55/kerf_sp_fly.png"
OUTPUT = PROJECT / "features/hud/art/ghost_chips/kerf_spectral.png"
BUST = (60, 0, 461, 243)  # Both raised blades, helmet and chest down to the waist.


def main() -> None:
    with Image.open(SOURCE) as sheet:
        hover = sheet.crop((0, 0, sheet.width // 4, sheet.height // 5))
        bust = hover.convert("RGBA").crop(BUST)
    square = Image.new("RGBA", (bust.width, bust.width))
    square.alpha_composite(bust, (0, (square.height - bust.height) // 2))
    square.resize((SIZE, SIZE), Image.Resampling.LANCZOS).save(OUTPUT)


if __name__ == "__main__":
    main()
