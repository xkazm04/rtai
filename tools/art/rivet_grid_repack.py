"""n11 hero: repack every Rivet walk/run grid at RES x the scales its n9 pack recorded.

usage: py -3 -I tools/art/rivet_grid_repack.py <out dir> [RES=1.5]

Reads evidence/n9/rivet_{walk8,run8,walk_eq_*,run8_eq_*}*.json (src cells, scales, tone ref) and
runs tools/art/rivet_walk.py with --k = RES x the recorded scales into <out dir>/p70|p55/<sheet>.png.
RivetWalk.RES must equal RES (the card's scale divides by it). RES 1.0 reproduces the n9 sheets
(a check that the library cells have not moved). Deterministic.
"""

import json
import re
import subprocess
import sys
from pathlib import Path


def sheet_of(stem: str) -> tuple[str, str]:
    bare = re.match(r"(rivet_(?:walk8|run8))_(55|70)$", stem)
    if bare:
        return bare.group(1), bare.group(2)
    armed = re.match(r"(.*)_p(55|70)$", stem)
    return armed.group(1), armed.group(2)


def main() -> None:
    out_dir = Path(sys.argv[1])
    res = float(sys.argv[2]) if len(sys.argv) > 2 else 1.5
    for j in sorted(Path("evidence/n9").glob("rivet_*.json")):
        if "knock" in j.name:
            continue
        m = json.loads(j.read_text())
        base, pitch = sheet_of(j.stem)
        out = out_dir / f"p{pitch}" / f"{base}.png"
        out.parent.mkdir(parents=True, exist_ok=True)
        k, kl = m["scales"]
        cmd = [sys.executable, "-I", "tools/art/rivet_walk.py", m["src"][0], m["src"][1], str(out)]
        cmd += [f"--cols={m['cols']}", f"--k={k * res},{kl * res}", f"--fig_h={m['fig_h'] * res}"]
        if "tone" in m:
            cmd.append(f"--tone={m['tone']}")
        r = subprocess.run(cmd, capture_output=True, text=True, check=False)
        print(j.stem, "->", out, "rc", r.returncode, r.stderr.strip()[-200:])


if __name__ == "__main__":
    main()
