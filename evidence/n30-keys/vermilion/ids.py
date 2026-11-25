"""Debug: 4x crop with numbered components (>=15 px), for naming parts by eye."""
import json, sys
import numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0, "evidence/n30-keys/vermilion")
from comps import vmask
D = json.load(open("evidence/n30-keys/vermilion/comps.json"))
for w in sys.argv[1:]:
    d = D[w]; a = Image.open(d["file"]).convert("RGBA")
    bg = Image.new("RGBA", a.size, (40, 40, 48, 255)); bg.alpha_composite(a)
    im = bg.resize((a.width * 4, a.height * 4), Image.NEAREST); dr = ImageDraw.Draw(im)
    for c in d["comps"]:
        if c["px"] < 15: continue
        x0, y0, x1, y1 = c["bbox"]
        dr.rectangle([x0*4-2, y0*4-2, x1*4+6, y1*4+6], outline=(255,255,255,255))
        dr.text((x0*4, max(0,y0*4-12)), f'{c["id"]}:{c["px"]}', fill=(255,255,0,255))
    im.save(f"build_ids_{w}.png") if False else im.save(f"C:/Users/kazda/AppData/Local/Temp/ids_{w}.png")
