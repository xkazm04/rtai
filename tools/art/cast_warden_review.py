"""Review the native Warden pose captures. Copy the native-scale swing comparisons without resizing."""
import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

from cast_feet import torso
from cast_mulroney_edge import rim
from cast_soles import project


def measure(folder):
    for pitch in (70, 55):
        path = folder / f"poses{pitch}_32/reversals.json"
        for track in json.loads(path.read_text()):
            body = [project(c,torso(c["path"],tuple(c["rect"]))) for c in track["frames"]]
            jumps = np.linalg.norm(np.diff(body,axis=0),axis=1)
            turn = track["turn"]
            print(pitch,track["speed"],"reversal seam",jumps[turn-1],"worst",jumps.max())
        for action in ("armed_walk", "planted8_armed_walk", "attack", "hit", "fall"):
            d = folder / f"poses{pitch}_64" / ("edge_"+action)
            raw, ground = [np.asarray(Image.open(d/(name+".png")).convert("RGB"), dtype=int)
                           for name in ("raw", "ground")]
            pixels = (abs(raw-ground).max(2)>22).sum()
            if pixels < 100:
                raise ValueError(f"empty exposure: {d}")
            print(pitch, action, "added dark exterior pixels", rim(d), "visible pixels", pixels)


def swing(folder, output):
    actions = [("wind_up","Wind-up"),("swing","Swing"),("catch","Catch"),("recover","Recover")]
    page = Image.new("RGB", (1320, 525), "#e9e4d9")
    draw = ImageDraw.Draw(page)
    def font(size):
        return ImageFont.truetype("arial.ttf",size)
    ink = "#272c2b"
    draw.text((32,21),"Peg Dolan  /  Catch pole",fill=ink,font=font(29))
    for pitch, y in ((70,99),(55,302)):
        draw.text((32,y),f"{pitch}°",fill=ink,font=font(22))
        for ppm, start, step in ((64,105,174),(32,847,113)):
            draw.text((start,y),f"{ppm} px/m",fill=ink,font=font(20))
            for i,(name,label) in enumerate(actions):
                photo = Image.open(folder/f"poses{pitch}_{ppm}"/(name+".png")).convert("RGB")
                foot = 3*ppm
                crop = photo.crop((foot-68,foot-102,foot+90,foot+23)) if ppm == 64 else photo.crop(
                    (foot-39, foot-60, foot+58, foot+17))
                x=start+step*i
                page.paste(crop,(x,y+147-crop.height))
                draw.text((x,y+156),label,fill=ink,font=font(16))
    page.save(output)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    parser.add_argument("--swing",type=Path)
    args = parser.parse_args()
    measure(args.folder)
    if args.swing:
        swing(args.folder,args.swing)
