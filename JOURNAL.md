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
