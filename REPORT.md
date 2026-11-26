# n31 lane `ground`: feet on the floor, a floor that stays put, props that say whether they block

Branch `n31-ground` (worktree `gtai-wt/n23-controls`), cut from `main` `ba8e470b0`. Run n31, 2026-11-25 21:00 to 2026-11-26 08:00.
Owner notes served: a (bounce, flying shadow), 4 (prologue surface layer moves with the player), 3 (what blocks).
Director: Opus (this session); builders: Claude sub-agents (sonnet / opus), briefs under `evidence/briefs/n31-*.md`. IMAGES 0/25 (no art generated: every fix was code or data).
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n31\ground\` (`frames.json` best first; per-item folders `item1` to `item4`).

## What works

### Item 1: Rivet stays on the floor and his shadow sits under his soles
- **Cause.** The bob table's helmet tops are in 110-space px, but `RivetBob.stretch` divided by the native recut's cell (1.5x taller), so the stretch delivered 2/3 of what it took back and the card lift carried the rest: the N flight frame dipped 7 px and lifted 8.6 px. The contact ellipse stayed at the rig's ground point while the card lifted.
- **Fix.** `72703154f` bob rule (each row aims at its mean figure height, stretch 0.92..1.12 about the planted feet, lift capped `lift_max_cell` 2.2), `2f143d1e1` the shadow answers a lift (radius and ring alpha shrink per hip of lift). Decisions line `docs/decisions.md` (ground n31 rivet lift).
- **Tool.** `tools/ground/lift/lift.py` + `capture.mjs` (probe `project/dev/ground_n31/lift_probe.gd`): per delivered frame helmet top, lowest sole, shadow centre, 8 directions x 80 ticks, 32 and 64 px/m. Tables `evidence/n31-ground/lift_before.md`, `evidence/n31-ground/lift_after.md`.
- **Numbers (32 px/m, p70, every row):** helmet travel per stride 4-8 -> **1-3 px**; sole lift max up to 8 -> **1.0 px** (planted 0.0-0.11); shadow-to-sole gap all frames max 9.5 -> **2.5 px**, planted 1.5-2.5; shadow rx vs lift correlation -1.0 on every lifting row (it shrinks as he rises). Lab still `item1/lift_N_64.png`: soles 17.3 px over the disc -> 3.0 px.
- **Play take.** Gauntlet `--pick-view`, wheel controls, average bot, seed 7, ticks 0-2400, main | HEAD: `item1/gauntlet_side_32.mp4`, `item1/gauntlet_side_64.mp4` (16.7 s), sprint tour 8 octants `item1/sprint_tour_p70_32.mp4` (24 s); crops `item1/pair_W_2080_64.png`, `item1/pair_E_1330_64.png`. In play HEAD's helmet sits 1.05-1.55 px lower on average at 32 px/m (5-7 px at the lift peaks), `evidence/n31-ground/item1_take.md`.
- **Contact shadow ink (item 1 c).** `f1689bf31`: `ContactInk.RINGS` (8 soft rings, about 0.70 effective alpha at the core, outer 1.25 @ 0.08), `CONTACT_R_HIPS` 0.5 -> 0.62, slide 0.05 -> 0.08, shared by Rivet, cops, card foes, crowd and kill cells. Measured in the delivered 32 px/m gauntlet take, one rule for both arms (`tools/ground/contact_ink.py --free`, `evidence/n31-ground/contact_ink.md`): core darkening vs floor median 46.3 -> **51.7 %** (main already passed the 35 % bar: the shadow was dimmer and smaller, not invisible), skirt step on clear floor 7.1 -> **4.2 %/px** (bar < 6, main failed it on 3 of 4 ticks: a harder rim), cop at tick 320 41.5 -> 51.6 %. Clip `item1/contact_ink_side_32.mp4` (20 s, main | HEAD), stills `item1/contact_ink_32_main_head.png`, `item1/contact_ink_64_main_head.png`.
- **What a player feels:** Rivet no longer hops off the ground on the run and his shadow stays under his boots and shrinks when a stride lifts him, so he reads less floaty; the remaining hop is a foot drawn in the air mid-stride (art).

### Item 2: the same for enemies
- **Tool.** `tools/ground/lift/foes.py` + `foes_capture.mjs` (probe `project/dev/ground_n31/foe_lift_probe.tscn`): 96 rows at 32 px/m, `evidence/n31-ground/foe_lift_before.md`, `evidence/n31-ground/foe_lift_after.md`.
- **Card foes share one contact shadow** (`33192b087`, `card_contact_shadow.gd`, gunner, thug, turret, shield): the gunner's shadow no longer rides the card: shadow y range 22 -> 1.0 px, shadow/head correlation 0.999 -> 0.28, planted gap 1.5 -> 1.0 px.
- **Street cops' placement:** `fe5712271` land mid-stance, `e3393e180` `SHIFT_ACROSS_TRAVEL` (N planted sole vs disc 3.2..15.6 -> -0.1..1.2 px), `258f6f6ef` `HOLD_TOE_OFF` (side-on head pump: patrol 8 -> 1 px, riot 5 -> 1 px at 32 px/m), `830858c2d` `GLIDE_NO_STEP` on: walk columns whose drawings make no forward step (S, N, three-quarter) follow the sim point instead of holding a boot and hopping (probe head travel 10-36 -> 1.4-2.9 px; boot slide 22-33 px a stance, too small to see at 32 px/m). Lever `StreetPatrolPose.GLIDE_SHARE` (1.0 glide, 0.0 lock).
- **Play take.** `item2/gauntlet_cops_glide_side_32.mp4` (lock | glide, seed 7, 24.5 s), `item2/gauntlet_cops_side_32.mp4`, `item2/gauntlet_cards_side_32.mp4`, `item2/group_walkin_32_lock_glide.png`; notes `evidence/n31-ground/item2_take.md`.
- **What a player feels:** cops walking toward the camera now move on smoothly instead of holding and hopping, and the card robots' shadows stay on the floor under them instead of riding up with the card.

### Item 3: the prologue's surface stays on the floor
- **Cause (measured, `b9cc3321f`):** the print shaders read `FRAGCOORD.xy + world_px`; FRAGCOORD is in render px, `world_px` was in logical px, and the game's `canvas_items`/`expand` stretch (s = 1.35 in the prologue window) made the whole print (halftone, grime, tooth, actor dots, light hatch, FX dither) slide at 1 - 1/s of the floor. Every film path turned the stretch off, so no earlier take showed it.
- **Fix:** `fbe6abf03` `PrintStage` and `CityView` compute `world_px` and the camera snap in render px; `b94e64c0e` `PartMaterials.set_world_px` on the prologue/gauntlet path (actors' dots were stuck at 0,0).
- **Numbers:** print vs floor over a 5.5 s sprint pan, prologue play: 32 px/m 386 -> **0.000 px**, 64 px/m 773 -> **0.000 px**; gauntlet 548 -> 0.0002 px; quest 1 city 207 -> 0.0003 px; actors' dots vs floor print 1617 -> 0 px. `evidence/n31-ground/item3_take.md`, `evidence/n31-ground/prologue_drift_before.md`.
- **Play take:** `item3/prologue_side_32.mp4` (prologue from the yard, stretch on, main | HEAD), `item3/prologue_still64_main_ba8e470b0.png` | `item3/prologue_still64_head.png`.
- **What a player feels:** when Rivet runs across the yard the grime, halftone and his own print dots stay glued to the ground and to him instead of sliding along with the camera.

### Item 4: what blocks, and where
- **Audit (before, `main`):** `tools/ground/props/audit.mjs`, `yard_structures.mjs`, `strip_cards.mjs`: 128 props, 56 solid; yard: six conveyor boxes 0.56-0.79 m north of their drawn machines, art 1.5-1.7 m wider per side, arches/spans 4.3-8.7 m wide blocking nothing; gauntlet tilt70 strip cards 12 of 17 solids off > 0.25 m; 29 standing decoratives. Shots: all three solid classes stop bullets. `evidence/n31-ground/prop_audit_before.md`, `evidence/n31-ground/prop_audit_strip.md`, `evidence/n31-ground/prop_audit_shots.md`.
- **Rule (one, learned once):** everything that blocks stands on a dark contact base the size of its collision footprint (`PropBase`, south-dense); nothing passable has one; overhead spans cast an offset floor shadow and have no base. Decisions lines (ground n31 what blocks, yard footprints, prop base).
- **Base softened (`e1c54b29a`, render-only):** the first base (alpha 0.86, 0.08 m rim) read as a black floor tile under the forklift and a pit under the press. It is now a contact shade: alpha 0.66, north share 0.45, rim 0.30 m centred on the footprint edge, so the visible edge stays within 0.15 m of the collision. Measured on the one prop with a clean south edge (yard fridge, 64 px/m): darkening vs the floor 72.7 -> 68.5 % (still a base), edge step 27.7 -> 12.8 per px. The other props have the art outline inside the measuring window, so they are unmeasured (`evidence/n31-ground/base_soft.md`). Stills `item4/base_soft_yard_64_before_after.png`, `item4/base_soft_gauntlet_64_before_after.png`. Re-shot on the soft base by n31-31 (`e09bbbc16`): `item4/prop_walk_{yard,gauntlet}_64_stop.png` and `item4/prop_walk_yard_32.mp4` now show HEAD as it draws, with stop_m identical to n31-24 (collision unchanged); `item4/prop_walk_gauntlet_32.mp4` re-shot by the director on `88bc88996` (22.6 s, stop_m identical).
- **Fix:** `92eab0a1a` PropBase in the yard and the gauntlet (replaces the hatched slab), `428511fc3` yard footprints on the drawn base (yard solids off > 0.25 m 7 -> **0**), `10c770a63` gauntlet cover cards undistorted on their box (strip 12 -> **5**).
- **Play take (Rivet driven by the real move actions into 15 props, main `ba8e470b0` | HEAD, `tools/ground/prop_take.mjs`, `evidence/n31-ground/prop_take_after.md`, before `evidence/n31-ground/prop_take_before.md`).** Bar: he stops with his 0.6 m body at the edge the player sees (|stop - 0.6| <= 0.25 m; against the dark base where one is drawn). Yard **4/8 -> 6/8**: conveyor from S 0.04 -> 0.60 m (half his body was inside the machine art), from E -0.92 -> 0.37 (he stood 0.9 m deep in the belt), fuel_vessel invisible wall 1.07 -> 0.61; still failing: conveyor_turn from W 0.31 (a leg, 0.04 m outside the bar) and belt_feed along 0.52 (a lane under the span, open on main, now closed by a support the rule made solid). Gauntlet **1/5 -> 5/5** against the dark base (kiosk and stalls stop at the pad edge, 0.60); against the art itself he still stops 1.5-2.05 m short of the stall wheels and the kiosk post: in the gauntlet the collision got drawn, the art did not move.
- **Films and stills:** `item4/prop_walk_yard_32.mp4` (24.0 s), `item4/prop_walk_gauntlet_32.mp4` (22.6 s), `item4/prop_walk_yard_64_stop.png`, `item4/prop_walk_gauntlet_64_stop.png` (main | HEAD), rule stills `item4/rule_yard_64_before_after.png`, `item4/rule_gauntlet_64_before_after.png`, `item4/rule_audit_sheet_after.png`.
- **What a player feels:** walking into a yard conveyor, a fridge stack or a market stall, Rivet now stops where the machine is drawn or where the dark pad under it ends, instead of sinking into the art or hitting an invisible wall a metre or two early; anything without a pad (spans, arches' tops, debris) he walks under or over.

## What does not
- Rivet's remaining hop at 32 px/m is drawn (run cells with a foot in the air): the code change is 1-2 px on screen; a full "planted" look needs an art pass on the run rows.
- Cops' S/N/diagonal walk columns have no forward step in the drawing; the glide hides the hop but the boots skate (22-33 px a stance in the probe, not measured in play).
- Gauntlet: 5 cover cards (kiosk_plaza#2, market_stalls#3-6) still stand on a post or wheels 2.7-9x narrower than their box; the dark base shows the box, the art does not fill it. Collision rects in the gauntlet did not move (by design); the base now draws them.
- Yard: `press_carcass` (2.5 x 3.7 m footprint under a thin arm) and the forklift keep footprints larger than their drawing. The softened base (`e1c54b29a`) no longer reads as a black tile, but it still shows that the box is bigger than the art. The real fix is a footprint trim, which is a collision change and needs a pilot re-pin, so it is left for the next run. The item 4 play takes were not re-filmed on the soft base.
- n30-yard readability bars (patrol blue >= 65 %, rifle >= 95, pellet >= 90; `evidence/yard30/decals_over.md`) were NOT re-measured on HEAD: the method needs two overlay projects with day and dusk captures (about 40 min of the lane's single Godot) and did not fit beside the final gates. Unmeasured, not passed. Expected risk is low but real: the footprints do not touch colour or light, but the new dark PropBase pads sit next to where cops walk in the yard.
- The softened base is faint at 32 px/m in the gauntlet (a grey shade under the stall; `item4/prop_walk_gauntlet_32.mp4` around 9 s). There the upright card carries most of the "this blocks" read and the base mostly confirms the footprint. If play shows the cue is lost, raise `PropBase.TINT` alpha (0.66 -> 0.75) before reverting the soft rim: one value, my call.
- Mutate: `rivet_bob.gd` 52.6 % (10/19), `rig_cast_shadows.gd` 50.0 % (6/12), `evidence/n31-ground/mutate.md`; survivors unpinned; `street_patrol_pose.gd`, `print_stage.gd`, `prop_base.gd` not run.

## What blocked or slowed you
- Film paths turn the window stretch off, so the item 3 drift was invisible in every take until n31-07 measured with the stretch on (about 30 min).
- play_take snapshots carry an `override.cfg` (1920x1080 viewport); a plain snapshot has none -> 1.3x scale mismatch (n31-05, two reruns, ~15 min).
- `quick.mjs` Godot parse step printed 622 "Failed to compile depended scripts" lines with no root error (n31-01, n31-03; ~10 min each).
- Builders dying at the session stop with uncommitted work (n31-13, n31-22): each cost a finishing call (~10 min of review each).
- Stale lane locks from dead builders (3 times, a few minutes each).
- The first final gate (`7b73c0d20`, 04:45) went red on selftest only (world lock "swims" 64-67 %, goldens 0/11) because our own `tools/ground/prop_take.mjs` had left project/override.cfg (window 1920x1080) in the live tree at 03:40 and the gate snapshot copied it: the selftest rendered under a 1.35 stretch. Not a product regression: without the file the selftest is green on the same code (world lock 0.00 %, goldens 11/11 worst 2.06; n31-29). Fixed in the tool (n31-30) and re-gated. About 25 min.

## Calls for the owner
1. **Prologue difficulty after the honest yard footprints.** The yard's solids now match the drawing (conveyor boxes on the machines, arch supports solid), which changes the cops' routes and shot lines. Scripted pilot, 5 seeds, main | HEAD (`evidence/n31-ground/prologue_difficulty.md`): deaths 2 | 4 (3 of HEAD's in the hands fight), median lowest hp in the hands fight 28 | 20, 42 % more ticks in the hands fight; median end tick 11940 | 11730. The deaths move between seeds (main dies on 3 and 42, HEAD on 7 and 11), and the seed spread (0-3 deaths) is larger than the gap. Keep (current), or ease the hands fight (a cop count or damage number, foes' or the owner's call)? Clip: `item4/prop_walk_yard_32.mp4` (what moved).
   Found on the way (pre-existing, not caused by n31): after a beat-two death replay, the beat-two opening line holds Mulroney's HUD row while a recurring order fires, so that order's words are not shown for their reading time. `test_prologue_dialogue` now runs a seed without a death replay (decisions line); the replay case is untested. Fix the row priority (orders over a replayed opening line) or accept?
2. **Foe glide vs lock** on no-step walk columns: glide on (smooth, small boot skate) vs lock (planted boots, hop). One value `StreetPatrolPose.GLIDE_SHARE`. Clip `item2/gauntlet_cops_glide_side_32.mp4`.
3. **Gauntlet cover cards on narrow bases** (stalls, kiosk): accept the dark base as the cue, or redraw/regenerate those five props to fill their box (art), or shrink the collision to the drawn base (a balance change to cover).

## Merge notes
- Foes' optional prologue_moves.patch (in the foes worktree, under evidence/n31/foes/) (yard patrol TRAVEL/FIGHT gait) is NOT applied here: foes' gait was still changing at 03:23 and the prologue pilots already moved once tonight on the yard footprints; applying it needs the prologue pilot re-pinned once more (`--foe-moves=legacy` keeps main).
- Digests moved deliberately: the prologue pilot / arched_line pins and the seed-7 shotgun tick (yard footprints, `428511fc3`, decisions line). The quest 1 script, owner's lines, native city sim and its parity digest did not move.
- `test_prologue_dialogue` recurring-orders test re-pinned seed 7 -> a seed without a death replay (item 4 moved seed 7's fight; decisions line).
- `JOURNAL.md` / `REPORT.md` add/add conflicts: keep each lane's own.
- Before gating the merge: make sure the donor worktree has no stray project/override.cfg (git-excluded, so `git status` does not show it). `tools/lib/snapshot.mjs` copies it into every gate snapshot, and a 1920x1080 window override turns the selftest red (frames under a 1.35 stretch). Tonight's ground tools leaked one; fixed in n31-30.

## Next steps
- Art pass on Rivet's run rows (a foot on the floor in every planted frame) and the cops' S/N walk columns (a forward step), the only way past the code limits above.
- Pin the mutate survivors; mutate `street_patrol_pose.gd`, `print_stage.gd`, `prop_base.gd`.
- Rivet's span shadow as a cast silhouette (item 5, not started).

## Builder ledger
| call | model | minutes | verdict |
|---|---|---|---|
| n31-01 lift-tool | opus | 60 | accepted |
| n31-02 play-take | sonnet | 27 | accepted |
| n31-03 lift-fix | opus | 43 | accepted |
| n31-04 foe-lift | sonnet | 24 | accepted (partial: 32 px/m only) |
| n31-05 item1-take | sonnet | 57 | accepted |
| n31-06 foe-shadow | opus | 38 | accepted |
| n31-07 prologue-drift | opus | 32 | accepted |
| n31-09 foe-placement | opus | 32 | accepted (partial) |
| n31-10 foe-finish | opus | 34 | accepted |
| n31-11 item2-take | sonnet | 23 | accepted (partial) |
| n31-12 print-stretch | opus | 32 | accepted |
| n31-13 foe-glide | opus | ~15 | died at the session stop; numbers committed, code finished by n31-15 |
| n31-14 item3-short | sonnet | 3 | accepted |
| n31-15 glide-finish | opus | 34 | accepted |
| n31-16 item3-take | sonnet | 48 | accepted |
| n31-17 prop-audit | sonnet | 11 | accepted (partial) |
| n31-18 prop-audit-b | sonnet | 9 | accepted |
| n31-19 prop-rule | opus | 58 | accepted (partial: strip 12 -> 5) |
| n31-20 mutate-tidy | sonnet | 19 | accepted |
| n31-21 prop-take | sonnet | 46 | accepted |
| n31-22 contact-ink | sonnet | ~40 | died at the session stop uncommitted; finished by n31-25 |
| n31-23 pilot-stall | opus | ~28 | accepted |
| n31-24 prop-take-final | sonnet | 53 | accepted |
| n31-25 contact-ink-finish | sonnet | 26 | accepted |
| n31-26 prologue-difficulty | sonnet | 36 | accepted (step 0 left red, as briefed) |
| n31-27 dialogue-repin | sonnet | 3 | accepted |
| n31-28 base-soft | sonnet | 36 | accepted (one clean measurement; needed a resume nudge after its background stills) |
| n31-29 selftest-lock | opus | 4 | accepted (diagnosis only: no product change, selftest green without the leaked override) |
| n31-30 override-leak | sonnet | 4 | accepted |
| n31-31 soft-stops | sonnet | 21 | accepted (evidence only; gauntlet 32 px/m film not re-shot) |

What I would brief differently: (1) every brief ends with "commit before the session stop" stated as a wall-clock time that is at least 15 min before MY session ends; two builders (n31-13, n31-22) died with uncommitted work because their END was after my stop. (2) Name the measurement box rule in the brief (n31-22 measured before and after at different boxes; n31-25 had to redo it). (3) A footprint change gets the full unit suite in the same call, not only its mapped tests: the red `test_prologue_dialogue` surfaced two calls later. (4) Check the premise number on main first (contact ink: main already passed the darkening bar). Short calls (10-35 min, one point each) were again the best value. (5) A tool that writes into a tree it was handed must restore it: a 1-line side effect (`override.cfg` left in the live tree) cost a red final gate.

## Gate
`node tools/gate/run.mjs --rev=HEAD` on `88bc88996` (ground slot, started 05:24, no `--reels`): `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n23-controls\build\gate\88bc88996d2f\gate.json`.
- PASS lint: all 19 checks pass over 2326 GDScript files
- PASS unit-tests: 4391 passed, 0 failed, 2 skipped
- PASS scenario-tests: 68 passed
- PASS parity: native == GDScript reference bit for bit over 1200 steps; planted mutation caught at step 629
- PASS selftest: D4 city frames ok (32 px/m 100 actors 114 colours; 48 px/m 85 / 111); look goldens 11/11 within mean 4 (worst 2.06)
- PASS export-audit: release-compile 1008 loaded, 0 failed

The first gate (`7b73c0d20`, 04:45) failed selftest only, because of the leaked window override (see What blocked). Commits after `88bc88996` are evidence, JOURNAL and REPORT only (inert paths).
