"""scratch (n15 hero): cut chosen manifest rows of one pitch into a scratch dir, fig_h override, compare."""
import json, subprocess, sys
from pathlib import Path
from PIL import Image, ImageChops
art, fig, names = sys.argv[1], sys.argv[2], sys.argv[3].split(",")
man = json.load(open("tools/art/rivet_frames.json", encoding="utf-8"))
out = Path(f"build/x15/{fig}").resolve()
(out / art).mkdir(parents=True, exist_ok=True)
rows = {n: dict(man["strips"][art][n]) for n in names}
for r in rows.values():
    if fig != "keep":
        r["fig_h"] = float(fig)
man2 = dict(man, out=str(out).replace("\\", "/"), strips={art: rows})
p = Path(f"build/x15/man_{fig}.json"); p.write_text(json.dumps(man2), encoding="utf-8")
subprocess.run([sys.executable, "-I", "tools/art/rivet_frames.py", f"--manifest={p}"], check=True)
for n in names:
    a = Image.open(out / art / f"{n}.png").convert("RGBA")
    b = Image.open(f"project/features/characters/art/view/{art}/{n}.png").convert("RGBA")
    same = a.size == b.size and ImageChops.difference(a, b).getbbox() is None
    print(n, a.size, b.size, "IDENTICAL" if same else "differs")
