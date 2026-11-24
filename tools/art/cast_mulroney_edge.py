"""Re-key the five living wound cells at their original registration and measure the street A/B."""
import argparse
import subprocess
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

from cast_attack_splice import solid_box
from cast_patrol_eight import key_figures
from cast_soles import VIEW
from street_hit import foot_x


def original_scale(pack, pitch, cells):
    stride = Image.open(pack / f"mulroney_armed_walk_{pitch}/stride.png")
    w, h = stride.width // 5, stride.height // 4
    heights = []
    for col in range(5):
        for row in range(4):
            tile = stride.crop((col*w, row*h, (col+1)*w, (row+1)*h))
            _, top, _, bottom = solid_box(tile)
            heights.append(bottom-top)
    walk_scale = (155 if pitch == 70 else 160) / heights[5]
    return np.mean([round(v*walk_scale) for v in heights]) / np.mean([im.height for im in cells])


def recut(root, pitch):
    pack = root / "pack"
    stem = f"mulroney_hit_{pitch}"
    rgb, labels, stats, spill = key_figures(root / "out" / (stem + ".png"))
    cells = [Image.open(pack / stem / f"1_{i}.png").convert("RGBA") for i in range(1, 6)]
    scale = original_scale(pack, pitch, cells)
    old = Image.open(pack / stem / "grid.png").convert("RGBA")
    grid = Image.new("RGBA", old.size)
    cw = grid.width // 5
    for i, im in enumerate(cells):
        # Locate the existing crop on the director's plate from a fully interior patch.
        u, v = im.width//2-12, im.height//2-12
        match = cv2.matchTemplate(rgb, np.asarray(im)[v:v+24, u:u+24, :3], cv2.TM_CCOEFF_NORMED)
        _, score, _, (x, y) = cv2.minMaxLoc(match)
        if score < 0.99:
            raise ValueError(f"missing source cell {i}")
        x, y = x-u, y-v
        region = np.s_[y:y+im.height, x:x+im.width]
        label = labels[y+im.height//2, x+im.width//2]
        if label == 0 or stats[label, 4] < 1500:
            raise ValueError(f"missing connected figure {i}")
        color = rgb[region].copy()
        color[spill[region]] = (21, 24, 29)
        alpha = (labels[region] == label).astype(np.uint8)*255
        color[alpha == 0] = 0
        size = tuple(round(d*scale) for d in im.size)
        prior = im.resize(size, Image.Resampling.LANCZOS)
        tile = Image.fromarray(np.dstack((color,alpha))).resize(size,Image.Resampling.LANCZOS)
        left = round(cw/2-foot_x(np.asarray(prior)[:,:,3]))
        top = 189-size[1]
        check = old.crop((i*cw+left, top, i*cw+left+size[0], 189))
        if not np.array_equal(np.asarray(prior)[:,:,3], np.asarray(check)[:,:,3]):
            raise ValueError(f"original packing disagrees for {pitch}/{i}")
        grid.paste(tile, (i*cw+left,top))
    # Keep the original flat-boot contact band. The rear 70-degree boot is higher
    # than the raised toe. Only alpha in the existing registration band is retained.
    data = np.array(grid)
    prior = np.array(old)
    for i in range(5):
        y = 170 if (pitch,i) == (70,4) else 179
        end = i*cw+109 if (pitch,i) == (70,4) else (i+1)*cw
        band = np.s_[y:,i*cw:end]
        empty = (data[band][:,:,3] == 0) & (prior[band][:,:,3] != 0)
        data[band][empty] = prior[band][empty]
        data[band][:,:,3] = prior[band][:,:,3]
    work = pack/"edge"
    work.mkdir(exist_ok=True)
    cut = work/(stem+"_keyed.png")
    Image.fromarray(data).save(cut)
    dest = VIEW/f"p{pitch}"/"sergeant_mulroney_hit.png"
    subprocess.run([sys.executable, str(Path(__file__).with_name("street_tone.py")),
                    str(cut), str(dest.with_name("cop_patrol_card.png")), str(dest)], check=True)


def rim(folder):
    live, raw, ground = [np.asarray(Image.open(folder/(n+".png")).convert("RGB"), dtype=int)
                         for n in ("live","raw","ground")]
    # Added dark pixels outside the painted figure on an identical, frozen street frame.
    return int(((abs(live-ground).max(2)>22) & (abs(raw-ground).max(2)<=8)
                & (live.max(2)<64)).sum())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("round", type=Path)
    parser.add_argument("--measure", action="store_true")
    args = parser.parse_args()
    for pitch in (70,55):
        if args.measure:
            for phase in ("before","after"):
                print(pitch, phase, rim(args.round/"pack/edge"/f"{phase}_{pitch}"))
        else:
            recut(args.round,pitch)
