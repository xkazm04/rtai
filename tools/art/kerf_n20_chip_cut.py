"""Cut Kerf's 84 px spectral HUD portrait from his shipped p55 hover sheet."""

from pathlib import Path

from PIL import Image

from ghost_chip_cut import SIZE


PROJECT = Path(__file__).resolve().parents[2] / "project"
SOURCE = PROJECT / "features/souls/art/view/p55/kerf_hover.png"
OUTPUT = PROJECT / "features/hud/art/ghost_chips/kerf_spectral.png"


def main() -> None:
    with Image.open(SOURCE) as sheet:
        width, height = sheet.width // 3, sheet.height // 5
        # Three-quarter toward is the second facing. POISED is the first column.
        cell = sheet.crop((0, height, width, height * 2)).convert("RGBA")
    body = cell.crop(cell.getchannel("A").getbbox())
    side = max(body.size) + 4
    square = Image.new("RGBA", (side, side))
    square.alpha_composite(body, ((side - body.width) // 2, (side - body.height) // 2))
    square.resize((SIZE, SIZE), Image.Resampling.LANCZOS).save(OUTPUT)


if __name__ == "__main__":
    main()
