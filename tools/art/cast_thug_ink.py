"""The checklist's Ink row for robot thug A: the left contour of the front passing pose at 192 px cell height.
His sheets have 256 px cells (so the cell is scaled by 192/256 with LANCZOS, as the gunner's tool does).
Run from the repo root: python tools/art/cast_thug_ink.py. The patrol reference is printed first."""
from cast_gunner_ink import report

if __name__ == "__main__":
    for pitch in (70, 55):
        report(pitch, "cop_patrol_armed_walk", 4, [1])
        report(pitch, "robot_thug_armed_walk", 4, [0, 1, 2, 3])
        report(pitch, "robot_thug_planted8_armed_walk", 8, range(8))
