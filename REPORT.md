# n16 kills-new: REPORT (DRAFT, updated 15:30 in iteration 16; the last session finalises it by 19:40)

Lane `n16-kills-new`: a unique death for every weapon that had none. Evidence: `evidence/n16-kills-new/`
and `gtai-masters/n16/kills-new/frames.json`. The journal is `JOURNAL.md`.

## What works (with evidence)

| Weapon | Row (style) | What plays | Drawn cells wired | Evidence |
|---|---|---|---|---|
| Pistol | `pistol_snap` (snap) | the head snaps back, red exit mist, the cap/helmet flies off and stays on the street, the knees buckle, he pitches face down toward Rivet | p70 patrol/riot/SWAT/suit, p55 patrol/riot/SWAT, loose headgear | `pistol_cells_ab_64ppm_patrol_t{340,350,356,390}.png`, `pistol_cells_reel_{32,64}ppm_dirs0-90-225.png`, clips |
| Machine pistol | `smg_stitch` (stitch) | four rounds walk up him with spurts and jerks, the cap tips, he spins and drops curled on his side | p70 patrol/riot/SWAT/suit | `stitch_cells_reel_64ppm_dir135_t174-324.png`, `stitch_cells_reel_32ppm_dirs-wall-135.png`, `stitch_cells_ab_64ppm_patrol_*` (before the facing fix) |
| Gloria | `nail_pin` (pin) | nails streak in; a wall within 1.4 m: slammed onto it, hangs by both sleeves, knees jerking; open street: on his back at the nailed boot | p70 patrol/riot/SWAT/suit | `nail_pin_cells_reel_64ppm_wall_t63-215.png`, `nail_pin_cells_reel_32ppm_wall_crops.png`, `nail_pin_cells_reel_64ppm_dir135_t62-214.png` |
| Gatling | `gatling_shred` (shred) | the stream holds him up and shakes him (drawn: arms flung, ragged holes, spray behind); he sags over cream ribs, the cap or helmet knocked off; the heap with a torn-off arm lies along the stream among six drawn scraps (cloth, flesh, bone, kit) | p70 patrol/riot/SWAT/suit + drawn scraps (`040ffb67a`) | cells: `gatling_shred_cells_32ppm_dir0_t95-245.png`; placeholder: `gatling_shred_ab_{32,64}ppm_patrol_t{381,390,410}.png`, `gatling_shred_reel_{32,64}ppm_dirs0-135-225.png` |
| Electro baton | `baton_overload` (cook) | locked and buzzing, cream veins and a glow under the skin, steam, the eyes go out, falls back smoking | p70 patrol/riot/SWAT/suit (`b083b6d5a`, `590902959`); the corpse turned along the blow (`040ffb67a`) | `baton_overload_cells_{64,32}ppm_dir0_t69-218.png`, before/after `baton_overload_ab_{64,32}ppm_dir0_t66-218.png`, `baton_overload_reel_{32,64}ppm_dirs0-225.png` |
| Molotov | `molotov_torch` (torch) | split from the flamethrower (which keeps `burn_char`): he drops to his knees mid-run, folds face down along the run, and amber flames keep licking over him to t180, smoke after | none yet (placeholder: pose track + fall grid + coded flames; cells requested) | `molotov_torch_ab_{32,64}ppm_dir0_t182-332.png`, clips `molotov_torch_{before,after}_{32,64}ppm_dir0.mp4` |

Gates (last measured): full unit 2666/0/2 on `953d2972e`; scenarios 55/55 on `d1ab2f3c3`; lint 19/19 at every commit; scenarios 54/55 + the
brutality_kills re-run ok at 13:11 (before the cells). Still to run on the final commit: scenarios, evidence (parity +
look goldens), the reel gate.

## What does not work yet
- Gatling: the ~0.5 m sideways jump at the drop stays for kinds WITHOUT cells (the fall grid starts from the hit
  card's origin, not its leaned drawn feet); the four street kinds play their own cells and do not jump.
- The pin and stitch corpse cells land ~0.4-0.5 m off the standing spot (each corpse cell is centred on the
  grid's corpse).
- Molotov: in the kill lab he dies inside the molotov's own fire patch, whose flames swamp the coded tongues at
  32 px/m; a street-fight film (he runs out of the patch first) is owed. The lying tongues follow the drawn corpse since
  `c9d7a73c4` (`molotov_torch_fix_64ppm_dir0_t182-332.png`) but read as small spikes (flame_m 0.32 wants ~0.5).
- KillShredArt's coded scraps (kinds without drawn scraps) flood `Invalid polygon data, triangulation failed`.
- Column 1 of the patrol stitch frame 3 shows a doubled cap for one beat (asset fault, known).

## Calls for the owner
- Pistol `pistol_snap`: keep / change / drop. 64: `pistol_cells_ab_64ppm_patrol_t340.png`; 32: `pistol_city32_after_t339-380.png` vs `_before_`; clip `pistol_cells_ab_64ppm_patrol_t330-400.mp4`.
- Machine pistol `smg_stitch`: keep / change / drop. 64: `stitch_cells_reel_64ppm_dir135_t174-324.png`; 32: `stitch_cells_reel_32ppm_dirs-wall-135.png`; clips `stitch_cells_reel_{32,64}ppm_dir135.mp4`.
- Gloria `nail_pin`: keep / change / drop. 64: `nail_pin_cells_reel_64ppm_wall_t63-215.png`; 32: `nail_pin_cells_reel_32ppm_wall_crops.png`; clips `nail_pin_cells_reel_{32,64}ppm_wall.mp4`. Parked cars count as walls.
- Gatling `gatling_shred`: keep / change / drop. A/B 32 + 64: `gatling_shred_ab_{32,64}ppm_patrol_t390.png`, clips `_t355-460.mp4`.
- Molotov `molotov_torch` (placeholder until its cells land): keep / change / drop; also the split itself (the
  flamethrower keeps burn_char). 32: `molotov_torch_ab_32ppm_dir0_t182-332.png`; 64: `molotov_torch_ab_64ppm_dir0_t182-332.png`; clips `molotov_torch_{before,after}_{32,64}ppm_dir0.mp4` (before = burn_char on the same tick).
- Electro baton `baton_overload`: keep / change / drop. 64: `baton_overload_after_64ppm_dir0_t78-88-108_zoom.png`; 32: `baton_overload_reel_32ppm_dirs0-225.png`.

## Merge notes
- Shared files touched (announced in JOURNAL): `kill_styles.gd` (hands STYLES to KillNewStyles), the
  `signature_kills` schema (`cells`, numeric `fx`). Taken from the tools lane (game side only, identical content):
  kill-lab turn (afe581336), spun-gun hold (0b5c55fc7), `--sig-wall` (bbee28a9c).
- Iteration 16: `brutality_hook.gd` names a `burn` kill by `KillFireSource` (one call; its header doc reflowed to
  stay at 200 lines); the schema gains `cells.scraps` and the `torch` style (additive). No sim file touched: the
  molotov/flamethrower split is view side (decision kills-new/molotov-torch).

## Next steps (art still owed per kind)
- smg_stitch and nail_pin at p55 (after the above).
- molotov_torch: p70 cells for patrol, riot, SWAT, suit (requested 15:40; beat sheet 6a in JOURNAL).
- Rivet's claw finisher (`claw_throw`, beat sheet 6b in JOURNAL): not built; needs `claw_shock` taken out of
  kills-polish's `electro_shock.also_weapons`.
