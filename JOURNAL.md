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


---- session 00:08 (iteration 10) ----
Read at open: no new delivery in `library/deliveries/` (newest still `facade_half_it180.md`, 17:41 on 11-08); no `REQUEST -> world` from another lane.

MILESTONE [00:18] Dock 9's push (NEXT 2) landed as 016cd98f, split into `StreetQuestDeadPush`. It now measures between drawn cell centres and relaxes over 8 passes (one summed pass let neighbours on two sides cancel). Unit: test_street_quest_dead_plan 12/0 in the commit's final state; the three-file select was 33/0 before the lint rename. Lint 15/15 in the hook. DECISION world/dock9-push-centres.
Filmed Dock 9 at 64 px/m (t13800, seed the same) at four settings, looked at each:
| SPACE_M / PUSH_MAX_M | result |
|---|---|
| 1.9 / 2.2 (shipped) | no body on another; a boot still crosses the kneeling body, a hand touches in the top pair |
| 2.1 / 3.0 | two bodies stacked at the top right (two helmets side by side) |
| 2.3 / 2.4 | two bodies stacked, worse |
| 1.9 / 1.4 summed, spots (item 3, the before) | top pair overlapped at the helmets |
So it is a modest gain, not a solved pile. The debug log of first-sight centres (one run, not kept) showed every later body ending at or past SPACE_M from the others it knew at that moment, so the stacks at wider settings are NOT a spacing shortfall at first sight. Unverified guess: bodies keep moving after their first sight, or are placed against neighbours first seen later.
FRICTION [00:17] First commit attempt of this change failed in the hook on `gdlint` (function-variable-name for `_pose_a`-style throwaways), though the shell line exited 0. The file count of the commit output was the only sign. Replaced them with `assert_gte` on the returned pose.
Evidence: `dead_dock9_centres_64.png`, `dead_dock9_centres_32.png`. First composition of the 64 pair had the before panel at 1.35x the after, so the sizes lied; rebuilt at matched scale and the note reworded to what the frame shows.

MILESTONE [00:24] Scenarios GREEN on 016cd98f: `node tools/tests/run_scenarios.mjs` 55 passed in about 5 minutes, 0 SCRIPT ERROR in `build/test-results/scenario-tests.log`; `replay_60s` 3600 ticks ran, `city replay` 20 checkpoints identical, quest1 input replay "identical". This closes the timeout on 4558d018. Note: this runner does not refresh `build/evidence/scenario-tests.json` (still the 4558d018 timeout); the evidence run has not been re-done.
Director reel x3 started 00:19 on the same head, in parallel; no result yet.
Correction to the 00:18 entry's guess: the sim does not move dead guards (`guard_brain` runs only for the living) and every first sight comes through the one draw path, so "bodies keep moving after first sight" is not the cause. Best remaining explanation, by reading, not proven: in a crowd the fixed-order relaxation can end on a spot that overlaps an earlier neighbour. Draft of the fix (nearest clear spot on rings) waits for the reels so the tree stays frozen under them.

CORRECTION [00:40] The 00:18 table and the guesses after it were wrong. At t13800 body 12 is 9 ticks dead, still sliding into its push (it eases in over `FALL_TICKS` 24), so the "stacks" at wider settings were a body mid-fall, not a spacing fault. Logging each draw found it (`DRAWDBG ... age=9`). 016cd98f's code comment and the first decision line repeated the error; both are corrected.
Re-filmed settled, t13900, 64 px/m, looked at each:
| SPACE_M / PUSH_MAX_M | settled result |
|---|---|
| 1.9 / 1.4 one pass, between spots (item 3's behaviour, rebuilt with a temporary edit, then restored) | three bodies chained, touching |
| 1.9 / 2.2 | a hand touches |
| 2.1 / 2.4 (shipped) | four bodies clear, all still on the crossing |
| 2.3 / 3.0 | clear, but one body thrown 3 m off its blood |
Ring search (nearest clear spot when relaxation leaves an overlap) stays: with it disabled `test_a_crowd_on_one_spot_ends_with_nobody_on_anybody` fails (15.7 px apart, 66 needed). I did not run the mutation tool. It never fires in the Dock 9 frame itself, so that test is its only evidence.
Evidence replaced: `dead_dock9_centres_64.png`, `dead_dock9_centres_32.png` are now same-tick settled pairs, before = the item 3 behaviour.

MILESTONE [00:25] Director reel x3 on 016cd98f (the brief's exact command, `--quit-after 40000`, top / tilt70 / combo): each 19 chapters, every one fully down, 0 SCRIPT ERROR. BUT every chapter also logs `director: no carry (run with --loadout=pistol); <weapon> skipped`: without `--loadout=pistol`, `stage.pilot` has no carry and `carry.take` never runs (19 of 19 in combo), so these reels show the chapters' victims going down, but do NOT show the chapters' weapons being carried. Reported, not changed: it is the brief's gate command.

FRICTION [00:45] The machine went heavily contended around 00:38: a small Python doc edit and a `gdformat` on one file each passed 2 minutes. A second hook refusal this session (gdformat on one long line) is the same trap as 21:50: read the hook's output, not the shell's exit code.

Gates state at this entry: lint 15/15 and scenarios 55/0 and reel x3 were on 016cd98f, BEFORE the ring-search commit that follows it. The ring commit is a view-only change to quest 1's corpses, tested by `--select=test_street_quest_dead_plan` 13/0 (before gdformat wrapped one line, no logic change). Full unit suite last ran on 4558d018 (1968/0). `tools/evidence/run.mjs --no-bench` has not been re-run since its scenario timeout; the exe is not exported (freeze job).

NEXT: (0) `git log`: the ring-search commit and the docs commit after it should be there; if missing, stage per path and commit in the background, read the hook's output. (1) On a quiet machine: `node tools/tests/run_unit.mjs` full, then `tools/evidence/run.mjs --no-bench` so the evidence JSON stops saying TIMED OUT. (2) Call w-4: the director reel without `--loadout=pistol` carries no weapon; run combo once with it to see whether the chapters still go down, and report; do not change the owner's gate command unasked. (3) Mid-fall bodies can cross a neighbour for up to 24 ticks (the push eases in): judge if it shows at play speed before doing anything. (4) REQUEST 2 (poses drawn for the 70 camera) still has no delivery. (5) `facade_half_it180` strips not filmed against the recut. (6) Freeze 08:30: export the exe with the REPORT's exact command.

MILESTONE [00:53] On 6ea62a9e: full unit suite 1972 passed, 0 failed, 0 skipped (63.9 s). Director reel combo WITH `--loadout=pistol`: 19 chapters, all fully down, `no carry` 0, 0 SCRIPT ERROR. So the weapons do work in the reel at combo; the gate command as briefed simply does not give them. top and tilt70 with the loadout were not run.
Scratch renders under `gtai-n10/tmp/world/dock_fix` deleted (nothing in frames.json points there).

NEXT (supersedes the 00:45 list's 1 and 2): (1) `tools/evidence/run.mjs --no-bench` on a quiet machine so `build/evidence/scenario-tests.json` stops saying TIMED OUT (the scenario suite itself is green on 016cd98f, unit full green on 6ea62a9e). (2) Mid-fall bodies can cross a neighbour for up to 24 ticks: judge at play speed before changing anything. (3) REQUEST 2 still has no delivery. (4) `facade_half_it180` strips not filmed against the recut. (5) Freeze 08:30: export the exe with the REPORT's exact command.

---- session 00:56 (iteration 14) ----
Read at open: no new delivery; the asset lane's runner log ends 17:55 on 11-08, before this night began, so nothing is producing REQUEST 2 (poses drawn for 70).

MILESTONE [01:03] Item 2's real biggest gap at street level, found while asking why shop walls read as a black band: the parapet ink core (`ChunkView._core`, `cast_shadows.json` `parapet_core_m` 0.22) is the flat city's raised-roof cue, the silhouette again in solid ink down-right on the ground. Under a tilt a wall stands on that edge, so it lay at every wall's foot as a 7 px black bar (and a detached strip on open east sides). 3cf3ffdc: not drawn when the city is lifted; flat views keep it (`CastShadows.CORE_UNDER_LIFT` true restores it). `test_cast_shadows` 6/0, lint 15/15 in the hook. Pair: `wall_foot_core_32.png`, `_48.png`, same seed and tick. I looked at both: the wall now ends on its own ink line and the hatch. My 22:10 audit had missed this.

Item 1 alternative filmed (`facade_half_it180`, NEXT 4), same frames, 32 and 48 px/m:
| style | delivered strip | result |
|---|---|---|
| shop, dark trim (the delivery's own recommendation) | `facade_half_shop_dark_70_strip_p70` | a heavy grey band, worse than the recut |
| shop, pale | `facade_half_shop_70_strip_p70` | adopted (35de190a): 4.1 m bays, drawn door, solid piers. A modest gain over the recut |
| tenement bold | `facade_half_tenement_bold_70_strip_p70` | rejected: flat grey panels, squat windows, the brick is lost under the print |
| tall bold | `facade_half_tall_bold_70_strip_p70` | not adopted; no tall building was in the test frame, so unjudged by eye |
`wall_tenement_delivered_rejected_48.png`, `wall_shop_delivered_32.png`, `_48.png`. Provenance line added for the shop strip.

Checked, no gap: the plan pose sits on the world canvas, which is already squashed by `ground_k` (only cards counter-scale), so a corpse's footprint foreshortens with the ground.

Item 3, the near side (579ef0f4): a shaded silhouette `SIDE_M` 0.16 below the pose. FRICTION: my first two films of this looked heavier by eye, but a numeric frame diff said the frames were byte-identical: Dock 9 draws through `StreetQuestDeadPlan`, which my first edit never reached. I had been reading a difference that was not there. Diff before judging a subtle change. Dock 9 pair: `dead_side_dock9_64.png`. The riot film was not re-run for this change: only a block still at 64 px/m exercised the near-rig path (0 SCRIPT ERROR, the corpse looks seated).
Evidence run started 01:12 on 579ef0f4 (`gtai-n10/tmp/world/evidence_0111.log`).

MILESTONE [01:19] Evidence on 579ef0f4, all PASS: lint 15/15, unit 1975/0, scenarios 55/0, parity, selftest (goldens 11/11), export-audit 633/0. The first evidence run on this branch with no failed gate. Bench not run (`--no-bench`).

MILESTONE [01:31] Item 3, the riot's near bodies pushed off each other: fdc80496. `StreetDeadHeading.resting` calls `StreetQuestDeadPush.push_of` with the city's `solid`, so a push ending on a wall takes the nearest free spot and a lone body never moves. `StreetDeadPlan.reset` now also clears pushes and runs at city setup (before this it was only ever called by tests, so a reused actor id would have inherited an old push). Unit select 44/0. Riot film 32 and 64 px/m, same seed and tick, before = ed952be6: the two corpses on top of the standing cops are off them. A numeric diff shows Dock 9 byte-identical to before this change. Not filmed: the rig-to-baked-crowd swap, where a pushed body can jump up to 2.4 m. DECISION world/riot-near-push.

Director reel x3 on ed952be6 (the brief's command): top, tilt70, combo each 19 chapters, 19 fully down, 0 SCRIPT ERROR, `no carry` 19 each (Call w-4). That head predates fdc80496.
FRICTION [01:28] A long bash heredoc with embedded Python failed to parse ("unexpected EOF while looking for matching `'`"); nothing was applied. Wrote the patch to a file and ran that.

MILESTONE [01:38] Evidence on fdc80496, all PASS: lint 15/15, unit 1979/0, scenarios 55/0, parity, selftest, export-audit 633/0. Bench not run.

MILESTONE [01:43] Director reel x3 on fdc80496 (the brief's command): top, tilt70, combo each 19 chapters, 19 fully down, 0 SCRIPT ERROR, `no carry` 19 each (Call w-4). With the evidence above, every gate is green on the last code commit. Scratch renders from this session deleted; `frames.json` has 15 entries, all present on disk.

NEXT: Code state: fdc80496 is the last code commit and every gate is green on it; if a later commit touches code, re-run `tools/evidence/run.mjs --no-bench` and the reels x3. What is left, in order: (1) Film a rig being swapped for the baked crowd (riot, walk the camera away) to see how far a pushed body jumps; up to 2.4 m by arithmetic, not seen. If it is ugly, lower the street push cap only. (2) Mid-fall crossing on Dock 9 (24 ticks): judge at play speed before changing anything. (3) Both big plan-view gaps left are art with no producer tonight: poses drawn for 70 (REQUEST 2) and roofs (Call w-2). The asset lane's log ends 17:55 on 11-08; check `library/deliveries/` once per session and do not wait on it. (4) Item 4 stays a Call (w-3); a diagonal film cannot read the boots in the toward and 3/4 rows. (5) Freeze 08:30: export the exe with the REPORT's exact command, name it in REPORT. If (1) and (2) come out clean and nothing has been delivered, write QUEUE EMPTY and stop rather than invent work.


---- session 01:45 (iteration 18) ----
Read at open: no new delivery (newest `facade_half_it180.md`, 17:41 on 11-08), no `REQUEST -> world`.

MILESTONE [01:55] Item 3, the rig-to-crowd swap (NEXT 1 of the last session): it was worse than I had guessed, and I had it wrong in REPORT. A near corpse only keeps its rig `RigSelect.CORPSE_HOLD_TICKS` 90 ticks (1.5 s) unless it is among the 16 nearest; then the baked crowd draws it. In the riot film that is most bodies, in view, 1.5 s after they die: 18 bodies handed over in 23 s, each jumping from where it lay to its sim point by 0.64-3.07 m, median 2.08 m (logged at each hand-over, `jump_m` = plan pose centre to sim point). At 64 px/m the frame pair shows more: the pink body vanishes and a grey man appears at its sim point, (WRONG, see the correction below) (`dead_swap_kept_64.png`). None of the careful placement (heading, push, near side, shadow) outlives 1.5 s. Fix: 39f4e53c `StreetDeadRest` keeps the lying sprites where they lay, moved off the rig's card to one layer under the rigs, until the row leaves the feed (the sim despawns a body after 8 s, or it passes the feed radius) or stands up; the kept ids go into `set_rig_slots`, so the atlas cell stays undrawn. CAP 48, oldest goes back to the atlas. View only: the sim and replay are not touched. `StreetDeadRest.ENABLED` false = before. DECISION world/dead-rest.
A second defect the logs caught: id 130 and id 318 were handed over, then re-rigged and handed over again with a different jump (2.76 then 2.42; 2.60, 2.60, 2.04), because a new rig has no blow to read and the body turned. `free_of` now keeps a kept body off the rig list; a re-run of the same riot shows 18 hand-overs, none repeated (22 before).
Test: `test_street_dead_rest` 6/0; `--select=test_street_dead_rest,test_character_rigs,test_street_dead_plan` 32/0. Lint 15/15 in the hook. Mutation tool not run.
FRICTION [01:48] Godot refuses a `Variant` argument under warnings-as-errors: `drop(_kept.keys()[0])`. The first unit run failed 30 ways at once with `Nonexistent function` errors, which all came from that one parse error. Read `unit-tests.log`'s first SCRIPT ERROR line, not the summary.

CORRECTION [02:06] "A grey man appears, the atlas draws it under a different look" (01:55 entry, and the first frames.json note, REPORT and decision text) was wrong. With the rest layer on and the kept bodies moved under the actors band, the grey man is still drawn: he is another body, who had been hidden under the pink one. A same-frame diff (before against after, frame 392) changes only the pink body's own area plus two slivers near its sim point, so the atlas does draw this corpse at its sim point, about 2 m away, mostly hidden under other bodies. No look change is evidenced; every note is corrected. What the film does show is the pop: the body vanishes from where it lay.

MILESTONE [02:06] Kept bodies drawn one z under the actors band (`UNDER_ACTORS` -1, relative, inside the band the render lint allows), because the first version left a corpse lying on top of the walking crowd's legs for its whole 8 s. Pair of the same frame: the grey figure now draws over the pink body. `--select=test_street_dead_rest,test_character_rigs` 19/0. Evidence pairs rebuilt from the final state: `dead_swap_kept_64.png`, `dead_swap_kept_32.png` (top row before, bottom row after, frames 370 and 392).
Evidence on 39f4e53c (before the z line), all PASS: lint 15/15, unit 1985/0, scenarios 55/0, parity, selftest 11/11, export-audit 634/0. Bench not run.

---- session 02:10 (iteration 18, BUILD) ----
Read at open: no new delivery, no `REQUEST -> world`. The queue is really the weakest item now: the dead are plan poses.

FINDING [02:15] REQUEST 2 already has art nobody delivered. `gtai-art/library/rounds/20261108-1750/out/` holds `corpse_cop_patrol_70.png` and `corpse_ped_suit_70.png`: five head directions x two families (face down, on the back), drawn at 70 degrees with the near side visible; `corpse_thug_70` failed at the Codex exit. The round stops at 17:55 on 11-08 and has no delivery note or catalog grade. I had read `library/deliveries/` every session and never the rounds folder. Only 2 of the 14 classes have it.
MILESTONE [02:19] eb2611c3: `StreetDead70` draws those two classes: the cell by the head's screen heading and the pose's family (poses sharing a heading take different rows), mirrored for the left, never turned, the ground squash undone, the near-side sliver off (the drawing has its own). `tools/art/dead_70.py` packs the sheets (384 px cells, pelvis at the centre, one scale per sheet matched to the class's plan poses: cop 0.651, suit 0.574), library only read; two provenance lines with the round and prompt hash. DECISION world/dead-drawn-70.
FRICTION [02:18] First film frame: a suit lying with his head straight up reads as a man STANDING in the crowd. Column 4 (head up) is left out (`LAST_COL` 3): an up heading takes the up-right cell, mirrored by the person. Re-filmed.
FRICTION: the hook refused this commit three times on 100-column comment lines and a 45-line function; awk printed the long line before I committed the third time and I committed anyway. Read the check's output before the commit.
REQUEST 3 -> assets: the other classes as `corpse_<id>_70` on the 20261108-1750 recipe (`tools/mk_corpse_round.py <round> 70 <ids>`, the sheet at 5 head directions x 2 families, GREEN): cop_riot, swat, contractor, thug first (they are the riot's and Dock 9's dead), then ped_hood, ped_worker, ped_shopper, ped_cap, ped_elder, ped_hat, ped_jogger, ped_punk. Reference: `gtai-art/library/rounds/20261108-1750/out/corpse_cop_patrol_70.png`. Column 4 (head up) can be dropped from the sheet: the game does not use it. Then add the class to `StreetDead70.CLASSES` and `tools/art/dead_70.py`.

MILESTONE [02:34] On cbdbc318: `tools/evidence/run.mjs --no-bench` all PASS: lint 15/15, unit 1994/0, scenarios 55/0, parity (planted mutation caught at step 629), selftest (look goldens 11/11, worst 0.00), export-audit 635/0. Bench not run. Director reel x3 (the brief's command): top, tilt70, combo each 19 chapters, 19 fully down, 0 SCRIPT ERROR, `no carry` 19 each (Call w-4).
How much the drawn poses change, measured by frame diff of the 64 px/m riot film (ENABLED false against true, same seed, one frame per second over 23 s): 0 to 2 changed bodies per frame, zero in seconds 2, 3 and 13-17. The first second differs in 49 places over the road and crossings, before anyone has died; I did not explain that first-frame difference and did not use it. Pairs: `dead_drawn70_64.png` (one body in the open), `dead_drawn70_32.png` (a body in the pile, the two hardly differ). My 02:20 glance at the contact sheet took the suits at t 10-18 for drawn cells; the diff says most of those frames show plan poses on their headings.
Raw `.avi` films deleted.

MILESTONE [02:52] Mutation on `street_dead_70.gd` at 8063688b, all 29 mutants, `--tests=test_street_dead_70`: 92.6 % (25 killed / 27, 2 invalid). The first sampled run was 75 % (9/12) and its survivors were real gaps (a diagonal right-side head mirrored, the row-0 family, a sheet swap, then `place` untested); four tests closed them. The two left are on line 45: the snap literal 0.001 -> 1.001 and `<` -> `<=`, both equivalent at the headings the tables can give (x is 0, +-0.707 or +-1, and 0 never reaches that branch). Test-only commits after cbdbc318, so the evidence and reels on cbdbc318 still cover the game code; the new tests ran by `--select=test_street_dead_70` 11/0, not in a full suite.

NEXT: Code state: cbdbc318 is the last game-code commit, evidence and reels x3 green on it; 136cbbcf and 8063688b only add tests. In order: (1) Check `library/rounds/` as well as `library/deliveries/` each session: REQUEST 3 is the rest of the classes on the corpse recipe. When a sheet arrives: add the class to `StreetDead70.CLASSES` and `tools/art/dead_70.py` (`CLASSES`, then `--provenance --only=<id>`), film it. (2) Dock 9's contractors and the far crowd have no drawn cells: wiring them is the next code step once `contractor` exists; do not do the far crowd's shader before the art is there. (3) Mid-fall crossing (24 ticks) still unjudged. (4) Item 4 stays Call w-3. (5) Freeze is 07:30 (older notes in this file say 08:30, wrong): export the exe with the REPORT's exact command and name it in REPORT, then `node tools/evidence/cites.mjs REPORT.md`. If nothing has been delivered and (3) is judged, write QUEUE EMPTY rather than invent work.

---- session 02:53 (iteration 19, BUILD) ----
Read at open: no new delivery or round since 17:54 on 11-08, no `REQUEST -> world`. The queue's movable weak spot is item 4: "feet drift" had only code reasoning and a pixel tracker that failed.

MILESTONE [03:08] Item 4, a defect found: 63e685d3. The drawn walk's row is `rig.head.global_rotation`, the aim, not the travel. The plan rig already folds a backpedal and twists its hips (`RigHips`), but the drawn grids since n9 always stepped forward. Temporary uncommitted log per tick in `RivetWalk.phase_of`, the pit bot (`res://dev/arena/arena.tscn --rigs --bot=pit --view=combo --loadout=pistol`, 3200 ticks, headless):
| 1808 ticks on a walk grid | off (`--rivet-stride=off`) | on |
|---|---|---|
| mean stance-foot mismatch / walking speed | 1.18 | 0.61 |
| ticks with the row within 22.5 deg of the walk | 14.2 % | not the same bin once a backpedal is folded |
| ticks stepping backward | 0 | 167 |
| drawn row changes per second | 2.59 | 4.45 |
| rows held 2 ticks or fewer | 9 | 20 |
Mismatch = `|walk - sign x row|` in units of the walking speed: it is the geometry of the stance foot against the ground (a row 90 deg off = 1.41), computed from the row and the walk, not tracked in pixels. The pit bot strafes every 45 ticks while aiming at guards, so it is a worst case, not a share of real play.
`RivetStride`: past RigHips' 105 deg the walk folds and the grid plays backwards; the row turns one octant (TWIST_ROWS) toward the walk. Flicker guards: HOLD_ROWS 0.25, FOLD latch 90-120 deg, DWELL_S 0.1. I first had no latch on the fold, and the row jumped two rows at 105 deg (row changes 5.77/s before the latch). 19 of the 20 remaining short rows have the aim's own octant changing at the same tick; the off run has 9 of its own for the same reason, so these are aim dither, left alone.
FRICTION: `int(rig.get_meta(...))` and `float(rig.get_meta(...))` are Variant casts, a parse error under warnings-as-errors, twice. `var x: int = rig.get_meta(...)` is what the codebase does.
Film: `move_stride_turn_64.png`, `move_stride_turn_32.png` (ticks 676-726 every 5th, top = off, bottom = on): the legs now stride along his path. 0 SCRIPT ERROR in all four films. DECISION world/rivet-stride.

Item 3, mid-fall crossing (NEXT 3 of last session), judged from a contact sheet of the 64 px/m clip (`quest1_clip`, ticks 13780-13830), NOT at play speed: four bodies knot together for a few frames while falling and are clear by the last frames; it reads as an impact, no change. No number.

Mutation on `rivet_stride.gd` at 63e685d3, all 30 mutants: 73.3 % (22 of 30). Real gaps closed by tests in 08e2f56b (the default on, the held row against a non-zero aim, a stale row dropped, a stop's wrap at row 7); see the re-run below.
Mutation re-run on 08e2f56b, all 30 mutants, `--tests=test_rivet_stride`: 90.0 % (27 killed / 30). The three survivors are `>`/`<` boundaries at lines 38, 50, 68: they differ only when a float angle lands exactly on the limit.

MILESTONE [03:40] On 08e2f56b: `tools/evidence/run.mjs --no-bench` all PASS: lint 15/15, unit 2013/0, scenarios 55/0, parity (planted mutation caught at step 629), selftest (goldens 11/11), export-audit 636/0. Bench not run. Director reel x3 (the brief's command): top, tilt70, combo each 19 chapters, 19 fully down, 0 SCRIPT ERROR, `no carry` 19 each (Call w-4). Raw films deleted.

QUEUE EMPTY: items 1, 2 and 4 are done or reported as Calls (w-2 roofs, w-3 the 1.8-2.5 m/s walk slide, w-6 how far the row turns). Item 3 is done for what code can reach; blocked on art: REQUEST 3 (the other 11 street classes and the contractor, drawn for 70). No delivery and no new round since 17:54 on 11-08. Unmeasured: foot drift of cops and peds; a human player's share of strafing.

NEXT: 08e2f56b is the last game or test commit, every gate is green on it. If a sheet has arrived in `library/rounds/` or `library/deliveries/`: add the class to `StreetDead70.CLASSES` and `tools/art/dead_70.py`, film it. Otherwise end at once, except the freeze job at 07:30: export the exe with `"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`, name it in REPORT, run `node tools/evidence/cites.mjs REPORT.md`. Merging n10-rivet: `rivet_walk.gd` changes do not overlap (`path_of`/`moving` there, `phase_of`/`row_k` here).

---- session 03:41 (iteration 20, BUILD) ----
Read at open: no new delivery or round since 17:54 on 11-08, no `REQUEST -> world`. Tree clean at 10ed4f51.

MILESTONE [03:45] Exe built ahead of the freeze, the one job left on the list (the other lanes did theirs early too): `build/export/windows/RTAI.exe`, 553,426,960 bytes, sha256 starts 8aa18f48808f55e6, code = 08e2f56b. The worktree had no city chunks, so `bake_city.gd` ran first (256 chunks, git status stayed clean). Boot check only: `--headless --quit-after 300` exit 0, 0 SCRIPT ERROR, reached the arena hub; not run windowed or played. One engine shader error in the log (`kill_char.gdshader:37` passes TEXTURE to a function): not this branch's shader, the Rivet lane's exe logs it too. Effect on the burn char's rim not checked. Logs: `gtai-n10/tmp/world/{bake,export,exe_boot}_it20.log`.

No other work this session, by the common rule: the journal said QUEUE EMPTY and nothing had changed. The phase's "raise the weakest item" has nothing code can reach: the weakest item is the plan-pose art for 11 street classes and the contractor (REQUEST 3), and image generation is not this lane's to run.

QUEUE EMPTY: as at 03:40. Items 1, 2 and 4 done or reported as Calls (w-2, w-3, w-6); item 3 done for what code can reach, blocked on REQUEST 3 art. Exe built on the current code.

NEXT: If a sheet has arrived in `library/rounds/` or `library/deliveries/`: add the class to `StreetDead70.CLASSES` and `tools/art/dead_70.py`, film it, then re-run evidence, reels x3 and the export. Otherwise end at once. At the freeze rebuild the exe only if `git log 10ed4f51..HEAD -- project native tools` is non-empty (bake, then the export command in REPORT), and run `node tools/evidence/cites.mjs REPORT.md`.


---- session 03:44 (iteration 21, BUILD) ----
Read at open: tree clean at f55f54b6. No new file in `library/deliveries/` or `library/rounds/` since 17:54 on 11-08 (`find -newermt`); the only `corpse_*_70` sheets are still cop_patrol and ped_suit, both wired. No `REQUEST -> world` in the other lanes. No project, native or tools commit since 10ed4f51, so the exe from iteration 20 is still the current code. The freeze's citation check run early: `node tools/evidence/cites.mjs REPORT.md` 3 paths, 3 ok, exit 0.

QUEUE EMPTY: unchanged from 03:40. Items 1, 2 and 4 done or reported as Calls (w-2, w-3, w-6); item 3 done for what code can reach, blocked on REQUEST 3 art. No game code touched this session.

NEXT: As iteration 20. If a sheet has arrived in `library/rounds/` or `library/deliveries/`: add the class to `StreetDead70.CLASSES` and `tools/art/dead_70.py`, film it, then re-run evidence, reels x3, bake and export. Otherwise end at once; nothing is owed at the freeze unless `git log 10ed4f51..HEAD -- project native tools` is non-empty.
