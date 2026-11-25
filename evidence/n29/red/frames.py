"""Adds the red-fire stills (and the film if present) to gtai-masters/n29/combat/frames.json, keeping other
entries (re-read just before the write). python -I evidence/n29/red/frames.py"""
import json, os

ROOT = "C:/Users/kazda/kiro/gtai-masters/n29/combat"
EFFECTS = {"blast": "rocket blast fireball (blast_1), reel t70", "flame": "flamethrower flame + cone, reel t470",
           "ground_fire": "molotov burning ground, reel t1000", "explosion": "explosion kind cloud (fx_atlas 9-12), fx showcase"}


def entries():
    out = []
    for name, what in EFFECTS.items():
        for side in ("before", "after", "after_colour"):
            for tail in ("_64.png", "_64_crop.png"):
                f = "stills/red_fire_%s_%s%s" % (name, side, tail)
                if os.path.exists(os.path.join(ROOT, f)):
                    out.append({"file": f, "title": "Red fire %s %s%s" % (name, side, " crop" if "crop" in tail else ""),
                                "ppm": 64, "before": side == "before", "note": what})
        f = "stills/red_fire_%s_pair_64.png" % name
        if os.path.exists(os.path.join(ROOT, f)):
            out.append({"file": f, "title": "Red fire %s before | after" % name, "ppm": 64, "before": False,
                        "note": what + "; left red, right the amber hue remap"})
        f = "stills/red_fire_%s_triple_64.png" % name
        if os.path.exists(os.path.join(ROOT, f)):
            out.append({"file": f, "title": "Red fire %s before | after | after --fx-colour=on" % name, "ppm": 64,
                        "before": False, "note": what + "; the default look's item print snaps amber back to vermilion"})
    f = "films/red_fire_after_32.mp4"
    if os.path.exists(os.path.join(ROOT, f)):
        out.append({"file": f, "title": "Rocket, flame and molotov fire in amber", "ppm": 32, "before": False,
                    "note": "reel director chapters rocket_launcher, flamethrower, molotov after the repaint; before = the before stills"})
    return out


if __name__ == "__main__":
    path = os.path.join(ROOT, "frames.json")
    cur = json.load(open(path, encoding="utf-8")) if os.path.exists(path) else []
    mine = entries()
    names = {e["file"] for e in mine}
    cur = [e for e in cur if e.get("file") not in names] + mine
    json.dump(cur, open(path, "w", encoding="utf-8"), indent=1)
    print(len(mine), "red-fire entries,", len(cur), "total")
