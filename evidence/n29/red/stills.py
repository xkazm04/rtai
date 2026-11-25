"""Copies the take frames to the masters as red_fire_<effect>_<side>_64.png (+ _crop) and prints the
reddish px per crop. python -I evidence/n29/red/stills.py <before|after|after_colour|after2|pair|pair2>  (run from the repo root)"""
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
        if not os.path.exists(src):  # after_colour: the reel only (--fx-colour=on)
            continue
        full = "%s/red_fire_%s_%s_64.png" % (OUT, name, side)
        shutil.copyfile(src, full)
        Image.open(src).crop(box).save(full.replace("_64.png", "_64_crop.png"))
        print(name, src, box, "reddish crop px", crop_count(src, box))


def pairs2():
    """red_fire_<effect>_pair2_64.png: before | after2 (the FX view's print with the amber ink)."""
    from PIL import ImageDraw
    for name in SHOTS:
        a = Image.open("%s/red_fire_%s_before_64_crop.png" % (OUT, name)).convert("RGB")
        b = Image.open("%s/red_fire_%s_after2_64_crop.png" % (OUT, name)).convert("RGB")
        s = Image.new("RGB", (a.width + b.width + 12, a.height + 28), (23, 19, 27))
        s.paste(a, (0, 28))
        s.paste(b, (a.width + 12, 28))
        d = ImageDraw.Draw(s)
        d.text((8, 7), "BEFORE %s (red)" % name, fill=(242, 232, 213))
        d.text((a.width + 20, 7), "AFTER2 %s (amber remap + amber ink in the FX print)" % name, fill=(242, 232, 213))
        s.save("%s/red_fire_%s_pair2_64.png" % (OUT, name))


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
        c = "%s/red_fire_%s_after_colour_64_crop.png" % (OUT, name)
        if os.path.exists(c):  # before | after (default ink FX) | after under --fx-colour=on
            c = Image.open(c).convert("RGB")
            t = Image.new("RGB", (s.width + c.width + 12, s.height), (23, 19, 27))
            t.paste(s, (0, 0))
            t.paste(c, (s.width + 12, 28))
            ImageDraw.Draw(t).text((s.width + 20, 7), "AFTER %s, --fx-colour=on" % name, fill=(242, 232, 213))
            t.save("%s/red_fire_%s_triple_64.png" % (OUT, name))


if __name__ == "__main__":
    if sys.argv[1] == "pair":
        pairs()
    elif sys.argv[1] == "pair2":
        pairs2()
    else:
        main(sys.argv[1])
