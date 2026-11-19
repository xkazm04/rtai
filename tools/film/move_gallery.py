"""Update the movement gallery after publishing the owner's Call pairs."""
import argparse
import json
from pathlib import Path


def update(masters):
    """Retain the selected earlier work and validate every link before replacing the index."""
    index = masters / "frames.json"
    old = json.loads(index.read_text(encoding="utf-8"))
    picks = [
        ("car/on-64/131-seat.png", "Into the sedan at tick 131", "car/off-64/131-seat.png",
         "The roof hides Rivet as he crosses the sill. The cosmetic entry still shows his boots."),
        ("calls/vault-64-t012.png", "Tackle or refuse the occupied landing", None,
         "At tick 12 the shipped vault carries Rivet over the crate. Blocking keeps him on the approach side."),
        ("calls/cover-64-t162.png", "Two shots past the station end", None,
         "The 0.45 m peek keeps Rivet closer to the box. Both rounds clear its corner."),
        ("calls/car-64-t124.png", "Two entries at the same tick", None,
         "At tick 124 the cosmetic entry follows the seated camera. Timed entry still follows Rivet on foot."),
    ]
    replaced = {"vault/tilt70_32_vault.mp4", "cover/tilt70_32_cover.mp4"}
    rows = [dict(file=file, title=title, ppm=64, before=before, note=note)
            for file, title, before, note in picks]
    replaced.update(row["file"] for row in rows)
    rows.extend(row for row in old if row["file"] not in replaced)
    if not 8 <= len(rows) <= 15:
        raise ValueError(f"Gallery has {len(rows)} entries")
    for row in rows:
        for file in (row["file"], row["before"]):
            if file is not None and not (masters / file).is_file():
                raise FileNotFoundError(file)
    pending = index.with_suffix(".tmp")
    pending.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    pending.replace(index)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("masters", type=Path)
    update(parser.parse_args().masters)
