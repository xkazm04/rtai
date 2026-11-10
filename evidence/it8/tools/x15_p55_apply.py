"""n15 hero it8: apply one p55 weapon's x1.5 cut (strip + its drawn left strip when the manifest has
one): manifest fig_h 165, RivetRes.X15 entries, copy build/x15/165/p55/<strip>.png. Run from the repo
root after `py -3 -I evidence/it4/tools/x15_cut.py p55 165 <rows>`. Prints the paths it touched."""
import json, shutil, sys
w = sys.argv[1]
man = json.load(open("tools/art/rivet_frames.json", encoding="utf8"))
p = "tools/art/rivet_frames.json"
s = open(p, encoding="utf8").read()
names = [n for n in [f"rivet_eq_{w}", f"rivet_eq_{w}_left"] if n in man["strips"]["p55"]]
at = s.index('"p55": {')
for name in names:
    i = s.index(f'"{name}": {{', at)
    j = s.index("}", i)
    block = s[i:j]
    assert "fig_h" not in block, name
    sh = man["strips"]["p55"][name]["sheet"]
    a = '    "sheet": "%s"\n' % sh
    k = s.index(a, i)
    assert k < j, name
    s = s[:k] + '    "sheet": "%s",\n    "fig_h": 165\n' % sh + s[k + len(a):]
open(p, "w", encoding="utf8", newline="\n").write(s)
g = "project/features/characters/rivet_res.gd"
t = open(g, encoding="utf8").read()
i = t.index("\n]", t.index("const X15"))
t = t[:i + 1] + "".join('\t"p55/%s.png",\n' % n for n in names) + t[i + 1:]
open(g, "w", encoding="utf8", newline="\n").write(t)
for n in names:
    shutil.copy(f"build/x15/165/p55/{n}.png", f"project/features/characters/art/view/p55/{n}.png")
    print(f"project/features/characters/art/view/p55/{n}.png")
