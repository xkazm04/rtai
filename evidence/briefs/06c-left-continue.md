# Package 6c (guns lane, n19): continue 6b - accepted, keep going

Director looked at `plasma_rifle_p55_left_check.png`: the corrected SW/W/NW are the hand-made figure, collar stripes slant as on the right cells. Accepted.

DECISION (yours, accepted): for a mirror-based cell the acceptance reference is its matching hand-made source facing (SW<-SE, W<-E, NW<-NE; fire twins from their fire source), within 5 % height and helmet ratio and inside the tone threshold; the E-rest difference stays published in the table as information. Write this as one `DECISION` line in `docs/decisions.md` (append-only, one line) with the commit.

Do now:
1. Commit the plasma_rifle candidate (art + rows + provenance + holes + matrix_after_6, `--no-godot` allowed for the known `part_library.gd:60` Log autoload error, say so). Then gatling, flamethrower, gloria, then rebuild rocket_launcher and mini_nuke `_left` (p55 + p70) the same way. One commit per weapon. Same evidence per weapon as 6b (left_check crops both pitches, old/new 64 px/m sheets, centred 32 px/m p55 turn clip, frames.json).
2. Do not stop to ask between weapons; when a reference question comes up, apply the rule above and note it in the report.
Law and acceptance as 6b.
