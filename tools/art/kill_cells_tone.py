"""n17 npc-react (DEFECTS 15): an n16 death's own drawn cells carry the asset lane's blue, not the
kind's walk blue: the SWAT's cells are drawn ~0.6-0.7 x as bright (value 0.27-0.35 against his
armed walk's 0.48), so at the kill his helmet and sleeves go dark navy on the tick his walk card
hides (film s_*_cop_head_swat t173 -> t174). The riot cop's drift violet (hue up to +17 deg).

Every own-cell grid of signature_kills.json (plus each kind's gatling scraps and headgear tumble) in
p70 and p55 is measured against its kind's armed walk in the same art by tools/art/street_tone.py's
blue mask (mean hue, saturation, value). A grid off by more than HUE_TOL deg or VALUE_TOL (relative)
is toned in place with street_tone.py's rule (blue px only: hue shifted, saturation and value
scaled, shading kept); a toned grid then reads equal to its walk, so a second run changes nothing.
A re-pack (kill_cells_pack.py) restores the delivered blue: run this after it.

Second pass (n17 23:00): the SWAT's helmet and vest are drawn grey-VIOLET in his own cells (hue 250-300 deg,
saturation 0.06-0.35: 7-18 % of the figure against 1.6 % in his walk, whose helmet is blue-grey, hue ~216).
A grid whose grey-violet share is over VIOLET_K x its walk's (and over VIOLET_MIN) has those px turned to the
walk's blue hue, saturation x VIOLET_SAT (value and shading kept); afterwards its share reads ~0, so a second
run changes nothing.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/kill_cells_tone.py [--write] [p55/file.png ...]
"""

import json
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
VIEW = ROOT / "project/features/characters/art/view"
TABLE = ROOT / "project/data/tables/signature_kills.json"
TONE = ROOT / "tools/art/street_tone.py"
KINDS = {"cop_patrol": "cop_patrol_armed_walk.png", "cop_riot": "cop_riot_armed_walk.png", "swat": "swat_armed_walk.png"}
EXTRA = ("_gatling_shred_scraps.png", "_headgear_tumble.png")
HUE_TOL = 10.0
VALUE_TOL = 0.15
VIOLET_K = 3.0
VIOLET_MIN = 0.04
VIOLET_SAT = 1.6


def violet(path: Path) -> tuple:
    """(image, hsv planes, grey-violet mask, its share of the opaque px)."""
    img = Image.open(path).convert("RGBA")
    a = np.asarray(img)[..., 3] > 127
    hsv = np.asarray(img.convert("RGB").convert("HSV")).astype(np.float64) / 255.0
    h, s, v = hsv[..., 0] * 360.0, hsv[..., 1], hsv[..., 2]
    m = a & (h > 250.0) & (h < 300.0) & (s > 0.06) & (s < 0.35) & (v > 0.15)
    return img, (h, s, v), m, float(m.sum()) / max(1, int(a.sum()))


def unviolet(path: Path, hue: float) -> None:
    img, (h, s, v), m, _ = violet(path)
    h2 = np.where(m, hue, h) / 360.0
    s2 = np.where(m, np.clip(s * VIOLET_SAT, 0.0, 1.0), s)
    hsv = (np.stack([h2, s2, v], axis=-1) * 255.0).round().astype(np.uint8)
    rgb = np.asarray(Image.fromarray(hsv, "HSV").convert("RGB"))
    out = np.asarray(img).copy()
    out[..., :3] = np.where(m[..., None], rgb, out[..., :3])
    Image.fromarray(out, "RGBA").save(path)


def blue(path: Path) -> tuple:
    """(blue px, mean hue deg, mean value) by street_tone's mask."""
    img = Image.open(path).convert("RGBA")
    a = np.asarray(img)[..., 3]
    hsv = np.asarray(img.convert("RGB").convert("HSV")).astype(np.float64) / 255.0
    h, s, v = hsv[..., 0] * 360.0, hsv[..., 1], hsv[..., 2]
    m = (h > 190.0) & (h < 250.0) & (s > 0.2) & (v > 0.08) & (a > 127)
    return int(m.sum()), float(h[m].mean()), float(v[m].mean())


def own_files() -> set:
    out = set()
    for row in json.loads(TABLE.read_text(encoding="utf-8"))["kills"]:
        for grids in (row.get("cells") or {}).get("grids", {}).values():
            out.update(grids.values())
    for kind in KINDS:
        out.update(kind + e for e in EXTRA)
    return out


def main() -> int:
    write = "--write" in sys.argv[1:]
    selected = {arg for arg in sys.argv[1:] if arg != "--write"}
    files = own_files()
    seen = set()
    for art in ("p70", "p55"):
        for kind, walk in KINDS.items():
            ref = VIEW / art / walk
            if not ref.exists():
                continue
            _, rh, rv = blue(ref)
            for f in sorted(x for x in files if x.startswith(kind + "_")):
                if selected and f"{art}/{f}" not in selected:
                    continue
                p = VIEW / art / f
                if not p.exists():
                    continue
                seen.add(f"{art}/{f}")
                n, h, v = blue(p)
                off = abs(h - rh) > HUE_TOL or abs(v / rv - 1.0) > VALUE_TOL
                print(f"{art}/{f:38s} hue {h - rh:+5.1f} value x{v / rv:.2f} {'TONE' if off else 'ok'}")
                if off and write:
                    subprocess.run([sys.executable, "-I", str(TONE), str(p), str(ref), str(p)], check=True)
                share, walk_share = violet(p)[3], violet(ref)[3]
                if share > max(VIOLET_MIN, VIOLET_K * walk_share):
                    print(f"{art}/{f:38s} grey-violet {share:.3f} vs walk {walk_share:.3f} UNVIOLET")
                    if write:
                        unviolet(p, rh)
    if selected - seen:
        print("No police grid matched: " + ", ".join(sorted(selected - seen)), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
