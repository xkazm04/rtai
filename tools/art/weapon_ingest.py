"""Ingest cut weapon parts into the project and write data/tables/weapon_art.json (weapon-art lane).

Inputs: a TOP-DOWN cut folder (held parts) and a SIDE cut folder (pickup + `_icon`), both made by
weapon_cut.py, plus the FX folder made by weapon_fx.py. Per weapon it copies
    project/features/combat/weapons/art/<id>/{held,pickup,icon}.png (+ extra parts, e.g. the tank)
and measures the held part: the muzzle point is the opaque tip on the bore line (the rightmost
opaque px on the row through the part's mid height band), the grip point is the bore line at the
row's `grip_u` fraction of the length. Both are data, so rivet-arsenal attaches the part at
`grip_px` and gunplay spawns shots at `muzzle_px` (see docs/art/weapons.md).

    python tools/art/weapon_ingest.py <top_dir> <side_dir> <fx_dir>
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ART = Path("project/features/combat/weapons/art")
RES = "res://features/combat/weapons/art"
TABLE = Path("project/data/tables/weapon_art.json")

# id: grip class, drawn length in metres (held, the read at 32 px/m), grip_u along the length,
# muzzle fx, projectile fx, casing (or ""), extra parts {name: file in top_dir}
ROWS = {
    "pistol": ("one_hand", 0.70, 0.40, "flash_pistol", "tracer", "casing", {}),
    "machine_pistol": ("one_hand", 0.90, 0.50, "flash_smg", "tracer", "casing", {}),
    "rocket_launcher": ("shoulder", 1.70, 0.50, "flash_tube", "rocket", "", {}),
    "flamethrower": ("backpack_hose", 1.15, 0.22, "flame", "flame", "", {"tank": "flamethrower_tank"}),
    "electro_gun": ("two_hand_long", 1.00, 0.32, "arc", "arc", "", {}),
    "molotov": ("thrown", 0.48, 0.40, "flame", "flame", "", {}),
    "gloria": ("one_hand", 0.80, 0.30, "flash_pistol", "tracer", "", {}),
    "katana": ("two_hand_long", 1.30, 0.12, "", "", "", {}),
    "electro_baton": ("one_hand", 0.80, 0.14, "arc", "", "", {}),
    "hand_cannon": ("one_hand", 0.85, 0.30, "flash_tube", "tracer", "casing", {}),
    "plasma_rifle": ("two_hand_long", 1.35, 0.40, "flash_energy", "plasma_bolt", "", {}),
    "chainsaw": ("heavy_two_hand", 1.30, 0.22, "", "", "", {}),
    "plasma_sword": ("two_hand_long", 1.30, 0.10, "", "", "", {}),
    "ray_gun": ("two_hand_long", 0.90, 0.30, "flash_energy", "ray_ring", "", {}),
    "homing_shard": ("two_hand_long", 1.00, 0.35, "flash_energy", "shard", "", {}),
    "mini_nuke": ("shoulder", 1.50, 0.40, "flash_nuke", "rocket", "", {}),
}


def bore(alpha):
    """The bore row: the mid height of the opaque band in the front third of the part."""
    h, w = alpha.shape
    front = alpha[:, int(w * 0.66) :] > 128
    ys = np.nonzero(front.any(axis=1))[0]
    return int((ys.min() + ys.max()) / 2) if ys.size else h // 2


def measure(path, grip_u):
    """Size, grip (on the bore line at grip_u of the span), muzzle (the tip near the bore line), span."""
    a = np.array(Image.open(path))[..., 3]
    h, w = a.shape
    y = bore(a)
    reach = max(4, int(h * 0.2))
    band = a[max(0, y - reach) : y + reach + 1, :] > 128
    xs = np.nonzero(band.any(axis=0))[0]
    x_tip, x_tail = int(xs.max()), int(xs.min())
    gx = int(x_tail + (x_tip - x_tail) * grip_u)
    return [w, h], [gx, y], [x_tip, y], x_tip - x_tail


def fx_rows(fx_dir):
    rows = json.loads((fx_dir / "fx_rows.json").read_text())
    out = []
    for r in rows:
        shutil.copy(fx_dir / f"{r['id']}.png", ART / "fx" / f"{r['id']}.png")
        out.append({"anchor_px": r["anchor_px"], "art": f"{RES}/fx/{r['id']}.png", "id": r["id"], "size_px": r["size_px"]})
    return sorted(out, key=lambda r: r["id"])


def main(top, side, fx):
    top, side, fx = Path(top), Path(side), Path(fx)
    (ART / "fx").mkdir(parents=True, exist_ok=True)
    weapons = []
    for wid, (grip_class, length_m, grip_u, flash, proj, casing, extra) in ROWS.items():
        d = ART / wid
        d.mkdir(parents=True, exist_ok=True)
        shutil.copy(top / f"{wid}.png", d / "held.png")
        shutil.copy(side / f"{wid}.png", d / "pickup.png")
        shutil.copy(side / f"{wid}_icon.png", d / "icon.png")
        size, grip, muzzle, span = measure(d / "held.png", grip_u)
        parts = {}
        for name, src in extra.items():
            shutil.copy(top / f"{src}.png", d / f"{name}.png")
            parts[name] = f"{RES}/{wid}/{name}.png"
        weapons.append({
            "casing": casing, "grip_class": grip_class, "grip_px": grip, "held": f"{RES}/{wid}/held.png",
            "icon": f"{RES}/{wid}/icon.png", "id": wid, "length_m": length_m, "length_px": span,
            "muzzle_fx": flash, "muzzle_px": muzzle, "parts": parts, "pickup": f"{RES}/{wid}/pickup.png",
            "projectile_fx": proj, "size_px": size,
        })
    doc = (
        "Weapon art by weapon id (weapon-art lane; docs/art/weapons.md). held = top-down part for the cutout rig, "
        "pointing +x; grip_px = where the claw closes (attach point), muzzle_px = the bore tip (shots and the "
        "muzzle flash spawn here); length_px = tail-to-tip span in the part, drawn length_m long in the world "
        "(the rig scale is 320 part px per metre). pickup = side view lying on the floor; icon = HUD silhouette. "
        "fx anchor_px = the point placed on the muzzle (flash) or the head (projectile); fx cells draw at "
        "fx_draw_scale x the rig part scale (2.0: at 1.0 a pistol flash is a speck at 32 px/m)."
    )
    table = {"doc": doc, "fx": fx_rows(fx), "fx_draw_scale": 2.0, "rig_px_per_m": 320, "schema": "gtai.weapon-art/1", "weapons": weapons}
    TABLE.write_bytes((json.dumps(table, indent=2, sort_keys=True) + "\n").encode())
    subprocess.run(["node", "tools/art/canon_json.mjs", str(TABLE)], check=True)
    print(f"wrote {len(weapons)} weapons, {len(table['fx'])} fx cells")


if __name__ == "__main__":
    main(*sys.argv[1:4])
