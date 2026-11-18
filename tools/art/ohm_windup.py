"""Rebuild Ohm's historical act sheets, verify their RGBA digests, then replace column one.

Run from the repo root: python tools/art/ohm_windup.py <library/keyed/ghosts> <output view dir>
"""
import argparse
import hashlib
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

from PIL import Image

from ghost_pack import PAD, mass_x


# Shipped RGBA before it383, including the per-cell re-tone of the p70 drawn left.
BASE = {
    (70, False): "4d6eb68a26668edb840c90572d27d4353044a7f8949aacc049c81262021cef27",
    (70, True): "fbcdbb4d2bffe2edbae00b5b2324f430a1c6be88ae694d2961fd9f08ddca0877",
    (55, False): "af096232f7b56d65d63815469d629e14f069b125899a336d67a06d8de4bc4f30",
    (55, True): "5a569598f9dbe9887dba96494a796603ac7c7f234baae7850f90828e056bbf3f",
}


def reproduce(src, pitch, left, out):
    spec = str(src) if left else f"{src}+{src}_hit2"
    if left and pitch == 70:
        spec += f"+{src}_pretone"
    scale = {70: "--k=0.9045226130653267", 55: "--k=0.8812"} if left else {
        70: "--match=180", 55: "--match=193"
    }
    subprocess.run([sys.executable, "tools/art/ghost_pack.py", spec, out, scale[pitch]], check=True)
    if left and pitch == 70:
        subprocess.run([sys.executable, "evidence/it13/tools/retone_sheet.py", out,
                        "4", "3", f"{src}_pretone", src, "grid"], check=True)
    base = Image.open(out).convert("RGBA")
    if hashlib.sha256(base.tobytes()).hexdigest() != BASE[pitch, left]:
        raise ValueError(f"{src}: original RGBA differs from the shipped sheet")
    return base


def replace_windup(base, cells):
    rows = len(cells)
    w, h = base.width // 4, base.height // rows
    # Keep the original horizontal origin and the foot line. Pad above the old rows.
    height = max(h, max(im.height for im in cells) + PAD + 2)
    sheet = Image.new("RGBA", (base.width, rows * height))
    for row, im in enumerate(cells):
        bottom = (row + 1) * height
        old = base.crop((w, row * h, 4 * w, (row + 1) * h))
        sheet.paste(old, (w, bottom - h))
        assert sheet.crop((w, bottom - h, 4 * w, bottom)).tobytes() == old.tobytes()
        x = round(w / 2 - mass_x(im))
        if x < 0 or x + im.width > w:
            raise ValueError(f"row {row + 1} needs horizontal padding")
        sheet.paste(im, (x, bottom - PAD - im.height), im)
    return sheet


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("keyed", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    with TemporaryDirectory() as scratch:
        for pitch, left in BASE:
            suffix = "_left" if left else ""
            src = args.keyed / f"ohm_act_{pitch}{suffix}_cells"
            base = reproduce(src, pitch, left, Path(scratch) / "baseline.png")
            rows = 3 if left else 5
            cells = [Image.open(Path(f"{src}_windup") / f"{r}_1.png").convert("RGBA")
                     for r in range(1, rows + 1)]
            sheet = replace_windup(base, cells)
            out = args.out / f"p{pitch}" / f"ohm_act{suffix}.png"
            out.parent.mkdir(parents=True, exist_ok=True)
            sheet.save(out)
            print(f"{out}: baseline exact, columns 2-4 exact, cell {sheet.width // 4}x{sheet.height // rows}")


if __name__ == "__main__":
    main()
