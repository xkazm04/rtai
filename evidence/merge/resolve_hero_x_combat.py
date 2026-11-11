"""Resolve the n15 hero x combat conflicts (both plain unions) in a merge-tree output.
Usage: python resolve_hero_x_combat.py <conflicted file> <out file>
rivet_res.gd X15: keep both lists (hero's strips, then combat's blade left sets).
cast_flags.gd: keep combat's `elif arg in WINDUP_FLAGS: _windup(arg)` (it now owns --rivet-windup=off) and
hero's `elif arg.begins_with("--ghost-"): _ghost(arg)` + hero's `_ghost` (it now owns --ghost-voice=facing)."""
import re, sys

src = open(sys.argv[1], encoding="utf-8").read()
pat = re.compile(r"<<<<<<< [^\n]*\n(.*?)=======\n(.*?)>>>>>>> [^\n]*\n", re.S)
n = len(pat.findall(src))
if n != 1:
    sys.exit(f"expected 1 conflict block, found {n}")
ours, theirs = pat.search(src).groups()
if "WINDUP_FLAGS" in theirs:
    o = ours.replace('\t\telif arg == "--rivet-windup=off":  # n13: the strike cell through the wind-up (before)\n'
                     '\t\t\tRivetWindup.enabled = false\n', "", 1)
    t = theirs.replace('\t\telif arg == "--ghost-voice=facing":  # n10: the voice at his facing\'s own left, on his head\n'
                       '\t\t\tGhostApparition.clear_figure = false\n', "", 1)
    if o == ours or t == theirs or "_ghost(arg)" not in o:
        sys.exit("cast_flags: the sides changed shape; resolve by hand")
    body = t + o
else:
    body = ours + theirs
open(sys.argv[2], "w", encoding="utf-8", newline="\n").write(pat.sub(lambda _m: body, src, count=1))
print(f"resolved {sys.argv[1]} -> {sys.argv[2]}")
