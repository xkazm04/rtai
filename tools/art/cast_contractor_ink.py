"""The checklist's Ink row for the contractor: left contour of a front walk pose at 192 px cell height,
the patrol's reference (cop_patrol_armed_walk col 0 row 1) first. Run from the repo root."""
from cast_gunner_ink import report

if __name__ == "__main__":
    for pitch in (70, 55):
        report(pitch, "cop_patrol_armed_walk", 4, [1])
        report(pitch, "contractor_armed_walk", 4, [0, 1, 2, 3])
        report(pitch, "contractor_planted8_armed_walk", 8, range(8))
