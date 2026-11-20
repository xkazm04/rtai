"""Cut the 1080p spectral HUD face from Tonnage's front-facing p55 CARRY cell."""
from pathlib import Path

from PIL import Image

SIZE = 84
AIR = 4
PROJECT = Path(__file__).resolve().parents[2] / "project"
SHEET = PROJECT / "features/souls/art/view/p55/tonnage_spectral_pose.png"
OUTPUT = PROJECT / "features/hud/art/ghost_chips/tonnage_spectral.png"


def main() -> None:
    with Image.open(SHEET) as sheet:
        cell = sheet.convert("RGBA").crop((0, 0, 384, 320))
    figure = cell.crop(cell.getchannel("A").getbbox())
    figure.thumbnail((SIZE - 2 * AIR, SIZE - 2 * AIR), Image.Resampling.LANCZOS)
    face = Image.new("RGBA", (SIZE, SIZE))
    face.alpha_composite(figure, ((SIZE - figure.width) // 2, (SIZE - figure.height) // 2))
    face.save(OUTPUT)


if __name__ == "__main__":
    main()
