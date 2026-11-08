# JOURNAL: night n10, lane world

MILESTONE [21:05] Session opened (runner calls it iteration 4; this worktree had no JOURNAL and no commits past c394af55, so nothing was lost from earlier iterations: start at item 1).

## Reading the frames
- d10/block70 h05 (half height): the wall band is a dark squashed strip. The p70 strip is 4 storeys cut to 768x297 and drawn over a 76 px wall: every storey about 19 px tall, windows squat.
- Heights after height_k 0.5: shop 4.25-5 m, tenement 6.5-8 m, tall 8.5-10.5 m, so canvas wall (32 px/m, lift_k/ground_k) about 49-121 px.

## Item 1, the wall art at half height
- Tool `tools/art/city_facade_storeys.py` cuts the r2 elevations into upper + ground storey rows (bay 256 px wide, native aspect). `FacadeStoreys` stacks them from the ground, as many upper storeys as fit. Tenement 2 storeys at 76-93 px, tall ground + upper rows, shop one storey.
- FRICTION: the machine is badly contended (a plain `--import` passed 200 s and was killed; grep over project/tests times out).

MILESTONE [21:45] Item 1 done (aadc7430): half-height walls stack whole storeys. Filmed at 32 and 48 px/m, lint 15/15, the three selected unit files green. DECISION world/half-height-storeys.
MILESTONE [21:47] Item 2 first fix: the "fallen lamp" is the game's own pole shadow (`ChunkLift.draw` shadow path), not the test scene. cast_m 0.7, no blob. DECISION world/pole-cast-short.

## Item 2 audit so far (from the block70 stills at 32 px/m; NOT yet measured)
- Lamp post CARD is still a stub about one person tall: a 5 m post should stand well over the people. Needs art.
- Still to check: parked cars at the kerb, kerb furniture, fire escape (`props` has no row: stays flat), roof edges, contact shadows.

REQUEST 1 -> assets: a tall street lamp for the true 70-degree camera, 5 facings on one strip like `project/features/city/art/view/p70/prop_lamp_post.png` (the same five facings and the same order, foot at the cell's bottom centre, transparent ground), tall thin post about 3 x a person's drawn height, one arm with a dome head, grey-print ink look; size about 900 x 640 for the strip. Reference: that strip and `C:\Users\kazda\kiro\gtai-masters\n10\world\lamp_cast_32_after.png` for the stub it replaces.

FRICTION [21:50] A long assert line failed gdformat, so the pre-commit hook refused the shadow-fix commit while the outer command still exited 0. Check `git log` after every commit here.

NEXT: (1) Finish the item 2 audit by measured gap (parked cars, kerb furniture, fire escapes, roof edges, contact shadows); the lamp card waits on REQUEST 1. (2) Item 3 the dead: `StreetDeadPlan.draw` (`project/features/characters/street_dead_plan.gd:101`) rotates a plan pose freely (`blow.angle() - head + jitter`). Restrict that to a small set of screen headings picked from the blow's screen direction, drop the free jitter there, keep n9's spread, mirror the same rule in `street_quest_dead_plan.gd`. Judge which headings read right at 70 from stills first, then REQUEST poses drawn for this camera; research the classic three-quarter-RPG corpse techniques before fixing the set. (3) Item 4 movement angle. Gates still owed: full unit run, scenarios, parity, evidence run, director reel x3.

---- session 22:10 (iteration 8) ----
MILESTONE [22:12] Shadow fix landed after the hook refusal (20c868c6). Lint 15/15 in the hook.

## Item 2 audit (real city, combo, block70 focus, 32 px/m; this session's still `gtai-n10/tmp/world/audit/now32_t200.png`)
Looked at by eye in one still, NOT measured; "biggest first" here means by share of the screen and how plan the thing reads.
| what | state at combo | verdict |
|---|---|---|
| roofs and roof gear (tanks, vents, solar) | drawn straight down, covers most of the screen | biggest plan read left; needs new art, cannot be fixed in code: Call |
| lamp post card | foot and globe still read from above, a stub about one person tall | REQUEST 1 still open |
| fire escape | `props` has no row, stays flat | not seen in this frame; not counted yet |
| parked cars | cards, windscreen and side show | stands, no gap seen |
| kerb furniture (bin, payphone, hydrant, bollard, box) | cards | stands, no gap seen |
| contact shadows | props and cars hatch down-right; bodies had none | the dead get one now (item 3) |

## Item 3 research (the dead)
Two web searches. What they confirmed: death art is drawn per facing from the game's own camera (8 directions typical, 16 at most), frozen on the last frame, and the shadow is a separate layer or a plain ellipse. What they did NOT reach: how any shipped isometric game seats its corpses or sorts them under the living; that part is my reasoning, not a source.
Applied: (1) a corpse is never turned to a free angle: few headings, picked by the blow's screen octant; (2) no head toward the camera (the upside-down face was the worst read); (3) a separate shadow layer, the pose's own silhouette, down the city's sun direction. The art is still PLAN poses, so this is the code half: poses drawn for this camera are REQUEST 2.

REQUEST 2 -> assets: the dead for the true 70-degree camera, one sheet per body class as `dead_plan_v1` (same 13 classes + contractor, same 5 poses A-E, same cell 384 x 384, pelvis at the cell centre, transparent, no blood), redrawn so the body is seen from a camera 20 degrees off straight down: the side of the torso and limbs nearest the viewer just visible, feet toward the viewer, head away. Head toward the top for A-D, head right for E (the headings the game now uses; it mirrors, it never turns E). Reference: `project/features/characters/art/view/plan/dead_ped_suit.png` and `C:\Users\kazda\kiro\gtai-n10\tmp\world\audit\dead_crop.png`. ped_suit first as a test of the look.

## Item 4 movement angle: first read (code trace only, nothing filmed or measured yet)
- Vehicles: the trace found no wheel animation at all (cards move rigidly), so no wheel drift to fix there; the atlas art itself was not inspected.
- Walkers and Rivet: the walk phase advances by ground distance and the card is drawn unsquashed, so the camera squashes foot art and displacement together: the view's ground_k adds no drift by itself.
- Facings are 8 octants (5 drawn, 3 mirrored); a run off an octant snaps to the nearest, up to 22.5 degrees off, so the feet stride along the drawn octant and sidestep the true path. Not measured on film. Suspected cheap residual: only `RUN_ROW_K` corrects the non-profile rows, walks have no per-row factor (up to about 6 % at 70 by arithmetic, unconfirmed).
- `rivet_walk` MAX_CYCLES_S 2.0 lets feet slide by design between about 1.8 and 2.5 m/s.

MILESTONE [22:56] Item 3 code done for near rigs, Dock 9 and the far crowd: 071e3780 and the far-crowd commit after it. Filmed before/after at 32 and 64 px/m, riot and Dock 9, same seed and tick, before = `StreetDeadHeading.ENABLED` false (Dock 9 also with n9's SPACE_M / PUSH_MAX_M). 4 pairs in masters, frames.json updated. DECISION world/dead-few-headings, world/dock9-push-wider, world/far-dead-few-headings.
Looked at every pair. Worked: no head toward the camera in near rigs or far crowd, headings read as a small set. Not fixed: the top pair at Dock 9 still touches, the far crowd has no contact shadow, and these are still plan poses (REQUEST 2).
FRICTION [22:40] A pre-commit lint passed the 10-minute background limit and was killed (nothing lost, no lock left); retried with a longer limit and it landed. Run commits in the background with a long timeout while films are running.

FRICTION [23:09] The full unit run hit its own `timeout 800` and was terminated: NO RESULT, neither pass nor fail. Run it with no outer timeout, in the background, when the machine is quieter.

NEXT: (0) The far-crowd commit landed as b8ba8f9e. Check `git log` that this JOURNAL and REPORT commit landed too; if not, stage those two paths and commit in the background with a long timeout. (1) Gates owed on this branch: full unit suite, scenarios, parity, `tools/evidence/run.mjs --no-bench`, director reel x3 at `--quit-after 40000`. (2) Item 2: fire escape census (how many, and stand it or leave it), measure rather than eyeball. (3) Item 4: film a diagonal run at combo, 32 and 64 px/m, against the ground; the code trace says no ground_k drift and no wheels, so what is left is the up-to-22.5-degree octant snap and the possible 6 % walk row factor. (4) Far-crowd contact shadow. (5) Dock 9's top pair still touches. (6) Check `library/deliveries/` for REQUEST 1 (lamp) and REQUEST 2 (poses drawn for the 70 camera).

---- session 23:11 (iteration 9) ----
MILESTONE [23:26] Full unit suite GREEN at 4558d018: 1968 passed, 0 failed, 0 skipped (195.6 s, machine quiet at the start). `tools/evidence/run.mjs --no-bench` started 23:27; result pending.

## Deliveries read (`library/deliveries/facade_half_it180.md`, made 17:41, before this lane's first request)
- Half-height strips (shop 4.6 m, tenement 2 storeys, tall 3 storeys) `keyed/building/facade_half_*_70_strip[_p70].png`. Item 1 is already built from a recut of the r2 elevations (aadc7430): the delivery is an alternative I have NOT filmed. Next-steps line, not a change tonight unless item 1 gets looked at again.
- `keyed/prop/fire_escape_70_v2.png` / `_55_v2`, A: standing art, five rotations, transparent.
- "The library already has corpse poses drawn for this camera" = the last frame of each 5 x 3 fall strip. Those frames ARE the game's `LONG_FALLS` lying frames (street_walker_fall.gd). They are what n9 replaced, on the owner's "they lay down like in the bed now". So they are not new, and `StreetDeadPlan.ENABLED` false already shows them. Looked at the contractor sheet: arms forward, legs straight, flat. Not adopted. REQUEST 2 (broken poses drawn at 70) stands; nothing of it has arrived, and nothing newer than 22:00 exists anywhere in the library.

## Item 2: fire escape census, closed
`KerbDresser` (KERB_PROPS 25-37, WALL_PROPS 39, 34, 32, 26) never places texture 40, and no other file in `features/city/gen` or `stream` names it (grep `\b40\b|escape`: nothing). So the streamed city draws 0 fire escapes; this is from the source, not a chunk count. Its one user is the alley arena (`alley_decor.json` `escapes`, 4 of them, `AlleyDecor._turned`). No street gap, no fix. The delivered standing art needs a `props` row only if the generator ever places one. DECISION world/fire-escape-no-gap below.

## Item 4: cars, closed by arithmetic
`VehicleCards.put` draws the view nearest the ground heading (45 deg apart) turned by the ground rest; `card_xf` turns it by that rest ON SCREEN. A car's path on screen is atan2(sin a * gk, cos a). Worst gap between drawn nose and screen path over all headings, assuming the turntable art was drawn at the true pitch (not checked): 1.29 deg at 70 (gk 0.940), 4.32 deg at 55 (gk 0.819), both at ground heading 292.5. Cards have no wheels to drift. Nothing to fix at 70; the 55 row only draws in boss fights.

FRICTION [23:30] Tried to measure each walk8 / run8 row's stance travel from the alpha alone (bottom-band boot blobs, followed frame to frame): the boots merge into one blob in most frames (`boots-per-frame` mostly 1) and the numbers swing 0.5 to 13.9 px/step inside one row. Discarded: no number from that script is used anywhere. Script left in tmp only.

## REQUEST 1 withdrawn [23:34]
REQUEST 1 -> assets is WITHDRAWN: no taller lamp please. I asked for a post "about 3 x a person's drawn height" without doing the sum. Measured: the card is 1.45 m wide over a 182 x 256 cell, so 2.04 m = 65 px drawn at 32 px/m, against Rivet's 53 px (1.65 m), so 1.24 x a person. Walls at `height_k` 0.5 draw 49-121 px. A 160 px lamp would stand over a two-storey wall. The shipped strip is the library's `lamp_70_v4` drawn for this camera (foot plate seen from above is right at 70). What I called a "stub" in the audit is the art's chunky foot, not a camera fault. No change.

## Item 4: Rivet's feet, what the film can and cannot say
`--bot=rivet --view=combo --rigs --ppm=64`, 640 frames: the only oblique segment in that bot is the short approach to the claw cops (ticks ~425-540). Contact sheet `gtai-n10/tmp/world/diag/sheet_obl.png`, looked at. At 64 px/m and a 70 camera his legs are mostly under the torso in the toward and 3/4 rows, so a boot against the ground cannot be read at all in these frames. I can't say feet plant or drift on a diagonal from this film; no measurement exists. By arithmetic from the code only: walk phase advances by ground distance, CYCLE_CELL 60 cell px x 0.48 px/cell = 28.8 px = 0.9 m a drawn cycle, `MAX_CYCLES_S` 2.0 holds up to 1.8 m/s, and above that the foot slides until `RUN_FROM_MPS` 2.5 swaps to the run: up to 28 % at 2.5 m/s. That band is Rivet-lane tuning, not mine: a Call, not a change.

FRICTION [00:05] `tools/evidence/run.mjs --no-bench`, started 23:27 on 4558d018, has NO RESULT: its log (`gtai-n10/tmp/world/evidence_2327.log`) was still empty at 00:05 and my 30-minute wait timed out. Newest artifact `build/evidence/world-lock.json` at 00:00, so it got as far as the world-lock scenarios at least. Pass or fail unknown, and I could not tell whether the process was still alive. Do not cite it.

NEXT: (0) `git log` for this JOURNAL / REPORT / decisions commit; if missing, stage those three paths and commit in the background (the hook's lint can pass 10 minutes). (1) Gates owed: read `build/evidence/` and the log above or re-run `tools/evidence/run.mjs --no-bench` alone with a wait longer than 30 minutes; director reel x3 at `--quit-after 40000` NOT run. Unit full is green at 4558d018 (1968/0). (2) Dock 9's top pair still touches. `StreetQuestDeadPlan.push_of` measures between sim points, but the drawn body sits at `at + head * pelvis`: measure between drawn centres (store each centre beside `_pushed`, the test at `test_street_quest_dead_plan.gd:85` should still hold with no stored centre), or try SPACE_M 2.4 / PUSH_MAX_M 1.9. Film with `res://dev/frames/quest1_clip_rec.gd` (`--out= --before --zoom= --every=`), t13800 at 64 px/m. Not touched this session because the evidence run needs a clean code tree. (3) Far-crowd contact shadow: about 2 px at crowd scale, low value; report it rather than build it. (4) Item 1 alternative not filmed: `keyed/building/facade_half_*_70_strip_p70.png` from `deliveries/facade_half_it180.md`. (5) REQUEST 2 (broken poses drawn at 70) has no delivery; the library has nothing newer than 22:00 on 2026-11-08.

CORRECTION [00:08] The evidence run did finish, after the FRICTION line above: on 4558d018 lint, unit 1968/0, parity, selftest and export-audit PASS; **scenario-tests FAIL, TIMED OUT after 1594 s, 0 of 0 reported** (`build/evidence/scenario-tests.json`). A timeout under load, not a failing scenario, but no scenario result exists on this branch. NEXT (1) becomes: run the scenarios alone on a quiet machine first (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`), then the director reel x3.
