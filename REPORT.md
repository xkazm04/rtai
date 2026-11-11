# n16 kills-new: REPORT (DRAFT, updated 17:40 in iteration 21; the last session finalises it by 19:40)

Lane `n16-kills-new`: a unique death for every weapon that had none. Evidence: `evidence/n16-kills-new/`
and `gtai-masters/n16/kills-new/frames.json`. The journal is `JOURNAL.md`.

## What works (with evidence)

| Weapon | Row (style) | What plays | Drawn cells wired | Evidence |
|---|---|---|---|---|
| Pistol | `pistol_snap` (snap) | the head snaps back, red exit mist, the cap/helmet flies off and stays on the street, the knees buckle, he pitches face down toward Rivet | p70 patrol/riot/SWAT/suit, p55 patrol/riot/SWAT, loose headgear | `pistol_cells_ab_64ppm_patrol_t{340,350,356,390}.png`, `pistol_cells_reel_{32,64}ppm_dirs0-90-225.png`, clips |
| Machine pistol | `smg_stitch` (stitch) | four rounds walk up him with spurts and jerks, the cap tips, he spins and drops curled on his side | p70 patrol/riot/SWAT/suit, p55 patrol/riot/SWAT (`8fc189cf6`) | `stitch_cells_reel_64ppm_dir135_t174-324.png`, `stitch_cells_reel_32ppm_dirs-wall-135.png`, `stitch_cells_ab_64ppm_patrol_*` (before the facing fix) |
| Gloria | `nail_pin` (pin) | nails streak in; a wall within 1.4 m: slammed onto it, hangs by both sleeves, knees jerking; open street: on his back at the nailed boot | p70 patrol/riot/SWAT/suit, p55 patrol/riot/SWAT (`8fc189cf6`) | `nail_pin_cells_reel_64ppm_wall_t63-215.png`, `nail_pin_cells_reel_32ppm_wall_crops.png`, `nail_pin_cells_reel_64ppm_dir135_t62-214.png` |
| Gatling | `gatling_shred` (shred) | the stream holds him up and shakes him (drawn: arms flung, ragged holes, spray behind); he sags over cream ribs, the cap or helmet knocked off; the heap with a torn-off arm lies along the stream among six drawn scraps (cloth, flesh, bone, kit) | p70 patrol/riot/SWAT/suit + drawn scraps (`040ffb67a`), p55 patrol/riot/SWAT + scraps (`b967042e3`) | cells: `gatling_shred_cells_32ppm_dir0_t95-245.png`; p55 under the 55-degree view vs the p70 cells: `gatling_shred_p55_ab_32ppm_tilt_t95-155.png`, clip `gatling_shred_p55_after_32ppm_tilt.mp4`; placeholder: `gatling_shred_ab_{32,64}ppm_patrol_t{381,390,410}.png`, `gatling_shred_reel_{32,64}ppm_dirs0-135-225.png` |
| Electro baton | `baton_overload` (cook) | locked and buzzing, cream veins and a glow under the skin, steam, the eyes go out, falls back smoking | p70 patrol/riot/SWAT/suit (`b083b6d5a`, `590902959`); the corpse turned along the blow (`040ffb67a`); p55 patrol/riot/SWAT (`b967042e3`) | `baton_overload_cells_{64,32}ppm_dir0_t69-218.png`, p55 under the 55-degree view vs the p70 cells `baton_overload_p55_ab_32ppm_tilt_t68-188.png` (clip `baton_overload_p55_after_32ppm_tilt.mp4`), before/after `baton_overload_ab_{64,32}ppm_dir0_t66-218.png`, `baton_overload_reel_{32,64}ppm_dirs0-225.png` |
| Molotov | `molotov_torch` (torch) | split from the flamethrower (which keeps `burn_char`): drawn: on his knees with flames on the shoulders (t0), hunched beating at them (t8), face down burning along the back and legs (t16), charred black with the bottle neck beside him (t150); coded tongues flicker over the drawn flames | p70 patrol/riot/SWAT (`e0cc756fa`); the suit keeps the placeholder (his kneel was refused by the image filter) | city street fight at 32 vs burn_char: `molotov_torch_city_ab_32ppm_t505-655.png`, clips `molotov_torch_city_{before,after}_32ppm.mp4`; `molotov_torch_cells_ab_{32,64}ppm_dir0_t182-332.png` (top placeholder, bottom cells), clips `molotov_torch_cells_after_{32,64}ppm_dir0.mp4`; vs burn_char: `molotov_torch_ab_{32,64}ppm_dir0_t182-332.png` |
| Rivet's bare claw | `claw_throw` (throw) | the charged claw THROWS him: hit-stop 4, a cream bolt into the chest, a 0.4 m hop back along the blow, 2.4 m out, skid to 3 m (4.2 m on the drawn cells, `76ae91d45`: at 3 m the drawn corpse's boots landed 1 m from Rivet at dir 0), sparks crawling to t60, an ink skid line and smoke; no blood | p70 patrol/riot/SWAT/suit (`0bbc3f265`, corpse head away from Rivet `8a15e9314`) | cells at 32, slide 3 vs 4.2, dirs 0/135/225: `claw_throw_cells_slide_ab_32ppm_dirs0-135-225_t127-187.png`; cells: `claw_throw_cells_ab_64ppm_dir0_t127-217.png`, `claw_throw_cells_turn_vs_noturn_64ppm_dir0.png`; placeholder: `claw_throw_ab_32ppm_dirs0-135-225_t159.png`, `claw_throw_ab_{64,32}ppm_dir0_t127-*.png`, the flight fix `claw_throw_flight_variants_64ppm_dir0_t127-159.png` (rows: fall grid from t8 / tipped to t14 / the kept fall_at 8), clips `claw_throw_{before,after}_{32,64}ppm_dir0.mp4` |

Gates (last measured): the gate on `b9dba1da8` (`../n16-tools/tools/gate/run.mjs --reels`, 17:41-18:11): lint 19/19, unit 2684/0/2, scenarios 55/55, parity bit for bit 1200 steps (planted fault caught at 629), look goldens 11/11 (worst 0.00), release-compile 698/0, reels tilt70 OK and combo OK, **top FAIL** (a SCRIPT ERROR at every new-style kill: no head card under the top view), fixed in `b07ca1b3f` (unit `test_kill_loose_art` fails without the fix) and the top reel re-run on `b07ca1b3f`: OK, 0 SCRIPT ERROR. Gore check: all 17 kills-new deaths drop whole under `--gore=reduced` (tools lane reel on `8f7fe6e6e`, n16-tools `evidence/n16-tools/reel_s4gore_new.md`). Still owed on the final commit: one full `--reels` gate (all three views on one commit).

## What does not work yet
- Gatling: the ~0.5 m sideways jump at the drop stays for kinds WITHOUT cells (the fall grid starts from the hit
  card's origin, not its leaned drawn feet); the four street kinds play their own cells and do not jump.
- The pin and stitch corpse cells land ~0.4-0.5 m off the standing spot (each corpse cell is centred on the
  grid's corpse).
- Molotov: the coded flame tongues are rigid cones at 64 px/m (`molotov_torch_flame05_{32,64}ppm_dir0_t182-332.png`); on the drawn kinds the drawn flames carry it (the street-fight film, `molotov_torch_city_ab_32ppm_t505-655.png`, reads at 32).
- KillShredArt's coded scraps flooded `Invalid polygon data, triangulation failed`: fixed in `80e6d139f` (KillPoly.fill): 315 -> 1 per Gatling-on-a-thug film (`fan_fill_polygon_errors.md`; the one left is `rig_cast_shadows.gd:71`, not this lane's).
- This branch's `tools/film/film.mjs` has no `kill:` shot; the lane films with the tools lane's (`../n16-tools/tools/film/film.mjs`), which also takes `kill:claw_shock` now.
- Column 1 of the patrol stitch frame 3 shows a doubled cap for one beat (asset fault, known).
- Claw throw, SWAT: frame 1's bolt reaches below his boots, so that cell sits ~10 px (of the p70 cell) higher than the
  registered feet for 4 ticks; at 32 px/m that is ~3 screen px and is left as drawn (asset note it434).
- The claw's p55 cells are owed (REQUEST 17:33): under the 55-degree view the claw plays the p70 cells.

## Calls for the owner
- Pistol `pistol_snap`: keep / change / drop. 64: `pistol_cells_ab_64ppm_patrol_t340.png`; 32: `pistol_city32_after_t339-380.png` vs `_before_`; clip `pistol_cells_ab_64ppm_patrol_t330-400.mp4`.
- Machine pistol `smg_stitch`: keep / change / drop. 64: `stitch_cells_reel_64ppm_dir135_t174-324.png`; 32: `stitch_cells_reel_32ppm_dirs-wall-135.png`; clips `stitch_cells_reel_{32,64}ppm_dir135.mp4`.
- Gloria `nail_pin`: keep / change / drop. 64: `nail_pin_cells_reel_64ppm_wall_t63-215.png`; 32: `nail_pin_cells_reel_32ppm_wall_crops.png`; clips `nail_pin_cells_reel_{32,64}ppm_wall.mp4`. Parked cars count as walls.
- Gatling `gatling_shred`: keep / change / drop. A/B 32 + 64: `gatling_shred_ab_{32,64}ppm_patrol_t390.png`, clips `_t355-460.mp4`.
- Molotov `molotov_torch` (placeholder until its cells land): keep / change / drop; also the split itself (the
  flamethrower keeps burn_char). 32: `molotov_torch_ab_32ppm_dir0_t182-332.png`; 64: `molotov_torch_ab_64ppm_dir0_t182-332.png`; clips `molotov_torch_{before,after}_{32,64}ppm_dir0.mp4` (before = burn_char on the same tick).
- Molotov drawn cells (`e0cc756fa`, `2c7040a23`): keep / change. 32 in a street fight vs burn_char: `molotov_torch_city_ab_32ppm_t505-655.png` (clips `molotov_torch_city_{before,after}_32ppm.mp4`); 32 in the lab: `molotov_torch_cells_ab_32ppm_dir0_t182-332.png`; 64: `molotov_torch_cells_ab_64ppm_dir0_t182-332.png` (top the placeholder, bottom the cells); clips `molotov_torch_cells_after_{32,64}ppm_dir0.mp4`.
- Rivet's bare claw `claw_throw` (drawn cells since `0bbc3f265`; filmed with cells at 64 dir 0 and at 32 in 3 dirs): keep / change / drop. The claw no longer borrows the electro gun's X-ray shock. 32: `claw_throw_cells_slide_ab_32ppm_dirs0-135-225_t127-187.png` (cells), `claw_throw_ab_32ppm_dirs0-135-225_t159.png` (X-ray before vs placeholder); 64: `claw_throw_ab_64ppm_dir0_t127-217.png`; clips `claw_throw_{before,after}_{32,64}ppm_dir0.mp4`. Also: the body lands 3 m (drawn cells: 4.2 m) from where he stood, so his dropped rifle (sim data) is not 0.5 m from the body, as with the hand cannon's thrown body. If the rifle rule wins, setting `slide_m` 0 (one data value) keeps the arc and sparks on a body that drops where it stood.
- Electro baton `baton_overload`: keep / change / drop. 64: `baton_overload_after_64ppm_dir0_t78-88-108_zoom.png`; 32: `baton_overload_reel_32ppm_dirs0-225.png`.

## Merge notes
- Shared files touched (announced in JOURNAL): `kill_styles.gd` (hands STYLES to KillNewStyles), the
  `signature_kills` schema (`cells`, numeric `fx`). Taken from the tools lane (game side only, identical content):
  kill-lab turn (afe581336), spun-gun hold (0b5c55fc7), `--sig-wall` (bbee28a9c).
- Iteration 20: kills-polish's `electro_shock` row loses `also_weapons` (claw_shock now has its own row `claw_throw`); `test_signature_kills.gd` (the claw test) and `scenario_brutality_kills.gd` (KILLS claw_shock -> throw) edited; the schema gains the `throw` style (additive).
- Iteration 16: `brutality_hook.gd` names a `burn` kill by `KillFireSource` (one call; its header doc reflowed to
  stay at 200 lines); the schema gains `cells.scraps` and the `torch` style (additive). No sim file touched: the
  molotov/flamethrower split is view side (decision kills-new/molotov-torch).

## Next steps (art still owed per kind)
- smg_stitch and nail_pin at p55: done for patrol, riot, SWAT (`8fc189cf6`); the suit has no p55 grid (it plays p70).
- molotov_torch: the suit ped's p70 frames 1-2 (kneel refused twice by the image filter; a third wording was rendering at 16:02); p55 for all four.
- claw_throw: p55 for patrol, riot, SWAT (p70 delivered for all four kinds and wired; REQUEST 17:33).
- gatling_shred and baton_overload p55: done for patrol, riot, SWAT (`b967042e3`); the suit plays p70.
