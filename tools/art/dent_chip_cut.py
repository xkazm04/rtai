"""Cut Dent's spectral HUD face from the shipped p55 flight atlas."""

from pathlib import Path

from PIL import Image

from ghost_chip_cut import SIZE


def main():
    project = Path(__file__).resolve().parents[2] / "project"
    atlas = project / "features/souls/art/view/p55/dent_sp_fly.png"
    dest = project / "features/hud/art/ghost_chips/dent_spectral.png"
    with Image.open(atlas) as sheet:
        # Four pose columns, five facing rows. HOVER toward camera is (0, 0).
        cell = sheet.convert("RGBA").crop((0, 0, sheet.width // 4, sheet.height // 5))
    # A square around both hands and the plume, which already has a tapered foot.
    face = cell.crop((25, 4, 241, 220)).resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    face.save(dest)


if __name__ == "__main__":
    main()
