"""Measure the shipped equipment, diagonal, left and reload cells at turn-kit scale.

python tools/art/cell_metrics.py [--out evidence/arsenal/cell_metrics]
E rest is equipped cell 2 (RivetFrames.EQ_OCT[0]). The plate on the helmet
is the shell sample: it is visible from both sides and clear of the claw and collar.
"""
import argparse
import json
import re
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
VIEW = ROOT / "project/features/characters/art/view"
# CanvasItem.get_global_transform_with_canvas() * viewport/output ratio, 1280x720
# 64 px/m turn, standing p55/p70, divided by RivetWalk.RES for high-density strips.
Y_AT_110 = {"p55": 0.836429 * 1.5, "p70": 0.811894 * 1.5}
HEIGHT_LIMIT = 5.0
TONE_LIMIT = 8.0  # CIE76 units in D65 Lab
FACING = ("S", "SE", "E", "NE", "N", "E-fire", "S-fire", "idle")
DIAG = ("SE", "NE", "SW", "NW")
LEFT = ("SW", "W", "NW")
RELOAD = FACING[:5] + ("SE-out", "SE-in", "SE-ready")


def cells(path, count):
    with Image.open(path) as im:
        if im.width % count:
            raise ValueError(f"{path}: width is not divisible by {count}")
        return np.split(np.asarray(im.convert("RGBA")), count, axis=1)


def shell_rgb(rgb):
    r, g, b = rgb.astype(np.float32).transpose(2, 0, 1)
    return ((r - g > 5) & (g - b > 1) & (r - g < 92) &
            (r - g < 3.5 * (g - b) + 5) & (r > 48) & (r < 248))


def sole(body, seed):
    """Follow the run of opaque boot pixels below the reviewed interior point.
    A camera-facing weapon can extend between both feet and join their component.
    """
    y, x = np.nonzero(body)
    sx, sy = seed
    nearest = np.argmin((x-sx)**2 + (y-sy)**2)
    sx, sy = x[nearest], y[nearest]
    ends = []
    for col in range(max(0, sx-5), min(body.shape[1], sx+6)):
        if body[sy, col]:
            clear = np.flatnonzero(~body[sy:, col])
            ends.append(sy + clear[0]-1 if clear.size else body.shape[0]-1)
    return int(max(ends))


def figure(cell, nominal, boot_seed=None):
    """Crown-to-sole opaque extent and upper helmet plate sample, in cut pixels."""
    opaque = (cell[:, :, 3] >= 128).astype(np.uint8)
    count, ids, stats, _ = cv2.connectedComponentsWithStats(opaque, connectivity=8)
    if count < 2:
        raise ValueError("empty figure")
    body = ids == (1 + stats[1:, cv2.CC_STAT_AREA].argmax())
    ys, xs = np.nonzero(body)
    y, x = np.indices(body.shape)
    warm = shell_rgb(cell[:, :, :3]) & body
    # A helmet makes a broad patch of rust above the shoulders. A thin barrel,
    # visor or stripe cannot fill this disk. Ignore detached effects entirely.
    radius = max(2, round(nominal * .085))
    disk = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2*radius+1, 2*radius+1))
    score = cv2.filter2D(warm.astype(np.float32), -1, disk, borderType=cv2.BORDER_CONSTANT)
    floor = int(ys.max())
    crown = max(int(ys.min()), floor - nominal * 1.4)
    zone = body & (y <= crown + (floor - crown) * .47)
    if not zone.any():
        zone = body
    cy, cx = np.unravel_index(np.argmax(np.where(zone, score, -1)), zone.shape)
    plate = ((x-cx)**2 + (y-cy)**2 <= radius**2) & warm
    if not plate.any():
        raise ValueError("no warm helmet pixels")
    # The midline crown (including its cap) and the boots below the helmet.
    column = body & (abs(x - cx) <= max(3, round(nominal * .13))) & (y <= cy)
    boots = body & (abs(x - cx) <= nominal * .49)
    top, bottom = int(y[column].min()), int(y[boots].max())
    if boot_seed is not None:
        bottom = sole(body, boot_seed)
    return bottom-top+1, np.median(cell[plate, :3], axis=0), (int(cx), int(cy), radius)


def lab(rgb):
    return cv2.cvtColor(np.float32([[rgb]]) / 255, cv2.COLOR_RGB2Lab)[0, 0]


def compare(height, tone, ref_h, ref_rgb):
    delta = (height / ref_h - 1) * 100
    de = float(np.linalg.norm(lab(tone) - lab(ref_rgb)))
    flags = [flag for flag, hit in (("H", abs(delta) > HEIGHT_LIMIT + 1e-8),
                                    ("T", de > TONE_LIMIT)) if hit]
    return round(delta, 2), round(de, 2), "".join(flags) or "-"


def report():
    arsenal = json.loads((ROOT / "project/data/tables/rivet_arsenal.json").read_text())
    high = set(re.findall(r'"(p(?:55|70)/[^"]+\.png)"',
                          (ROOT / "project/features/characters/rivet_res.gd").read_text()))
    rows = []
    seeds = json.loads(Path(__file__).with_name("cell_boot_seeds.json").read_text())
    for weapon in sorted(arsenal["weapons"]):
        gun = weapon.replace("-", "_")
        for pitch, game_scale in Y_AT_110.items():
            folder = VIEW / pitch
            eq = "rivet_eq_" + gun
            reload = "rivet_reload_" + gun
            groups = [(eq, FACING), (eq+"_noflash", FACING), (eq+"_diag", DIAG),
                      (eq+"_diag_noflash", DIAG), (eq+"_left", LEFT),
                      (reload, RELOAD), (reload+"_left", LEFT)]
            measured = []
            for stem, frames in groups:
                path = folder / (stem + ".png")
                if not path.exists():
                    continue
                factor = 1.5 if f"{pitch}/{stem.removesuffix('_noflash')}.png" in high else 1
                dark = path.with_stem(stem + "_noflash")
                # Flash is a timed texture swap on the same card. Its twin exposes
                # the actual boots and helmet even where a flare covers them.
                source = dark if dark.exists() else path
                for index, (image, facing) in enumerate(zip(cells(source, len(frames)), frames)):
                    seed_key = f"{pitch}/{stem.removesuffix('_noflash')}"
                    seed = seeds.get(seed_key, {}).get(str(index))
                    h, rgb, _ = figure(image, 110 * factor, seed)
                    measured.append((stem, index, facing, h * game_scale / factor, rgb))
            ref = next(r for r in measured if r[:2] == (eq, 2))
            for stem, index, facing, height, rgb in measured:
                delta, de, flag = compare(height, rgb, ref[3], ref[4])
                rows.append(dict(weapon=weapon, pitch=pitch, strip=stem, cell=index,
                                 facing=facing, height_px=round(height, 2),
                                 shell_rgb=list(map(int, np.rint(rgb))), height_pct=delta,
                                 delta_e=de, flag=flag))
    return rows


def write(out):
    rows = report()
    method = ("64 px/m standing turn scale; alpha >= 128, connected crown to sole, "
              "median sRGB of rust pixels on upper helmet plate. E = equipped cell 2. "
              "H: abs(height difference) > 5%; T: CIE76 D65 delta E > 8. "
              "Lit cells use matching flashless geometry when supplied; projecting weapons use reviewed boot seeds.")
    out.with_suffix(".json").write_text(json.dumps(dict(method=method, rows=rows), indent=1)+"\n")
    with out.with_suffix(".txt").open("w", newline="\n") as f:
        print(method, file=f)
        print("weapon pitch strip cell facing height_px shell_rgb height_pct delta_E flag", file=f)
        for r in rows:
            print(*[(",".join(map(str, v)) if isinstance(v, list) else v)
                    for v in r.values()], file=f)
    return rows


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=ROOT / "evidence/arsenal/cell_metrics")
    write(parser.parse_args().out)
