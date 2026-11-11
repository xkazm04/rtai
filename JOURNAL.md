# JOURNAL n16 kills-new

Lane: a unique brutal death for every weapon that has none (pistol, machine pistol, Gloria nail gun,
Gatling, electro baton; then molotov vs flamethrower, Rivet's bare claw). Branch `n16-kills-new` from `5843f5a28`.

## Iteration 4 (2026-11-11 11:00, BUILD; iterations 1-3 died at start on billing, no work lost)

- 11:00 read: briefs (common + kills-new), `kills/` (kill_styles, signature_kills, signature_kill(_table), kill_view,
  kill_shock_fx, kill_sprawl_cut, gib_sim, gib_cut, gib_card_cut, brutality_hook), signature_kills.json + schema,
  weapons.json / melee_weapons.json ids, n15 combat REPORT, last 30 decisions, kills-polish JOURNAL (its schema note:
  it ADDS optional keys alphabetically; I do the same, union on merge).
- Registry rules applied (resolved through `game-production/index.json`):
  - `realtime-combat-semantics`: "reaction budgets" - a death is not a wind-up the player must answer, so no
    anticipation on guns; recovery band 0.1-0.5 s -> every kill's readable beat ends inside ~0.5 s (30 ticks) and the
    fight never waits on it (gib hold <= 3 ticks).
  - `combat-pacing-and-dramatic-arc`: "beats are mined, not admired" -> each death is a beat sheet with ticks, and the
    held beat is short; the pistol (the most used gun) is the shortest, the rare guns get the longer show.
  - `motion-quality-gating`: craft / responsiveness / integrity judged separately; never a made-up number ->
    every death gets film at 32 and 64 px/m, ticks counted from the film, and placeholder vs drawn judged at the same ticks.
  - `sprite-and-atlas-production`: a death is a SET -> requests name the grid (5 facings x N frames, the existing fall
    grids' cell and px/m, feet at cell centre = the anchor), the palette (riso ink + cream + kind colours, red = blood
    only) and the frame durations in 60 Hz ticks.

### SHARED FILES (kills-polish, read me)
- `project/features/combat/kills/kill_styles.gd`: I add ONE child (`new_fx: KillNewStyles`, my own class) and one
  line in each of `bind`, `pose`, `forget`, `parts`, `take` that hands my styles to it. No change to your branches.
- `project/data/tables/signature_kills.json`: I only APPEND new rows (`pistol_snap`, `smg_stitch`, `nail_pin`,
  `gatling_shred`, `baton_overload`). `signature_kills.schema.json`: new style enum values + new optional keys,
  alphabetical. Merge = union.
- `project/tests/scenarios/scenario_brutality_kills.gd`: I add my weapons to `KILLS` (one line each).
- `project/tests/unit/test_signature_kills.gd` line 83: its "a gun with no row" was `pistol`; now `no_such_gun`.

### Architecture (DECISION kills-new/pose-track)
The five deaths share one render-only animator, `KillTrackFx`: the victim's whole-body copy (GibCut / the drawn
card) is laid through a data pose track (`track`: keys `[tick, lean_deg, squash, tip]` in the row, linear between
keys) relative to the shot, and each style adds its own overlay class (spray, spurts, nails, scraps, glow). The sim
side is the framework's own: `GibSim.throw` (body + cap, or the six parts for the shred), the brutality RNG stream,
the marks. A new row changes no hit, no damage and no city replay or parity: SignatureKills lives only in the arena
hook, its gibs are in the ARENA world hash (re-run equal, no stored golden). Rejected: special-casing each death in
KillView (kills-polish's file) and keeping the standard death + overlays (the pistol's fold forward onto the face
contradicts the standard bullet death's fall back; the drawn cells replace the copy when they land).

### Beat sheets (60 Hz ticks; t0 = the lethal hit; gib hold = SignatureKills.hold, the camera's kill punch is hit_feel's, unchanged)

1. **Pistol `pistol_snap`** (the most used gun: short and clean; gib hold 2). AS BUILT (11:30):
   - Anticipation: none.
   - Impact t0-2: the head snaps back - the standing copy leans 22 deg away from the shooter in 2 ticks; a red jet
     (9 drops) and a mist puff leave the back of the head along the shot for 7 ticks (`KillSnapArt`, ~0.8 m); the
     street gets the row's spray (8 drops, 24 deg) and the framework's blot behind him.
   - Held beat t2-8: hangs at the lean.
   - Knees buckle t8-14: shortens to 0.84, back to upright.
   - Fold t14-32: his own drawn fall grid, faced TOWARD the shooter: buckle t14-17, mid-fall t17-21, face-down lying
     from t21 (`fx.cells_at` 14, `cells_ticks` 18).
   - Aftermath: face down, head toward Rivet, the blot and spray behind where he stood. Readable death 21 ticks (0.35 s).
   - The cap: deferred to the drawn loose cap cell (a sim cap piece on a card victim copied the whole figure, then
     left a stray shadow).
2. **Machine pistol `smg_stitch`** (gib hold 1)
   - Impact t0-9: the stitch - four spurts walk up the body (hip, belly, chest, neck: 0.35/0.7/1.05/1.4 m) at t0, 3, 6,
     9; each one a jerk of the figure (alternating 7 deg, 0.05 m back) and a red spurt out of the back plus an ink hole
     dot on the front.
   - Spin t9-21: on the last he whirls once (the card turns through edge-on, scale.x 1 -> -1 -> 1).
   - Drop t21-30: falls sideways, across the shot.
   - Aftermath: body across the shot, a dotted spray line on the street along the shot.
3. **Gloria `nail_pin`** (gib hold 2)
   - Impact t0-2: three nails strike (ink shank, cream head): both sleeves and a foot; he is knocked back along the shot.
   - Wall within 1.4 m behind him (the stage's push_out probe): t2-10 he slides back to it and hangs pinned upright
     (feet off the street), t10-90 writhes (a decaying wobble), then hangs slumped. The nails stay drawn in the wall.
   - Open street: t2-12 he falls back; the foot nail holds him to the street: t12-80 writhes on the spot (decaying
     wobble), the nails stay drawn.
4. **Gatling `gatling_shred`** (gib hold 0: the stream never stops)
   - Impact t0-24: the stream holds him upright, shaking hard; every 3 ticks a torn scrap tears off him and flies
     along the stream with a red spurt (8 scraps).
   - Drop t24-34: what is left falls in a heap of his parts (the six rig/card pieces held together through the shred,
     then let go at low speed: GibSim grind hold).
   - Aftermath: the heap, scraps scattered behind along the stream, a wide spray.
5. **Electro baton `baton_overload`** (gib hold 3: the heavy blow). Must read unlike the electro gun's X-ray strobe:
   no skeleton, no strobe, no arcs.
   - Impact t0-3: held.
   - Cook t3-45: locked upright, a fine tremble (a third of the electro gun's); a cream glow builds from inside him
     (veins of light, brighter each tick), steam rises from the collar and shoulders; his eyes burn as two cream points
     that go out at t40.
   - Fall t45-55: drops back limp, smoke rises for 200 ticks.
   - Under --reduced-motion: no tremble and no flicker.
   All five: `--gore=reduced` = the standard death (the table lookup misses). Before = the base commit
   (`tools/film/compare.mjs --a=<base> --b=<after>`, same tick), so no before flag is added.

### REQUEST assets (asset lane: reply to `gtai-assets/replies/n16-kills-new.md`)
Kinds: the four street humans seen most in play, counted from `enemy_waves.json` (all curves): patrol cop 16,
riot cop 12, SWAT 10 (robot thug 5 and gunner 3 are robots: no signature kills), plus the suit pedestrian
(`ped/head_hair`, the base crowd ped, the bystander killed most). Each at p70 and p55. Grid = the existing drawn fall
grids (`street_walker_fall.gd`: 5 facings across - front, 3/4 front, side, 3/4 away, away; the left side mirrored -
frames down; the long-fall cell size and px/m of `p70/cop_patrol_long_fall.png` (738x482 per cell) and
`p55/cop_patrol_long_fall.png`; feet at the cell centre). Riso ink and cream, kind colours, red for blood only,
no vermilion, no teal. Gore: "go further, stay riso" - drawn bone/innards allowed in wounds and cut edges.
- REQUEST assets: pistol_snap death cells, patrol cop / riot cop / SWAT / suit ped, p70 + p55. 4 frames down:
  (1) head snapped back, exit spray from the back of the head, cap leaving (2 ticks) (2) knees buckled, upright (8 ticks)
  (3) pitching forward, arms limp (6 ticks) (4) lying FACE DOWN, long (~1.5x standing), head toward the shooter
  (the corpse). Plus a loose cap cell per kind (2 tumble frames, ~0.3 m) that flies separately.
- REQUEST assets: smg_stitch death cells, same kinds/sizes. 5 frames: (1)-(3) the stitch: the body jerking with
  1/2/3 visible exit wounds rising hip -> chest (red spurts behind), (4) spinning, seen edge-on mid-turn
  (5) lying on his side across the shot.
- REQUEST assets: nail_pin cells, same kinds/sizes. 3 frames: (1) pinned upright against a wall by both sleeves,
  feet dangling, head slumped (2) writhing variant of (1) (3) lying on his back on the street with a foot nailed,
  writhing. Plus a nail cell (shank + head, 3 angles) for the wall/street.
- REQUEST assets: gatling_shred cells, same kinds/sizes. 3 frames: (1) upright, torn by the stream, cloth and
  flesh scraps leaving, red spray (2) more torn, bone showing at the cuts (3) the heap: what is left on the street,
  drawn parts. Plus 6 loose scrap cells (cloth/flesh/kit pieces, ~0.15-0.3 m) per kind.
- REQUEST assets: baton_overload cells, same kinds/sizes. 4 frames: (1) locked rigid, a cream glow through the skin
  (veins of light), eyes burning cream (2) brighter, steam from collar and shoulders (3) eyes out, glow fading,
  sagging (4) lying on his back smoking (no blood, a soot ring).

- 11:20 FRICTION: the before film (`film.mjs weapon:pistol --victim=cop/head_cap --ppm=64`) shows the STANDARD pistol death
  is already a good drawn fall (thrown back, arms flung, the long face-down lying cell). A pose-track transform of the
  standing card would read worse than that. DECISION kills-new/fall-cells: the n16 deaths play the victim's OWN drawn
  fall grid (`KillFallCells`: StreetWalkerFall's buckle / mid-fall / lying, the between rows where a kind has them)
  inside the body copy from the row's `fx.cells_at` tick, faced the row's fall (the pistol: toward the shooter). The
  pose track drives only the beats before it (the snap, the buckle) and parts-rig victims (no card). Rejected: the
  transform-only lie (a rotating paper card). When the drawn pistol cells land they replace the grid in the same slot.
- 11:40 pistol: `kill_track.gd`, `kill_track_rows.gd`, `kill_new_styles.gd`, `kill_snap_art.gd`, `kill_fall_cells.gd`,
  row `pistol_snap`, schema (style `snap`; keys `fall`, `fx`, `lie_len`, `slide_m`, `track`), unit
  `test_kill_new_styles.gd` 21/21 with test_signature_kills (`run_unit.mjs --select=...`).
  FRICTION: warnings-as-errors reject `int()/float()` on a Variant and `as Sprite2D` on get_meta; the row extras
  are parsed once into typed containers (`KillTrackRows.Extra.num`). `wrap()` clashes with the global: `wrap_body`.
- 11:35 MILESTONE pistol `6579e6a2a`. Films (64 px/m lone patrol cop, `compare.mjs weapon:pistol --a=HEAD --b=.`;
  32 px/m city street fight `compare.mjs city --a=917064b44 --b=6579e6a2a --at=336-380`). Defects by eye, fixed before
  the commit: (1) on a CARD victim GibCut's HAT group is a copy of the whole drawn card (the card hangs under the
  head), so a second whole cop flew off and stood there: the hat group is freed when the drawn grid is attached;
  (2) then the sim cap piece still drew a soot shadow: the pistol row throws the body only (the cap waits for the
  drawn cap cell). FRICTION: compare's `--subject=dead` is UNVERIFIABLE for every signature kill (the consumed
  victim's rig is hidden, its probe screen is off-screen): use `--subject=rivet`.
- 11:47 MILESTONE machine pistol `e7a082c12`. Defects by eye on the way: the hit card (the first, non-lethal round)
  draws the figure SHOVED off the rig's feet and off-centre in its cell, so holes placed from the rig origin and a
  mirror-whirl about it missed him by ~1 m. DECISION kills-new/stitch-on-cells: the stitch plays on his drawn fall
  grid from the hit (feet exactly at the cell centre); the whirl is the grid's drawn facings turning a full circle
  (`KillStitchArt.facing`), not a mirrored card (a sliver at edge-on).
- 11:51 `bc3cea26e` blot_m: the framework's fixed 0.5 m splat at the hit read as a pool before the pistol victim fell
  and hid the spurts (32 px/m sheet). SHARED FILES touched (kills-polish, read me): `signature_kill.gd` (+`blot_m`,
  one var, one parse line), `kill_marks.gd` (+`Mark.blot_m`, view only, not in write_state), `kill_mark_art.gd` (the
  blot reads it; 0.5 = every existing row unchanged).
- Evidence so far (build/, to be copied to gtai-masters at report time): `build/film/cmp_pistol_64/compare-t*.png` +
  `compare-330-400.mp4` (64), `build/film/cmp_pistol_city32/compare-t*.png` + clip (32, city), sheets
  `build/pistol_after_64_sheet.png`, `build/smg_after_64_sheet.png`, `build/pistol_city32_{A,B}.png`.
  Owed: a same-tick compare of the stitch (only the after is filmed), 3 directions each, the 32 px/m stitch.
- 11:56 full unit on `bc3cea26e`: 2647 passed, 0 failed, 2 skipped (`run_unit.mjs`, 130 s). Scenario `brutality_kills`
  ok with pistol + machine pistol in KILLS (each >= 2 kills of its own style, replay identical, same seed same gibs).
- 12:02 MILESTONE Gloria `d6a4fb1a8` (open-street case filmed: `evidence/n16-kills-new/nail_pin_street_after_64ppm_riot_t338-398.png`;
  nails streak in t339-341, he falls back on his drawn grid, nails at the foot and torso, a slow writhe).
  NOT filmed: the WALL case (the lone-victim shot has no wall behind him).
- REQUEST tools: (1) `compare.mjs --subject=dead` is UNVERIFIABLE for every signature kill: the consumed victim's rig
  is hidden and the probe reports it off screen; please treat a signature-consumed victim as on screen at his
  `KillView` body (or add `--subject=kill`). (2) a film shot whose lone victim stands with a wall ~1 m behind him
  along Rivet's shot (`weapon:<id> --victim-wall`), for Gloria's pin-to-wall case.
- Evidence committed under `evidence/n16-kills-new/` (sheets + clips). Defects open: a 1-frame double figure at the
  stitch's kill tick (t341: the living rig still drawn the frame the copy appears); the pistol cap (waits for the
  drawn cap cell); the exit mist is still small at 32 px/m.

- 12:12 same-tick A/B re-filmed from HEAD `d6a4fb1a8` vs `917064b44` (64 px/m): `evidence/n16-kills-new/pistol_snap_ab_64ppm_patrol_t330-400.mp4`
  (+ t354, t358 stills) and `smg_stitch_ab_64ppm_swat_t335-400.mp4` (+ t348, t365). The 32 px/m city clip
  `pistol_city32_ab_t320-420.mp4` is of `6579e6a2a` (before blot_m and the bigger mist). Scenario brutality_kills ok
  with Gloria (12:05).

NEXT (iteration 5): (a) film the pin same-tick A/B (`compare.mjs weapon:machine_pistol|gloria --a=917064b44
--b=HEAD --subject=rivet`), 32 px/m city fights and 3 directions each (chapter:<weapon> or the city shot); (b) the
Gatling `gatling_shred` (beat sheet 4: the six rig/card pieces held by a GibSim grind hold while scraps tear off,
then a heap; style `shred`, a `KillShredArt`); (c) the electro baton `baton_overload` (beat 5, melee: KillLab blade
path; glow/steam/eyes, no X-ray); (d) check `gtai-assets/replies/n16-kills-new.md` and wire any drawn cells in place
of the fall grid (KillFallCells is the slot); (e) the kill reel when the tools lane delivers it; (f) copy the best
frames to `gtai-masters/n16/kills-new/` with `frames.json`; (g) full gates on the last code commit (lint, unit,
scenarios, evidence run with parity + look goldens, reels).
- 12:14 read the replies: asset lane it410/it414 DELIVERED pistol_snap p70 for all four kinds:
  `gtai-art/library/keyed/street/{cop_patrol,cop_riot,swat,ped_suit}_pistol_snap_70_cells/{frame 1..4}_{column 1..5}.png`
  (frame 1 snap + cap flying, 2 buckle, 3 pitch forward, 4 face-down corpse; columns = the kind's long_fall grid
  order; cells = the kind's grid cell (738x482 patrol/riot, 806x482 SWAT, 542x470 suit), registered to the grid's
  bottom-centre; patrol frames 1-2 sit ~20 px low). Loose headgear `cop_headgear_tumble_70_cells/{1 cap,2 riot,3 swat}_{1,2}.png`
  (~0.3 m). Grades: patrol 1-2 B / 3-4 B (4_5 = 4_1 turned); riot 1-2 A / 3-4 B (frame 3 a stoop); SWAT 1-2 A /
  3-4 B; suit 1-2 A / 3-4 B (no briefcase). p55 follows. They asked: keep the thin blood strand head -> cap? (keep:
  red = blood, it reads the exit.)
- tools lane: the kill reel is ready (`node C:/Users/kazda/kiro/gtai-wt/n16-tools/tools/film/kill_reel.mjs --out=<dir>
  --weapons=all --dirs=90,270 [--before=<sha> --rev=<sha>] [--ppm=32,64]`); `--dirs`/`--victims` need cherry-pick
  `afe581336` (brutality_hook.gd +2 lines, kill_lab_turn.gd). `--subject=kill` for film/compare served in `dfccc7f0d`
  (run their copy of compare.mjs). `--victim-wall` still open.
- kills-polish NOTE (11:45): `GibCut.cut(rig, false)` now dresses a rig victim's six groups with its kind's DRAWN gib
  pieces (`GibCardPieces.dress_rig`) - the Gatling shred gets drawn pieces (with bone) for free.

NEXT (iteration 5, in this order): (1) WIRE the drawn pistol cells: pack each kind's 4x5 cells into one grid PNG under
`project/features/characters/art/view/p70/<kind>_pistol_snap.png` (follow `tools/art/street_fall.py`'s packing; LFS,
`.import`, a provenance line per PNG in `steam/ai-provenance/2026-11.jsonl`), point KillFallCells at a per-row grid
table (`fx` cannot hold strings: add a `cells` key or a `KillFallCells.GRIDS[row id][art][row]` dict) so pistol_snap
plays frames 1-4 from t0 (snap 0-2, held 2-8, buckle 8-14, pitch 14-21, corpse 21+) with the cap cell thrown as the
HAT piece; judge against the placeholder at the same ticks (compare `--a=027571cc9 --b=HEAD --subject=kill`);
(2) cherry-pick afe581336 and film every new death with the kill reel at 32 + 64 px/m, 3+ directions;
(3) the Gatling shred; (4) the electro baton overload; (5) then the items in the earlier NEXT list.
- 12:16 JUDGED the delivered patrol boards by eye (`gtai-art/library/evidence/it410/patrol_snap_v2_cells_vs_grid.png`,
  `patrol_drop_cells_vs_grid.png`): frame 1 (head thrown back, the cap up and away, a thin red strand from the exit) is
  the pistol's identity and reads in all 5 facings; frame 2 buckle (blood running from the head) matches the grid's
  camera; frame 3 pitches forward with the arms limp; frame 4 the face-down corpse with the back-of-head wound, as long
  as the grid's lying frame. Keep the blood strand (red = blood, it shows the exit). The away facing (column 5) of
  frame 3 still reads standing: watch it at 32 px/m. Verdict: wire all four kinds first thing next session.

## Iteration 8 (2026-11-11 12:13, BUILD)

- 12:13 read JOURNAL, git log, replies (it414: all four kinds' pistol_snap p70 delivered; p55 for the cops running).
- 12:20 the delivered cells measured (`/tmp/feet.py`: the lowest opaque row per cell): frame 2 (the upright buckle)
  sits on the fall grids' feet line for patrol/SWAT/suit; the riot cells came at 738x482 (its grid is 684x494) with
  the feet 7 px low; frame 1 runs lower (blood drips). Patrol `4_5` (the delivered away corpse, = `4_1` turned) reads
  as a man STANDING seen from behind, so the away column takes the 3/4-away corpse, as the long fall grids do.
  `tools/art/kill_cells_pack.py --death=pistol_snap` packs 5 facings x 4 frames per kind, each column shifted so its
  buckle feet sit on the cell centre.
- DECISION kills-new/death-cells: a row's new `cells` key (`at`: each frame's start tick; `grids`: view art -> card
  row -> grid file; schema extended, data first) gives a death its OWN drawn grid; `KillDeathCells` looks it up (the
  art's own, else p70 as the fall grids fall back) and `KillFallCells.attach` carries it instead of the fall grid,
  faced the row's fall, from t0; the pose track keeps only its slide (no lean on drawn frames). Kinds without cells
  keep the fall-grid placeholder; dropping the `cells` key restores it everywhere. Rejected: a per-row dict in code.
- 12:38 MILESTONE `74a345aaf` the drawn pistol cells. Same-tick A/B 64 px/m patrol cop (`compare.mjs weapon:pistol
  --a=HEAD --b=. --victim=cop/head_cap`): `evidence/n16-kills-new/pistol_cells_ab_64ppm_patrol_t{340,350,356,390}.png`
  + `_t330-400.mp4`. Judged by eye: t340 the head thrown back with the cap in the air and the red exit strand (the
  placeholder at that tick: the standing card leaned, cap on); t350 the buckle, cap gone, blood from the head (the
  placeholder still capped); t356 the pitch, arms limp; t390 face down, head toward Rivet, the back-of-head wound up.
  Drawn wins on every beat. Unit `test_kill_death_cells.gd` 4/4 + kill_new_styles + signature_kills 26/26.
- `64be75e2a` took the tools lane's kill-lab turn (afe581336, game side only, identical content) for the kill reel.
  Its `--before=d6a4fb1a8` refuses (native differs; and that commit has no lab turn), so the reel films the after
  only; the same-tick before/after is the compare above.
- 12:45 the cap: the drawn frame 1 throws it, frame 2 has none, so it vanished. `KillLooseArt`: from t8 the asset
  lane's loose tumble cells (`<kind>_headgear_tumble.png`, packed `--headgear`) arc 1.1 m back along the shot over
  12 ticks (0.4 m hop, 2 tumble frames every 3 ticks) and stay on the street. Row `cells.loose` + fx `loose_*`.
- 12:30 kill reel (tools lane's `kill_reel.mjs --weapons=pistol --dirs=0,90,225 --ppm=32,64 --clips`) on `64be75e2a`+:
  dirs 0 and 225 PASS (kill at 63), dir 90 UNVERIFIABLE (no kill event in 420 ticks). Judged at 64 px/m: t64 the
  snap with the cap in the air, t73 the buckle with the loose cap arcing back, t83 face down with the head toward
  Rivet (dir 225: the body lies under Rivet, close in the lab) and the cap behind him on the street.
  Evidence: `evidence/n16-kills-new/pistol_cells_reel_{32,64}ppm_dirs0-90-225.png`, `_reel_{32,64}ppm_dir{0,225}.mp4`,
  `_reel_64ppm_dir0_225_t64-83.png`.
- 12:33 MILESTONE `e4fcf6448` the loose cap/helmet (KillLooseArt; provenance lines for the 3 tumble PNGs).
- REQUEST tools: (3) the kill reel's lab never kills with `--weapons=gatling` (all dirs: "0 kill event(s) in 420
  ticks"), nor the pistol at `--dirs=90`. The Gatling was filmed with `film.mjs weapon:gatling` instead.
- 12:40 Gatling, first build: the six rig parts held by GibSim's grind hold (24 ticks), shaken by the view, then
  gathered into a heap at his feet. FILMED (`film.mjs weapon:gatling --victim=cop/head_cap --ppm=64`, kill at 369):
  on a CARD victim on this branch the six GibCardCut bands drew only his legs, the upper bands lost under the splat;
  a heap of nothing. DECISION kills-new/shred-whole: the shred plays on the whole body copy like the other n16
  deaths: the pose track shakes him back (2-12 deg every 1-2 ticks, t0-24), KillShredArt tears 8 scraps (cloth or
  flesh with a bone fleck, 0.16 m, a red spurt) off his figure hip to neck every 3 ticks and flies them up to 1.4 m
  along the stream to lie on the street, and from t24 his drawn fall grid drops him back along the stream (12
  ticks). The six-part heap stays in KillShredArt as the data alternative (`pieces` = the six + `grind_ticks` 24)
  once kills-polish's drawn gib pieces (GibCardPieces.dress_rig) are merged. No hit-stop (the stream never stops).
- 12:52 MILESTONE `5b5ac0d49` Gatling. Evidence `evidence/n16-kills-new/gatling_shred_after_64ppm_patrol_t369-449.png`
  (t369-390 held upright, scraps leaving along the stream; t393 the drop; t400+ lying among the scraps).
  DEFECT open: at t393 the drawn fall's first frame sits ~0.5 m left of the standing copy (the copy is his HIT card,
  shoved off his feet by the earlier rounds; the stitch had the same and moved to the fall grid from the hit).
  Owed: a same-tick before (the standard death) and the 32 px/m film.
- 12:58 asset replies it414: pistol_snap p55 DELIVERED for patrol, riot (bald redraw) and SWAT (suit ped: no p55
  long_fall, so p55 falls back to the p70 suit cells; answer to them: yes, keep using p70 for the suit at p55, no
  extra drawing). smg_stitch patrol p70 sheets B, cells next asset session. Packed p55 (`kill_cells_pack.py
  --art=p55`), board by eye: snap/buckle/pitch/corpse in all 5 columns, the away corpse already the 3/4-away one.
- 13:00 Gatling same-tick A/B (`compare.mjs weapon:gatling --a=917064b44 --b=HEAD --native=donor`, patrol cop, kill
  t369) at 64 and 32 px/m: `evidence/n16-kills-new/gatling_shred_ab_{32,64}ppm_patrol_t{381,390,410}.png` + clips
  t355-460. At 32 px/m in the city block: before = already lying at t390; after = still held up with the scraps
  flying off along the stream, then down among them. Reads at play zoom. Variant (buckle frame from the hit,
  `fall_at`) filmed and rejected: `gatling_shred_variant_buckle_from_hit_64ppm_t369-449.png`.
- 13:05 MILESTONE `011bbe3a4` electro baton `baton_overload` (style `cook`, KillCookArt; beat sheet 5 as written, AS
  BUILT: hit-stop 3; t3-45 locked, a 1.5 deg buzz every tick (none under --reduced-motion), cream veins from the chest,
  a glow under the skin, steam puffs off collar/shoulders every 6 ticks, eyes two cream points out at t40; t45 the
  drawn fall grid back along the blow over 10 ticks; smoke 200 ticks; no blood). Kill reel `--weapons=electro_baton
  --dirs=0,225 --ppm=32,64`: all four PASS (kill at 68). Judged at 64 (`baton_overload_after_64ppm_dir0_t78-88-108_zoom.png`):
  glow, veins, eyes and steam read on the dark-blue cop; the eyes sat on the cap brim -> moved to 0.87 of his height
  (not re-filmed). NOT judged yet at 32 px/m by eye (sheet `baton_overload_reel_32ppm_dirs0-225.png` committed).
  No same-tick before (the standard baton death) yet: owed.
- Gates on `9a5ccf426`: full unit 2655 passed / 0 failed / 2 skipped (12:55, on `5b5ac0d49` + the p55 data).
- 13:08 item 6 scouted (no code): `burn_char` is keyed on weapon `burn` (the fire damage kind), so molotov and
  flamethrower reach the table as the same id: splitting them needs the kill event to carry the source weapon (or
  a `burn_molotov` kind at the molotov's fire): read `KillEvent.make` callers and the fire damage path first. The
  claw: `claw_shock` sits in kills-polish's `electro_shock.also_weapons`; a claw finisher row needs that entry moved
  (a shared-file edit: announce it in this JOURNAL and in theirs before making it).
- masters: `gtai-masters/n16/kills-new/` with `frames.json` (12 entries: pistol cells A/B 64, pistol reel, Gatling A/B
  32 + 64 + sheet, baton zoom, stitch A/B, pin street, 2 clips).
- 13:11 scenarios on `011bbe3a4`: 54/55 ok, `brutality_kills` FAILED "gatling landed 0 shred kills in 700 ticks":
  the kill lab tapped the trigger 1 tick, so the Gatling never spun up (the same cause as the reel's REQUEST 3).
  The tools lane had already served it (`0b5c55fc7`, kill_lab.gd `_held_ticks` holds a spun gun through its spin-up);
  taken game side only, identical content, in `e5e78bcbb` (+ their `test_kill_lab_held.gd`). Re-run
  `run_scenarios.gd -- --only=brutality_kills`: ok (44 s), with the Gatling and the baton in KILLS.
  New unit `test_kill_cook_shred.gd` (cook tremble only while cooking, none under reduced motion; shred tears its
  count on its ticks, off his figure). Selected units 19/19.
- 13:15 Gatling kill reel dirs 0/135/225 at 32 + 64 px/m: all six PASS (kill at 95, hit-stop held 0 measured):
  held up t95-115, down by t135 among the scraps in all three (`gatling_shred_reel_{32,64}ppm_dirs0-135-225.png`).
- 13:18 FRICTION: `compare.mjs kill:electro_baton` fails at once on this tree ("unknown shot kill": the `kill:` shot
  is in the tools lane's film tools, not this branch's); my wait loop on its log then burned 10 min. The baton's
  same-tick before is still owed: run the tools lane's copy (`node ../n16-tools/tools/film/compare.mjs kill:electro_baton
  --a=917064b44 --b=HEAD --native=donor --at=74,85,100,118,150`) or `kill_reel.mjs --before=` once the base has the lab.

### Asset status (asked, delivered, wired)
- pistol_snap: p70 patrol/riot/SWAT/suit WIRED (`74a345aaf`), loose cap/helmet WIRED (`e4fcf6448`), p55
  patrol/riot/SWAT WIRED (`9a5ccf426`; the suit at p55 uses p70, no p55 suit grid: tell the asset lane no extra drawing).
- smg_stitch: patrol p70 sheets B, cells promised next asset session -> `cop_patrol_smg_stitch_70_cells/`; riot/SWAT/suit
  and p55 not started. nail_pin, gatling_shred, baton_overload: not started (queued in the asset lane's order).

NEXT (iteration 9, in this order): (1) wire the smg_stitch cells when `gtai-art/library/keyed/street/cop_patrol_smg_stitch_70_cells/`
lands: `kill_cells_pack.py --death=smg_stitch`, add `cells` to the smg_stitch row (frame ticks from beat sheet 2: hip
0, belly 3, chest 6, neck 9, spin 10, lying 18), keep the drawn whirl only where the cells lack one; film compare
`--a=<before wire> --b=HEAD --subject=rivet` at 64 and the reel at 32; provenance lines. (2) the baton's same-tick
before/after with the tools lane's `compare.mjs kill:electro_baton` (see FRICTION 13:18) and judge it at 32 px/m by
eye (the eyes now at 0.87: check they sit on the face). (3) the Gatling's sideways jump at the drop (t+24): offset
the fall grid to the hit card's drawn feet (StreetWalkerHit.shove) rather than the copy's origin, or ask the asset
lane for the shred cells. (4) Gloria's WALL case: film it (tools REQUEST 2 `--victim-wall` still open). (5) item 6:
molotov vs flamethrower (both are weapon `burn` in the table: needs the source weapon on the kill event) and the
claw finisher (`claw_shock` lives in kills-polish's electro_shock row: announce before moving it). (6) the full
gates on the last code commit: lint, full unit, scenarios (54+1 ok as of 13:11 + brutality re-run ok), the evidence
run (parity + look goldens), the reel gate; REPORT.md by 19:40 with a Calls line per death (pistol, stitch, pin,
shred, overload) and its 32 + 64 px/m stills from `gtai-masters/n16/kills-new/frames.json`.
## Iteration 12 (2026-11-11 13:30, BUILD; iterations 9-11 left no journal or commits)

- 13:30 read JOURNAL, git log, replies: smg_stitch p70 DELIVERED for all four kinds (it418), nail_pin p70 for patrol,
  riot (13:29) and SWAT (13:33); the steel nail cells `keyed/fx/nail_70_cells/1_{1,2,3}.png` (301 px).
- 13:33 stitch wired: `kill_cells_pack.py --death=smg_stitch` (5 facings x 5 frames), row `cells.at` [0,4,7,10,18]
  (hip wound t0, two t4, three + cap tipping t7: the rounds land at 1/4/7/10 after hit-stop 1; the drawn spin t10-18
  turned a full circle by KillStitchArt.facing; on his side from t18). fx `cells_lean` 1 (new, KillDeathCells.lean_of:
  the stitch keeps its jerks on drawn frames; the pistol's 0 holds the drawing). The ink holes drop on own cells (the
  drawing carries the wounds); the coded spurts stay.
- 13:36 MILESTONE `099b7c514` drawn stitch cells. Same-tick A/B 64 px/m patrol cop (`compare.mjs weapon:machine_pistol
  --a=HEAD --b=. --victim=cop/head_cap --ppm=64`, all 7 ticks PASS): `evidence/n16-kills-new/stitch_cells_ab_64ppm_patrol_t342-380_zoom.png`
  + `_t330-400.mp4` + `_t349.png`. Judged by eye: t342-349 the wounds climb, the cap tips off, t353 the spin, t358+ on
  his side curled; the placeholder at t365 is the long face-down fall grid. Asset fault seen: column 1 frame 3 shows a
  doubled cap (known, one beat). DEFECT FOUND at 3x zoom (`stitch64/zoomB.png`): the drawn frames show his BACK to
  Rivet (exit wounds and the drawn spurts toward the shooter): own cells were faced by the fall direction like the
  fall grids. The long_fall grid is a FORWARD fall (column 1 = the figure facing the camera, lying head toward it),
  so face(angle) = he looks along angle. The pistol's forward fall faced -dir by luck of its fall; fix below.
- DECISION kills-new/own-cells-face: a death's own drawn cells face the SHOOTER (-dir) while upright; the drawing
  carries which way he falls. The stitch whirls from there a full turn onto the fall side. Fall-grid placeholders
  keep their fall-faced columns.

### Beat sheet 3 AS DRAWN: Gloria nail_pin cells (patrol, riot, SWAT p70; suit next asset session)
- Frames: 1 pinned upright (a nail through each sleeve top, arms out, head slumped, blood from the sleeves), 2 the
  same pinned with the knees drawn up (the writhe), 3 on his back on the street, both hands at the nailed boot, the
  cap/helmet beside him. Packed with frame 1's feet on the cell centre (`UPRIGHT_BY_DEATH`).
- Wall case (a wall within 1.4 m behind): hit-stop 2; t0 frame 1 (arms flung back as the nails streak in), carried
  back onto the wall over 6 ticks, lifted 0.12 m; t10-90 the writhe = frame 2 on the writhe's positive peaks (the
  knees jerk up), frame 1 between; it dies out; hangs on frame 1. No lean on the wall (he is nailed).
- Street case: t0-8 frame 1 (arms flung as the nails hit), t8 frame 3 on his back clutching the nailed boot, rocking
  with the writhe at 0.5 of its lean (fx cells_lean). Aftermath: the pinned/lying body, its drawn nails.
- Hit-stop 2 (unchanged). The coded nail stubs drop on own cells (the drawing carries them); the streaks stay.
- 13:39 stitch reel started then KILLED by PID (taskkill /T 102096): it was filming the wrong-facing stitch. Dir 0
  32 px/m had PASSed (kill at 174) before the stop; nothing kept.
- 13:43 MILESTONE `953d2972e` nail_pin cells (patrol, riot, SWAT p70) + own cells face the shooter (KillDeathCells
  .face_of/.step; the stitch fix) + the tools lane's `--sig-wall` lab (bbee28a9c game side, identical content:
  kill_lab_turn.gd, brutality_hook.gd line 67, test_kill_lab_turn.gd). Unit test_kill_death_cells (face, pin frames
  by case) + kill_lab_turn + kill_new_styles + cook_shred + signature_kills 34/34 + 15/15. FRICTION: debt ratchet
  (kill_new_styles.gd 205 lines past the soft cap) on the first try: the own-cells step moved to KillDeathCells.step.
- REPLY to the asset lane (gtai-assets): smg_stitch p55 can WAIT behind nail_pin suit + gatling + baton at p70; the
  suit pistol at p55 uses p70 (no extra drawing).
- REQUEST assets: order from here (13:45): (1) nail_pin p70 suit ped (as planned); (2) gatling_shred p70 and (3)
  baton_overload p70 for patrol, riot, SWAT, suit (beat sheets 4 and 5 above; same cell layout as the stitch, cut to
  each kind's long_fall grid, figure FACING THE CAMERA in column 1 = facing the shooter); (4) only then smg_stitch and
  nail_pin at p55. The suit ped's pistol_snap at p55: use p70, no drawing needed. All delivered cells so far wired.
- 13:50 Gloria kill reel (`../n16-tools/tools/film/kill_reel.mjs --weapons=gloria,machine_pistol --dirs=wall,135
  --ppm=32,64 --clips`, on `953d2972e`): gloria wall (kill 65; lab: "dir 235, guard 3.95 m, wall 1.00 m behind him",
  a parked car) and dir 135 (kill 64) PASS at both zooms. Judged by eye:
  WALL (`evidence/n16-kills-new/nail_pin_cells_reel_64ppm_wall_t63-215.png`, `_32ppm_wall_crops.png`, clips): kill+2
  the nail streaks and the pinned frame, slammed back against the car; kill+6..+40 the knees jerk up and drop on the
  writhe's peaks, blood from the sleeves running down; kill+150 hangs pinned. Faces Rivet. Reads at 32 px/m as a
  spread-eagled figure on the car's flank.
  STREET (`nail_pin_cells_reel_64ppm_dir135_t62-214.png`): kill+0..+6 the pinned flinch, arms flung (from Rivet's
  side, above, the camera sees his back: correct for a top-down view of a figure looking up-screen), the streaks at
  +2; from +10 on his back, feet toward Rivet, both hands at the nailed boot, the cap beside him, blood behind.
  Defect: the lying cell sits ~0.4 m off the standing spot (the asset lane centred frame 3 on the grid's corpse).
- 14:02 stitch after the facing fix (same reel, machine_pistol dirs wall + 135, all four PASS, kill at 174/175):
  `evidence/n16-kills-new/stitch_cells_reel_64ppm_dir135_t174-324.png` (+ 32 px/m sheet `_reel_32ppm_dirs-wall-135.png`,
  clips dir 135 at 32 and 64). Judged: kill+0..+4 the wounds climb, the spurts and blood go AWAY from Rivet now (the
  pre-fix A/B `stitch_cells_ab_64ppm_patrol_*` shows the defect: his back toward Rivet); +6 the cap tips off; +10
  the drawn spin; +20 on his side, curled, ~0.5 m down-shot of where he stood (the corpse cell's own centre).
- 14:05 GATE full unit on `953d2972e` (+ evidence-only de40a1dcd): 2666 passed / 0 failed / 2 skipped (208 s).
- 14:08 masters `gtai-masters/n16/kills-new/frames.json` now 14 entries: the stitch reel crops (after the facing fix),
  Gloria wall 64 + 32 crops and street 64 on top; the two superseded entries and their files removed.
- 14:10 Gatling sideways jump at the drop, read only (no fix): KillFallCells.feet_of takes the hit-card copy's
  position, but StreetWalkerHit.shove also LEANS the card (z = side * LEAN * e), so the copy's drawn feet are not at
  its origin; the fall grid's first frame lands on the origin. Fix candidates: rotate the feet by the copy's lean
  about its pivot, or start the fall grid from the copy's drawn feet. Moot once gatling_shred cells land (requested).
- 14:13 baton same-tick before/after: kill reel `--weapons=electro_baton --dirs=0 --ppm=32,64 --before=5b5ac0d49`
  (the last commit before 011bbe3a4) running.
- 14:23 baton same-tick before/after (kill reel `--before=5b5ac0d49`, dir 0, 32 + 64, all four PASS, kill at 68):
  `evidence/n16-kills-new/baton_overload_ab_{64,32}ppm_dir0_t66-218.png` (top before, bottom after), the reel's 32 px/m
  sheet, the before clip. Judged by eye: BEFORE (the standard baton death) knocks him flat by +10 into a large red
  pool. AFTER: locked upright +1..+40 with the cream glow on his chest and the eyes, down at +45, clean. At 64 the cook
  reads; at 32 px/m it reads only as a light flare on his chest (veins and steam are lost) and the corpse leaves
  NOTHING on the street, so the aftermath beat is missing. The eyes at 0.87 sit on the face (+10..+40 at 64).
- DECISION kills-new/baton-scorch: the overload leaves a 0.3 m ink scorch where he stood (the current earthing
  through his boots; `scorch_radius_m` 0.3, data only, the existing KillMarks scorch: ink, no red, no RNG), so the
  aftermath stays on the street. Rejected: blood (the cook has none by design). 0 restores the clean street.
- 14:28 `227294f8b` baton scorch (scorch_radius_m 0.3); kill reel dir 0 at 32 + 64 on it: NO visible mark where he
  stood (`evidence/n16-kills-new/baton_overload_scorch_{32,64}ppm_dir0_t69-218.png`). Read: KillMarks' scorch is ink +
  soot, the victim stood on dark asphalt; `scorch_m` is not in KillMarks.write_state, so replay was never at risk.
  REVERTED in `d1ab2f3c3`; DECISION kills-new/baton-scorch above is WITHDRAWN. The overload's aftermath still owes a
  LIGHT mark (cream ash ring / a cream "burnt-out" print, or the drawn smoking cells from the asset lane).
- FRICTION: a kill reel's "after" side: filmed with the change uncommitted and then committed, the frames were the
  same; the cause was the dark street, not the root. Not a tools issue.

NEXT (iteration 13, in this order): (1) asset replies: wire nail_pin suit p70 when it lands (`kill_cells_pack.py
--death=nail_pin`, add `ped/head_hair` to the row's grids, provenance line), then gatling_shred / baton_overload cells
(add `cells` with frame ticks from beat sheets 4/5; the shred's held-upright frames from t0, the drop at 24; the cook's
locked frames from t3, eyes out at 40, fall at 45). (2) the baton's aftermath: a light mark that reads on asphalt at
32 px/m (a cream ash ring in KillCookArt drawn on the street from the fall, data `fx.ash_ring_m`), film dir 0 before/
after at 32. (3) Gatling drop jump (see 14:10 read: lean the copy's feet by StreetWalkerHit.shove's z). (4) the pin's
lying cell ~0.4 m off: shift frame 3 per column so its body centre sits on the standing feet (pack-time `--lie-anchor`).
(5) item 6: molotov vs flamethrower; the claw finisher (announce the kills-polish row edit first). (6) gates on the
last code commit (`d1ab2f3c3`): full unit (2666/0/2 on 953d2972e), scenarios, `tools/evidence/run.mjs` (parity + look
goldens), the reel gate `node tools/reel/run_reels.mjs`; REPORT.md is drafted (finalise by 19:40 with the Calls).
- 14:36 GATE scenarios on `d1ab2f3c3`: 55/55 passed (`node tools/tests/run_scenarios.mjs`).
- 14:38 MILESTONE `26b2bc2a6` nail_pin suit ped cells (nail_pin complete at p70 for all four kinds; grid looked at:
  pinned, a real writhe with the head thrown aside, on his back at the nailed shoe).
- 14:40 MILESTONE `b083b6d5a` baton_overload drawn cells for patrol, riot AND SWAT (SWAT landed meanwhile): cells.at
  [0,20,40,45] (locked + veins; brighter + arcs + steam; sagging + smoke; on his back smoking in a grey soot ring);
  KillCookArt's coded glow/veins/eyes step aside on own cells, steam and smoke stay. Unit 34/34. Kill reel dir 0 at
  32 + 64 PASS (kill 68): `evidence/n16-kills-new/baton_overload_cells_{64,32}ppm_dir0_t69-218.png` (crop centred on
  the standing spot; the camera drifts, so the corpse is cut at the left in the later tiles) and
  `baton_overload_cells_64ppm_dir0_corpse_t108-218.png`, clips `_cells_reel_{32,64}ppm_dir0.mp4`. Judged: the drawn
  veins of light, the arcs and steam at +20 and the sag at +40 read far better than the placeholder's chest flare,
  at 32 px/m too. DEFECT: the corpse frame lies head TOWARD Rivet (the long fall's corpse direction, faced at the
  shooter), not knocked back along the blow; the soot ring is faint on asphalt. Fix next: face the last frame along
  +dir (a per-row fx, e.g. `cells_turn_at`), then judge again.
- Asset status now: gatling_shred p70 patrol/riot/SWAT DELIVERED (frames 1-3 + 6 scrap cells `4_{1..6}.png`: the pack
  must skip row 4, frames_of() would count it); the suit's gatling redraw and the suit's baton follow.

NEXT (iteration 13, replaces the list above): (1) wire gatling_shred cells (patrol, riot, SWAT): teach
`kill_cells_pack.py` a `--frames=3` (row 4 is the scraps), pack the scraps as KillShredArt's drawn scraps (0.15-0.3 m),
cells.at e.g. [0,12,24]; judge vs the shred placeholder at the same ticks (the sideways jump goes with it). (2) the
baton corpse faced back along the blow (above). (3) gates on the final code commit: full unit, scenarios (55/55 on
d1ab2f3c3), `tools/evidence/run.mjs`, `tools/reel/run_reels.mjs`. (4) the pin/stitch corpse offset; item 6 (molotov
vs flamethrower, the claw). REPORT.md is drafted: update its table (nail_pin suit, baton cells) and Calls by 19:40.

## Iteration 16 (14:45-16:15)
- 14:46 asset replies read: baton_overload p70 suit + SWAT re-cut (navy shift) delivered 14:43; gatling_shred p70 all
  four kinds delivered (patrol 13:51 A, SWAT 14:20 B, riot 14:25 B/A, suit 14:34 B). All wired this session.
- 14:55 MILESTONE `590902959` baton_overload suit ped cells (the four kinds complete at p70); SWAT re-packed from the
  navy-shifted re-cut (grid looked at: frames 2-4 now a scorched navy, no slate-teal).
- Shared-file note: no kills-polish file touched. Edited (all mine since n16): kill_shred_art.gd, kill_loose_art.gd,
  kill_death_cells.gd, kill_track_rows.gd (one Extra field `scraps`), the schema (`cells.scraps`, additive).
- 15:20 MILESTONE `040ffb67a` gatling_shred drawn cells for patrol, riot, SWAT, suit: cells.at [0,12,24] (shaken back
  with spray behind; sagging/kneeling over cream ribs, headgear off; the heap with a torn-off arm), cells_lean 0.6
  (the stream still shakes the drawn frames), the six drawn scraps per kind (`cells.scraps`, `<kind>_gatling_shred_
  scraps.png`, scrap_cell_m 0.25, spinning in flight) in place of the coded polygons. Pack tool: FRAMES_BY_DEATH
  (row 4 = scraps) + the scraps strip. Unit 41/41 (kill files), full lint 19/19.
- DECISION kills-new/corpse-turn: a death's drawn corpse frame may turn to look ALONG the blow (fx `cells_turn_from`
  = the frame index; -1/absent = never), because the asset lane lays each column's corpse head the way its figure
  looked, so a figure faced at the shooter lies head TOWARD Rivet (fell forward). The shred's heap (2) and the
  baton's last frame (3) turn: both are knocked back. The pistol keeps the face-down fold (its brief). Rejected: a
  re-draw per kind (owes the asset lane 8 sheets), a pack-time column swap (fixes one pitch only). Restoring the old
  look = delete the fx key.
- 15:40 item 6 read (molotov vs flamethrower): the sim emits weapon `burn` for EVERY fire death (FightAreas._burn ->
  arena.damage(h, .., e.burn_by, &"burn", &"burned")), so the view cannot tell the molotov from the flamethrower.
  Plan (no replay move): FighterFx gains `burn_src: StringName` (NOT in write_state), set in FightAreas._strike from
  the shot's spec id and to &"molotov" by a fire patch; BrutalityHook._on_kill_landed asks it when weapon == burn and
  routes the kill to the `molotov` row when the source is the molotov. Gunplay's files (fighter_fx.gd, fight_areas.gd)
  are not kills-polish's; a decisions line names the field as view-only. Unit: the field stays out of write_state
  (hash identical with and without it set). Not started this session.
- BEAT SHEET 6a molotov_torch (the molotov's own death; burn_char stays the flamethrower's char-and-crumble):
  the burning man does not stop and char where he stands: the spirit soaked into his clothes keeps burning on him.
  Anticipation: the sim's burning panic run (already there). Impact t0 (hit-stop 0; the fire killed him, no blow):
  he drops to his knees mid-stride, arms thrown up, a sheet of drawn flame over his back and shoulders (frame 1,
  facing ALONG his run, `cells_turn_from` 0). t10 doubled over on his knees, flames taller (frame 2). t20 he folds
  face down along the run (frame 3, burning). t20-180 the drawn flames keep licking on the body (coded flicker
  between frames 3 and 4, then frame 4 alone): t180 frame 4, a blackened (ink, not ash) body face down, smouldering,
  the broken bottle neck and glass ring beside him; smoke for 200 ticks. No blood. Camera: a 2-px shake at t0 only
  (dropped under --reduced-motion). Reads at 32 px/m as a kneeling bright flame column, then a long burning shape.
- REQUEST assets: molotov_torch cells (NEW death), patrol cop / riot cop / SWAT / suit ped, p70 (p55 later), the
  kind's long_fall grid cells, 5 columns in the grid's facing order, column 1 = facing the camera. 4 frames down:
  (1) dropped to his knees, arms thrown up, a sheet of flame over back and shoulders (amber/cream fire with ink line,
  no vermilion, no teal) (2) doubled over on his knees, the flames taller (3) face down, still burning, flames along
  the back and legs (4) the same pose charred black (ink), smouldering, a broken bottle neck and a little glass ring
  beside him, no blood. Frames 1-2 on the standing feet; frames 3-4 lying FACE DOWN with the head the way the figure
  looked (as the pistol corpse). Priority after the p55 stitch/pin round.
- 15:15 item 6 BUILT (placeholder, uncommitted until the reel frees Godot): DECISION kills-new/molotov-torch (in
  docs/decisions.md). The source plumbing is VIEW side after all (`KillFireSource`: CombatArena.struck records the
  last fire weapon per fighter; BrutalityHook names a `burn` kill by it; no record = a walk into a ground fire =
  the molotov's). The FighterFx field was rejected: gunplay's sim file and fight_areas.gd is pinned at 222 lines on
  the debt ratchet. Row `molotov_torch` (style `torch`, KillTorchArt): squash to the knees t0-6, sag t6-16, the fall
  grid face down along the run from t16, 6 amber/cream flame tongues (0.32 m) up the figure then along the body to
  t180 (shrinking from t120), smoke after (KillCookArt.smoke, now public). hit-stop 0. brutality_hook.gd's header
  doc reflowed (5 lines) to stay at 200 lines.
FRICTION: the kill reel's after side films the live tree: uncommitted code (a new class not yet imported) broke 'after gatling dir 0 64' with SCRIPT ERROR; stopped by PID 100504 tree. Film from --rev=<commit> while editing.
