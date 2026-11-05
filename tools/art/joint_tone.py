"""Re-inks the paving joints of the city ground art toward r2_a5's tile joints (look lane, iteration 13).

The procedural paving draws its slab joints in two exact colours: the heavy joint (64,60,58) and the
fine joint (128,121,117). At 32 px/m the print snaps the heavy joint to a black grid; r2_a5's joints
are one crisp dark brown-grey weight. Each listed tile is copied to `<name><suffix>.png` with those
exact colours swapped (nothing else moves: cracks, hatch, the kerb face and the asphalt keep their
pixels). city_textures.json points the rows at the copies; pointing them back is the old look.
Usage: python tools/art/joint_tone.py   (run from the repo root; PIL only; deterministic)
"""
import json

from PIL import Image

G = "project/features/city/art/ground/"
CFG = "tools/art/joint_tone.json"


def recolour(src: Image.Image, swaps: dict) -> Image.Image:
    out = src.copy()
    px = out.load()
    w, h = out.size
    for y in range(h):
        for x in range(w):
            p = px[x, y]
            to = swaps.get(p[:3])
            if to is not None:
                px[x, y] = (to[0], to[1], to[2], p[3])
    return out


def main() -> None:
    cfg = json.load(open(CFG, encoding="utf-8"))
    swaps = {tuple(m["from"]): tuple(m["to"]) for m in cfg["map"]}
    for name in cfg["files"]:
        src = Image.open(G + name + ".png").convert("RGBA")
        recolour(src, swaps).save(G + name + cfg["suffix"] + ".png", optimize=True)
        print(name + cfg["suffix"])


if __name__ == "__main__":
    main()
