# REPORT lane combat, run n30 (2026-11-25, day run) — DRAFT (session 2, 12:40; final at 18:55)

Branch `n30-combat`, worktree `gtai-wt/n23-street`, cut from `main` `5114a4441`. Director Opus 5.5; builders Claude
sub-agents (Agent tool; Sonnet 5.5, Opus 5.5 for the card fall). Films and stills: `C:/Users/kazda/kiro/gtai-masters/n30/combat/`
(`frames.json`). IMAGES 0/25: every change is code, data or a masked recolour of shipped pixels.
Gate on the last code commit `3398da308` (14:29-14:48): `gate: PASS` (lint 19/19 over 2294 GDScript files; unit 4330
passed, 0 failed, 2 skipped; scenarios 68 passed; parity bit for bit over 1200 steps, planted mutation caught at step 629;
selftest; export-audit 1004 loaded, 0 failed), `build/gate/3398da308002/gate.json` (the earlier gate on `2566b97d0` also PASS).
Later commits: docs, JOURNAL, REPORT, evidence.
`--reels` once after the freeze: (pending).

## What works

### 1. `kill_reel.mjs` passes `--controls=legacy` by default (`73895c4a3`)
- `withControls(flags)` in `planFilm` (every film incl. `--before`/`--rev`); a passed `--controls=` wins. Node test;
  `tools/film/*.test.mjs` 292/292.

### 2. Chain hop and daze stars back to the thin look; bold only for the bolt (`a0f9c8bed`, evidence `fde0b1f4c`)
- Hop + daze stars: 3 px amber body, 1.5 px cream core, no ink, the n28 kink (no `JAG_K`). The bolt in flight keeps
  10 / 4 / ink 13 + `JAG_K` 3: bolt tick 114 whole frame 0 px diff.
- Hop box at t121: amber 1056 -> 10, red 0, teal 0; stun box amber 373 -> 0 (the thin stars read cream/tan). Units 31/0;
  mutate 10/12 = 83.3 % (2 equivalent). `evidence/n30/electric/thin.md`.
- Stills `stills/hop_thin_pair_64.png`, `stills/stun_thin_pair_64.png`; film `films/hop_thin_32.mp4` 1920x1080 60/1 18.0 s.

### 3. Rivet's rocket and nuke nose band amber (`42e7af756`, `201763968`, evidence `b67599ee5`)
- Masked recolour (value and alpha kept, 0 PNG px changed > 1 px from the band core). In game at 64 px/m: rocket t836
  vermilion 91 -> 0, amber 0 -> 84; nuke t1212 1048 -> 39, amber 0 -> 957; 0 px diff outside the round boxes.
- Stills `stills/round_band_{rocket,nuke}_pair_64.png`; film `films/round_band_32.mp4` 1920x1080 60/1 25.0 s.
- The nuke keeps 39 vermilion px (of 957 amber) on the stripe edges: darkening the sprite's edge px made it worse in game
  (39 -> 71 / 60 / 55 at value caps 0.30 / 0.14 / 0.09; `74b56e6db`, `evidence/n30/rounds/band.md`): the print blends the
  amber with the stripe ink one px out. Not landed.

### 4. Explosion light rim amber through a new palette token: token and data in, NOT on screen (`d4b6aabcc`, `199faedc7`, `aa824a4da`)
- `palette.json` token `amber` `#EDAB42` (role accent, no accents row: r - max(g,b) 0.26 < verm_gate 0.31, the accent audit
  does not move); `lights.json` explosion `alt_token` vermilion -> amber; `test_light_explosion_amber.gd` (3 tests).
  Units 25/0 with the palette/light tests. Cost: one light per blast, unchanged.
- It does not reach a pixel: `light_pool.gd:71-72` uses `alt_color` only for a strobe (`flicker_hz > 0`) and the shader prints
  one ink per light, so the explosion never had a vermilion rim on screen (n29's call read the row's doc). Probe: the nuke's
  light starts t478 and draws t480-513 (~421k px on/off at t480-496); a rocket blast right after launch is refused by the
  photosensitivity budget. Ready patch for the Director: `evidence/n30/lights/rim_patch.md` (rim flag, alt ink packed into
  the instance custom data, the shader prints the outer band in it). Still `stills/explosion_light_seen_64.png` (t486 off | on).
- Proven on screen and shipped as one command for the Director (`3398da308`): `git apply evidence/n30/lights/rim.patch`
  (8 files: shader, `LightPool.custom_data`, lights.json `rim` + schema, the comment, two tests), then
  `node tools/tests/run_unit.mjs --select=test_light_pool_rim,test_light_explosion_amber,test_light_layer` (15/0 patched;
  lint 19/19). At t486 64 px/m the outer bands go cream -> amber (mean RGB of changed px 255,241,187 -> 255,235,161),
  red/teal/vermilion added 0, one light as before. Still `stills/explosion_rim_patched_pair_64.png`. `evidence/n30/lights/rim_proof.md`.
- 32 px/m film with the patch applied (`591d4cacf`, patch reversed after): `films/explosion_rim_after_32.mp4` 1920x1080 60/1 25.0 s
  beside `films/round_band_32.mp4` (same chapters): the films differ only at 8.17-8.3 s (the light's life on screen); at 8.2 s
  the blast centre prints warmer amber (`stills/explosion_rim_32_pair.png`, ~8k px at 1080p).

### 6a. `current_look.gd` draw() survivors pinned (`5fd6c1eaa`, `2566b97d0`)
- `CurrentLook.k_of(ci)` and `const ANTIALIAS` carry draw()'s scale and AA flag (pixels identical by construction); 4 tests,
  units 12/0; mutate on those lines 4/5 = 80 % (survivor: deleting the `draw_polyline` call, only a GPU readback sees it).
  `evidence/n30/mutate/current_look.md`.

### 5. A killed card foe falls on his own fall sheet (`480268dcf`, `0351c7020`, evidence `1c14f5010`, `7d221357f`)
- `KillCardFall.path_of(rig)` routes `sheets.fall` into `KillFallCells.attach` at `scale_of`, faced as the grid.
  `--kill-card-fall=grid` = before. Every enabled card row (mulroney, warden, contractor, trooper; robot_thug once on)
  has a usable 5x3 fall sheet: no generic-grid fallback. Units 14/0 (25/0 with kill_new_styles + claw_card_victims);
  mutate 14/16 = 87.5 % (the 2 flag-read survivors covered by `0351c7020`).
- Stills `stills/card_fall_{sergeant_mulroney,appliance_warden,rocket_trooper}_pair_64.png` (t173/196/214); film
  `films/card_fall_32.mp4` 1920x1080 60/1 15.15 s. `evidence/n30/kills/card_fall.md`.
- A street walker (no card) takes the old path untouched: kill_reel `--before=73895c4a3 --rev=HEAD`, machine pistol,
  64 px/m, street cop: 0 px differ in the whole frame at 9 ticks t172-234 (`65739e6f2`, still
  `stills/street_fall_identity_pair_64.png`). The split rule's last mutate survivor (`or`->`and`) is killed by
  `KillCardFall.splits` + its test (`1444843f3`, mutate 4/4 on the line; whole file 5/6 before it).

### 6b. A natural bond film (`a8cfd67fa`)
- Seed 1, average bot, no prefill: Tonnage's bond 12/32/48/52/64/68/70 by release, full at t7937 (wave 7), the mastery card
  at t8774, mastered and Tonnage entered at t8775 (146 s of play, 7 releases), matching n29's measured seed 1.
  Film `films/bond_natural_32.mp4` 1920x1080 60/1 29.87 s. `evidence/n30/bond/natural.md`.

## What does not
- (pending)

## What blocked or slowed you
- Session 1: c07 (nuke specks) lost its take to a 240 s timeout under machine contention (10 min).

## Calls for the owner
- Thin hop/stun: at 3 px (shipped) the hop line and stun stars read cream/tan; at 4 px (`THIN_BODY_PX`, one value) they keep
  thin but gain a clear amber/gold edge, most on the stun stars. `stills/thin_3_vs_4_pair_64.png` (`2d661435b`); pick 3 or 4.
- Card fall: a card foe no longer takes a kill style's street-row cells (they were another kind's drawing: the patrol/SWAT
  cop's stitch wounds), only `*` cells or his own sheet. `stills/card_fall_sergeant_mulroney_pair_64.png`.
- The `fire` light kind prints vermilion (its main token, strobing with paper at 2.5 Hz). With the new `amber` token,
  `lights.json` fire `"token": "amber"` is a one-value change (heat by the colour law); not in the picks, not done.
- A short-flight rocket's blast gets no light: its launch muzzle flash spent the 1/s photosensitivity budget
  (`FlashBudget.spend_light`). Letting a blast win changes the photosensitivity behaviour: owner call.
- Explosion rim (patch, not merged): over the nuke's own amber floor the amber rim reads weakly (low contrast;
  `stills/explosion_rim_patched_pair_64.png`). A deeper ink for the rim is one value (the alt token's colour); apply as is, or deeper.
- The nuke's amber blast floor prints vermilion specks on its ink edges (`stills/explosion_light_seen_64.png`), the same
  print snap as the band's last 39 px.
- Warden at the switch to his fall sheet: NOT a size fault (cast c06b measured delivered frames at 64 px/m: cap walk / hit /
  fall p70 36 / 28 / 28-31, p55 30 / 23 / 22-31; our "1.4-1.5x" was a wrong reading of the walk). What changes is the angle
  (steeper top-down walk, frontal fall) and the hat (grey bucket -> tan camo cap): a one-row hat recolour of his walk, or keep.
  `gtai-masters/n30/cast/warden_switch_64.png`. The NEED cast is withdrawn.

## Merge notes
- After merging `n30-cast` (`c2281acbb`, cop build +-8 %): `project/features/combat/kills/kill_fall_cells.gd:95`
  becomes `var k: float = StreetCrowdCards.body_scale_of(rig)` (cast's NEED combat: a killed street cop is sized at the
  crowd's +-16 % while his living card draws at +-8 %; `body_scale_of` exists only on n30-cast, so it cannot be done here).
- `--kill-card-fall` was added to `KNOWN_FLAGS` (debt accepted, launch_args 226 -> 227).

## Next steps
- (pending)

## Builder ledger
- Session 2: c04 explosion-rim 30 accepted-partial (data in, its takes missed the light: brief should have named the tick
  the light is live and a lights-off control at that tick); c07b nuke-specks 24 accepted (negative result); c04b light-probe
  (Opus) 6 accepted; c08 current-pin 24 accepted; c11 decisions 1 accepted.
- c01 reel-legacy 5 min accepted; c02 thin-hop 29 accepted; c05 card-fall (Opus) 68 accepted; c03 round-band 39 accepted
  (one send-back: edge fringe); c06 decisions 1 accepted; c07 nuke-specks 10 abandoned (clock + contention).
