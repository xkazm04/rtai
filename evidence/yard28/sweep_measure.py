"""n28 floor sweep measure for one k: python -W ignore -I evidence/yard28/sweep_measure.py build/n28/k<k> [floor_tag]
Reads <dir>/day and <dir>/dusk (the --dusk captures of arched_day / arched_line, one sim). Prints one JSON line:
floor L*/C*/hue between pools and in the fire core (ground frames, actors hidden, floor_warmth mask), rivet delta
(rivet_delta.py), patrol blue / rifle / shotgun retained (dusk_contrast.py)."""
import json, os, subprocess, sys
from pathlib import Path
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import floor_warmth_lib as fw

root = Path(sys.argv[1])
dusk = root / "dusk"
ky = 32 * np.sin(np.radians(70))
table = json.loads(Path("project/data/tables/prologue_yard_dressings.json").read_text())["dressings"]["arched_line"]
pools = [(p["id"], p["kind"], p["at"]) for p in table["lights"]["pools"]]

def zone_pixels(directory):
    acc = {"between": [], "core": []}
    for fr in json.loads((directory / "sample_points.json").read_text())["frames"]:
        riv = [p for p in fr["points"] if p["kind"] == "rivet"]
        f = directory / f"{fr['frame']}_ground.png"
        if not riv or not f.exists():
            continue
        x, y = riv[0]["xy"]; rx, ry = riv[0]["pos_m"]
        cx, cy = rx - (x - 960) / 32.0, ry - (y - 540) / ky
        L, a, b = fw.lab(fw.load_half(f))
        wx, wy = fw.world(cx, cy, ky / 2)
        m = fw.floor_mask(L, np.hypot(a, b), wy, "mid") & (wx > 1) & (wx < 59) & (wy > 1) & (wy < 33)
        dall = np.full(L.shape, 1e9, dtype=np.float32); dfire = dall.copy()
        for pid, kind, (px, py) in pools:
            d = np.hypot(wx - px, wy - py).astype(np.float32)
            dall = np.minimum(dall, d)
            if kind in ("yard_fire", "yard_fire_mid"):
                dfire = np.minimum(dfire, d)
        for name, z in (("between", m & (dall > 12)), ("core", m & (dfire <= 3))):
            if z.sum():
                acc[name].append(np.stack([L[z], a[z], b[z]], 1))
    return {k: (np.concatenate(v) if v else np.zeros((0, 3), dtype=np.float32)) for k, v in acc.items()}

res = {}
zp = zone_pixels(dusk)
for name, v in zp.items():
    if len(v) < 300:
        res[name] = None
        continue
    ma, mb = v[:, 1].mean(), v[:, 2].mean()
    res[name] = dict(px=len(v), L=round(float(v[:, 0].mean()), 1), C=round(float(np.hypot(v[:, 1], v[:, 2]).mean()), 1),
                     hue=round(float(np.degrees(np.arctan2(mb, ma)) % 360), 1))
if res.get("core") and res.get("between"):
    res["pool_gain_L"] = round(res["core"]["L"] - res["between"]["L"], 1)
res["rivet"] = subprocess.run([sys.executable, "-W", "ignore", "-I", "evidence/yard28/rivet_delta.py", str(dusk)], capture_output=True, text=True).stdout.strip()
env = dict(os.environ, ROW="arched_line")
r = subprocess.run([sys.executable, "-W", "ignore", "-I", "evidence/yard28/dusk_contrast.py", "--day", str(root / "day"), "--dusk", str(dusk),
                    "--json", str(root / "contrast.json")], capture_output=True, text=True, env=env)
res["contrast"] = r.stdout.strip().splitlines()
print(json.dumps(res))
