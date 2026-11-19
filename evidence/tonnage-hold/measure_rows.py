"""Measure logged-key rides and two-dimensional stance drift at 32 px/m (leg 2)."""

import argparse
import contextlib
import io
import itertools
import json
import re
import runpy
import sys
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
ROW = {0: 2, 45: 1, -45: 3, 135: 0, -135: 2, 180: 1, 90: 0, -90: 4}


def film_holds(prefix):
    log = prefix.with_suffix(".txt")
    text = log.read_text(encoding="utf-8-sig") if log.exists() else json.loads(
        prefix.with_suffix(".log").read_text())["out"]
    samples = re.findall(r"sample (\d+) (\d+) (\S+) oct=\d+ row=\d+ col=(\d+)", text)
    assert [int(s[0]) for s in samples] == list(range(110))
    first = int(samples[0][1])
    assert [int(s[1]) for s in samples] == list(range(first, first + len(samples)))
    keys = [("C" if Path(s[2]).stem in ("tonnage_walk8", "tonnage_walk8_left") else "M")
            + s[3] for s in samples]
    args = sys.argv
    try:
        sys.argv = ["hold_ride.py", str(prefix), "2", str(len(samples)), "0,45", "70,150,190,222"]
        with contextlib.redirect_stdout(io.StringIO()):
            shifts = runpy.run_path(str(ROOT / "evidence/s15/tools/hold_ride.py"))["shift"]
    finally:
        sys.argv = args
    tick = 0
    spans = []
    for key, group in itertools.groupby(keys):
        length = len(list(group))
        ride = sum(shifts[tick:tick + length - 1])
        spans.append((key, first + tick, first + tick + length - 1, ride))
        tick += length
    return spans


def contacts(cell):
    alpha = np.asarray(cell)[..., 3] > 128
    low = np.flatnonzero(alpha.any(1))[-1]
    xs = np.flatnonzero(alpha[low - 3:low + 1].any(0))
    points = []
    for g in np.split(xs, np.flatnonzero(np.diff(xs) > 6) + 1):
        y = np.flatnonzero(alpha[:, g[0]:g[-1] + 1].any(1))[-1]
        points.append([(g[0] + g[-1]) / 2 - cell.width / 2, y - cell.height])
    return np.array(points)


def row_contacts(sheet, count, row, rows):
    with Image.open(sheet) as im:
        w, h = im.width // count, im.height // rows
        return [contacts(im.crop((i*w, row*h, (i+1)*w, (row+1)*h))) for i in range(count)]


def pose_dwells(weights, base, divisions, extra):
    """The original key centres stay fixed. New cells partition the gap between them."""
    dwell = np.maximum((weights + np.roll(weights, 1)) / 2, 0.4 * weights.mean())
    dwell /= dwell.sum()
    if not divisions:
        return base, dwell
    centres = np.cumsum(dwell) - dwell / 2
    art, phase = [], []
    added = iter(extra)
    for i, count in enumerate(divisions):
        gap = (dwell[i] + dwell[(i + 1) % len(dwell)]) / 2
        for j in range(count):
            phase.append(centres[i] + gap * j / count)
            art.append(base[i] if j == 0 else next(added))
    # Nearest-sample intervals end halfway to the next art centre, including the seam.
    ends = (np.array(phase) + np.r_[phase[1:], phase[0] + 1]) / 2
    return art, (ends - np.roll(ends, 1)) % 1


def stance_drift(pitch, turn, weights, divisions=(), atlas="diag"):
    left = abs(turn) > 90
    grid = ROOT / "project/features/souls/art/view" / pitch
    suffix = ("_left" if left else "") + ".png"
    row, rows = ROW[turn], 3 if left else 5
    base = row_contacts(grid / ("tonnage_walk8" + suffix), len(weights), row, rows)
    extra_path = atlas if isinstance(atlas, Path) else grid / ("tonnage_walk8_" + atlas + suffix)
    extra = row_contacts(extra_path,
                         sum(divisions) - len(weights), row, rows) if divisions else []
    art, dwell = pose_dwells(np.array(weights), base, divisions, extra)
    angle = np.deg2rad(turn)
    ground = np.array([np.cos(angle), np.sin(angle) * np.sin(np.deg2rad(int(pitch[1:])))])
    cycle = 223.25 if pitch == "p55" else 235
    # Straight-facing travel has no horizontal component. Gate those contacts on y.
    axis = 1 if abs(turn) == 90 else 0
    errors = []
    for i, points in enumerate(art):
        j = (i + 1) % len(art)
        travel = ground * (dwell[i] + dwell[j]) * 0.5 * cycle
        # Same horizontal support-pair gate as ghost_slip; include both screen axes in the error.
        pairs = [np.linalg.norm(b - a + travel) for a in points for b in art[j]
                 if -80 < (b[axis] - a[axis]) * np.sign(ground[axis]) <= 4]
        if pairs:
            errors.append(min(pairs))
    return np.mean(errors) * 32 * 3.3 / 190.5, len(errors)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("prefix", type=Path)
    parser.add_argument("--steps", type=Path, required=True, help="captured step tables, keyed by pitch")
    parser.add_argument("--pitch", choices=["p70", "p55"], required=True)
    parser.add_argument("--turn", type=int, choices=ROW, required=True)
    parser.add_argument("--divisions", help="comma-separated interval counts for the extra atlas")
    parser.add_argument("--atlas", default="diag")
    parser.add_argument("--atlas-file", type=Path, help="captured comparison atlas for this facing")
    args = parser.parse_args()
    spans = film_holds(args.prefix)
    for key, a, b, ride in spans:
        print(f"{key:>3} {a}-{b} {ride:.3f}")
    rides = [span[3] for span in spans[:-1]]
    divisions = list(map(int, args.divisions.split(","))) if args.divisions else []
    error, n = stance_drift(args.pitch, args.turn, json.loads(args.steps.read_text())[args.pitch],
                            divisions, args.atlas_file or args.atlas)
    print(f"{len(rides)} closed holds, worst {max(rides):.3f}, mean {np.mean(rides):.3f}, "
          f"open tail {spans[-1][3]:.3f}, drift {error:.3f} ({n} matched pairs)")
