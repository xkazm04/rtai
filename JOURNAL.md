# n15-combat JOURNAL

Lane combat, night n15 (2026-11-10 22:00 to 2026-11-11 08:00). Branch `n15-combat`, cut from main `5c5c03611`.
APPDATA for every Godot run: `C:/Users/kazda/kiro/gtai-n15/appdata/combat`.

## Session 1 (iteration 1, 21:58-23:28)

- 21:58 read: brief, common rules, AGENTS.md, tools/README.md, n11 combat REPORT "What does not work",
  last 30 decisions lines. Reply file `gtai-assets/replies/n15-combat.md` is empty (c-2 redraw not yet in).
  No other lane's journal names combat yet.
- FRICTION 22:05: ran the look goldens through `tools/dev/run.mjs` (headless): wrong, headless renders
  nothing. Killed my tree by PID (94744). Re-ran as `node tools/selftest/run.mjs` (windowed, the evidence
  path) for the baseline.
- Registry rules applied: (filled per decision below)
- BASELINE 22:30 (look goldens on the fresh worktree, main 5c5c03611 code with int-day's DLLs, `node tools/selftest/run.mjs`,
  log `build/selftest-baseline.log`): look goldens 11/11 within mean 4 (worst 0.00); block goldens 5/5 (worst 0.69);
  world lock holds; accents on doctrine. So the n14 "worst 0.69" is the BLOCK site and is present on main's code here.
- MILESTONE 22:40 `13a74d4dd` item 2: SWAT hit v4 + elder hit v3 packed (`street_hit.py VERSIONS`, one scale per kind,
  boot-bottom alignment, shift-in instead of bleed). FILL re-measured (swat 1.36, elder 1.20). Both filmed
  before/after at t341-348, 64 px/m: SWAT's carbine now continuous into the fall; elder thrown hard. Shipped.
- FRICTION: re-running `street_hit.py` re-packs 4 shipped burn sheets differently (hood, punk, swat, thug): the
  library's `burn/1_*` cells were re-keyed at 07:02, after n11's 06:58 pack. Restored them with `git checkout`; the
  flail item (next) has to pack frame 1 and 1b from the same (07:02) cells anyway.
- FRICTION / REQUEST tools: `node tools/film/compare.mjs` refuses `--victim=<kind>` ("bad argument"), and
  `film.mjs` refuses it after `--` ("give --victim before the --"), so a lone-victim before/after cannot go through
  compare. I filmed the before by putting the parent's sheet (via `git lfs smudge`) and FILL back for one film, then
  `git checkout --`. REQUEST tools: compare.mjs passes `--victim` through to both sides.
- Registry: no design fork taken yet beyond "ship only what reads better" (brief); judged on film.
- MILESTONE 23:18 `709321330` item 2 (burn flail): `street_hit.py FLAILS` packs `burn/1b` for the 8 BURNS kinds as
  `p70/<kind>_flail_burn_hit.png` (each facing at its `burn/1` cell's scale); `StreetWalkerHit.flail_frame` swaps
  on odd half shakes when `FLAIL_FRAMES` is true. Shipped OFF: not filmed yet. Unit test_street_walker_burn +
  test_street_walker_hit 22/22. CAVEAT: the shipped frame-1 burn sheets for hood, punk, swat and thug were packed
  from the pre-07:02 library cells; the 1b frames are scaled to the 07:02 frame-1 cells. Film both (and the
  repacked frame 1, `python tools/art/street_hit.py` re-makes them) before turning the flag on.
- Gates this session: quick + pre-commit lint on every commit; unit select only. Full unit / scenarios / evidence /
  reels NOT run yet on this branch.

NEXT: (1) film a burning patrol cop and SWAT with FLAIL_FRAMES true vs false (flamethrower or molotov victim,
`film.mjs weapon:flamethrower --victim=...`, 32 + 64 px/m, a 10-40 s clip); keep frame 1 as shipped or repack it
from the 07:02 cells, decide, record DECISION. (2) check `gtai-assets/replies/n15-combat.md` for the c-2 redraw
(item 1, first priority when it lands). (3) item 2 rest: drawn charred cells for a fire death, contractor/cultist
cells (`street_reactions_it321.md`), `dropped_weapons_it325.md`. (4) item 3 baton strike re-cut, etc.
(5) DEFECTS.md #3 (dark streak across the victim t345-348) and #4. (6) run the full gates
(`node tools/gate/run.mjs --rev=HEAD --reels`) once there is a batch. Keep REQUEST tools (compare --victim) open.

## Session 2 (iteration 2, 22:13-)

- 22:13 read JOURNAL, git log. (Session 1's clock stamps ran ahead of the wall clock; commits say 22:02-22:12.)
  Reply file `gtai-assets/replies/n15-combat.md` still empty: no c-2 redraw yet.
- MILESTONE 22:22 `261669f02` item 2: FLAIL_FRAMES ON. Filmed flamethrower lone kill, cop/head_cap and cop/head_swat,
  64 px/m t380-420 (fire 341, kill 542; victim is fighter id 1, not the probe's first "hostile"): arms alternate on the
  odd half shakes (394-398, 414-418), no size seam vs frame 1, also on SWAT (older frame-1 pack). Frame 1 kept as
  packed. Clip 32 px/m in masters. DECISION combat/burn-flail-2.
- MILESTONE 22:40 `b8da0a47f` items 2+3: the navy cop pistol (it325 cell 1, `dropped_gun.py --cop`, part
  `dropped_cop`) drawn by ShockArcsView; `--dropped-gun=pale` the before. Filmed electro_gun stun 64 + 32 px/m.
  DECISION combat/dropped-cop-pistol. Owner Call (it was an open n14 call).
- FRICTION: `GODOT_BIN` is not set in a fresh Bash; export it before a raw `--import`.
- MILESTONE 22:28 `42c826289` + `108ec888c` item 3: p55 baton strike cells re-cut (act_k 1.0; wind-up sheet_k 0.2632).
  compare HEAD~1 vs HEAD, chapter electro_baton --view=tilt t54-70: no more shrink into the swing. DECISION
  rivet/baton-p55-strike-size. (Registry not consulted: a size-match fix, no design fork.)
- MILESTONE 22:42 `a76c26f9a` + `6486e5e59` item 3: the baton's drawn left strike (it334) at p70/p55, one cell past the
  left wind-up; `--rivet-left-strike=off` the before. First cut hid the held part and a stale RivetSwipe wedge lingered
  t90-104: fixed by counting the strike as "left" in hides_held. DECISION rivet/baton-left-strike.
- Films of a director extra chapter: `film.mjs chapter:electro_baton -- --chapter=electro_baton_left` (ArenaArgs: last
  value wins; the log line `director chapter electro_baton_left` proves it). REQUEST tools: film.mjs/compare.mjs
  should list ReelChapters.extras() (`<blade>_left`, `<blade>_cam`) as chapters.
- DEFECTS.md: session-2 films added; top open = the game melee smear's flat white hexagon slab.
- MILESTONE 22:49 `1ede2ce03` + `9d564d282` ITEM 1 (c-2): the reply (it350) says the walk-camera redraws were drawn
  this morning for n11 and never taken. VERSIONS for 9 kinds (patrol, cap, hat, jogger, shopper v2; suit, punk, hood v3;
  thug v4 B), FILL re-measured (all down, 1.02-1.27), test floor 1.1 -> 1.0. Before = `film.mjs --tree` on compare's
  kept b8da0a47f checkout (same hit sheets as the parent): patrol, suit, thug, punk at 64 px/m t338-350, the seam gone.
  Restored the 4 burn sheets the re-run re-packs (hood, punk, swat, thug). DECISION combat/c-2-hit-walk-camera.
- MILESTONE 22:54 `07bb047cf` item 3: body-hit ink disc 0.12 m (was 0.22), `--body-ink=n7` the before.
- MILESTONE 23:03 `5bdad7a0c` item 3: dev arena lights age out: `PrintStage.light_tick` (core/render/print_stage.gd,
  a shared core file: the hero lane does not list it) set by `ArenaCombatLights.attach` for a clockless stage.
  First cut grew arena_rigs.gd past the debt baseline (294 -> 296): moved the hookup into attach.
- Films with feel ON: `film.mjs ... --lock=off` (shots.mjs drops `--feel=off` only then; `HitFeel.feel_flag` takes the
  FIRST `--feel=`, so a trailing `-- --feel=on` does not work). REQUEST tools: a `--feel=on` film flag.
- 23:04 full gates started on 5bdad7a0c: `node tools/gate/run.mjs --rev=HEAD --reels` -> build/gate/5bdad7a0c*/.
- To the asset lane (your it350 question): the shot men in n11 `hit_scale_ab.png` are the HOOD and the PATROL COP;
  both now ship their walk-camera redraws (`1ede2ce03`, c-2 done for all 9 offered kinds). No new REQUEST from c-2.
- 23:06 WIP (not committed yet, unverified): `project/dev/bosses/boss_blade_bot.gd` (BossBladeBot, `--bot=boss
  --boss=king --loadout=pistol --boss-blade=<weapon>`), hooked by `BossBladeBot.wrap(bot, args)` in
  `arena_game.gd _boss_bot` (same line count: arena_game.gd is at 299). Needs: a film, then a commit with
  `node tools/debt/debt.mjs --update --accept-regression="n15 blade boss bot (owner call), dev_loc +55"`.
  Godot is reserved by the gate run, so not filmed yet.
- GATES 23:20 on `5bdad7a0c` (`node tools/gate/run.mjs --rev=HEAD --reels`, log build/gate_5bdad7a0c.log): PASS lint (16/16),
  PASS unit 2502 passed / 0 failed / 2 skipped, PASS scenarios 55, PASS parity bit-exact (mutation caught at 629),
  PASS selftest (look goldens 11/11 worst 0.00; block goldens 5/5 worst 0.69 = the session-1 baseline, unchanged),
  PASS export-audit (667 loaded). Reel gate still running at session end: read build/gate/5bdad7a0c26d/ (reels.log, gate.json).
  Debt ratchet: ok on 5bdad7a0c (lint's debt-ratchet check passed).
- Perf of the new warmed art (baton left strike, 2 small PNGs; dropped_cop 64 px): NOT measured (no fight_gate run).

NEXT (session 3):
(1) Read build/gate/5bdad7a0c26d/gate.json (full gates on 5bdad7a0c incl. reels; see the gate line above). Fix any red first.
(2) Blade boss bot WIP (uncommitted: project/dev/bosses/boss_blade_bot.gd + the one-line arena_game.gd hook): parse check
    (`node tools/godot/check.mjs res://dev/bosses/boss_blade_bot.gd`), then film
    `node tools/film/film.mjs arena --lock=off --ppm=32 --view=tilt --out=build/film/bossblade -- --bot=boss --boss=king --boss-blade=katana`
    (check the log for "blade bot: katana taken" and that the bot flag wins: ArenaArgs last-wins, the arena shot passes --bot itself);
    if it swings at King, commit with `node tools/debt/debt.mjs --update --accept-regression="n15 blade boss bot (owner call), dev_loc +55"`,
    film the p55 wind-ups in that fight; else delete the WIP.
(3) Item 3 offers: blade LEFT sets (katana, plasma sword, chainsaw): left strips it338 (preview of katana p70 cut looks clean:
    build/baton/katana_left_preview.png), left strike it342, left wind-up/follow it346. Needs: a LEFT_DRAWN list so two-handed
    blades take `rivet_eq_<w>_left.png` (today only ONE_HAND), rivet_frames.json `_left` rows (p70 katana/chainsaw fig_h 165 +
    RivetRes.X15 entries), rivet_windup_cells rows (`_left` wind-up, `_left_strike` as the baton). Ship only if the film beats the mirror.
(4) Item 2 rest: contractor/cultist hit/burn/death cells (street_reactions_it321.md; contractor is StreetQuestCards: card + DOWN only,
    so hit/burn need a new path), the drawn charred cells for a fire death.
(5) Item 4: rocket gib in pieces at combo; impacts by surface + casings; flame jet clip; vehicle shadows.
(6) DEFECTS top open: the game melee smear's flat white hexagon (MeleeSmearView, a baton swing sweeps ~300 deg in 3-4 ticks
    so the fan wraps Rivet as a ring); the body-hit burst lands ~0.5 m off the drawn thrown-back card; lone victims of every kind
    drop the brown rifle.
(7) Perf: RivetStripWarm now also warms the baton left strike (2 small PNGs); judge with tools/perf/fight_gate.mjs vs its A/A.
REQUEST tools (open): compare.mjs passes --victim through; film/compare list ReelChapters.extras() chapters; a film flag for feel ON.
- PASS reels on 5bdad7a0c: the whole gate passes (`build/gate/5bdad7a0c26d/gate.json`).
- MILESTONE 23:29 the blade boss bot committed (see the commit after this line): parse ok, filmed King + katana in tilt, swings
  from t300; debt baseline raised with --accept-regression (dev_loc +55). NEXT item (2) is now: film 64 px/m close-ups of
  the p55 katana/plasma sword/baton/chainsaw wind-ups inside it (`--boss-blade=<w>`; --lock=off follows Rivet).
- 23:31 masters frames.json at 15 (dropped the elder v3 and the SWAT flail still from masters; both stay in evidence/n15-combat/).
  Session 2 ends here; NEXT above stands, with (2) already half done (bot committed b6443d22e, wind-up close-ups to film).

## Session 3 (iteration 3, 23:30-)

- 23:30 read JOURNAL, git log, the replies file (no new section since it350). Gate on 5bdad7a0c was PASS incl. reels.
- MILESTONE boss-blade film: `film.mjs arena --lock=off --ppm=64 --view=tilt --ticks=420 --stills=300-340 -- --bot=boss
  --boss=king --boss-blade=katana` (log: "blade bot: katana taken"): the p55 katana wind-ups (t309-311, t319-322) and
  strikes in a real King fight, `evidence/n15-combat/boss_blade_katana_p55_64ppm_t306-326.png` (masters too, replacing
  the 32 px/m sheet). Defect: t308, one upright frame between follow-through and the next wind-up (DEFECTS).
- MILESTONE `15c8abbcc` item 3 (n14 open call): katana, plasma sword and chainsaw turned left take their drawn left set
  (it338 strip, it346 wind-up, it342/it346 strike) at p70 and p55. `RivetWindup.BLADE_LEFT`/`left_drawn` (moved out of
  rivet_strips.gd: that file is at the 200-line ratchet). The drawn left strike shows straight left only (blade_drawn);
  the left diagonals keep the drawn left facing under the game arc. k per blade by the helmet dome (one k for wind-up and
  strike, p55 x1.3 by eye as it346 asks; p55 chainsaw x1.15 more). Board `evidence/n15-combat/blade_left_set_cells_board.png`.
  Films 64 px/m, director extra chapters `<blade>_left`, before `--rivet-blade-left=off`, same build, same ticks: all three
  beat the mirror (he faces the cop, hose arm near; the mirror turned his back). DECISION rivet/blade-left-set.
  The it346 follow-through cells are not used (the strike cell holds the recovery, as the baton's).
- FRICTION: `run_unit.mjs --select=test_quest_blade` fails `test_dock_hint_names_the_blade_key_only_with_a_blade`
  ("[weapon_slot_2]" not "[2]"): the InputMap is empty in a narrowed run (order dependence: another test registers the
  actions). Not my change; the full run decides. REQUEST tools: make test_quest_blade register the input actions itself.
- FRICTION: the lint function-size count includes the NEXT function's doc comment (cast_flags apply 40 -> 41 from a third
  doc line on `_windup`).
- 23:44 full gates started on 15c8abbcc: `node tools/gate/run.mjs --rev=HEAD --reels` -> build/gate_15c8abbcc.log.
- 23:50 stopped the 15c8abbcc gate (it held this lane's one Godot slot for 30+ min and blocked every film); its snapshot
  removed. Gates run once on the last commit instead (below).
- MILESTONE `9f966271e` (+ `96206efc4` uid) item 5, DEFECTS top open: the melee smear unwraps its angles, caps the fan at
  150 deg back from the newest, 6 deg chords. The baton's ~300 deg sweep over 4 kept angles with 5 chords per step drew
  the flat white hexagon ring. Film: chapter electro_baton_left 32 px/m, before `--melee-smear=n7`: one crescent, no ring.
  DECISION combat/melee-smear-span.
- MILESTONE `324927f99` item 4: the rocket gib at combo flies in six pieces cut from the victim's drawn card
  (`GibCardCut`: head band 0.30, torso between 0.30-wide arm strips to 0.62, leg halves; placed where the card drew
  them, flip mirrored). Before `--gib-card=whole` = one tumbling body (the card in one group, hidden rig parts empty).
  Film: weapon:rocket_launcher --victim=cop/head_cap 48 px/m fire 333 kill 347. Straight cut edges (paper-cut); drawn gib
  pieces per kind would be better: no REQUEST yet (judge first). DECISION combat/gib-card-pieces.
- Item 4 flame jet FILMED (not changed): chapter flamethrower combo 32 px/m t48-192,
  `evidence/n15-combat/flame_jet_sustained_combo_32ppm_t48-192.png`. The teardrop chain is the owner's look-14 pick (kept).
  New defect: the ground fire stacks into a tall red starburst column beside the cop (DEFECTS).
- Item 4 vehicle shadows: NOT JUDGED. The city shot's only car is cut by the frame edge. Needs a shot with traffic.
- MILESTONE `54297457d` item 5 city street fight film (`film.mjs city` 32 px/m, 1200 ticks): the range-target rings on
  the road (empty where down) read as debug; the city draws none now, `--target-rings=on` the before. FRICTION: the
  same `city` shot with `--ticks=620` frames a different block from `--ticks=1200` (lock auto), so a before/after pair
  must keep --ticks equal. DECISION arena/city-target-rings.
- Perf of tonight's new art (blade left sets: 18 small PNGs warmed by RivetStripWarm; GibCardCut: 6 sprites per gib
  instead of 1): NOT MEASURED (no fight_gate run; the machine is contended and the gate holds Godot).
- 00:05 full gates started on 54297457d (`node tools/gate/run.mjs --rev=HEAD --reels`, log build/gate_54297457d.log,
  build/gate/54297457d8d5/).
- Item 2 scoping (no code): the cultist has no fighter in the game (`grep -ri "cultist\|kronk" project/features
  project/data/tables` finds nothing), so its it321 cells have no target tonight. The contractor (quest 1, CastView via
  `StreetQuestCards.draw_guard`) draws a facing card, a walk and a fall/corpse only: its hit stagger (v2 A), flinches
  and 5 death poses need a new hit state in `draw_guard` (street_quest_cards.gd is at 200 lines: a new
  `StreetQuestHit` file), packed by street_hit.py like the street kinds.
- GATES 00:29 on `54297457d` (`node tools/gate/run.mjs --rev=HEAD --reels`, build/gate/54297457d8d5/gate.json): PASS lint 16/16,
  PASS unit 2512 passed / 0 failed / 2 skipped (test_quest_blade passes in the full run: the --select red was order
  dependence), PASS scenarios 55, PASS parity bit-exact (mutation caught at 629), PASS selftest (look goldens 11/11 worst
  0.00; block goldens 5/5 worst 0.69 = the session-1 baseline), PASS export-audit (668 loaded), PASS reels. The commits
  after it (d4e361a5c, 5b9724927 and the evidence commit below) are docs/evidence only.
- 00:35 p55 film of the drawn left set in the King fight (before `--rivet-blade-left=off`, same build, t306-326 64 px/m):
  `evidence/n15-combat/boss_katana_left_set_p55_ab_64ppm_t306-326.png`. He faces King, hose near, at his facing's size;
  the mirror swapped arms and drew the wind-up/strike ~1.4x his facing. New defect: the p55 katana's RIGHT wind-up and
  strike cells pop ~1.4x (as the baton did before 42c826289).

NEXT (session 4):
(1) Item 2 contractor (quest 1): new `StreetQuestHit` for `StreetQuestCards.draw_guard`: the hit stagger v2 (A) on a
    non-lethal hit, the 5 drawn death poses (contractor_death_70_cells) in place of the fall frame; pack with
    street_hit.py (a contractor SHEETS row with no blue tone). Film quest1 (`film.mjs quest1 --stills=...`) before/after.
    Cultist: no fighter in the game, skip.
(2) DEFECTS: p55 katana right wind-up/strike size pop (re-cut act_k as the baton's, film with --boss-blade=katana);
    the t308 one upright frame between swings; the body burst stays at the world stop point while the body flies
    (carry the victim in GunFx.impacts); the flame jet's red starburst column of floor fire.
(3) Item 4 vehicle shadows: needs a shot with traffic in frame (city shot has none in view): find a dev scene with cars
    (`node tools/dev/run.mjs` list) or ask tools for a `--lock=at:<x,y>` on a road.
(4) Perf: the new warmed strips (18 blade-left PNGs) and GibCardCut (6 sprites per gib): fight_gate A/A when the machine
    is quiet (blade left: `--arms=off:--rivet-blade-left=off,on:` on a blade scene).
(5) Then loop item 5: film arena + city, rank, fix the top one.
REQUEST tools (open): compare.mjs --victim; film/compare list ReelChapters.extras(); a film flag for feel ON;
test_quest_blade registers its own input actions (fails under --select).
- 00:40 item 4 vehicle shadows JUDGED: `node tools/dev/run.mjs res://dev/showcase/city_frame.tscn --windowed -- --out=<abs>
  --view=combo --zooms=1,2 --foci=0,1,2` (verdict line: ok exit 0; SCRIPT ERROR 0; unknown arg 0): the parked car's
  hatched cast runs down-right with the props'. No defect. `evidence/n15-combat/vehicle_shadows_combo_64_32ppm.png`.
  Call candidate (not changed, n13/n14 kept as built): the p55 katana's right wind-up/strike cells draw ~1.4x his facing.
- 00:37 session 3 ends. Godot: none of mine running (checked by command line; the rest are third-life and the tools
  lane's accent audit). Masters `gtai-masters/n15/combat/frames.json` 15 entries, every file referenced, none missing.
  Calls to carry into REPORT: (a) p55 katana right wind-up/strike ~1.4x his facing (n13/n14 kept as built; the left
  set is at his size); (b) the rocket gib's paper-cut pieces vs drawn gib pieces per kind (asset lane); (c) the t308
  between-swings frame is likely the equipped strip's REST cell (o 1-3, not aiming): hold the facing instead?
  NEXT stands as written above.

## Session 4 (iteration 4, 00:35-02:05)

- 00:36 read JOURNAL, DEFECTS, git log, replies (no new section since it350), tools JOURNAL (all combat REQUESTs served on n15-tools; not merged here: the Director merges).
- 00:40 p55 katana right wind-up/strike pop: measured the cut strips (visor and helmet crops, `build/k55/heads.png`): the
  strip cells are within ~1.1-1.3x of the facings by eye, not a clean number; n13/n14 are kept as built, so NOT changed:
  stays a Call for the owner (a) with the session-3 film `evidence/n15-combat/boss_blade_katana_p55_64ppm_t306-326.png`.
- MILESTONE `302a0d670` item 2 contractor (quest 1): `StreetQuestHit` draws the it321 hit stagger v2 (A) for 20 ticks
  after a living blow and the first 10 ticks of a death (then the plan dead's lying pose). Packed by street_hit.py
  (`contractor` SHEETS + VERSIONS v2), sized off the standing card (CELL_K 1.063 from the two 70 sheets' one scale).
  Film quest1 combo 48 px/m, before `--quest-hit=off`, same build, t13708-13726:
  `evidence/n15-combat/contractor_hit_stagger_ab_48ppm_x2_t13708-13726.png` (card -> thrown back, at the card's size,
  no pop -> lying). In t13600-13838 every hit was a kill (10-tick diffs only), so the living hold is unfilmed.
  Not taken: gut/shoulder flinches (no wound-site signal on the cast view), 5 death poses (the plan dead draw 5 already),
  burn cells (no burn on the dock contractors' path). Cultist: no fighter in the game. DECISION combat/contractor-stagger.
- FRICTION: `street_hit.py` repacks every kind; 4 burn grids (hood, punk, swat, thug) come out different bytes from HEAD
  (restored with git checkout). The packer is not byte-stable against the committed burn sheets.
- FRICTION: two quest1 films of the same build differ by ~250k px at t13708 when the stills list starts at a different
  tick (13600 vs 13708): the camera's state depends on the first still. A/B pairs must use the same --stills list.
- MILESTONE `19e7768ff` item 4 impacts by surface: a round in the ground draws the it317 drawn concrete dust
  (`GunFxImpactCells`, `tools/art/impact_cells.py`), chips back toward the shooter. Film weapon:machine_pistol 48 px/m
  t352-363, before `--impact-fx=shapes`: `evidence/n15-combat/impact_dust_drawn_ab_48ppm_x3_t352-363.png`.
  Tried and NOT shipped: the metal-spark cell on Rivet's plating (city t363 at 3 m debug size: the FX layer is under the
  rigs, the cell hid under him; only its rim showed). Metal (crates): no round on metal filmed, so not taken yet.
  DECISION combat/impact-dust-drawn. Casings: GunFx already drops shells (not changed tonight).
- 01:08 masters frames.json: the contractor stagger and the impact dust added at the top; dropped the p55 baton left
  strike and the c-2 suit (still in evidence/). 15 entries, none unreferenced, none missing (checked by script).
- Item 5 body burst (DEFECTS c-2 #3) scoped, not fixed: the drift is the death's view-only rig carry
  (HumanReact.slide / last_carry), not the sim; GunFx.shield_test shows the wiring path (a Callable on GunFx set by
  ReactLink), but react_link.gd is at 288 lines and GunFx has no fighter id per impact. Fix path: impact_who +
  GunFx.body_off Callable(id) -> rig carry, drawn in GunFxArt.draw_over.
- PERF 01:15 `node tools/perf/fight_gate.mjs "--arms=now:,before:--rivet-blade-left=off --rivet-left-strike=off
  --gib-card=whole --target-rings=on --body-ink=n7 --quest-hit=off" --rounds=4 --out=build/perf/fg_s4` (bench.lock held
  by this lane, noclobber, deleted after; the export was built from the worktree at ~01:08, 19e7768ff or its parent).
  city (reel ch 18): before - now p50 -0.46 [-1.88,+1.93] ms, p99 -0.58 [-2.87,+3.31], cpu -0.78 s: all WASH; A/A floor
  p50 +0.09 [-0.61,+0.97]. horde (Gatling): p50 -0.20 [-0.72,+0.68], p99 +0.71 [-0.38,+2.57], cpu +0.10: all WASH.
  0 frames over 25 ms in any arm; 21 of 24 runs CONTENDED. Verdict: tonight's befores vs nows are inside the noise on
  both scenes (the warmed blade-left strips do not appear in these scenes' frames: a load-time cost, not measured).
- 01:17 full gates started on 896c5c30d (`node tools/gate/run.mjs --rev=HEAD --reels`, log build/gate_896c5c30d.log,
  results build/gate/896c5c30d*/); code since the last PASS: 302a0d670 (contractor stagger), 19e7768ff (impact dust).

NEXT (session 5):
(1) Read build/gate/896c5c30d*/gate.json (log build/gate_896c5c30d.log; gates on 896c5c30d incl. reels). A moved look
    golden is most likely quest 1 (the contractor stagger) or a ground impact (the drawn dust): look at the frame,
    re-bless only that golden with a dated decisions.md line naming the item. Fix any red first.
(2) Item 2 charred cells (cop patrol only, B: library `cop_patrol_hit_70_cells/char/{1,2}_{c}.png` standing,
    `char_lying/1_{1..5}.png` lying; faint cyan smoke traces: desaturate them, teal is souls only). Path found: the
    burn signature kill (`KillStyles.parts` -> GibCut copies the rig's sprites, keeping `head_card` by name, texture,
    hframes/frame, flip) -> `KillStyles.take` -> `KillCharFx.add` puts the char shader on every sprite. Plan: pack
    `p70/cop_patrol_char_hit.png` with street_hit.py (a CHARS site like FLAILS, each facing at its burn/1 scale);
    in `KillStyles.parts` for style burn tag the BODY group with the rig's head row (RigHeadCard key); in
    `KillCharFx.add` swap that group's `head_card` to the char grid (hframes 5, frame = the card's facing, flip kept,
    scale so the figure matches StreetWalkerHit's burn FILL) and leave the char shader off it. Flag `--char-cells=off`.
    Film: weapon:flamethrower --victim=cop/head_cap 64 px/m around the kill (session 2 film ticks), before/after.
(3) Metal impacts: the it317 metal-spark cell (`fx_impacts_70_cells_rim/1_1.png`) is ready; needs a shot where a round
    hits metal (dev arena metal range targets: `ArenaTargets.metal_points`), then add it to GunFxImpactCells.FILES
    and impact_cells.py CELLS.
(4) DEFECTS: body burst drift (fix path in the 01:08 line), the contractor's living hold film, the t62 white stick in
    the katana kill (likely the dropped rifle's flight), the flame jet's floor-fire column shape.
(5) REPORT.md is drafted (commit 896c5c30d): fill the gate line, the perf line (fight_gate WASH, 01:15), new rows.
REQUEST tools (open, served on n15-tools, not merged here): none new.
- 01:35 WIP (UNCOMMITTED, on purpose: not wired, not filmed): NEXT (2) started. `tools/art/street_hit.py` gains
  `CHARS = {"cop_patrol": "char/1"}` (each facing at its burn/1 scale, as FLAILS) and `grey_cyan` (hue 165-205, sat >
  0.03 -> its grey: the stripped smoke's teal traces); it packs `p70/cop_patrol_char_hit.png` (untracked; no .import
  yet). Re-running the packer still drifts the 4 burn grids (hood 2 px, punk 428, swat 62, thug 8 px differ > 2/255):
  restore them with `git checkout -- project/features/characters/art/view/p70/{ped_hood,ped_punk,swat,thug}_burn_hit.png`.
  Sizing for the swap: StreetWalkerCards.place draws a hit grid at s = HEIGHT_BY_ART * PX_PER_M * k * FILL / tex_h with
  offset (-cell.x/2, -cell.y*FOOT_Y); use FILL["cop_patrol_burn_hit.png"] (1.14). GibCut copies the card with
  `transform = xf` (rig-relative), so the swap must rebuild the copy's scale from that, not keep the old card's.
- REQUEST assets: drawn gib pieces for the patrol cop (`cop_patrol`, 70 walk camera, keyed): head with cap, torso,
  two arms, two legs, each a separate sprite with a torn (not straight) edge and no blood beyond the edge, one set.
  Why: the rocket gib now flies in six pieces cut straight across the drawn card (`GibCardCut`, commit 324927f99),
  which reads as paper cut-outs (`evidence/n15-combat/rocket_gib_card_pieces_ab_48ppm_x1.5_t347-372.png`).
- REQUEST assets: charred standing cells like `cop_patrol_hit_70_cells/char/` (it272, B) for `thug`, `ped_hood` and
  `cop_riot` (the kinds the flamethrower most often kills in the reel), same layout `{1,2}_{c}.png`, no smoke (it keyed
  to teal last time). Why: a fire death is brutality's char shader over the card; only the patrol cop has drawn cells.
- REQUEST assets: the contractor's hit stagger (`contractor_hit_70_cells/v2/1_{1..5}.png`) with the long dock carbine
  his card holds, not the short gun: in quest 1 his carbine drops beside him as the stagger draws a short gun
  (`evidence/n15-combat/contractor_hit_stagger_ab_48ppm_x2_t13708-13726.png`, t13716). Low priority.
- GATES 01:27 on `896c5c30d` (`node tools/gate/run.mjs --rev=HEAD --reels`, build/gate/896c5c30dce1/): PASS lint 16/16,
  PASS unit 2519 passed / 0 failed / 2 skipped, PASS scenarios 55, PASS parity bit-exact (mutation caught at 629),
  PASS selftest (look goldens 11/11 worst 0.00: neither the contractor stagger nor the impact dust moved a golden),
  PASS export-audit (670 loaded). Reels still running at 01:38 (build/gate/896c5c30dce1/reels.log, gate.json when done).
  The commits after 896c5c30d are JOURNAL only.
- 01:38 charred WIP grew (all UNCOMMITTED, not imported, not run): `project/features/combat/kills/kill_char_cells.gd`
  (KillCharCells: tag in KillStyles.parts for style burn by StreetWalkerCards.row_of, swap in KillStyles.take after
  char_fx.add: head_card -> the char grid, frame = card.frame % 5, upright, offset feet at FOOT_Y, scale
  HEIGHT * PX_PER_M * FILL[burn] / tex_h, material null; `--char-cells=off`), the two hooks in
  `project/features/combat/kills/kill_styles.gd`, `project/tests/unit/test_kill_char_cells.gd`, the packer change and the
  PNG. Next: `--import`, `node tools/godot/check.mjs` on the two .gd, run_unit --select=test_kill_char_cells,
  film weapon:flamethrower --victim=cop/head_cap --on=kill:1+90 at 64 and 32 px/m with/without `--char-cells=off`,
  look whether the HAT group also carries a head_card copy (whole-body cut copies head sprites twice), then provenance
  (steam/ai-provenance), DECISION, commit. If the film loses to the char print, delete the WIP.
- GATES PASS incl. reels on `896c5c30d` (01:46, build/gate/896c5c30dce1/gate.json: `gate: PASS`).
- MILESTONE `8eb67bc62` item 2 charred cells (the 01:38 WIP, finished): import, parse ok, test_kill_char_cells 3/3,
  film weapon:flamethrower --victim=cop/head_cap --on=kill:1+80 64 px/m, before `--char-cells=off`, same build:
  `evidence/n15-combat/char_cells_cop_ab_64ppm_x2_t542-620.png`: the drawn charred cop (ember cracks, dull blue cap)
  stands where the black silhouette stood, same size, crumble unchanged. DECISION combat/char-cells. Lint passed in
  the pre-commit hook; full unit/gates NOT run on 8eb67bc62 (session time). Masters: added it, dropped the c-2
  thug/punk sheet (still in evidence/); 15 entries checked by script.
- 01:52 session 4 ends. Godot: none of mine running (the gate and films exited; their logs say PASS).

NEXT (session 5): (1) full gates on the HEAD after 8eb67bc62 (`node tools/gate/run.mjs --rev=HEAD --reels`): the
charred swap is new code (kill_styles.gd, kill_char_cells.gd); a look golden or reel with a burn kill could move.
(2) 32 px/m film of the charred cop (brief: 32 + 64) and a check that the HAT group carries no second head_card copy
(none seen at 64 px/m). (3) Then the session-5 list above from item (3) on: metal impacts, body burst drift,
contractor living hold, the t62 white stick, flame jet column. (4) REPORT.md draft: add rows for 8eb67bc62 and the
01:15 fight_gate line; gate lines.

## Session 5 (01:52-03:22)
- GATES on `968346c90` (`node tools/gate/run.mjs --rev=HEAD --reels`, build/gate/968346c90c49/): PASS lint 16/16, unit 2522
  / 0 failed / 2 skipped, scenarios 55, parity bit-exact (mutation at 629), selftest (look goldens 11/11 worst 0.00: the
  charred cop swap moved no golden), export-audit 671. Reels STOPPED by PID at 02:03 (taskkill /T 106608) to free the
  Godot slot for films; the session's last commit gets the full gate with reels.
- 01:55-02:02 WIP while the gate ran (no Godot): charred cells for thug / ped_hood / cop_riot (it359 A, packed by
  `street_hit.py --only=char`, new flag: packs only the CHARS sheets, so the burn grids no longer drift; the thug's
  3/4-away char cell is capped to the cell height); drawn gib pieces (`tools/art/gib_pieces.py`, it359/it363: patrol v2,
  thug, hood, riot; one scale per kind, torso 128 px; the riot's orange arm bands greyed by street_armband) wired by
  `GibCardPieces` in `GibCardCut.placed` (`--gib-pieces=cut` = before); the contractor stagger v3 (long carbine, it359 (3))
  at v2's scale, registered by the hat (the boot finder takes the hanging muzzle), the grid padded 32 px below the feet
  (StreetQuestHit scales cell + foot line by the texture height); metal sparks (it317 1_1, pulled half way to cream:
  amber is plasma's) for GunFx.Hit.METAL (a round on a riot shield or near a metal dummy).
- MILESTONE `63811e09c` item 2 charred cells for the thug, hooded ped and riot cop (it359 A): film weapon:flamethrower
  --victim=<kind> --on=kill:1+80 64 px/m, before `--char-cells=off`, same build:
  `evidence/n15-combat/char_cells_thug_hood_riot_ab_64ppm_t542-620.png`. Each stands as its drawn charred figure (robot
  plating with ember cracks; the hooded man from behind; the riot cop with his shield) where the black silhouette stood.
  DECISION combat/char-cells-more. Unit test_kill_char_cells 4/4; lint passed in the hook.
- Metal sparks NOT shipped (unwired, files kept in build/scratch/metal_wip/): film weapon:machine_pistol
  --victim=cop/head_helmet 64 px/m t333-349: every round hit his body (ink burst), none his shield, so no METAL impact
  to judge. Note: a round that hits a metal DUMMY is a BODY hit (the dummies are hostiles), so METAL only fires for a
  missed round landing within 0.9 m of one, or a shielded hit. Next try: GunFxRounds._impact makes a hit on a metal
  target METAL (arena.metal holds their positions), then film the arena reel's metal range.
- Rocket gib drawn pieces, first cut at TORSO_PX 128 (cell 192): at 48 px/m the pieces drew ~5x down without mipmaps
  and speckled; repacked at 64 (cell 96) like the walking card's ~2.3x downscale. The thug in the lone rocket shot is a
  rig, not a card (GibCardCut does not cut him), so his drawn pieces never show there: before == after.
- MILESTONE `11a460e80` item 4 rocket gib drawn pieces (it359/it363) for the patrol cop (v2) and the riot cop: film
  weapon:rocket_launcher --victim=cop/head_cap|cop/head_helmet 48 px/m t349-368, before `--gib-pieces=cut`, same build:
  `evidence/n15-combat/rocket_gib_drawn_pieces_ab_48ppm_x2_t349-368.png` (x2 nearest). Cap from above, torso with torn
  edges, arms with hands, legs fly where paper-cut strips flew (the riot's were mostly grey shield chunks). Small at
  48 px/m; lighter blue than the card's navy. Thug/hood sets NOT shipped (rigs in the lone shot, unfilmed as cards).
  DECISION combat/gib-drawn-pieces. Owner Call. Unit test_gib_card_pieces 3/3.
- MILESTONE `51034570a` item 2 contractor stagger v3 (it359 (3), the long dock carbine): film quest1 48 px/m
  t13710-13722, before = v2 grid on the same build (swapped in via `git cat-file -p HEAD:<png> | git lfs smudge`,
  re-imported, restored + re-imported): `evidence/n15-combat/contractor_hit_v3_carbine_ab_48ppm_x3_t13710-13722.png`.
  DECISION combat/contractor-stagger-v3.
- FRICTION: `git show HEAD:<png>` gives the LFS pointer; importing it marks the .import `valid=false` and the texture
  stops loading until the .import is restored (`git checkout -- <png>.import`) and re-imported. Use `git lfs smudge`.
- FRICTION (mine): my scratch provenance helper appended the contractor's v3 line instead of replacing v2's; the stale
  v2 line is removed in the next commit. Checked by script: every n15 combat provenance line's sha256 matches its file.
- Masters (gtai-masters/n15/combat/frames.json): added the drawn gib pieces and the 3-kind charred cells at the top;
  dropped the superseded paper-cut gib and the arena lights (15 entries, none unreferenced/missing, by script).
- GATES on `65acf2e8e` (02:35-03:00, build/gate/65acf2e8e046/): PASS lint, unit 2526/0/2, scenarios 55, parity
  bit-exact, look goldens 11/11 worst 0.00 (block 5/5 worst 0.69 = baseline), export-audit 672; FAIL reels: top reel,
  `SCRIPT ERROR: Cannot call method 'has_meta' on a null value` at StreetWalkerCards.row_of <- KillCharCells.tag (a burn
  kill under the top view: a rig with no head card). My bug from `8eb67bc62` (session 4's reels never ran on it).
- MILESTONE `f7baf2dbc` fix: KillCharCells.tag skips a rig with no head card; regression test
  test_a_rig_without_a_head_card_is_not_tagged (5/5). Top reel re-run on a clean tree == f7baf2dbc
  (`node tools/reel/run_reels.mjs --out=build/reel_f7baf2dbc --views=top`): OK, 19 chapters down, 0 SCRIPT ERROR.
- MILESTONE `df7d5da6a` gib pieces toned to the armed walk's blue (street_tone): untoned vs toned film 48 px/m:
  `evidence/n15-combat/rocket_gib_pieces_toned_ab_48ppm_x2_t352-364.png`. DECISION combat/gib-pieces-tone.
- Metal sparks: chapter:riot_cop 64 px/m t46-72 with/without `--impact-fx=shapes`: identical frames, so no shielded
  (METAL) impact there either. Still unshipped; files in build/scratch/metal_wip/.
- 03:13 session 5 ends. No Godot or node process of mine running (checked by command line).

NEXT (session 6): (1) Full gates with reels on HEAD (`node tools/gate/run.mjs --rev=HEAD --reels`): code since the last
full PASS of everything bar reels (65acf2e8e) is f7baf2dbc (the null guard) and df7d5da6a (two PNGs); the reels must
pass on the final commit. Start it first and do only non-Godot work for ~30 min. (2) Metal sparks (build/scratch/
metal_wip: impact_cells.py CELLS sparks + CREAM 0.5, FILES/SPAN_M METAL 0.6, the test): find a filmed METAL impact.
Neither a riot cop's rounds (lone shot or chapter riot_cop) nor a metal dummy (a BODY hit) gives one. Options: make a
round that hits a metal target METAL in GunFxRounds._impact (arena.metal holds their positions), then film the
rivet-motion melee line's metal dummies with a gun (combat_reel `melee_line` beat). Or drop it. (3) DEFECTS loop (item
5): film `city` 32 px/m t100-1150 fresh and rank; known open: the body burst drift (c-2 #3, fix path in session 4's
01:08 line), the t62 white stick in the katana kill, the flame jet floor-fire column, the contractor's two carbines on
a death. (4) Gib pieces for the thug and hood (it363, drawn, unpacked): need a shot where they are CARDS (city crowd +
rocket). (5) Masters: the gib frame shows the untoned pieces (fine; the toned A/B is in evidence/). (6) REPORT: the
final gate line.

## Session 6 (03:12-04:42)
- Read: JOURNAL, git log -30, replies n15-combat.md (it363 offers: char cells for ped_cap / jogger / punk / swat; gib
  pieces for thug / hood / riot / patrol v2). No new REQUEST to combat in the other lanes' journals checked last session.
- 03:13 GATES started on `7778d347a` (`node tools/gate/run.mjs --rev=HEAD --reels`, build/gate/7778d347ad77/): proves
  the reel fix f7baf2dbc on the full set. Non-Godot work while it holds my Godot slot:
- WIP (uncommitted until filmed): street_hit.py CHARS += ped_cap, ped_jogger, ped_punk, swat (it363; packed with
  `--only=char`, the four shipped char sheets re-packed byte-identical: git shows no change); KillCharCells GRIDS /
  FILL_OF for the four rows, so every kind with a burning figure (StreetWalkerHit.BURN_GRIDS) ends as a drawn char
  cell; test_every_burning_kind_has_a_drawn_char_cell. Sheet check (burn row over char row, each kind):
  build/scratch/s6/char4_sheets.png: same scale and stance as the burn cells, no smoke, no red; swat holds his carbine.
- WIP: DEFECTS c-2 #3 (the body burst left on the floor 0.5 m short of the knocked-back card): HitLink's knock-back
  moves the sim Fighter.pos, and a death's slide is the view's rig carry (HumanReact.last_carry, session 4's reading),
  so GunFxRounds._impact records [victim, where his body was drawn] per body-hit impact (new GunFxFollow, held by
  GunFx.follow; body_off = RigCarry.hook(rigs), wired in ArenaRigs next to ShieldSparks) and GunFxArt draws the burst
  at follow.drawn_at (= stop point + how far his drawn body moved since). `--impact-follow=off` = the before.
  test_gun_fx_impact_follow (5). Debt: gun_fx.gd / arena_rigs.gd held at their baselines (comments tightened).
- Finding: GunFx.shield_test is never wired in the game (only tests set it): a riot shield's round is thrown as
  white sparks by ShieldSparks (blood fx), never as a GunFx METAL impact. So the metal-spark cells have no shield case.
- Metal sparks: DECISION combat/metal-sparks-later: not shipped tonight. Two films found no METAL impact in the shots
  that exist; making one needs a new shot or a sim-side reading of what a round hit, which is more than the gain.
  Files stay in build/scratch/metal_wip/ (git-ignored); the n11 shapes keep drawing METAL.
- Registry (realtime-combat-semantics, "information is partial and late": state that changes outcomes must be
  perceivable inside the reaction budget, not in a log): applied to impact-follow. The hit mark is the player's proof
  of which body took the round, so it is drawn on the body that took it, not on a floor point the body has left.
- GATES on `7778d347a` (03:13-03:36, build/gate/7778d347ad77/gate.json): PASS lint 16/16, unit 2527/0/2 (FLAKY 1:
  test_character_rigs `test_a_fresh_corpse_keeps_its_rig_for_the_hold_then_drops`, also logged flaky at 02:14 on
  88077fb80, not mine), scenarios 55, parity bit-exact (mutation at 629), look goldens 11/11 worst 0.00, block 5/5 worst
  0.69 (= baseline), export-audit 672, reels top / tilt70 / combo OK (281 s each). The reel fix f7baf2dbc holds.
- MILESTONE `c11391625` item 2 charred cells for swat, ped_cap, ped_punk, ped_jogger (it363): film weapon:flamethrower
  --victim=<kind> --on=kill:1+80 64 px/m, before `--char-cells=off`, same build:
  `evidence/n15-combat/char_cells_swat_cap_punk_jogger_ab_64ppm_t542-620.png`; 32 px/m punk
  `char_cells_punk_32ppm_t542-620.png` (reads: mohawk, dark plated body). Each drawing stands where the black print
  stood, same size, crumble unchanged. Provenance 4 lines, all 8 char sha256 checked by script. DECISION
  combat/char-cells-all. Unit test_kill_char_cells 6/6 (every BURN_GRIDS row has a char grid).
- FRICTION (mine): 1) `LaunchArgs.value()` returns "" for any flag not in its KNOWN_FLAGS list, so a dev before-flag
  read through it never fires (my first impact before/after was byte-identical); dev arena flags go through
  `ArenaArgs.parse().text()`. 2) I edited gun_fx_follow.gd while a film queue ran: a local `off` shadowed the new
  static `off()` (warning = error) and 4 queued films died in 4 s with SCRIPT ERROR. Parse-check before queueing.
- Finding (impact): the floor dot was not mainly the knock-back. A round is "on a body" when its last step passes
  within radius + 0.3 m (0.75 m) of the centre, and the burst was drawn at that step's closest point, short of him.
- MILESTONE `273bb2232` item 5 / DEFECTS c-2 #3: a body hit's burst on the body's front (GunFxFollow.on_body,
  FRONT_M 0.15) riding the knock-back and the death carry (RigCarry.hook wired in ArenaRigs). Film weapon:machine_pistol
  --victim=cop/head_cap 64 + 32 px/m t336-345, before `--impact-follow=off`, same build:
  `evidence/n15-combat/body_burst_on_body_ab_64_32ppm_t336-345.png`: the floor dots at t337-338, t341-344 gone; a dot
  at t339-340 stays near his old spot (the thrown-back cell draws him ~0.5 m on; the drawing's offset, not the sim).
  DECISION combat/impact-follow. Unit 50/0 on the touched suites. Mutation (`mutate.mjs --file=features/combat/
  weapons/gun_fx_follow.gd --max=10`): 60 % (6/10); survivors: the `_off` cache (equivalent without the flag), the
  FRONT_M literal, and the age boundary at :40 -> test added in `2f1ac74c8`. Checkout clean after.
- 03:56 GATES started on `2f1ac74c8` (`node tools/gate/run.mjs --rev=HEAD --reels`, log build/gate/s6_gate2.log).
- Masters (gtai-masters/n15/combat/frames.json): added the 4-kind charred cells and the body burst at the top; dropped
  body_ink_disc (superseded by the burst on the body) and the p55 baton re-cut (still in evidence/); 15 entries, none
  unreferenced or missing (checked by script).
- REQUEST assets: (low) the SWAT man's charred standing cells (it363 `swat_hit_70_cells/char/1_{1..5}.png`) again with
  EMPTY hands: in the game his carbine falls from him at the kill and lies at his feet, so the drawn charred carbine
  across his body reads as a second gun (`evidence/n15-combat/char_cells_swat_cap_punk_jogger_ab_64ppm_t542-620.png`,
  rows 1-2, t560-620). Same layout, same scale, no smoke, no red.
- GATES on `2f1ac74c8` (03:56-04:19, build/gate/2f1ac74c8c6e/gate.json): PASS lint 16/16, unit 2535/0/2, scenarios 55,
  parity bit-exact (mutation at 629), look goldens 11/11 worst 0.00, block 5/5 worst 0.69 (= baseline), export-audit
  673, reels top / tilt70 / combo OK. Every code commit of this session is in it; later commits are JOURNAL/docs only.
- Tried, NOT shipped: RigCarry.metres + the living wound's card push (StreetWalkerHit.shove), so the t339-340 dot
  follows the thrown-back card. Film 64 px/m t336-345 (build/scratch/s6/sh64.png, scratch): t339's dot moves onto his
  leg edge (better) but a new dot shows beside his boots at t344 where the committed build shows none (worse). Mixed;
  reverted (`git checkout -- rig_carry.gd`, the file was never committed with it).
- 04:21 city street fight film for the DEFECTS loop (`film.mjs city --ppm=32 --ticks=1200`, stills every 50 ticks,
  build/film/s6city32).
- DEFECTS loop (item 5), city 32 px/m film: ranked (1) four cops clumped on top of the sidewalk wall t250-1150, never
  coming down (likely nav, not looked into), still `evidence/n15-combat/city_fight_cops_on_wall_32ppm_t650.png`;
  (2) a cop's card over Rivet's head at contact t650. Both open.
- 04:24 session 6 ends. Godot: none of mine running (every film and gate exited with its verdict line).

NEXT (session 7): (1) If code lands, the full gate with reels on the final commit (`node tools/gate/run.mjs --rev=HEAD
--reels`); `2f1ac74c8` is the last code commit and PASSES everything. (2) DEFECTS city #2 (a cop's card over Rivet at
contact): film `city` 64 px/m around t640-660 (`--stills=630-670`) and judge the depth order; #1 (cops on the wall) is
likely nav: one line to the owner in REPORT, no sim edit. (3) The t339-340 burst dot: the wound-push attempt was mixed
(JOURNAL 04:20); an alternative is to skip the burst while the thrown-back cell plays (the hit reads by the cell and
the blood). (4) Asset replies: swat char cells with empty hands (REQUEST 04:10). (5) REPORT: final pass by 07:40 (rows
are current to session 6; Calls (a)-(c) stand).

## Session 7 (04:23-05:53)
- Read: JOURNAL, git log, replies n15-combat.md: it371 04:23 DELIVERED my session-6 REQUEST (swat char cells with
  empty hands, `swat_hit_70_cells/char_v2/`, A).
- MILESTONE `406fb812e` item 2: the SWAT char sheet re-packed from char_v2 (street_hit.py CHARS["swat"] =
  "char_v2/1", file name unchanged; sheet check build/scratch/s7/swat_char_v1_v2.png: same scale, hands empty). Film
  weapon:flamethrower --victim=cop/head_swat --on=kill:1+80 64 px/m, before = the it363 sheet swapped back in on the
  same build: `evidence/n15-combat/swat_char_empty_hands_ab_64ppm_t545-620.png` + x3 crop t565-620. The dropped
  carbine at his feet is the only gun. Provenance line replaced (sha256 ed3cbdc8...). DECISION
  combat/swat-char-empty-hands. Lint 16/16.
- DEFECTS city #2 (a cop's card over Rivet at contact): filmed `city` 64 px/m t630-670 (build/film/s7city64): the cop
  stands 1.75 m NORTH of Rivet (behind him) yet draws over his head and gun at t642-654. Cause: RigDepthSort's overlap
  test used one 0.9 x 1.8 m box for every rig; Rivet's drawn figure (x1.5, the owner's visual-only size) is ~2x a cop's
  height on screen at combo (125 vs 55-60 px at 64 px/m), so the pair read "no overlap", both took level 0, and the
  parts interleaved. Fix: `RigDepthBox` (new): each rig's box is at least as tall as its drawn card above its foot (the
  NEAR body's height decides a pair), Rivet's (card meta RivetFrames.ON) x1.5 wide. `BodyPlan.kind` was rejected as
  the Rivet test: thugs and the King keep the RIVET kind. rig_depth_sort.gd held at its 200-line baseline (199): the
  unused `_foot` removed, the box sizing in rig_depth_box.gd.
- MILESTONE `ac7991f58` item 5 DEFECTS city #2: film city 64 px/m t634-660, before = HEAD's sorter swapped back on the
  same build: `evidence/n15-combat/city_depth_rivet_over_cop_behind_ab_64ppm_t634-660.png`: Rivet and his pistol now
  draw over the cop behind him (t634-638 the cop's hands no longer cover Rivet's gun). Unit test_rig_depth_sort 7/7
  (+2: a tall near body overlaps; card_tall). DECISION combat/depth-drawn-box. Registry depth-ordered-layered-art applied ("the order is a measurement", each layer's true shape): the
  draw order is decided from what is drawn (the card), not an assumed man.
- FRICTION: `test_quest_blade` `test_dock_hint_names_the_blade_key_only_with_a_blade` fails under
  `run_unit.mjs --select` on HEAD too (with my files set aside): [fire], [melee], [slot2] stay unresolved, as if
  InputMap had no actions in that run. It passed in the 04:19 gate. Not mine; the full gate decides.
- 04:38 GATES started on `ac7991f58` (`node tools/gate/run.mjs --rev=HEAD --reels`, log build/gate/s7_gate1.log).
- DEFECTS session 1 #3 (dark streak across the victim t345-348) looked at in build/film/s6if64_a: a later round of
  the burst flies on through the fresh corpse (the sim lets rounds pass a dead body), its ink tail across his falling
  body for 2 ticks (t346-347). Minor; left open (a view-only cut at the corpse would orphan the round's later impact).
- GATES on `ac7991f58` (04:39-05:02, build/gate/ac7991f5885c/gate.json): PASS lint 16/16, unit 2537/0/2 (test_quest_blade
  passes in the full run), scenarios 55, parity bit-exact (mutation at 629), look goldens 11/11 worst 0.00, block 5/5
  worst 0.69 (= baseline), export-audit 674, reels top / tilt70 / combo OK. The depth box moved no golden.
- DEFECTS city #1 re-read from the still: the four cops are not ON the wall, their feet are at its north foot (road side):
  blocked from Rivet (sim/AI path) and drawn over the wall's cap (no occlusion). REPORT line rewritten; not this lane.
- c-2 #3 t339 re-read: the thrown-back card is pushed ~0.5 m by StreetWalkerHit.shove (view) while the contact shadow
  stayed on the feet (RigCastShadows draws at rig.global_position): the man floated beside his shadow, and the burst dot
  sat on the shadow. Touches rig_cast_shadows.gd (characters; not in hero's watch list, hero has no commit on it).
- MILESTONE `b9544422e` item 5: the contact shadow rides the hit card's push (RigCastShadows.card_push: only a visible
  hit-grid card; deaths unchanged, shove is zero while dying). Before `--shadow-push=off`, same build: weapon:machine_pistol
  --victim=cop/head_cap, `evidence/n15-combat/hit_shadow_rides_push_ab_64ppm_x2_t338-344.png` and
  `hit_shadow_rides_push_ab_32ppm_x3_t337-342.png`: at t339-341 he stands on his shadow. The t339 burst dot stays at the
  round's point (now on bare floor beside him): left open. DECISION combat/hit-shadow-push. Unit 37/0 on the touched
  suites (+2 tests).
- Mutation `mutate.mjs --file=features/characters/rig_depth_box.gd --max=8`: 25 % (half() untested) -> tests added in
  `f128a280e` -> 100 % (8/8). Checkout clean after.
- 05:11 GATES started on `f128a280e` (`node tools/gate/run.mjs --rev=HEAD --reels`, log build/gate/s7_gate2.log).
- GATES on `f128a280e` (05:11-05:34, build/gate/f128a280e879/gate.json): PASS lint 16/16, unit 2540/0/2, scenarios 55,
  parity bit-exact (mutation at 629), look goldens 11/11 worst 0.00, block 5/5 worst 0.69 (= baseline), export-audit
  674, reels top / tilt70 / combo OK. This is the LAST code commit; later commits are JOURNAL/docs/evidence only.
- City 32 px/m whole fight re-filmed on the final tree (build/film/s7city32, same shot and stills as s6city32):
  `evidence/n15-combat/city_depth_fight_32ppm_t600-700.png`: at t650 Rivet now draws over the cop behind him at the
  game camera; t600 / t700 unchanged. (Before = the session-6 film of an earlier build, same seed: not same-build.)
- Masters frames.json: + the depth fix, the swat empty hands, the shadow push; dropped char_cells_cop (covered by the
  other char sets), city_target_rings, impact_dust (still in evidence/); 15 entries, none missing or unreferenced.
- 05:38 session 7 ends. Godot: none of mine running (every film, mutation and gate exited with its verdict line).

NEXT (session 8): (1) `f128a280e` is the last code commit and PASSES every gate with reels; if code lands, re-run
`node tools/gate/run.mjs --rev=HEAD --reels` on the final commit. (2) The t339 burst dot: with the shadow now riding the
card's push, the dot sits on bare floor beside him; try GunFxFollow.body_off = RigCarry.metres + card_push / PX_PER_M
(session 6 tried the push alone: t339 better, a new dot by his boots at t344, because the push drops to zero at the
death while the burst still follows); film machine_pistol cop/head_cap 64 px/m t336-345 before `--impact-follow=off`.
(3) DEFECTS: the round through a fresh corpse (minor), the cops at the wall's foot (owner line written: nav +
occlusion). (4) Asset replies (n15-combat.md) for anything new. (5) REPORT final pass by 07:40 (rows current to
session 7; Calls (a)-(c) stand; update the gate line to the final commit).

## Session 8 (05:36-07:06)
- Read: JOURNAL, git log, replies n15-combat.md (nothing new since it371 04:23), DEFECTS, REPORT open rows.
- Finding (t339 dot): session 6's try kept the push in BOTH the recorded body point and the draw, so a later round
  recorded while he was already pushed was drawn at the round's point minus that push once he died (the t344 boots dot).
  Fix: record the body point without the push, draw with the push of the moment (GunFxFollow.body_push).
- MILESTONE `61a2d3baa` item 5: the body burst rides the living hit card's push (RigCarry.wire sets body_off and
  body_push; arena_rigs.gd held at 294 lines). Film weapon:machine_pistol --victim=cop/head_cap 64 px/m t334-346,
  before `--burst-push=off`, same build: `evidence/n15-combat/burst_rides_push_ab_64ppm_x2_t338-344.png`: t339's dot
  moves ~0.2 m onto his shadow's edge; no new dot at t344. Still a floor dot at his feet front: the burst is a floor
  print and the thrown-back figure leans back off it (the root, left open). DECISION combat/burst-push. Unit 18/0 on
  the touched suites (+2 tests). Lint 16/16.
- 05:43 GATES started on `61a2d3baa` (`node tools/gate/run.mjs --rev=HEAD --reels`, log build/gate/s8_gate1.log).
- DEFECTS blade t62 white stick DIAGNOSED (build/film/kl64_after t58-69): KillSplitFx's designed slash streak (a cream
  bar edged in ink, STREAK_M 1.7 m along the cut, 12 ticks). The cut is the blow rotated by the row's cut_deg 55
  (SignatureKills.on_kill, which also orients the gibs and the ground mark), so it crosses the cop diagonally while
  Rivet's drawn left swing sweeps level: it reads as a stick. Lane brutality's look: Call (d) in REPORT, no code.
  Still `evidence/n15-combat/katana_slash_streak_64ppm_t58-69.png` (an earlier build's film, not same-build).
- Call (c) (the upright frame between blade swings) left as a Call: a one-tick blip at 60 Hz, and the latch lives in
  rivet_strips.gd at its 200-line ratchet.
- GATES on `61a2d3baa` (05:43-06:04, build/gate/61a2d3baac58/gate.json): PASS lint 16/16, unit 2542/0/2, scenarios 55,
  parity bit-exact (mutation at 629), look goldens 11/11 worst 0.00, block 5/5 worst 0.69 (= baseline), export-audit
  674, reels top / tilt70 / combo OK. This is the LAST code commit unless a later line says otherwise.
- Mutation `mutate.mjs --file=features/combat/weapons/gun_fx_follow.gd --max=12`: 66.7 % (8/12); the 4 survivors are
  the flag caches (`_off`/`_push_off` init, the `< 0` test, the parse's `1 if`): equivalent without the flag. Every
  mutant in the push path killed. Checkout clean after.
- Masters frames.json: + burst_rides_push (beside body_burst), - chainsaw_left_set (katana_left_set covers the left
  set; file deleted); 15 entries, none missing, none unreferenced (checked by script).
- 06:08 bench.lock taken (noclobber; tools lane's t-5 lock of 05:41 was gone). PERF fight_gate started: arms now vs
  before = every tonight flag off, 4 rounds, log build/perf/s8_fg.log. Other lanes' Godot running: CONTENDED expected.
- PERF fight_gate (06:08-06:14, bench.lock held by this lane, deleted after; export from the worktree at 346aabd9e = the
  code of 61a2d3baa; arms now vs before = every tonight flag off: --rivet-blade-left=off --rivet-left-strike=off
  --gib-card=whole --gib-pieces=cut --target-rings=on --body-ink=n7 --quest-hit=off --char-cells=off
  --impact-follow=off --shadow-push=off --burst-push=off --melee-smear=n7 --dropped-gun=pale; 4 rounds;
  build/perf/fight-gate/2026-11-11T05-08-07-904Z/gate.json, log build/perf/s8_fg.log). city (reel ch 18): before - now
  p50 +0.02 [-0.13,+0.11] ms, p99 -0.07 [-1.58,+0.65], worst -0.12, cpu +0.31 s: all WASH; A/A p50 +0.03
  [-0.20,+0.19]. horde (Gatling): p50 +0.02 [-0.12,+0.21], p99 +0.61 [-0.05,+3.28], cpu +0.05: WASH; worst -0.38
  [-0.63,-0.02] 4/4 LOWER (now's worst frame ~0.4 ms higher than before, both ~16 ms; A/A worst [-0.32,+0.16]).
  0 frames over 25 ms in any arm; 6 of 24 runs CONTENDED (other lanes' reel and rivet_tour ran).
- 32 px/m pair of 61a2d3baa (same shot, stills 336-344, before --burst-push=off, same build):
  `evidence/n15-combat/burst_rides_push_ab_32ppm_x3_t338-344.png`: t339 the dot moves from bare floor onto his shadow's
  edge; t344 unchanged.
