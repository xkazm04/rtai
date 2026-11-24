"""Map the support shoes on Peg's selected walk sheets (percent of opaque figure width)."""
from pathlib import Path
import hashlib
import numpy as np
from PIL import Image

from cast_soles import ROOT, VIEW, band, body_point

STRIP = "appliance_warden_planted8_armed_walk.png"
# The wire loop can hang below a boot. Restrict each bottom-band sample to the painted shoe.
CENTRES = {
    70: [[36,38,38,38,40,39,42,59], [46,38,38,22,47,39,39,20],
         [45,29,21,10,47,32,12,8], [9,23,30,12,8,35,37,12], [34,34,34,35,56,55,55,39]],
    55: [[38,42,41,40,40,40,42,40], [46,37,33,17,50,38,37,10],
         [52,32,12,8,52,31,10,10], [9,47,32,9,8,36,35,9], [30,29,31,31,31,56,54,28]],
}


def sole(mask, pitch, col, row):
    mid = CENTRES[pitch][col][row]
    return band(mask,(max(0,mid-10),mid+10))


def generate():
    lines = ["class_name CastWardenAnchors","extends RefCounted",
             "## Generated from shipped alpha by tools/art/cast_warden_soles.py.",
             f'const EIGHT: String = "{STRIP}"',
             'const FOUR: String = "appliance_warden_armed_walk.png"',
             'const WALK: String = EIGHT']
    steps = []
    for pitch,height in [(70,1.7),(55,2.0)]:
        p = VIEW/f"p{pitch}"/STRIP
        lines += [f"## p{pitch} SHA-256 {hashlib.sha256(p.read_bytes()).hexdigest()}",
                  f"const WALK{pitch}: Array[Vector4] = ["]
        alpha = np.asarray(Image.open(p))[:,:,3]>128
        for col,strip in enumerate(np.hsplit(alpha,5)):
            offsets = []
            for row,mask in enumerate(np.vsplit(strip,8)):
                foot,body = sole(mask,pitch,col,row),body_point(mask)
                pivot = np.array([mask.shape[1]/2,mask.shape[0]*.875])
                x,y = foot-pivot
                u,v = body-pivot
                lines.append(f"\tVector4({x:g}, {y:g}, {u:g}, {v:g}),")
                offsets.append(body[0]-foot[0])
            if col == 2:
                steps += [(offsets[i+2]-offsets[i])*height*1.10/192/2 for i in (0,4)]
        lines.append("]")
    print("metres per drawing",steps)
    lines.append(f"const STEP_M: float = {np.mean(steps):.4f}")
    out = ROOT/"project/features/characters/cast_warden_anchors.gd"
    out.write_text("\n".join(lines)+"\n",encoding="utf-8",newline="\n")


if __name__ == "__main__":
    generate()
