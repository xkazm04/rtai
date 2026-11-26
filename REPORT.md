# REPORT - lane melee, run n31 (2026-11-25 night)

Branch `n31-melee`, worktree `gtai-wt/n23-street`, base `ba8e470b0`. Owner's notes served: 5 (melee passes
through, nothing happens; the space in which melee hurts), 6 (fatalities on advanced melee weapons; uneven impacts).
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n31\melee\` (`frames.json`, best first).

## Gate
`node tools/gate/run.mjs --rev=HEAD` on `ef6c95c2b` (05:36-05:53, melee slot, no reels): `gate: PASS;
build/gate/ef6c95c2b4af/gate.json` - lint 19 checks, unit 4434 passed / 0 failed / 2 skipped, scenarios 68,
parity bit-exact (planted mutation caught at step 629), selftest, release-compile 1010 / 0. Every commit after it
is docs/evidence/JOURNAL/REPORT only.

## What works

### Item 2: the blade hits what it is drawn crossing (`--melee-sweep`, ON by default)
- What a player now feels: **the cop the drawn blade crosses goes down, and a swing no longer kills a man
  standing beside you where nothing was drawn.**
- Rule: on main the hit was tested on one tick (the last windup tick) from Rivet's centre with the table cone;
  the blade was drawn cutting 2-6 ticks after it, so anyone it crossed later took nothing. Now the hit is tested
  on every tick the blade is drawn cutting, inside the sector the drawn blade crossed since the last tick, each
  enemy at most once per swing (`MeleeSweep`). Tested ticks per swing, main -> n31: claw 1 -> 7 (2..8), baton
  1 -> 7 (1..7), katana 1 -> 8 (4..11), plasma sword 1 -> 11 (5..15), chainsaw 1 -> until its first bite
  (then the grind re-tests as before).
- Reach to the victim's centre minus his radius (m), main -> n31: claw 1.4 -> 1.4, chainsaw 1.65 -> 1.65,
  baton 1.55 -> 2.2, katana 2.1 -> 2.25 (+ its 0.55 m lunge now arrives before contact: `sweep_lunge_ticks` 4),
  plasma sword 2.2 -> 2.2. Arc (whole sweep, deg) main cone -> drawn range: claw 120 -> 96 (-62..34),
  chainsaw 74 -> 68, baton 106 -> 95, katana 142 -> 120 (-100..20), plasma sword 203 -> 89 (-48..41).
- Owner's complaint as a number (pixel-measured drawn blade vs hit, 60 ring cells per weapon; in front of the aim
  +-90 deg, inside the cut): see `evidence/n31-melee/01-volumes/` and `02-sweep/volumes/`; plot
  `volumes_before_after.png` (masters). Baton and katana meet the bars (drawn-no-hit 0 in front); claw and plasma
  sword miss by one cell; the chainsaw by 4 (its swing-in before the cut).
- Guard rail (kills per swing, average bot, waves 1-4, seeds 1-5), main -> n31: claw 0.795 -> 0.872 (+9.7 %,
  paid back with recovery 13 -> 18 ticks), chainsaw 0.787 -> 0.886 (+12.6 %), baton 1.04 -> 1.17 (+12.9 %),
  katana 0.994 -> 1.073 (+7.9 %), plasma sword 1.238 -> 1.189 (-4.0 %). All inside +-15 %.
- Evidence: `beside_play_{katana,plasma_sword,claw}.mp4` (gauntlet, wheel controls, average bot, seed 7,
  32 px/m, tilt 70, 35 s, main | n31); the labelled polar sheet `volumes_before_after.png` carries the lab
  evidence. The 64 px/m slow clips with the hit sector were dropped from masters: the sector does not read in them.

### Item 3: fatalities where the owner plays (`--kill-feed`, ON by default)
- What a player now feels: **every melee kill ends in the weapon's own fatality - the chainsaw grinds every
  shieldless cop it kills, the katana and plasma sword split, the baton overloads, the claw rakes.**
- The signature-kill feed is installed in the gauntlet street and in quest 1 with the rig cast; `--gore=reduced`
  and `--kill-feed=off` turn it off. Proof (`evidence/n31-melee/03-fatal/table.md`, waves 1-4 x 5 weapons x seeds
  1-5): chainsaw on a shieldless human = `chainsaw_grind` 138/138 (100 %, bar 100 % over >= 40); every melee
  kill plays its weapon's row; riot cops: 21 saw kills all through the shield face -> `chainsaw_grind_riot_cop`.
- Frame cost (`evidence/n31-melee/03-fatal/feed-cost.md`, rendered d3d12 under the bench lock, chainsaw, seed 7,
  3600 ticks, 2 rounds): frame p50 4.57 -> 6.14 ms, p99 9.56 -> 12.09 ms; no frame over 25 ms that the off arm
  does not also show (bar PASS), so no grind cap. Draw calls 273 -> 918 p50: the fatality pieces left on the
  street are the cost, not the sim (sim loop p99 1.7 ms). A long wave stacks more pieces than this first minute:
  watch it.
- Films (gauntlet, average bot, seed 7, 32 px/m, tilt 70, 1920x1080, 35 s, cropped round Rivet; left main
  `--melee-sweep=off,--kill-feed=off`, right HEAD): `beside_fatal_chainsaw.mp4` (grind at 14 s, torn pieces at
  18 s), `beside_fatal_katana.mp4` (first split 18 s: blue halves and pools round Rivet, left whole bodies),
  `beside_fatal_plasma_sword.mp4` (16 s: burst pieces; left whole bodies); still `still_grind_chainsaw_64.png`.
  `beside_fatal_electro_baton.mp4` (re-shot after 04g: 12.9-13.5 s the struck cop stands in amber current,
  falls dark and smoking at 13.6 s; left a plain body on a pool), `beside_fatal_claw.mp4` (13 s: the cop at Rivet raked into torn pieces with red
  spray; left whole bodies).

- Baton overload raised (04g, view only): it was the weakest fatality (white-blue bolts for 20 ticks, then the
  sheet's 1 px cream lines, read as a pale grey cop). Now four amber current arcs run from the baton contact to
  head, hands and ground until he falls (`KillOverloadArcs`; `arc_n` 4, `arc_ticks` = the variant's fall tick + 3
  in `signature_kills.json`), with a 3-tick amber-white contact flash. Stills
  `still_overload_32_before_after.png` (masters) and both 32/64 px/m pairs in `evidence/n31-melee/03-fatal/`. Mutate 11/12 = 91.7 %.
  The figure under the arcs stays pale (the drawn jolt rows).

### Item 4: impacts of one quality (view only, no digest)
- What a player now feels: **a katana or plasma sword hit leaves a cut or a sear across the body, and the
  chainsaw bites and chatters on whatever it touches, not only in the kill.**
- Audit `evidence/n31-melee/04-impacts/` (14 weapons x human/robot/shield/kill, scored 0-3). Lifted: katana cut
  (ink + cream, red beads on a human, 9/4 px, 1.0 m), plasma sword sear (scorch palette), chainsaw bite (kerf +
  SawMarks burst held 36 ticks, kick 1 -> 2.5 px). Lifted in round 2 (04d), below.
- 04d: the plasma sear reads hot (cause: the FX print `look_d4_item.gdshader:72-96` snapped the white-hot core
  to cream, the ember->char blend to vermilion and the alpha glow to ink; now opaque ember strokes); a
  non-lethal melee hit on a robot throws white sparks that land as oil (`thug_hit`), the chainsaw on a riot
  shield sprays off the slab 5 times a second, the baton flicks an amber arc and the plasma sword an ember spit
  off the slab. Stills `evidence/n31-melee/04-impacts/after/d_*.png`.
- 04e: a pistol, machine pistol, gloria or gatling round that stops on a human throws a small red flick (3
  drops that land as specks; at most one per victim per 6 ticks, `gun_fx.json` `flick_gap_ticks`), on a robot
  white sparks that land as oil; a 2-tick cream hot point inside the ink burst. Stills
  `evidence/n31-melee/04-impacts/after/e_*.png` (the hot point reads at 64 px/m, barely at 32).
- Play takes (same fight frame for frame, only the marks differ; left = the audit commit `0f1e1ce95`, right =
  HEAD with `--melee-sweep=off,--kill-feed=off`): `beside_impacts_katana.mp4` (cuts at 15.2, 16.8, 30.6 s where
  main shows only the dust), `beside_impacts_plasma_sword.mp4` (12 sears, e.g. 15.2, 17.55, 27.6 s),
  `beside_impacts_chainsaw.mp4` (bite burst + one camera kick per bite at 15.4, 16.9, 18.65 s). Most bot strikes
  kill, so the marks show on the non-lethal hits.
- Audit sheet before | after at 64 px/m (`evidence/n31-melee/04-impacts/sheet_before_after.png`, masters
  `impacts_sheet_before_after.png`), scores hit human / robot / shield: katana 1/1/2 -> 2/2/2, plasma sword
  1/1/1 -> 2/2/2, chainsaw 1/0/1 -> 2/2/2, baton 2/2/1 -> 2/2/2, pistol and gatling 1/1/2 -> 2/1/2, claw 3/2/2
  (the reference) unchanged. Caveats: the 'human' cell is the riot guard; gun rows draw no victim at the stop.
- Mutate (`evidence/n31-melee/04-impacts/mutate.md`, `--max=20`, test subsets): `shield_sparks.gd` 11/19 =
  57.9 %, `gun_fx_wound.gd` 8/19 = 42.1 % (06b then pinned the early-out counts, robot/flesh counts, blocked blood
  throw and the zero-direction fallback in 10 tests; the Director's re-run at 06:02 after the gate, `--max=20 --tests=test_gun_fx_wound`, 463 s: `gun_fx_wound.gd`
  94.7 % = 18 / (18 + 1), invalid 1; the one survivor is the splash position `at * PX_PER_M` at :41, a view-only value); `shield_sparks.gd` 57.9 % -> 84.2 % = 16 / (16 + 3), invalid 1 (464 s, `--tests=test_shield_sparks_melee`;
  survivors: the early-out count at :64, the robot-vs-slab kind branch value at :77, the face offset at :103), `blade_marks.gd` 5.0 % = 1 / (1 + 19) (Director's full run at 06:11,
  `--max=20 --tests=test_blade_marks`, 345 s): the survivors are the cut and sear stroke geometry (offsets,
  widths, the 45 deg slant, alpha) that no headless test reads. Not fixed tonight (after the gate; tests are code).
- Ghost lane's NEED served: Ohm's and Kerf's deploy kills play `ohm_shock` / `kerf_split` (`also_weapons`),
  no digest moved (68 scenarios pass).

### Item 5: the amber print rule (a patch for the Director, core render)
- `evidence/n31-melee/05-amber/look_d4_item.patch` + `rule.md`: in `look_d4_item.gdshader` vermilion is kept only
  when the colour is nearer vermilion than the amber-ink segment; the dark ember mixes (t 0.30-0.35) now print
  amber instead of vermilion and the rim-to-ink half ink. Pure vermilion and Rivet's collar stay vermilion.
  Node mirror `tools/melee/amber_rule.mjs` + test 4/4. Not applied (core render is no lane's file); no still pair.

## What does not
- Enemy melee on Rivet (item 1/2 second half): measured (`evidence/n31-melee/01-foes/before/before.md`): no hit
  lands with Rivet's whole body past the drawn tip (body contact, fair), but 42 of 58 hits landed while he was
  walking sideways out of the tell (the aim locks at +-60 deg). Not changed: `foe_attacks.gd` is foes' file.
- The drawn reach depends on facing (katana 3.14 m drawn at facing 0, 1.91 m at 90); one reach per weapon.
- The 64 px/m slow clips with the hit sector drawn do not read (three calls: 02p4, 02p5; the stage's crowd
  covers the dummies, the sector is lost under the rigs). Stopped by decision; the polar sheet stands in.
- Nothing reaches 3/3 in the audit except the claw on a human; the light guns on a robot stay 1.
- `blade_marks.gd` (the katana cut and plasma sear marks) is barely tested: mutate 5.0 %, only its wiring is pinned.

## What blocked or slowed you
- Lane Godot lock self-deadlock (03p5 took the lock, then a tool that takes it itself): 27 min, two films lost.
- Lock interleave (a mutate builder took the lock between a film tool's per-run locks): ~15 min, claw fatality
  take lost.
- Lab slow clips with the live hit sector: three calls (02p4 part, 02p5 31 min bounced) and still unreadable.
- Shared tree: builders' live edits leaked into each other's films (21:52); one builder killed another lane's
  Godot after a timeout (22:14; the ghost lane was told at 22:15; every brief since prints CommandLine before a kill).
- Busy machine: blade_marks.gd mutate baseline took 261 s, the first run did not finish (re-run after the gate, 345 s).

## Calls for the owner
1. Plasma sword: with the sweep it no longer cuts sideways where nothing is drawn; damage taken per run 44.4 ->
   56.8 (+28 %), kills per swing -4 %. Keep (fair blade) or widen its drawn arc? Clip: `beside_play_plasma_sword.mp4`.
2. Every melee kill is now a fatality (100 % of 1200+ kills in the table). Frequency is your call; the lever is
   one value (a share or a cooldown for the non-chainsaw weapons; the chainsaw stays 100 % on shieldless humans).
3. Claw recovery 13 -> 18 ticks to pay back the sweep (+24 % kills/swing -> +9.7 %).
4. Hit windows and reaches above (item 2).
5. Enemy melee: a sidestep out of a baton or claw tell still gets hit (aim locked +-60 deg). Narrow it (foes'
   file) or keep it?

## Merge notes
- Code conflict with `n31-ground` (`git merge-tree`, 05:40): `project/tests/scenarios/scenario_prologue_pilot.gd`
  and `project/tests/unit/test_prologue_pump_tell.gd`. Both lanes re-pinned the prologue pilot digests and the
  seed-7 shotgun tick (melee 81b877a99: the bot's swept melee, shot 6205 -> 7674; ground 428511fc3: yard
  footprints). Neither side's numbers hold on the merged tree: take either side's code, then re-measure the
  LEGACY / LINE_FIRE_TICKS / RAISED_LINE_TICKS / COVER_SEED_7 / LINE_FIRE_SEED_7 pins and the shot tick on the
  merge (one scenario run + the unit test's failure message), with a dated decisions line. With foes and ghost
  only the root JOURNAL/REPORT add/add (keep each lane's own) and `tools/debt/baseline.json`
  (`node tools/debt/merge_baseline.mjs`).
- `project/features/gauntlet/gauntlet_session.gd`, `project/boot/collect_call/quest1_session.gd`: additive
  install lines for the kill feed (no lane owns them).
- Digests re-pinned deliberately: see the `DECISION melee n31 item 2` and `item 3` lines (quest1_input moved by
  the hit rule and by kill state; its script and lines unchanged; native parity unmoved).
- NEED director: `project/dev/gauntlet/gauntlet.gd` KNOWN_FLAGS "--gore", "--kill-feed"; `camera.json` a held
  low shake id for the grind.

## Next steps
1. Owner's verdict on the fatality frequency (call 2): if every kill is too much, a share or cooldown value.
2. Enemy melee tells (foes): unlock the aim at the strike or narrow it, so a sidestep out of a drawn swing is
   safe; then re-run `tools/melee/foe_reach.mjs` (the before is committed).
3. Apply the amber print patch (Director) and re-shoot the plasma sear still.
4. Make the drawn reach not depend on facing (katana 3.14 m at facing 0, 1.91 m at 90): a per-direction blade
   length in the swing view, or one reach clamp.
5. Raise the light guns on a robot (audit 1); the shotgun's kill row when it goes on the wheel (it is
   `enabled:false` today, so the player never meets it).
6. Repaint the baton overload's jolt rows (the body under the new amber arcs stays pale).
7. Pixel or stroke-list tests for `blade_marks.gd` (mutate 5.0 %, 19 survivors in the cut/sear stroke geometry).

## Builder ledger
29 calls (sonnet and opus Claude sub-agents), about 885 builder-minutes; 7 accepted whole, 21 accepted-partial,
1 bounced (code kept), 0 abandoned. Calls (minutes, verdict): 01a 38 ap, 01b 47 a, 02 30 ap, 01c 42 ap, 02p2 46 ap,
03 17 a, 01d 22 ap, 01e 10 ap, 03p2 25 a, 04a 5 a, 02p3 50 ap, 04b 39 ap, 04c 9 ap, 02p3b 30 a, 02p4 62 ap,
03p3 39 ap, 04d 21 ap, 04e 17 ap, 03p4 41 ap, 03p5 26 ap, 02p5 31 b, 03p6 35 ap, 04f 36 ap, 05 5 ap, 03p7 18 ap,
06 29 ap, 03p8 7 a, 04g 44 a, 06b 43 ap. Brief differently: say "blade pixels only, never the body" in the first measurement brief; one film
tool per lane at a time, alone on the lock; say in the brief which tools take the lock themselves; the short
one-point calls (04a, 04c, 05, 03) were the best value, the 50-60 min calls all ended partial.
