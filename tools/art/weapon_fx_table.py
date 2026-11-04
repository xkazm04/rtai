"""Copy the FX cells into the project and rewrite the `fx` rows of data/tables/weapon_art.json (weapon-art lane).

The weapon rows stay as they are (weapon_ingest.py owns them); this only refreshes the fx cells from
weapon_fx.py + weapon_fx_blast.py output and adds the gore stickers as `gore_<name>` fx cells (one frame
each, anchor at the centre), so `WeaponArt.fx_frames(&"gore_stump_round")` loads them. Then it turns
mipmaps on in every `*.png.import` under the art folder (the rig parts use mipmaps; new imports default
off), so run Godot's `--import` once before and once after.

    python tools/art/weapon_fx_table.py <fx_dir> [--nail]
"""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image

ART = Path("project/features/combat/weapons/art")
RES = "res://features/combat/weapons/art"
TABLE = Path("project/data/tables/weapon_art.json")


def main(fx_dir, nail):
    fx_dir = Path(fx_dir)
    table = json.loads(TABLE.read_text(encoding="utf-8"))
    rows = []
    for r in json.loads((fx_dir / "fx_rows.json").read_text()):
        shutil.copy(fx_dir / f"{r['id']}.png", ART / "fx" / f"{r['id']}.png")
        rows.append({"anchor_px": r["anchor_px"], "art": f"{RES}/fx/{r['id']}.png", "id": r["id"], "size_px": r["size_px"]})
    for png in sorted((ART / "gore").glob("*.png")):
        w, h = Image.open(png).size
        rows.append({"anchor_px": [w // 2, h // 2], "art": f"{RES}/gore/{png.name}", "id": f"gore_{png.stem}", "size_px": [w, h]})
    table["fx"] = sorted(rows, key=lambda r: r["id"])
    if nail:
        for w in table["weapons"]:
            if w["id"] == "gloria":
                w["projectile_fx"] = "nail"
    TABLE.write_bytes((json.dumps(table, indent=2, sort_keys=True) + "\n").encode())
    subprocess.run(["node", "tools/art/canon_json.mjs", str(TABLE)], check=True)
    fixed = 0
    for imp in ART.rglob("*.png.import"):
        text = imp.read_text(encoding="utf-8")
        if "mipmaps/generate=false" in text:
            imp.write_bytes(re.sub("mipmaps/generate=false", "mipmaps/generate=true", text).encode())
            fixed += 1
    print(f"{len(table['fx'])} fx cells in the table; mipmaps turned on in {fixed} imports")


if __name__ == "__main__":
    main(sys.argv[1], "--nail" in sys.argv[2:])
