# REPORT lane combat, run n30 (2026-11-25, day run) — DRAFT (session 2, 12:40; final at 18:55)

Branch `n30-combat`, worktree `gtai-wt/n23-street`, cut from `main` `5114a4441`. Director Opus 5.5; builders Claude
sub-agents (Agent tool; Sonnet 5.5, Opus 5.5 for the card fall). Films and stills: `C:/Users/kazda/kiro/gtai-masters/n30/combat/`
(`frames.json`). IMAGES 0/25: every change is code, data or a masked recolour of shipped pixels.
Final gate: (pending).

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
- Open: the nuke's 39 stripe-edge px (session 2 call c07b).

### 4. Explosion light rim amber through a new palette token — (session 2 call c04)

### 5. A killed card foe falls on his own fall sheet (`480268dcf`, `0351c7020`, evidence `1c14f5010`, `7d221357f`)
- `KillCardFall.path_of(rig)` routes `sheets.fall` into `KillFallCells.attach` at `scale_of`, faced as the grid.
  `--kill-card-fall=grid` = before. Every enabled card row (mulroney, warden, contractor, trooper; robot_thug once on)
  has a usable 5x3 fall sheet: no generic-grid fallback. Units 14/0 (25/0 with kill_new_styles + claw_card_victims);
  mutate 14/16 = 87.5 % (the 2 flag-read survivors covered by `0351c7020`).
- Stills `stills/card_fall_{sergeant_mulroney,appliance_warden,rocket_trooper}_pair_64.png` (t173/196/214); film
  `films/card_fall_32.mp4` 1920x1080 60/1 15.15 s. `evidence/n30/kills/card_fall.md`.

## What does not
- (pending)

## What blocked or slowed you
- Session 1: c07 (nuke specks) lost its take to a 240 s timeout under machine contention (10 min).

## Calls for the owner
- Thin hop/stun: the thin stars read cream/tan at 3 px (`THIN_BODY_PX` 4 = more amber, one value). `stills/stun_thin_pair_64.png`.
- Card fall: a card foe no longer takes a kill style's street-row cells (they were another kind's drawing: the patrol/SWAT
  cop's stitch wounds), only `*` cells or his own sheet. `stills/card_fall_sergeant_mulroney_pair_64.png`.
- The `fire` light kind is still vermilion (not in the picks; heat by colour law would make it amber).
- Warden's fall sheet draws his head ~1.4-1.5x his walk at the switch (kill and living death alike): NEED cast.

## Merge notes
- After merging `n30-cast` (`c2281acbb`, cop build +-8 %): `project/features/combat/kills/kill_fall_cells.gd:95`
  becomes `var k: float = StreetCrowdCards.body_scale_of(rig)` (cast's NEED combat: a killed street cop is sized at the
  crowd's +-16 % while his living card draws at +-8 %; `body_scale_of` exists only on n30-cast, so it cannot be done here).
- `--kill-card-fall` was added to `KNOWN_FLAGS` (debt accepted, launch_args 226 -> 227).

## Next steps
- (pending)

## Builder ledger
- c01 reel-legacy 5 min accepted; c02 thin-hop 29 accepted; c05 card-fall (Opus) 68 accepted; c03 round-band 39 accepted
  (one send-back: edge fringe); c06 decisions 1 accepted; c07 nuke-specks 10 abandoned (clock + contention).
