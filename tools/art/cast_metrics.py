"""Read the shipped street cards, measure the patrol reference and check LEG-05 paths and hashes.

Run from any directory: python tools/art/cast_metrics.py [cop_patrol|cop_riot|swat|thug|contractor]
"""

import argparse
import hashlib
import json
from pathlib import Path
from runpy import run_path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "project/features/characters/art/view"
SOLE_X = run_path(str(ROOT / "tools/film/foot_slide.py"))["sole_x"]
GRID_ROWS = {
    "card": 1,
    "walk": 4,
    "armed_walk": 4,
    "hit": 1,
    "shoulder_hit": 1,
    "gut_hit": 1,
    "jab_hit": 1,
    "heavy_hit": 1,
    "shock_hit": 1,
    "fall": 3,
    "long_fall": 3,
    "between_fall": 5,
    "pistol_snap": 4,
}


def provenance():
    hashes = {}
    for ledger in sorted((ROOT / "steam/ai-provenance").glob("*.jsonl")):
        for n, line in enumerate(ledger.read_text(encoding="utf-8-sig").splitlines(), 1):
            if line.strip():
                entry = json.loads(line)
                if entry.get("sha256"):
                    hashes[entry["file"], entry["sha256"]] = f"{ledger.name}:{n}"
    return hashes


def ink_runs(cell):
    """Horizontal run inward from the left silhouette of the patrol's front passing pose."""
    lengths = []
    for y in (70, 75, 80):
        row = cell[y]
        edge = np.flatnonzero(row[:, 3] >= 128)[0]
        fill = np.flatnonzero(row[edge:, :3].max(axis=1) >= 48)[0]
        lengths.append(int(fill))
    return lengths


def measure(path, rows, hashes):
    with Image.open(path) as image:
        rgba = np.array(image.convert("RGBA"), dtype=np.int16)
        hsv = np.array(image.convert("RGB").convert("HSV"), dtype=float) / 255
    height, width = rgba.shape[:2]
    if width % 5 or height % rows:
        raise ValueError(f"Sheet does not divide evenly into cells: {path}")
    cw, ch = width // 5, height // rows
    ref = path.relative_to(ROOT).as_posix()
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    ledger_line = hashes.get((ref, digest), "NO matching ledger line")
    print(f"{path.parent.name}/{path.name}  5x{rows}  {cw}x{ch} px  {ledger_line}")
    if not path.stem.endswith(("_walk", "_card")):
        return
    r, g, b, alpha = rgba.transpose(2, 0, 1)
    solid = alpha >= 128
    green = solid & (g - np.maximum(r, b) > 50)
    magenta = solid & (np.minimum(r, b) - g > 50)
    h, s, v = hsv.transpose(2, 0, 1)
    blue = solid & (h * 360 > 190) & (h * 360 < 250) & (s > 0.2) & (v > 0.08)
    if blue.any():
        hue = h[blue].mean() * 360
        print(f"  blue mean HSV {hue:.1f} deg {s[blue].mean():.3f} {v[blue].mean():.3f}")
    print(f"  retained strong green/magenta pixels {green.sum()}/{magenta.sum()}")
    if rows == 4:
        profile = solid[:, 2 * cw : 3 * cw]
        soles = [float(SOLE_X(profile[i * ch : (i + 1) * ch])) for i in range(rows)]
        print(f"  right-profile boot x {soles}, contact-to-pass texels "
              f"{soles[0] - soles[1]:g}, {soles[2] - soles[3]:g}")
    if path.stem == "cop_patrol_armed_walk":
        print(f"  left contour at cell (0,1), y=70/75/80: {ink_runs(rgba[ch:2*ch, :cw])} px")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("role", nargs="?", default="cop_patrol",
                        choices=["cop_patrol", "cop_riot", "swat", "thug", "contractor"])
    role = parser.parse_args().role
    ledger = provenance()
    for pitch in ("p70", "p55"):
        for action, count in GRID_ROWS.items():
            file = ART / pitch / f"{role}_{action}.png"
            if file.is_file():
                measure(file, count, ledger)
