# REPORT: night n10, lane world (draft, updated 2026-11-09 02:30)

Evidence: `C:\Users\kazda\kiro\gtai-masters\n10\world\` (`frames.json`). Every performance number is unmeasured so far.

## What works, with evidence

1. **Half-height walls read as real shorter walls** (`aadc7430`). Each style is cut into whole storey rows at the flat elevation's own proportions and stacked from the ground up: tenement two storeys, tall block ground plus uppers, shop one storey with its sign band and awning. 48 px/m: `wall_tenement_48_after.png`. Grey print look and `height_k` 0.5 unchanged.
   - **The shop wall now takes the asset lane's half-height strip** (`35de190a`): 4.1 m bays, a drawn door, solid piers. A modest gain over my recut, filmed on the same frame: `wall_shop_delivered_32.png`, `wall_shop_delivered_48.png` (left = recut). The delivered dark-trim shop read as a heavy grey band, and the delivered tenement printed as flat grey panels (`wall_tenement_delivered_rejected_48.png`), so those stay out. The delivered tall strip was tried but no tall building was in frame, so it is unjudged; tall keeps the recut.
2. **Lamp posts no longer lie flat** (`20c868c6`). The "fallen lamp" was the game's own pole shadow stroke with a globe at its end, not the test scene. It is now a short contact dash. `lamp_cast_32_after.png`.
3. **The black bar at every wall's foot is gone** (`3cf3ffdc`). It was the flat city's raised-roof cue (a solid ink copy of the building's silhouette on the ground, 0.22 m down-right), still drawn under the tilt, where a wall stands on that edge. It read as a 7 px black band at 32 px/m. Now the wall ends on its own ink line and the hatched shadow; flat views keep the band. `wall_foot_core_32.png`, `wall_foot_core_48.png`, same seed and tick. My first audit had missed it.
4. **The dead lie only on a few screen headings** (`071e3780` near rigs and Dock 9, `b8ba8f9e` far crowd).
   - A body's head lies up, up-right, up-left, right or left, picked by the blow's screen direction and the pose, with no free turn. No head points at the camera. Pose E is only ever mirrored.
   - The far crowd's baked corpses follow the same headings through a view-only shader snap.
   - Each near body has a contact shadow (its own silhouette, down the sun).
   - Each body now shows a sliver of its near side, a shaded copy of its silhouette 0.16 m of height below the pose (`579ef0f4`), on both draw paths. Subtle: the lower edge is heavier and the body sits on the road. 0.32 m doubled the fingers and boots. `dead_side_dock9_64.png`.
   - Dock 9's dead no longer touch once settled. The push measures between the drawn bodies, relaxes over 8 passes, and a body a crowd still defeats takes the nearest clear spot (`SPACE_M` 2.1, cap 2.4). `dead_dock9_centres_64.png` and `dead_dock9_centres_32.png`, same tick t13900: before, three bodies chain together; after, four lie clear.
   - **A near corpse no longer jumps 1.5 s after it dies** (`39f4e53c`). After its 90-tick hold a body used to go back to the baked crowd: measured over a riot film, 18 hand-overs in 23 s, each jumping 0.6-3.1 m (median 2.1 m), losing its shadow and near side. `StreetDeadRest` keeps its drawn pose, shadow and near side where it lay until the body leaves the feed. Pairs either side of a hand-over: `dead_swap_kept_64.png` (top, before: the pink body vanishes, and the atlas draws it at its sim point about 2 m away, here under other bodies; bottom, after: it stays and the living draw over it) and `dead_swap_kept_32.png`.
   - **Two classes now lie in poses drawn for this camera** (`eb2611c3`, `cbdbc318`). The patrol cop and the suit take a cell of a sheet drawn at 70 degrees (library round `20261108-1750`, never delivered; I found it in the rounds folder), picked by the head's screen heading and the pose's family, mirrored for the left, never turned. A head straight up is left out because it read as a man standing. It is a modest gain and a small share of the bodies: over the 23 s riot film at most 2 bodies on screen at once differ from the plan poses, and none at all in some seconds (`dead_drawn70_64.png`). Inside the pile at 32 px/m the two are hard to tell apart (`dead_drawn70_32.png`). Dock 9's contractors and the baked far crowd are not on this art.
   - Same seed and tick, before = `StreetDeadHeading.ENABLED` false: `dead_riot_before_after_64.png`, `dead_riot_before_after_32.png`.
   - **The riot's near bodies are pushed off each other too** (`fdc80496`), with the city's solid test so a push cannot end in a wall. The two corpses that lay on top of the standing cops are off them. `dead_riot_push_64.png`, `dead_riot_push_32.png`, same seed and tick. Dock 9's frame is byte-identical to before this change.

## What does not work yet

- **The art is still the n9 plan poses for 11 of the 13 street classes and for Dock 9's contractors.** The poses are placed on drawn headings but are not drawn for this camera. Only `cop_patrol` and `ped_suit` have sheets; `corpse_thug_70` failed in the library's round and the rest were never run. REQUEST 3 in JOURNAL asks for them. The far crowd's baked corpses stay on plan poses for every class, the two drawn ones included.
- **The riot's pile is only partly solved.** The push moves corpses, but only near rigs: the baked far crowd's bodies are not pushed, and the living melee stays dense. One pushed body now lies among the crowd's legs (`dead_riot_push_64.png`, top). A pushed body also sits up to 2.4 m from its blood. Bodies the rigs never drew (those falling far from Rivet) still draw from the atlas, at their sim point, without shadow or near side. A kept body gives way when it passes the feed radius (18 m from Rivet), so at the far edge of the view a body can still pop to the atlas.
- **While a body is still falling, it can pass over a neighbour.** Its push eases in over 24 ticks, so for that moment it can overlap one already lying (`DRAWDBG`: t13800, age 9). Settled frames are clear; the mid-fall crossing is not fixed.
- **The far crowd has no contact shadow** (near rigs and Dock 9 only).
- **The lamp post card stays as drawn.** I had called it a stub and asked for a lamp three times a person's height (REQUEST 1), then measured it: 65 px against Rivet's 53 px at 32 px/m, and the half-height walls are 49-121 px, so a taller lamp would stand over the walls. REQUEST 1 is withdrawn; the art is the library's `lamp_70_v4`, drawn for this camera.
- **Item 2's audit is by eye from one still, except the fire escape.** Parked cars and kerb furniture stand. Roofs and roof gear are the biggest plan-view read left and need art; the black bar at the wall's foot, which this audit missed, is fixed (item 3 above). The fire escape is closed from the source: the city generator never places one, so the streets draw none; only the alley arena has four.
- **Item 4 (movement angle) is only half answered.**
  - Cars: no wheels are drawn, and the drawn nose stays within 1.29 degrees of the path on screen at 70 (4.32 at 55). This is arithmetic from `VehicleCards`, assuming the turntable art was drawn at the true pitch; it was not filmed.
  - Rivet's feet on a diagonal: not measured. I filmed the only oblique walk the arena bot has at 64 px/m (`--bot=rivet`), and his boots are hidden under the torso in the toward and 3/4 rows, so that film cannot show drift either way. A pixel tracker over the drawn rows failed (the boots merge), so no number from it is used.
  - From the code only: facings are 8 octants, so a run between octants strides up to 22.5 degrees off its path, and the walk slides by up to 28 % between 1.8 and 2.5 m/s (`MAX_CYCLES_S`). See Call w-3.

## Gates so far

- **`node tools/evidence/run.mjs --no-bench` on `cbdbc318`: all PASS.** Lint 15/15, unit 1994 / 0, scenarios 55 / 0, parity 1200 steps with the planted mutation caught, selftest with look goldens 11/11, export-audit 635 / 0. The bench was not run. This replaces every older result below.
- Director reel, the brief's exact command, on `cbdbc318`: top, tilt70, combo each 19 chapters, 19 fully down, 0 SCRIPT ERROR, `no carry` in all 19 (Call w-4).

- **`node tools/evidence/run.mjs --no-bench` on `fdc80496`: all PASS.** Lint 15/15, unit 1979 / 0, scenarios 55 / 0, parity 1200 steps with the planted mutation caught, selftest, export-audit 633 / 0. This replaces every older result below. The bench was not run.
- Director reel, the brief's exact command, on `fdc80496`: top, tilt70, combo each 19 chapters, 19 fully down, 0 SCRIPT ERROR, `no carry` in all 19 (Call w-4).

- `node tools/lint/lint.mjs`: 15 of 15 in the pre-commit hook on `071e3780`.
- `node tools/tests/run_unit.mjs --select=test_street_dead_heading,test_street_dead_plan,test_street_quest_dead_plan,test_street_crowd_corpse`: 32 passed, 0 failed before the shader tests; `--select=test_street_dead_heading,test_street_crowd_corpse`: 15 passed, 0 failed with them.
- Eight film runs (Dock 9 and riot, 32 and 64 px/m, before and after): 0 SCRIPT ERROR each.
- `node tools/tests/run_unit.mjs` (full) at `4558d018`: 1968 passed, 0 failed, 0 skipped.
- **`tools/evidence/run.mjs --no-bench` on `4558d018`: NOT green.** Lint, unit (1968 / 0), parity (1200 steps, planted mutation caught), selftest (look goldens 11/11) and export-audit (release-compile 632 / 0) PASS. **scenario-tests FAIL: timed out after 1594 s, with 0 scenarios reported**, while my film and other lanes were loading the machine. So no scenario has a result on this branch, and that includes the replay.
- `node tools/tests/run_scenarios.mjs` on `016cd98f`: **55 passed**, 0 SCRIPT ERROR, with `replay_60s` (3600 ticks) and the quest 1 input replay identical (`build/test-results/scenario-tests.log`). This replaces the timeout above as the scenario result; `tools/evidence/run.mjs` itself has not been re-run.
- Director reel on `016cd98f`, the brief's exact command, top / tilt70 / combo: 19 chapters each, all fully down, 0 SCRIPT ERROR, but all 19 chapters log `no carry`, so no weapon is given (Call w-4). Once with `--loadout=pistol` at combo on `6ea62a9e`: 19 chapters, all down, 0 `no carry`, 0 SCRIPT ERROR.
- `node tools/tests/run_unit.mjs` (full) on `6ea62a9e`: **1972 passed, 0 failed, 0 skipped.**
- The scenario and reel runs above predate `6525a2e3` (the ring search, a view-only change to quest 1's corpses).
- Not exported yet.

## What blocked me

- The machine is badly contended: a commit's lint hook passed 10 minutes once and was killed, and a plain `--import` passed 200 s earlier. Neither lost work.
- REQUEST 2 and 3 (poses drawn for this camera) have had no producer tonight: the asset lane's runner log ends 17:55 on 2026-11-08, before this run began. The near-side sliver is a code stand-in for the classes still on plan poses.
- This lane opened with no `JOURNAL.md` and no commits past `c394af55`, although the runner called it iteration 4.

## Calls for the owner

- **w-1, the set of headings.** Five headings, heads never toward the camera. A blow toward the camera turns the body away, so it no longer falls that way. Frame: `dead_riot_before_after_64.png`. The tables are `StreetDeadHeading.HEAD_DEG` and `HEAD_DEG_ODD`; `ENABLED` false restores n9.
- **w-3, a walk that slides between 1.8 and 2.5 m/s.** From the code, Rivet's walk holds its cadence at 2 cycles a second above 1.8 m/s, so a stick walk at 2.5 m/s slides about 28 % until the run takes over. Raising `RivetWalk.MAX_CYCLES_S` to about 2.8 would plant it but makes the walk's legs churn faster. Left as built; it is the Rivet lane's tuning. Frame: `move_oblique_walk_64_sheet.png`, which shows why it is unread: the boots are hidden in the toward and 3/4 rows.
- **w-4, the director reel gate gives no weapons.** The briefed command has no `--loadout=pistol`, so `stage.pilot` has no carry and all 19 chapters log `no carry ... skipped` (`reel_director.gd:155`) and go down without the chapter's weapon. Run once with the flag at combo on `6ea62a9e`: 19 chapters, all down, 0 `no carry`, 0 SCRIPT ERROR. Suggest adding the flag to the gate; I did not change the gate. top and tilt70 with the flag were not run.
- **w-5, two art styles of corpse in one riot.** Patrol cops and suits lie in drawn-for-70 poses, the other classes in plan poses on the same headings. I kept the two classes on because a drawn body reads better and the rest can follow the same recipe. `StreetDead70.ENABLED` false puts every class back on plan poses; `StreetDead70.LAST_COL` 4 allows the head-straight-up cells I left out. Frame: `dead_drawn70_64.png`.
- **w-2, roofs.** Roofs are drawn straight down and are the largest plan-view area left under the 70 camera. Fixing that is a new art round for every roof type, not code. Frame: `wall_foot_core_32.png` (roofs above the wall).

## Next steps

Run the remaining classes through the library's corpse recipe (REQUEST 3) and add each to `StreetDead70.CLASSES` and `tools/art/dead_70.py`; give Dock 9 and the far crowd the same art. Film Rivet's feet on a diagonal with a dedicated bot and a leg-visible row. Roof art for this camera is the largest plan-view area left and needs its own art round.
