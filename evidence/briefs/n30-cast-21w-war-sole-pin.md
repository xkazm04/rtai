# n30-cast-21w: the pile-driver's held walk drawing pins the planted pad (tag `c21w`, model opus)

Read `evidence/briefs/_common.md` first: it binds (lane lock `C:/Users/kazda/kiro/gtai-n30/appdata/cast/godot.lock`, shared
with builder c21b who is landing the DOOR fix now: wait for the lock, never delete c21b's). Then `build/look/n30-c21/NOTES.md`
and `build/look/n30-c20/NOTES.md` (how the door fault was found and measured) and `docs/art/cast-audit.md` "## Pile-driver, n30"
(Part A numbers; the registration patch `build/look/n30-c02/register_pads.patch` that LOST).
Launch time T = 16:20. Measure table by 16:45. Commit (if earned) started by 16:55. Hard stop 17:10: report and END. Never end
with finished uncommitted work, never leave a commit in the hook at your stop.

## The question
The door card threw away the pose's lean correction on a held walk drawing (`position = last_ground`), so a held drawing leaned
about its cell pivot and the planted sole slid; pinning the planted SOLE's screen point instead took the door four's soles to
0.00 (`build/look/n30-c21/fix.patch`: `last_sole = transform * _sole_local()` before the draw, `position += last_sole -
transform * _sole_local()` after). `project/features/combat/squad/foe_war_card_view.gd` (~line 78-82, `hold_foot`) has the same
`position = last_ground` pin. Does pinning the planted pad there cut the pile-driver eight's sole slide (Part A eight sole 18.16 /
27.45 / 20.91 / 23.86 for p70 R / p70 DR / p55 R / p55 DR, jump 10.73 / 10.37 / 10.74 / 9.93; bars sole <= 2, jump <= 12)?

## Do
1. Read the war view (`_cell`, the pose it applies, which anchor point it registers) and say in NOTES whether a held drawing is
   leaned/sheared at all and about which point. If the war card applies no lean (position-only), say so: then the pin cannot
   help and the slide is the art (Part A's finding); write that and END without Godot.
2. Otherwise: the smallest change in `foe_war_card_view.gd` that keeps the planted pad's screen point fixed while the walk
   drawing is held (the war anchors' sole point for the drawn cell through the current transform). Functions <= 40 lines,
   file <= 205 lines (it is 200 now; trim a comment if needed).
3. Lane lock; `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/cast`; `node tools/film/cast_war_films.mjs
   build/look/n30-c21w/war feet four,eight`. Table four / eight before (Part A) | after, sole and jump, every facing. Save the
   patch as `build/look/n30-c21w/fix.patch` and the table in `build/look/n30-c21w/NOTES.md` (first line `RESUME:` state).
4. Commit ONLY if the eight (what ships) gets no worse on any bar in any facing AND better sole somewhere, and the four is
   no worse where it passes. Before it: `node tools/tests/run_unit.mjs --select=test_cast_war_walk,test_cast_foe_walks` (or
   whichever `test_cast_war*` exist) green; `node tools/gate/quick.mjs`; check no other commit is in the hook (`git -C . rev-parse
   --git-dir` -> `index.lock` absent) and stage per path. Message: `cast: pile-driver card pins the planted pad on a held walk
   drawing (not the pivot)`. Then mutate: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_war_card_view.gd
   --max=6 --lines=<changed> --tests=<the war/walk tests>`; quote killed/(killed+survived).
   If not earned: revert the file (`git checkout -- project/features/combat/squad/foe_war_card_view.gd`), keep the patch and
   the table in NOTES. Either way the table is the deliverable.
5. If committed and time remains before 17:05: a 64 px/m still of the eight walking (film tool `stills` mode) to
   `build/look/n30-c21w/` and LOOK at it (pads on the footprint row). No masters edits (c21b owns frames.json now).

## Allowlist
`project/features/combat/squad/foe_war_card_view.gd`, `project/tests/unit/test_cast_war*.gd` (only to pin the new behaviour),
`build/look/n30-c21w/**`. NOT `foe_shield_card_view.gd` (c21b), NOT `docs/art/cast-audit.md` (c21b), NOT `docs/decisions.md`,
NOT `street_patrol_pose.gd`, NOT `project/features/combat/kills/**` or any other lane's files. Anything else: NEED in the report.

## Report
The finding of step 1, the diff summary, the table, the verdict, the commit, mutate score, every command's result line.
