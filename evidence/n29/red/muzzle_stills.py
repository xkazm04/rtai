"""n29 combat 02b: muzzle stills. python -I evidence/n29/red/muzzle_stills.py <before|after|pair>  (repo root)
Frames: build/n29muz/<side>/fine/t<tick>.png (take.mjs, ticks below) and build/n29muz/<side>/fxshow/fx-64ppm-1-fx.png."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image, ImageDraw
from count_red import crop_count

OUT = "C:/Users/kazda/kiro/gtai-masters/n29/combat/stills"
# gun: (frame, crop box x0 y0 x1 y1)
SHOTS = {
    "pistol": ("build/n29muz/{side}/fine/t47.png", (440, 405, 800, 685)),
    "smg": ("build/n29muz/{side}/fine/t407.png", (340, 180, 940, 580)),
    "rocket": ("build/n29muz/{side}/fine/t828.png", (397, 395, 757, 675)),
    "nuke": ("build/n29muz/{side}/fine/t1194.png", (65, 259, 665, 659)),
    "d4_muzzle": ("build/n29muz/{side}/fxshow/fx-64ppm-1-fx.png", (1250, 250, 1560, 620)),
}

def main(side):
    os.makedirs(OUT, exist_ok=True)
    for name, (frame, box) in SHOTS.items():
        src = frame.format(side=side)
        full = "%s/red_muzzle_%s_%s_64.png" % (OUT, name, side)
        Image.open(src).save(full)
        Image.open(src).crop(box).save(full.replace("_64.png", "_64_crop.png"))
        print(name, src, box, "reddish crop px", crop_count(src, box))

def pairs():
    for name in SHOTS:
        a = Image.open("%s/red_muzzle_%s_before_64_crop.png" % (OUT, name)).convert("RGB")
        b = Image.open("%s/red_muzzle_%s_after_64_crop.png" % (OUT, name)).convert("RGB")
        s = Image.new("RGB", (a.width + b.width + 12, a.height + 28), (23, 19, 27))
        s.paste(a, (0, 28)); s.paste(b, (a.width + 12, 28))
        d = ImageDraw.Draw(s)
        d.text((8, 7), "BEFORE %s (vermilion)" % name, fill=(242, 232, 213))
        d.text((a.width + 20, 7), "AFTER %s (amber remap)" % name, fill=(242, 232, 213))
        s = s.resize((s.width * 2, s.height * 2), Image.NEAREST)
        s.save("%s/red_muzzle_%s_pair_64.png" % (OUT, name))

if __name__ == "__main__":
    pairs() if sys.argv[1] == "pair" else main(sys.argv[1])
