"""Our floor from 32 px/m stills (bare floor, floor_warmth mask on a 2x reduced copy): mean sRGB, L*, C*, hue.
python -W ignore -I evidence/yard28/floor_game.py <png:cx,cy:ky> ...   cx,cy = world centre of the still; ky = y px/m (film stills 32, --dusk captures 30.07)
Zones: between pools (> 12 m from every pool) and all bare floor."""
import sys
from pathlib import Path
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
import floor_warmth_lib as fw
POOLS = [(11.8, -0.8), (26.6, -0.8), (56.2, -0.8), (12.15, 7.6), (43.2, 17.4), (46, 26), (32.2, 20.6), (15.5, -1.75), (30.3, -1.75), (41.4, -1.9), (40.8, 32.3)]
for arg in sys.argv[1:]:
    f, c, k = arg.rsplit(":", 2); cx, cy = map(float, c.split(",")); ky = float(k) / 2
    rgb = fw.load_half(f); L, a, b = fw.lab(rgb); C = np.hypot(a, b)
    wx, wy = fw.world(cx, cy, ky)
    m = fw.floor_mask(L, C, wy, "mid")
    d = np.full(L.shape, 1e9, dtype=np.float32)
    for x, y in POOLS:
        d = np.minimum(d, np.hypot(wx - x, wy - y).astype(np.float32))
    for name, z in (("between pools (>12 m)", m & (d > 12)), ("all bare floor", m)):
        if z.sum() < 300: print(f"{Path(f).name} {name}: too few ({z.sum()})"); continue
        mc = rgb[z].mean(0); ma, mb = a[z].mean(), b[z].mean()
        print(f"{Path(f).name} {name}: {z.sum()} px(half) sRGB {mc[0]:.0f},{mc[1]:.0f},{mc[2]:.0f} L* {L[z].mean():.1f} C* {np.hypot(a[z],b[z]).mean():.1f} hue {np.degrees(np.arctan2(mb,ma))%360:.1f}")
