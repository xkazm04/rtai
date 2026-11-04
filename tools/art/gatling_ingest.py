"""Ingest the gatling's cut parts and add its weapon_art.json row (n5-look, 2026-11-04).

The weapon-art lane's weapon_ingest.py rewrites every row from its own cut folders; this adds the
one new weapon without touching the others (their art has moved on since: blade_longer, small).
The sheet came from text plus a style reference (the flamethrower's tank and pickup), never as an
edit of a gun image (the image tool's moderation), barrels 50 % longer than r1_w6's variant A.

    python tools/art/gatling_ingest.py <cut_dir>   (weapon_cut.py output: gatling, gatling_tank, gatling_side)
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from weapon_ingest import ART, RES, TABLE, measure  # noqa: E402

WID = "gatling"
LENGTH_M = 1.55  # x hip_belt held_scale 1.2 = 1.86 m in the claw, the rocket tube's span
GRIP_U = 0.16  # the claw on the housing's rear grip; the off claw takes the carry handle


def main(cut):
    cut = Path(cut)
    d = ART / WID
    d.mkdir(parents=True, exist_ok=True)
    shutil.copy(cut / f"{WID}.png", d / "held.png")
    shutil.copy(cut / f"{WID}_tank.png", d / "tank.png")
    shutil.copy(cut / f"{WID}_side.png", d / "pickup.png")
    shutil.copy(cut / f"{WID}_side_icon.png", d / "icon.png")
    size, grip, muzzle, span = measure(d / "held.png", GRIP_U)
    row = {
        "casing": "casing", "grip_class": "hip_belt", "grip_px": grip, "held": f"{RES}/{WID}/held.png",
        "icon": f"{RES}/{WID}/icon.png", "id": WID, "length_m": LENGTH_M, "length_px": span,
        "muzzle_fx": "flash_smg", "muzzle_px": muzzle, "parts": {"tank": f"{RES}/{WID}/tank.png"},
        "pickup": f"{RES}/{WID}/pickup.png", "projectile_fx": "tracer", "size_px": size,
    }
    table = json.loads(TABLE.read_text(encoding="utf-8"))
    table["weapons"] = [r for r in table["weapons"] if r["id"] != WID] + [row]
    TABLE.write_bytes((json.dumps(table, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode())
    subprocess.run(["node", "tools/art/canon_json.mjs", str(TABLE)], check=True)
    print(json.dumps(row))


if __name__ == "__main__":
    main(sys.argv[1])
