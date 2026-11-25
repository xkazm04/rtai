"""red_elec_<tazer|burst|tuckin>_after2_64.png + _pair2_64.png (before | after2, 3x nearest) and the reddish px table.
python -I evidence/n29/red/elec_stills.py   (run from the repo root; build/n29elec/{before,after,after2} from electric_run.mjs.txt)"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
from count_red import crop_count

OUT = "C:/Users/kazda/kiro/gtai-masters/n29/combat/stills"
BOX = {"tazer": (1330, 380, 1530, 540), "burst": (300, 500, 540, 700), "tuckin": (1100, 70, 1250, 170)}
for n, b in BOX.items():
    a = "build/n29elec/after2/%s.png" % n
    Image.open(a).crop(b).save("%s/red_elec_%s_after2_64.png" % (OUT, n))
    be = Image.open("build/n29elec/before/%s_full.png" % n).crop(b)
    af = Image.open(a).crop(b)
    w, h = be.size
    pair = Image.new("RGB", (w * 6 + 8, h * 3), (40, 40, 40))
    pair.paste(be.resize((w * 3, h * 3), Image.NEAREST), (0, 0))
    pair.paste(af.resize((w * 3, h * 3), Image.NEAREST), (w * 3 + 8, 0))
    pair.save("%s/red_elec_%s_pair2_64.png" % (OUT, n))
    print(n, "before", crop_count("build/n29elec/before/%s_full.png" % n, b), "after", crop_count("build/n29elec/after/%s.png" % n, (0, 0, w, h)) if False else "-", "after2", crop_count(a, b))
