"""Rebuild all eight 110 and native PNGs in scratch and check their Git LFS hashes.
Run from the repository root with py -3 -I evidence/rivet-x15/reproduce.py.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

VIEW = Path("project/features/characters/art/view")
BEFORE = "e0a504451"
AFTER = "4b31b3b3c"
TONE_REV = "738de8ddd"
MANIFEST = json.loads(Path("tools/art/rivet_frames.json").read_text(encoding="utf-8"))
LIB = Path(MANIFEST["library"])


def git_file(rev, path):
    return subprocess.check_output(["git", "show", f"{rev}:{path.as_posix()}"])


def verify(art, name, args, version, output):
    subprocess.run([sys.executable, "-I", f"tools/art/rivet_{name}.py", *args], check=True)
    pointer = git_file(version, VIEW / art / f"rivet_{name}.png").decode("ascii")
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    if f"oid sha256:{digest}" not in pointer.splitlines():
        raise ValueError(f"{art} {name} differs from {version}: {digest}")
    print(f"{art} {name} {version}: byte-identical {digest}", flush=True)


def check_pitch(art, scratch):
    pitch = art[1:]
    row = MANIFEST["strips"][art]["rivet_frames"]
    tone = scratch / "walk8_tone.png"
    tone.write_bytes(subprocess.check_output(
        ["git", "lfs", "smudge"], input=git_file(TONE_REV, VIEW / art / "rivet_walk8.png")
    ))
    left = "rivet_walk_70_left_cells" if art == "p70" else "_raw/rivet_walk_55_left_cells_v2untoned"
    length = 1.2 if art == "p70" else 1.45
    for scale, version in [(1.0, BEFORE), (1.5, AFTER)]:
        out = scratch / "cut.png"
        res = f"--scale={scale}"
        verify(art, "knock", [art, out, f"--len={length}", f"--tone={tone}", res], version, out)
        verify(art, "strike", [LIB, pitch, out, res], version, out)
        verify(art, "walk", [LIB / f"rivet_walk_{pitch}_cells", LIB / left, out, res], version, out)
        verify(art, "frames", [LIB / row["sheet"], out, row["counts"], f"--left={LIB / row['left']}",
               f"--act_k={row['act_k']}", f"--layout_h={row['layout_h']}",
               f"--fig_h={row['layout_h'] if scale == 1 else row['fig_h']}"], version, out)


if __name__ == "__main__":
    Path("build").mkdir(exist_ok=True)
    with TemporaryDirectory(dir="build") as tmp:
        for pitch_key in ("p70", "p55"):
            check_pitch(pitch_key, Path(tmp))
