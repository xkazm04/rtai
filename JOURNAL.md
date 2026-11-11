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
