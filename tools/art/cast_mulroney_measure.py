"""Measure an eight-drawing Mulroney take from cast_feet.mjs with the checklist's ink oracles."""
import argparse
import json
from pathlib import Path

import numpy as np

from cast_feet import contact_stats, passes, torso
from cast_mulroney_soles import STRIP, sole
from cast_soles import cell, project


def measure(take, ppm):
    cards = [frame["card"] for frame in take["frames"]]
    series, bodies, edges = [], [], []
    for i, card in enumerate(cards):
        path, rect = card["path"], tuple(card["rect"])
        if not path.endswith("/" + STRIP) or card["col"] != (2 if take["facing"] == "right" else 1):
            raise ValueError("wrong walk or facing")
        row = card["row"]
        if i and row != cards[i - 1]["row"]:
            if row != (cards[i - 1]["row"] + 1) % 8:
                raise ValueError("skipped a drawing")
            edges.append(i)
        point = sole(cell(path, rect), take["pitch"], card["col"], row)
        series.append({str(row // 4): project(card, point) * 32 / ppm})
        bodies.append(project(card, torso(path, rect)) * 32 / ppm)
    travel, _, spans = contact_stats(series)
    if {span["boot"] for span in spans} != {"0", "1"} or len(edges) < 8:
        raise ValueError("incomplete stride")
    jump = float(np.linalg.norm(np.diff(bodies, axis=0), axis=1).max())
    row = {k: v for k, v in take.items() if k != "frames"}
    row.update(max_contact_travel_px=travel, max_body_jump_px=jump, contacts=len(spans),
               observed_drawings_per_second=60 * (len(edges) - 1) / (edges[-1] - edges[0]),
               verdict="PASS" if passes(travel, jump) else "FAIL")
    return row, spans


def run(directory, ppm):
    rows = []
    for pitch in (70, 55):
        takes = json.loads((directory / f"tracks_{pitch}_{ppm}.json").read_text())
        if len(takes) != 2 or {t["facing"] for t in takes} != {"right", "down_right"}:
            raise ValueError("incomplete facing coverage")
        for take in takes:
            if take["archetype"] != "sergeant_mulroney" or take["ppm"] != ppm or take["pitch"] != pitch:
                raise ValueError("unexpected actor, scale or pitch")
            row, spans = measure(take, ppm)
            rows.append(row)
            print(pitch, take["facing"], row["max_contact_travel_px"], row["max_body_jump_px"],
                  row["observed_drawings_per_second"], row["verdict"])
            if ppm == 64 and take["facing"] == "right":
                trace = dict(tick=38, spans=spans, ppm=32, row=row)
                (directory / f"sergeant_mulroney_{pitch}_dots.json").write_text(json.dumps(trace))
    output = "feet" if ppm == 32 else "feet_64"
    (directory / f"{output}.json").write_text(json.dumps(
        dict(schema="gtai.cast-feet/1", unit_ppm=32, rows=rows), indent=2) + "\n")
    return all(row["verdict"] == "PASS" for row in rows)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("ppm", type=int, choices=(32, 64))
    args = parser.parse_args()
    raise SystemExit(0 if run(args.directory, args.ppm) else 1)
