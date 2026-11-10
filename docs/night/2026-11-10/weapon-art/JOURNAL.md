# JOURNAL: lane n13-weapon-art, 2026-11-10

Branch `n13-weapon-art` in `C:\Users\kazda\kiro\gtai-wt\n13-weapon-art`, cut from main `0e5e1e19d`.
Brief: `BRIEF.md` beside this file (committed alone, `2f03b0024`). Scratch: `build/n13/` (git-ignored:
film.sh, strip.py, zoom.py, abf.py, ab_sheet.py, d1sheet.py, abmp4.sh, the films). Masters (films,
stills, `frames.json`): `C:\Users\kazda\kiro\gtai-masters\n13\weapon-art\`. Godot: the launcher's
known path `gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; every windowed run with
`--position 0,1440`. Native DLLs as copied from n12 (release md5 7995c493), untouched.

## Setup
- Brief committed by path (`2f03b0024`; the hook ran lint 15/15).
- First `--import` exit 0, 0 ERROR (2 m 13 s); `dev/bake_city.gd` 256 chunks, 0 SCRIPT ERROR.
- Films: `build/n13/film.sh <label> <ticks> <flags>` = n12's sync/film.sh (editor binary, d3d12,
  1280x720, Movie Maker MJPEG, `--fixed-fps 60`, the arena at `--ppm=32 --rigs --clean`, FightFrames
  log for frame -> tick) plus `--position 0,1440`. A director chapter needs `--loadout=pistol` (without
  it the chapter is skipped: my first sword film showed a bare claw; the log says so).

## Item 1: plasma sword, treatment B (heavier ink rim)

### Audit
- `sword-before` (`--bot=reel --reel=director --chapter=plasma_sword --loadout=pistol`, 330 ticks):
  rest cell ticks 52-58, the side strike from tick 59 (hit 61, held to 63), back to the facing at 86.
- The strip is cut by `tools/art/rivet_frames.py --manifest` from the library sheet
  (`rivet_eq_plasma_sword_70_v2.png`, p55 `_55_v4`); re-running the cutter reproduces both shipped
  strips byte for byte (p70 1944x161, p55 1688x128), so a manifest key is a clean before.
- The n12 B candidate was made by an uncommitted PIL pass. Read back at strip scale (the 3x candidate
  is NEAREST, so every third pixel is the strip): it is solid ink (27,21,23) laid on the cutter's soft
  halo (alpha < 160) 1-2 px outside the silhouette, plus a few edge pixels; no colour inside the blade
  changed. It also inked part of the body's halo and left stray ink dots on the side strike's drawn
  arc (cell 5).

### Change
- `tools/art/blade_ink_rim.py` (new): per cell, the blade's core = the largest run of its glow; its
  plate = opaque pixels within `reach` px of it; ink = the darkest decile of the plate's outline (the
  plate's own line, no new colour); the soft halo outside the plate out to `px` turns solid ink,
  falling off over one more pixel; bright soft pixels (the arc) are never painted. Blade only (the
  owner's B label is "heavier ink rim round the blade").
- Fit to the n12 candidate on its cells 0 and 5 (pixels within reach of the blade): px 0.5 reach 4
  matched 37/53 and 57/79 of B's changed pixels with about as many of its own; reach 6 also catches the
  spine's top edge (B inked it), so shipped px 0.5 reach 6. px 1.0+ was visibly heavier than B.
- `rivet_frames.py --manifest`: a row's `ink_rim` ({px, reach}) runs the pass after the cut;
  `--no-ink-rim` skips it. `rivet_frames.json`: `ink_rim` on p70 and p55 `rivet_eq_plasma_sword`.

### Before
- `python -I tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json --only=rivet_eq_plasma_sword --no-ink-rim`
  (or the two `ink_rim` keys removed) cuts the shipped strips: verified byte-identical to the shipped
  PNGs (both art keys). The same command without the flag reproduces the B strips byte for byte.

### Measured
- Every cell (5 facings, side and camera strike, rest), p70 and p55: the blade wears the ink rim, the
  arcs untouched. Game scale (x 0.33, x3): `i1_plasma_sword_B-game-scale-x3.png` (shipped / n13 B /
  n12 B cells 0 and 5).
- Film A/B, same build, 32 px/m: `i1_plasma_sword_B-ab-32ppm.mp4` (left before, 2x slow, x3),
  `i1_plasma_sword_B-ab-32ppm-frames52-60-64-70-90.png`. Same strip size and path: nothing new to
  load (RivetStripWarm already prefetches it).
- Commit `7c2626947`.

## Item 2: the dropped pistol, a drawn gun cell

### Audit
- `baton-before` (`--chapter=electro_baton --loadout=pistol`, 330 ticks) frames 70/85/130 match n12's
  D1 shot: ShockArcsView's n7 placeholder (an ink polygon in a 1.5 px cream rim) reads as a cream
  bracket beside Rivet. The pistol art in weapon_art.json: `held` / `parts.small` (top-down, along
  the bore) and `pickup` (the side view lying on the floor: the view a dropped gun shows the camera).
  The cop's own gun is part of his drawn forearm cell (navy, not a separate part).

### Change (four passes on film, `build/n13/film/d1-ab-v*.png`)
1. The pickup cell as drawn, 0.38 m, the pickups' 2 px ink outline: an ink blob (a 12 px cell inside
   4 px of ink, and the 301 px cell sampled 25:1 without mips: the project's default filter is
   linear, no mipmaps).
2. Floor node `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`, 1 px ink: a grey smudge; the drawn rust and steel
   sit at the pavement's own grey (luminance about 110).
3. `tools/art/dropped_gun.py` (new, committed, re-runnable): the pickup cell through held_small.py's
   re-tone (mid tones lifted into Rivet's tone budget, darkest ink kept, no new colour), cut to 64 px
   wide with a premultiplied Lanczos -> `pistol/dropped.png` (mipmapped import), `parts.dropped` in
   weapon_art.json. Pale and readable, but turned 35-60 deg at 12 px it read as a bone.
4. Offline sim (12/15/18 px, 0/35 deg, three tones: `scratchpad gunsim.png`): the L of barrel and
   grip reads near flat from about 15 px. Shipped: span 0.48 m (15 px at 32 px/m), the drop angle
   folded so the muzzle points sideways (mirrored, never upside down) with half its tilt
   (`ShockArcsView.lie_of`), 1.5 px ink outline (1.0 was soft at the edge).
- Keeps `GUN_ON_FLOOR` (the floor child, cast-shadow band + 1); the toss, spin, sink and ink-out with
  the corpse unchanged (the whole cell inks out now, not the rim).

### Before
- `--dropped-gun=polygon` (read through ArenaArgs: no new LaunchArgs flag, launch_args.gd sits at its
  200-line soft cap). Film `baton-flagoff` vs `baton-before` (pre-change build): 0 of 330 frames
  differ (framemd5). After vs before: frames 59-329 differ (from the drop).

### Measured
- `i2_dropped_gun_cell-ab-32ppm-frames70-85-130.png` (top before, bottom after; 8x crops on the gun at
  right), `i2_dropped_gun_cell-ab-32ppm-frame130-2x.png`, `i2_dropped_gun_cell-ab-32ppm.mp4`. At 1x
  the gun is a pale pistol about 15 x 11 px with an ink edge: barrel and grip read, the tape and
  slots do not; softer than the drawn rigs (mip-sampled). Read: a pistol, not a bracket.
- Load: one 64x52 texture, loaded in ShockArcsView._ready (the arena's build, behind the load).
- Tests: `test_dropped_gun_cell.gd` (5: loads at ready, mip filter, lie_of side, mirror, tilt cap);
  test_shock_arcs_floor 1/1.
- Commit `39d372ffd`.

## Item 3: the plasma impact disc, smaller

### Audit
- The brief's ticks 333-341 come from n12's B1 film (`--weapon=plasma_rifle --bot=gunplay --lone
  --armored=3`, on n12's 723d86db6). On this main the same flags play another fight (a pit wave runs;
  the lone kill lands at tick 304, not 346), so the moment was re-shot on the director's
  `plasma_armored` chapter (`--chapter=plasma_armored --loadout=pistol`: an armored cop takes a bolt
  and lives, staggers, the next bolt kills): the wound bolt lands at tick 60 (movie frame 59), the
  stop holds frames 60-62, frames 63-68 the ring opens. Frame <-> tick from the FightFrames log.
- The disc is not a cell: `GunFxMarks.pop()` draws a 0.22 m cream core for 4 ticks plus an ink and
  cream ring opening from 0.2 m with 10 / 5 px widths: at the burst one cream disc about 0.58 m
  across (19 px at 32 px/m) on the bolt's impact point, the cop's front half under it through the
  held frames (`i3_...-ticks58-66.png` top row). The ray gun and the homing shard use the same pop.
- Found on the way (inherited, not this lane's, not fixed): in the plain dev arena every gun's
  first shot leaves n12 E1's `muzzle_flash` light ON for good (a white paper fan beside Rivet in
  every film here; gone under `--feel=off`; pistol too). Cause: the arena's PrintStage has no clock
  (`clock` is only set for the city view, arena_game.gd:192), so `PrintStage.place()` steps the
  LightLayer at tick 0 while ArenaCombatLights adds lights born at `arena.tick`; they never age out.
  The city block fight sets the clock (n12's E1 film is clean). A call below.

### Change
- `GunFxMarks.pop(ci, at, age, row)`: the gun's gun_fx.json row may size the burst: `pop_core_m`
  (core radius, 0 = none), `pop_from_m` (the ring's first radius), `pop_ink_px` / `pop_cream_px`
  (widths at the burst); absent keys = the n7 values. The sizing is `pop_shape()` (pure, tested).
  GunFxArt passes the drawing gun's row (`fx.look(arena.gun...)`, already read once per draw).
- Tried both on film (`i3_plasma_pop_candidates-shipped-small-ring-32ppm.png`):
  small (core 0.08, from 0.12, ink 6, cream 3) and ring (core 0, from 0.35, ink 5, cream 3).
  Picked small. The ring alone uncovers the generic body-hit ink burst (GunFxMarks.impact BODY:
  an ink disc 0.22 m for 4 ticks, every gun), which the cream core used to hide: an ink blob then
  sits on the torso through the held frames. Small keeps the burst a hot point in a tight double
  ring at the impact, and the cop's torso, arm and the 2-tick throw read beside it in every held
  frame (59-62). The ring still opens to 0.8 m as approved.
- gun_fx.json plasma_rifle: `pop_core_m 0.08, pop_from_m 0.12, pop_ink_px 6, pop_cream_px 3`.

### Before
- Remove the four `pop_*` keys from gun_fx.json's plasma_rifle row. With the code change and no keys
  the film is pixel-identical to the pre-change build (`parm-codebefore` vs `parm-before`, 0 of 130
  frames differ); the ray gun and homing shard rows carry no keys (test pins them to the n7 burst).

### Measured
- `i3_plasma_pop_small-ab-32ppm-ticks58-66.png` (frames 59-68, x3, top before), `i3_plasma_pop_small-ab-32ppm.mp4`
  (3x slow), the kill bolt `i3_plasma_pop_small-ab-32ppm-kill-frames112-120.png` (the kill star still
  dominates; the core no longer adds a second white disc). Before vs after: frames 59-62, the next
  bursts, 27 of 300 differ; re-run of the after build identical (0 of 130).
- No art, no load: four draw calls as before (radius and widths only).
- Tests: `test_plasma_pop_size.gd` (5: no keys = the n7 burst at every age; ray gun and shard keep
  it; the shipped plasma row is small; the core ends at age 4 and a 0 / negative core draws none;
  the ring starts at from_m).
- Commit `b1514f8e4`.

## Item 4: wind-up cells (plasma sword, katana, electro baton)

### Audit
- `RigClips.strike(windup_s, active_s, recovery_s)` starts `strike_t` at the wind-up; RivetStrips'
  `fire_latched` counts any `strike_t >= 0`, so the strike cell (swing through, arc drawn) shows from
  the first wind-up tick the view sees. The view learns of a strike late (`RigInput.strike`'s packed
  `late`): in the sword combo the strike cell appears 2 ticks into the 4-tick wind-up of plasma_1.
- Strips: plasma sword (glow blade, two hands), katana (rust-steel blade in the body's own plates),
  baton (one hand, hangs at his side; a drawn left strip, never mirrored; p55 NO_ARC).

### (a) The composed cell
- `tools/art/blade_windup.py` (committed, re-runnable; rivet_frames.py runs it for a row carrying
  `windup`): body = the nearest facing cell (side: cell 1, camera: cell 0); the blade plate (glow core
  + opaque px within reach 8) lifted out and turned about its base (the hilt end) to `*_deg`, laid
  over (or `--under`) the body; whole source pixels, no new colour; 48 px headroom.
- Slot plumbing: `RivetWindup` (new, 44 lines): `path_or` swaps the equipped strip for
  `rivet_eq_<weapon>_windup.png` while `strike_t < strike_ph.x`; `small_of` picks cell 0 (side,
  mirrored on the left octants) or 1 (camera, octant 2). RivetFrames +0 lines net (two call sites),
  RivetStrips.cells_of +2, RivetStripWarm lists the file, CastFlags `--rivet-windup=off`.
- Stills (`i4_plasma_sword_windup_compositions-p70-2x.png`): raised up-and-back (-125 / -170 deg,
  under) the blade hides behind the torso (hands at the hip); raised in front (-95, over) it stands
  upright beside his chest off a still-horizontal hilt (a bent sword at 3x). Shipped to the trial:
  -95 over, both art keys.
- Film (`sword-wu` vs `sword-wuoff`, same build): 4 frames differ (59, 60, 74, 75). First swing: two
  frames of the facing body with the blade raised, then the strike cell: a cock you can see at 1x,
  but only 2 frames. Second swing (73-76): strike-cell lunge -> standing facing body -> lunge in
  three frames: a pop. Anticipation (melee.md, "nothing pops = 2"): stays 2 (a raised blade for 33 ms
  on the opener, a flicker on the chain). Fails the bar (+1 with no pop). Not shipped.
  `i4_plasma_sword_windup_trial-dropped-ab-32ppm.png` / `.mp4` (top / left = off).
- Katana and baton: not cut. The katana's blade has no glow plate (rust-steel, the body's own
  plates: the lift's mask finds the visor), and the baton hangs one-handed at his side (no hilt end
  in front to turn about, a left strip never mirrored); the same arms-cannot-move limit applies.
  Strips: `i4_katana_baton_strips-p70-facings-strikes.png`.
- What stays in the tree: RivetWindup and the slot (no strip ships, so it is off: the sword film with
  the plumbing and no file is identical to item 1's, 0 of 130 frames differ), `blade_windup.py`
  (the trial: add `"windup": {"side_deg": -95, "cam_deg": -95}` to a manifest row to re-cut it), the
  rivet_frames.py hook. The trial's PNGs are not committed.
- Before: no `rivet_eq_<weapon>_windup.png` (today's state), or `--rivet-windup=off` (verified: the
  flag-off film is identical to item 1's after film, 0 of 330 frames).

### (b) The commission
- `docs/art/requests/windup-cells.md`: per weapon the slot, cell sizes (p70 / p55), facing, pose,
  plates (the p70 strip's 10 plates by share), combo timings, reference stills, how to fit it in.
  None marked "interim cell shipped" (none passed). The baton's left wind-up needs a second slot
  (a one-line follow-up in RivetWindup, listed there).
- Tests: `test_rivet_windup.gd` (8: wind-up ticks swap, no strike / active / no wind-up keep, only
  the equipped strip and a weapon with a cut, the flag, cells and pad, no cut changes nothing and
  warms nothing, cells by octant incl. the diag strip unchanged, the warm lists it). Strip presence
  stubbed through RivetStrips' file cache.
- Commit `0d05ca907`.

### 14:02: the asset lane answered the request (not integrated: an owner call)
- `ASSETS-REPLIES.md` appeared beside this journal (written by the asset lane, not committed by me):
  drawn wind-up figures in `gtai-art/library/keyed/rivet/` for all three blades, p70 side + cam (A),
  pre-cut at the p70 strip's scale in `rivet_windup_70_cells/`, the baton's left side (v2), and the
  p55 figures (not laid out); overview `gtai-art/library/evidence/it309/windup_70_cells_overview.png`
  (rest | wind-up side | strike side | wind-up cam | strike cam per blade): the blade cocked back over
  the shoulder and raised overhead, both claws on the haft, the baton in the right claw.
- Not wired in this lane: the brief scoped item 4 to the composed trial and the request; new art
  needs the owner's eye on film. The slot is ready: a manifest row per weapon and art key with
  `counts "2"` on the delivered sheet, written to `rivet_eq_<weapon>_windup.png` (cell 0 side, 1 cam;
  set `fig_h` by eye, the asset note says the sword's cam body is ~8 % long), `--import`, film with
  and without `--rivet-windup=off`. The baton's left wind-up needs the second slot (one line).
