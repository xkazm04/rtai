"""Copies the take frames to the masters as red_fire_<effect>_<side>_64.png (+ _crop) and prints the
reddish px per crop. python -I evidence/n29/red/stills.py <before|after|pair>  (run from the repo root)"""
import sys, os, shutil
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
from count_red import crop_count

OUT = "C:/Users/kazda/kiro/gtai-masters/n29/combat/stills"
# effect: (frame in build/, crop box x0 y0 x1 y1)
SHOTS = {
    "blast": ("build/n29red/{side}/reel/t70.png", (760, 200, 1440, 860)),
    "flame": ("build/n29red/{side}/reel/t470.png", (560, 260, 1320, 860)),
    "ground_fire": ("build/n29red/{side}/reel/t1000.png", (740, 320, 1400, 900)),
    "explosion": ("build/n29red/{side}/fxshow/fx-64ppm-1-fx.png", (540, 660, 1120, 1080)),
}

def main(side):
    os.makedirs(OUT, exist_ok=True)
    for name, (frame, box) in SHOTS.items():
        src = frame.format(side=side)
        full = "%s/red_fire_%s_%s_64.png" % (OUT, name, side)
        shutil.copyfile(src, full)
        Image.open(src).crop(box).save(full.replace("_64.png", "_64_crop.png"))
        print(name, src, box, "reddish crop px", crop_count(src, box))


def pairs():
    """red_fire_<effect>_pair_64.png: before crop left, after crop right, labelled."""
    from PIL import ImageDraw
    for name in SHOTS:
        a = Image.open("%s/red_fire_%s_before_64_crop.png" % (OUT, name)).convert("RGB")
        b = Image.open("%s/red_fire_%s_after_64_crop.png" % (OUT, name)).convert("RGB")
        s = Image.new("RGB", (a.width + b.width + 12, a.height + 28), (23, 19, 27))
        s.paste(a, (0, 28))
        s.paste(b, (a.width + 12, 28))
        d = ImageDraw.Draw(s)
        d.text((8, 7), "BEFORE %s (red)" % name, fill=(242, 232, 213))
        d.text((a.width + 20, 7), "AFTER %s (amber remap)" % name, fill=(242, 232, 213))
        s.save("%s/red_fire_%s_pair_64.png" % (OUT, name))


if __name__ == "__main__":
    if sys.argv[1] == "pair":
        pairs()
    else:
        main(sys.argv[1])
