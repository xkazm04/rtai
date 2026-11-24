# JOURNAL lane melee (n27, 2026-11-24)

Branch `n27-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, cut from `main` `a3b3f1466`.
Continues `docs/day/2026-11-23/n26-melee/`. Builder: Claude Sonnet 5.5 via `gtai-n27/tools/builder.mjs`.

- 02:45 MILESTONE session 1 start. Read n26 REPORT, briefs, decisions tail. No `NEED melee` in other lanes' journals;
  keys has not posted `MILESTONE keys-order` yet (needed before any film with the HUD strip).
- 02:46 DECISION plan: call m1 = items 1+2 (master_at 30, per_boss_cut 3, mastery free behind `bond.mastery_free`,
  ten-seed table in two arms `pace` / `free`); m2 = item 3 films entries + films (bond film, charged-claw take);
  m3 = item 5 ring render test + item 4 if time.
- 02:46 DECISION free mastery: the draw stays as is (reserved slot, same RNG); taking `master_*` applies at once and the
  rest stays open for one normal pick among the other cards. Alternative (a fourth card) rejected: it changes the draw.
- 02:46 BUILDER RUNNING m1-mastery since 02:46 (pid 80724, brief `evidence/briefs/n27-melee-01-mastery.md`, hard stop 03:55).
- 02:57 REVIEW m1 part A `58a1b8d07` (master_at 30, per_boss_cut 3, `release_boss_cuts` on the strike, a killing cut
  counts as a kill only): read the diff, sound. TOUCH keys `project/features/souls/ghost_deploy.gd:54` (one line, the
  record call gains `strike.release_boss_cuts`) -> merge note for the Director.
- 03:12 REVIEW m1 part B `1a6badfc8`: `bond.mastery_free` true; `GauntletDraw.take` returns the rest of the hand after a
  free mastery, the rest stays open (manual picks get `pick_offered` again with the remaining cards); draw and RNG untouched;
  each free mastery is its own `run.picks` entry (schema allows no extra field). Bot unchanged (it already takes master_*
  first and then picks again). Integration + unit tests added. Accepted pending part C and the scenario line.
- 03:15 keys posted MILESTONE keys-order e1c4b73d9 (deploy_slots in ghost_forms.json). Merge it after m1 ends, before m2 films.
- 03:51 BUILDER m1-mastery 65 min $1.65 accepted. Commits `58a1b8d07` (A), `1a6badfc8` (B), `6522ce667` (table).
  Unit 4097 passed 0 failed (1 FLAKY test_audio_driving, passed alone); scenarios 68 passed; tapes did not move.
  TOUCH `gauntlet_waves.gd` (`choose()`, 3 lines; gauntlet rest code, melee owns it tonight). Mutate on ghost_bond.gd
  timed out at 900 s (no score) -> redo in m3. NEED (not raised further): `gauntlet_run.schema.json` allows no extra pick
  field, so a free mastery is its own `run.picks` entry.
- 03:51 MILESTONE mastery table `evidence/n27/bond/mastery.md`: n26 6/10 (2,4,4,8,8,8) -> n27 pace 4/10 (3,3,4,8) ->
  free 4/10 (3,3,4,8); in band 8..15: 3 -> 1 -> 1. Kerf never mastered (28/30 on seed 5, boss cuts 4). Raising the bar
  does not move the early Tonnage masteries (waves 3-4): it only drops the late ones. Builder's single-value estimate:
  master_at 22 -> three firsts at 8, 8, 9 (not re-run). Call for the owner.
- 03:55 MILESTONE merged keys `e1c4b73d9` -> `4a3ff4b04` (conflict in ghost_forms.json `doc` only, resolved by hand:
  keys' text + the bond sentences; lint 19/19 on the hook). Tests of both lanes re-run as m2's step 0.
- 03:55 BUILDER RUNNING m2-films since 03:55 (pid 29208, brief `evidence/briefs/n27-melee-02-films.md`, hard stop 05:00).
  Next brief ready: `evidence/briefs/n27-melee-03-ring-tests.md` (item 5; add times + the ghost_bond mutate redo).
NEXT: wait for m2 (check `gtai-n27/logs/melee/builder.lock`); review its films frame by frame (ffprobe, 4 frames each);
  then m3 ring tests + ghost_bond mutate; then item 4 (thug/gunner wreck art, discharge arcs). Mastery-pace call for
  the owner: early Tonnage is the problem, not the bar; consider a per-form value only as an owner call (no tuning tonight).
  Commit last work by 08:00, gate by 08:15.
- 04:06 session 1 end. BUILDER RUNNING m2-films since 03:55 (pid 29208, lock held; it has staged
  `tools/film/owner_take.gd`, `owner_takes.mjs`, `evidence/n27/films/films.md`: the claw_shock take, not yet committed).
  Commit beside it only with a pathspec (`git commit -- JOURNAL.md`).
NEXT: (same as 03:55) review m2 at its end (~05:00): films in `C:/Users/kazda/kiro/gtai-masters/n27/melee/`, ffprobe +
  4 frames each, frames.json; then launch m3 (`evidence/briefs/n27-melee-03-ring-tests.md`, add times and a
  `ghost_bond.gd` mutate with `--max=20 --tests=test_ghost_bond,test_ghost_boss_cut` and a 25 min budget).
- 04:08 MILESTONE session 2 start. m2 still running (pid 29208). Reviewed film 2 `films/claw_shock_robots.mp4` (1920x1080 60 fps 27.2 s): 8 frames + crops; thug t106, thug t356, gunner t606, shield t856/t956, war machine stunned only (never_finish). Discharge reads; white branched strokes at 64 px/m still look like glyphs (item 4). Accepted. No `NEED melee` in other journals. Wrote `evidence/briefs/n27-melee-04-wreck-arcs.md` (item 4: wrecks from each robot's live rig art, so cast's thug/gunner redraw carries over; arcs as current).
- 04:08 DECISION item 4 wrecks: built from the victim's own live rig textures, no generated images (cast redraws gunner A and thug A tonight on its branch; a fixed new texture would be stale at the merge). Alternative (generated wreck sheets) rejected: IMAGES 0/15 stays.
- 04:54 BUILDER m2-films 58 min $2.05 accepted. Commits `def638f6e` (bond_film entry, `dev_loc` debt rise accepted),
  `465e93e21`, `437733281` (films log). Film 1 `films/bond_mastery.mp4` ffprobe `1920,1080,60/1,28.82`: reviewed 14
  frames + chip crops: Tonnage's teal ring closes (24/30 -> full by tick 1765), rest screen held 2.5 s with Master
  Tonnage / +10 % Health repair / Ohm, the mastery card leaves (hand 3 -> 2), Ohm taken, wave 3, T at tick 2884 into the
  teal Tonnage slam. HUD strip shows 1 Dent 2 Tonnage 3 Kerf 4 Ohm. DEFECT: the Master Tonnage card has a blank picture
  band (`project/dev/gauntlet/gauntlet_pick_card.gd` has no `mastery` branch) -> part C of m4 (TOUCH pressure's dir,
  one file, no other lane touched it: checked `git log a3b3f1466..n27-<lane>`).
- 04:54 BUILDER RUNNING m3-ring-tests since 04:54 (Start-Process pid 61536, hard stop 05:56, brief
  `evidence/briefs/n27-melee-03-ring-tests.md` + ghost_bond mutate redo).
- 04:56 m4 brief extended: C mastery card picture first (+ re-render bond film/offer still, old ones kept as before),
  then B arcs, then A wrecks. Times placeholders LAUNCH/COMMIT1/COMMIT2/HARDSTOP to fill at launch.
- 05:29 REVIEW m3 so far: `9249226c6` ring `plan()` -> command list, `_draw` replays it (no pixel change intended;
  4 chips x <=5 dicts per redraw, fine for the HUD); tests pin every command; `01273d2a8` zero-threshold guard test.
  Mutate ring 2/18 -> 16/19 (`evidence/n27/ring/mutate-ring-{before,after}.txt`). Pixel proof + ghost_bond mutate
  still running. Note: `_replay`'s own draw calls are not covered by the plan tests: check the survivors list.
- 05:30 session 2 end. BUILDER RUNNING m3-ring-tests since 04:54 (pid 61536, hard stop 05:56).
NEXT: (1) when `gtai-n27/logs/melee/builder.lock` is gone: read `evidence/briefs/n27-melee-03-ring-tests.out.txt` tail,
  check the pixel diff = 0 under `evidence/n27/ring/`, the ghost_bond mutate score, log `BUILDER m3-ring-tests ...`.
  (2) launch m4: fill LAUNCH/COMMIT1 (+25)/COMMIT2 (+45)/HARDSTOP (+70, never later than 07:50) in
  `evidence/briefs/n27-melee-04-wreck-arcs.md`, commit it, Start-Process detached (tag `m4-wreck-arcs`, out to
  `evidence/briefs/n27-melee-04-wreck-arcs.out.txt`). (3) review C first: new bond film must show the mastery card with
  the ghost + full ring; then B arcs, A wrecks stills. (4) last new work committed by 08:00, final gate
  `node tools/gate/run.mjs --rev=HEAD` started by 08:15, then REPORT (mastery table n26 vs n27, both films, calls:
  mastery pace (early Tonnage at waves 3-4; master_at 22 estimate), Master card art, war machine only stunned).
- 05:31 MILESTONE session 3 start. m3-ring-tests still running (pid 61536 node, lock held, hard stop 05:56). No `NEED melee` in other journals.
- 05:42 BUILDER m3-ring-tests 48 min $1.00 accepted. Commits `9249226c6`, `01273d2a8`, `1d12de3f6` (pixel proof: 3 frames
  at 64 px/m md5-identical before/after the plan split), `084772279`, `eb49f67f6`. Ring mutate 2/18 -> 16/19 (then a test
  for the two line-27 survivors; the third survivor, antialias in `_replay`, is pixel-only). ghost_bond.gd mutate 18/20
  (one equivalent, one gap fixed by a new test; line 59 re-run 4/4). No pixel test: GUT is headless/dummy renderer.
- 05:42 FRICTION `test_ghost_form_hud.test_deploy_hint_follows_the_rebound_key` fails on HEAD (120 vs 249.2): keys'
  test, fixed on n27-keys by `3f2bb5c2e`; clears at merge. Keys also has `403a31a8f` (larger chip numbers): merge n27-keys
  again before any re-film with the HUD strip if time allows.
- 05:43 BUILDER RUNNING m4-wreck-arcs since 05:43 (Start-Process pid 46808, brief `evidence/briefs/n27-melee-04-wreck-arcs.md`,
  C by 06:10, B by 06:30, hard stop 06:55).
- 05:58 REVIEW m4 part C `42f8c948f`: `mastery` cards mount the ghost figure (shared `_mount_ghost` with `ghost`) and draw a full teal ring + crown diamond from GhostBondRing constants; unit test `test_gauntlet_pick_card.gd`. Accepted pending the re-rendered film/still.
- 06:24 REVIEW m4 C film: `films/bond_mastery.mp4` re-rendered 06:02 (ffprobe `1920,1080,60/1,28.82`); frame at 16.5-17 s: Master Tonnage card shows the Tonnage figure inside a full teal ring with the teal crown diamond; the ring's lower edge touches the title text (minor). `stills/bond_offer_64.png` NOT yet re-rendered (same bytes as the blankcard copy) -> follow-up if m4 does not.
- 06:29 REVIEW m4 B `34c12865c`: new `ElectricArc` (hash of born serial, slot, tick/3; no RNG; held under reduced motion; screen-pixel widths core 2 / mid 4.5 / halo 9 amber; 5 kinks, 1-2 forks); every `_arc` of `ElectricWreckFx` goes through it; `test_electric_arc.gd` pins re-jag cadence. Code accepted; after still + claw film pending. A (wrecks) uncommitted in electric_chassis.gd / electric_wreck_fx.gd.
- 06:35 REVIEW m4 A `013c156db`: thug/gunner wrecks copy the live rig's torso + head sprites (found by texture in the
  kill's body copy; fallback fit_core); test `test_robot_wreck_plates.gd`. Stills `wreck_thug_vs_gunner_{before,after}_64.png`:
  the plates are now each robot's own grey torso/visor (before: shield plate + turret head on both); thug and gunner still
  differ mainly by the weapon because both use ThugPlan art today; cast's redraw carries over at merge. Accepted.
- 06:35 FINDING B: `claw_arcs_{before,after}_64.png` are identical in panels 1-2: the cream ink-rimmed glyphs are
  `ShockJolt._spark` (`project/features/combat/react/shock_jolt.gd:97`, melee code from n26, untouched by any lane tonight),
  not the wreck arcs. DECISION: restyle `_spark` (core + amber halo, no ink rim) with `--ink-sparks` = before; brief
  `evidence/briefs/n27-melee-05-sparks.md` (also re-renders `bond_offer_64.png`, still the blank-card image, and the claw film).
- 06:56 BUILDER m4-wreck-arcs 72 min $3.49 accepted. Commits `42f8c948f` (C card picture), `34c12865c` (B ElectricArc),
  `013c156db` (A own plates), `5f74fc4eb` (`electro_gun_wrecks` take), `43f19f9ab` (notes). Films: `films/bond_mastery.mp4`
  (`1920,1080,60/1,28.82`, card with figure), `films/claw_shock_robots.mp4` (`27.2 s`), `films/electro_gun_wrecks.mp4`
  (`1920,1080,60/1,18.0`: gun kills thug t106, thug t318, gunner t530). Mutate electric_chassis.gd 7/20 (plate geometry
  unpinned). quick.mjs parse check FAIL on electric_wreck_fx.gd ("same on HEAD", to verify). bond_offer_64.png not re-cropped.
- 06:56 BUILDER RUNNING m5-sparks since 06:56 (Start-Process pid 34052, brief `evidence/briefs/n27-melee-05-sparks.md`:
  A-C `_spark` restyle + `--ink-sparks` + tests by 07:25, D stills by 07:40, E films, F parse check + plate tests; hard stop 07:55).
- 06:57 session 3 end.
NEXT: (1) review m5 at its commits (07:25 code: read diff; stills `claw_sparks_after_64.png`, `ohm_stun_sparks_{before,after}_64.png`,
  `bond_offer_64.png` must show the card picture); log `BUILDER m5-sparks ...`. (2) last new work committed by 08:00; if m5
  leaves the spark code broken or ugly, revert by flag value (`ink_rim` default true) via a short `--resume` call, not by hand.
  (3) final gate `node tools/gate/run.mjs --rev=HEAD` started by 08:15 (one Godot per lane: only after m5 ends), then
  `--reels` once after 09:30 freeze. (4) REPORT.md is drafted: fill the M4_*/GATE_LINE placeholders (m4: card picture, arcs,
  wrecks share ThugPlan art -> differ by weapon only; electro_gun_wrecks film; spark call; electric_chassis mutate; ledger m4
  72 min $3.49, m5), run `node tools/evidence/cites.mjs REPORT.md`, commit. Check frames.json has 8-15 entries, best first.
- 06:57 MILESTONE session 4 start. m5-sparks running (pid 34052 node alive, lock held, hard stop 07:55). No `NEED melee` in other journals.
- 07:25 REVIEW m5 A-C `518810786` (07:20, on time): `ShockJolt.spark_plan()` default = ink alpha 0.3 9 px under-halo + amber 0.18 9 px + amber 0.5 4.5 px + core 2 px (screen px, from `ElectricArc.strokes`); `--ink-sparks` = ink 6 + cream 2.5; `test_shock_spark.gd` 4 tests. Code accepted; stills pending.
- 07:44 REVIEW m5 D stills: `ohm_stun_sparks_{before,after}_64.png`: on the stunned cop the zig-zags change as briefed (before ink-rimmed cream, after cream core in an amber glow). But the cream star/hand glyphs with ink rims are the SAME in both, and `claw_sparks_after_64.png` panels 1-2 equal `claw_arcs_after_64.png`. FINDING: those are drawn atlas cells, not strokes: `WeaponFxElectro.stun` draws `fx_atlas.png` `spark` cells (`project/features/combat/weapons/art/weapon_fx_electro.gd:40`) and `chain` draws the `arc` cell with an 8-way ink outline (`ink_under`, ARC_INK_DIRS 8). Drawn art, outside this lane's files and past the 08:00 last-work line: Call for the owner (redraw the atlas spark/arc cells in the halo look, or keep the comic ink glyphs).
- 07:55 BUILDER m5-sparks 58 min $1.29 accepted. Commits `518810786` (spark restyle, `--ink-sparks`), `022e72dde` (stills notes, same finding as 07:44: glyphs are `WeaponFxElectro.stun` atlas cells, NEED weapons), `c24e5c03a` (spark plan pinned), `21756bc1d` (wreck plate width/z/cap pinned), `2d1dfef56` (mutate notes). Mutate shock_jolt spark lines 2/3; electric_chassis 7/20 -> 12/20. Unit full run 4122 pass, 0 fail (1 flaky audio radio, passed on re-run). Quick gate committed with `--no-godot`: check.mjs isolated-load cascade via characters/rig_clips.gd also hits untouched react_pose.gd -> pre-existing. `bond_offer_64.png` re-rendered with the card picture (looked: ring touches the title, minor). claw_shock_robots.mp4 re-rendered 27.2 s; frames.json 13 entries.
- 07:56 DECISION no further keys merge: the full unit run is green without `3f2bb5c2e`; the Director merges keys whole.
- 07:56 GATE start `node tools/gate/run.mjs --rev=HEAD`.
