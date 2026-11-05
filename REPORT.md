# n5-look REPORT (draft 2026-11-05 05:45; rewritten at the 08:40 report)

Branch `n5-look`, cut from main `a1275c82`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n5\look\` (`frames.json`, 15 entries).
Detail and every measurement: `JOURNAL.md`. Decisions: `docs/decisions.md` (lines tagged n5-look).

## What works (with its evidence)

1. **The print, toward the riso middle ground** (r2_a5 + r1_a1). It's a riso layer inside `look_d5`, set by one dial (`world_riso.riso`); `--look=today` gives the old print for A/B.
   - What's in the layer: world-locked fine halftone, small per-plate misregistration, paper fibre, the tan stained sheet (`tan_k`, `stain_k`), and grain toned down (0.5 -> 0.3, not removed).
   - Iteration 9: r2_a5's grain is back, toned down: sparse world-locked 1 px toner specks on the paper and light fills (`world_riso.speck_k` 0.4, `speck_density` 0.07; 0 = before). The it2 sheet had gone smooth. The pan residual on light ground is 3.39 % with the specks off vs 3.47 % on, so they are world-locked. The goldens stay inside the gate (worst mean 0.59), so they were not re-blessed. Evidence: `print-speck-it9-2x-vs-r2a5.png` (today | it2 | it9 | target, 2x crops) and `arena-speck-ab-32ppm-it9.mp4` (20 s, off | on).
   - Iteration 9: uneven riso inking. The halftone's contrast dips in soft world-locked patches (`world_riso.dot_patchy` 0.7; 0 = even), so the alley lane's dot screen stops reading as a mechanical pattern (last row of `alley-it7-ab-48ppm-vs-r2a6.png`).
   - Iteration 10: the paper tone. Measured, the iteration 2 tan had printed the sidewalk paper darker than both today and the target (median 212/193/162 vs today 238/220/197 and r2_a5's sheet 250/218/177). The tone is now data (`world_riso.tan_tone` [1.02, 0.99, 0.94]; the old tone is the shader default): it warms without darkening, median 238/218/187, between today and the target. Evidence: `print-3way-city-32ppm-it10.png` (today | old tan | new tone | r2_a5, 64 px/m crops below).
   - Iteration 11: r2_a5's grime. On the lighter sheet, the sidewalk lacked the target's small sharp grey splats along the tiles. Raising stain_k only deepened the soft clouds, so a new term prints hard-edged grey splats with satellite drops on the paper and light fills (`world_riso.splat_k` 0.8, `splat_cut` 0.79, `splat_scale` 0.07; 0 = before). The asphalt is untouched and blood stays the only deep red. The pan residual is 2.93 % with the splats on and off, so they are world-locked. The goldens stay inside the gate (worst mean 0.76). Evidence: `print-splat-it11-city0-vs-r2a5.png` (before | splat | r2_a5) and `city-fight-splat-ab-32ppm-it11.mp4` (12 s riot, off | on).
   - Iteration 12: r2_a5's cracked tiles. A new term prints two diagonal families of jagged ink hairlines in short runs on the paper and light fills (`world_riso.crack_k` 0.6, `crack_scale` 0.012, `crack_run` 0.62; 0 = before); the asphalt keeps its baked cracks only. The pan residual is 2.95 % with the cracks vs 2.93 % without, so they are world-locked. The goldens stay inside the gate (worst mean 0.91). Evidence: `print-crack-it12-city0-vs-r2a5.png` (before | cracks | r2_a5 at 64 and 32 px/m) and `city-fight-crack-ab-32ppm-it12.mp4` (12 s riot, off | on).
   - Iteration 13: r2_a5's crisp tile joints. The paving tiles' joints printed as a black grid at 32 px/m; `tools/art/joint_tone.py` copies the paving tiles to `*_jt.png` with the joint colours lifted, so the heavy joints print about 86/78/74 (the target's brown-grey) and the actors' black outlines pop more (`city_textures.json` back = the old tiles). The look goldens were re-blessed for it (d1@32 moved; decisions line). Evidence: `print-joint-it13-city0-vs-r2a5.png`.
   - The building cast shadow went from 1.1 m to 0.45 m, so there are no long casts.
   - Blood stays the only deep red: the tan and the stains apply to neutral pixels only.
   - Evidence: `print-3way-city-32ppm-it2.png` (today | ours | target), `print-pan-today-vs-riso-32ppm.mp4` (the shimmer check: the residual after the camera shift matches today's, 1.29 %), `arena-reel-today-vs-riso-it2-32ppm.mp4` (the fight is identical tick for tick).
   - The look goldens were re-blessed once, with a decisions line.
   - Frame cost was CONTENDED, so the riso delta is unresolved below the ~0.1 ms noise. Statically it adds 2 screen fetches plus about 5 lattice fetches, with no new full-screen pass.
2. **The alley stage** (`--arena=alley`, 48 px/m). It's an east-west lane north of the range: asphalt, puddles, dumpsters, bag piles, fire escapes from above, roofs with a brick lip, and a chain-link fence. Cop waves come in from both ends (AlleyHook).
   - Evidence: `alley-it7-ab-48ppm-vs-r2a6.png` (iteration 3 | iteration 7 | target) and `alley-fight-vs-r2a6-48ppm-it7.mp4` (20 s beside r2_a6). Iteration 7 flipped the value structure toward the target: a light concrete lane between dark roofs and a dark brick lip, dark dumpsters, grey pools, bags and litter; every fill is `alley_decor.json tones`; bags are tied sacks, and the south side passage is closed (hub cops had queued in it).
   - Iteration 10: lane grime. 100 soft dark blotches, crowded toward the wall feet, so the middle of the lane reads worn clean as in r2_a6 (`alley_decor.json grime`; count 0 = before). A dirt band along the wall feet was tried and set to 0: the print banded it into a hard strip that read as a cast shadow. Evidence: last row of `alley-it7-ab-48ppm-vs-r2a6.png`.
3. **Weapon FX in the sheet's colours** (r2_w4).
   - The colours: muzzle yellow-orange; blast orange-yellow with a white core; arc violet-white; plasma white-hot with gold; ray acid green; shards pale crystal with a cyan-white glint. The tracer is its own hot-yellow family.
   - No blood red and no teal in any of them. In the live fight the cells draw on their own canvas under `look_d5_fx`; `fx_colour_dir ""` switches back to ink.
   - Iteration 10: the blast's smoke ring carries 9 ragged fire pockets with hot yellow cores toward the centre, as in r2_w4, instead of a continuous orange band (`tools/art/fx_colour.json` blast_smoke `pockets`; drop it = the band). Evidence: last row of `fx-colour-arena-64ppm-vs-r2w4.png`.
   - Iteration 11: the pockets' edges are lumpy (`pockets.wobble` 0.2, r_px 30-52; 0 = round), so they read as r2_w4's ragged fire tongues instead of discs; a white-hot tier inside each yellow core grades them orange -> yellow -> white toward the blast centre (`pockets.hot`). Evidence: the last two rows of `fx-colour-arena-64ppm-vs-r2w4.png`.
   - Iteration 12: the smoke-ring frame keeps r2_w4's white-hot core and yellow radial spikes through the smoke, where it printed a hollow grey ring (`fx_colour.json` blast_smoke `flash`, painted by `tools/art/fx_flash.py`; drop it = the hollow ring). Evidence: `fx-flash-it12-64ppm-vs-r2w4.png` (before | after at ticks 1216 and 1220 | r2_w4). The flash grades white -> yellow -> orange into the smoke (`flash.mid`; `fx-flash-mid-it12-64ppm-vs-r2w4.png`).
   - Blast debris: concrete slabs and ink specks fly out over 30 ticks (`blast_debris.json`). Iteration 12: three big chunks (up to 1.5 m), a third of the ring apart, among six small slabs, as in r2_w4 (`chunk_big` 3; 0 = the uniform 0.35-1.3 m slabs). Evidence: `fx-debris-it12-64ppm-vs-r2w4.png`.
   - Iteration 14: the gun muzzle flashes (pistol, Gloria, machine pistol, Gatling, rocket, hand cannon, mini-nuke) grade white-hot -> yellow -> an orange rim, as r2_w4's pistol flash does; they were pale cream stars that washed into the paper (`fx_colour.json` `muzzle_core`, rim 3 px via `tools/art/fx_rim.py`; drop = before). Evidence: `fx-muzzle-it14-64ppm-vs-r2w4.png`.
   - Iteration 14: Rivet's bullet tracer is r2_w4's comet (a round white-hot head, a tapering orange tail) instead of a spear head that printed as a gold blade as long as Rivet at 64 px/m; length and weight kept, so it still reads at 32 px/m (`tools/art/tracer_comet.py`; `weapon_art.json` tracer `art`, back = `tracer.png`). Evidence: `fx-tracer-comet-it14-vs-r2w4.png` (64 and 32 px/m).
   - Iteration 14: the plasma round is r2_w4's comet too (a round white-hot head and gold tongues) instead of a smooth gold teardrop (`plasma_comet.png`; `weapon_art.json` plasma_bolt `art`, back = `plasma_bolt.png`). Evidence: `fx-plasma-comet-it14-vs-r2w4.png`.
   - Iteration 14: the electro arc prints a white-hot core inside a violet edge, as r2_w4's bolt does, instead of one lavender fill; it reads stronger on cream at 32 px/m too (`fx_colour.json` arc rim 4 px). Evidence: `fx-arc-it14-vs-r2w4.png`.
   - Iteration 16: the homing shard is r2_w4's barbed crystal arrowhead with three ink speed dashes, instead of a long pale lozenge on a charcoal tail (`tools/art/shard_arrow.py`; `weapon_art.json` shard row `art` shard_arrow.png at 190x64, back = shard.png at 190x44). Evidence: `fx-shard-arrow-it16-vs-r2w4.png` (64 and 32 px/m).
   - Iteration 16: the ray gun fires r2_w4's straight acid-green beam with a pale core and green tendrils that re-crackle every tick, instead of a train of green hoops (`tools/art/ray_beam.py`, `WeaponFxRay.draw_beam`; `weapon_art.json` ray_gun `projectile_fx` "ray_beam", back = "ray_ring"). Evidence: `fx-ray-beam-it16-vs-r2w4.png` (64 and 32 px/m).
   - Evidence: `fx-colour-reel-ab-32ppm.mp4`, `fx-colour-arena-64ppm-vs-r2w4.png`, `fx-colour-energy-ab-32ppm-2x.png`, `fx-colour-lineup-64ppm-vs-r2w4.png`.
4. **The held gun follows Rivet's size** (answers n5-cast REQUEST 19:08). `rivet_arsenal.json held_size_ref` is 1.2; the cast lane's 0.97 Rivet carries 0.81x guns.
   - Evidence: `held-size-ab-cast-merge.png`.
5. **The plasma sword blade is 20 % longer.** The hilt keeps its size and the reach data is unchanged (tip ~2.07 m against reach 2.0-2.2 m).
   - Evidence: `plasma-blade-ab-64ppm.png`.
6. **The Gatling is a new unique weapon** (r1_w6 variant A, barrels 50 % longer).
   - Fire: the barrels spin up for 0.5 s, then it fires 20 rounds/s at 50 dmg, so TTK on a human is 0.6 s from cold and 0.1 s spun up. While the barrels turn, Rivet walks at 0.45x.
   - The hold (`hip_belt`): hip-held, with a box on his back and a brass ammo belt.
   - The art was generated from text plus a non-gun style reference, because moderation blocks gun edits.
   - It is in the armory, the weapon wall and `--weapon=gatling`.
   - Its body draws 1.3x across the bore (`weapon_art.json cross_k`; 1 = before), so at 32 px/m it reads as r1_w6's heavy gun instead of a thin bar.
   - Evidence: `gatling-128ppm-vs-r1w6.png`, `gatling-pit-32ppm.mp4` (3 waves, 8 kills, 0 deaths), `gatling-belt-tracer-ab-128ppm.png`.
7. **Pickups lie inside a dashed paper loot ring** over a faint wash, as in r2_w8, instead of an opaque paper disc. `--pickup-disc=on` brings the disc back for A/B.
   - The small pickups draw at least 1.05 m (`weapon_art.json pickup_min_span_m`), so they fill the ring as on the sheet; the big ones keep their length. 0 gives true size.
   - Pickups take r2_w8's bold ink edge: 2 world px (`weapon_art.json pickup_outline_px`, was 1; `--pickup-outline=<px>` for A/B; 3 fattens the katana into a blob).
   - Evidence: `pickup-ring-ab-48ppm-vs-r2w8.png` (second row: the span before and after; third row: the edge 1 over 2 beside r2_w8).
8. **Tooling:** lint now runs gdformat/gdlint in batches of 200. Before, past ~810 files the file list overran the Windows command line and both tools failed with no output.

**Combat did not regress.** The director reel (`--bot=reel --reel=director --loadout=pistol`, 7200 ticks) brings down every one of its 16 chapters, last checked on 0fa61942 (the muzzle flash, the comet tracer, the violet arc and the plasma comet), 0 script errors.

**Gates on 192b7e8c:**
- lint 13/13;
- unit 949/950 (the one failure is the known `test_noir_shadows` flake; it passes 2/2 alone);
- scenarios 46/0.

The last full evidence gate was green on 9cc56a51 (2026-11-05 05:10, the muzzle flash, the comet tracer, the violet arc and the plasma comet; `scenario_rig_stress` failed its 1 ms timing budget once under contention and passed 2/2 alone): lint 13/13, unit 958/0, scenarios 46, parity bit-exact, look goldens 11/11 (worst 0.00, re-blessed at ef4dda00 for the joints) + block 5/5, world lock 0.00 %.

## What doesn't (yet)
- **Pickups:** the ring and the fill now follow r2_w8 (see item 7 above); the side views themselves (gunmetal tone) do not yet.
- **Held parts:** in design they are close to r1_w1-w3 (the hand cannon's cylinder, the SMG's feed box, the pistol's slide); only the tone differs, rust-tan against gunmetal.
- **The Gatling:**
  - its housing prints grey (the 1.3x `cross_k` fixed the slim silhouette). The grey is by design: the held parts print through `print_part`, whose only inks are paper, ink, vermilion and cop blue. The cast lane's warm ramp is Rivet's D5 close-up only, so the merge will not change it (see Calls);
  - there is no director-reel chapter for it (left out on purpose, so the approved reel keeps its timings).
- **FX gap to r2_w4:** the white-hot tier prints cream through the FX print's paper snap (the smoke frame's flash, b59dfb73, carries the white-hot core now) (the lumpy edge landed cd654482, the grade 986da3b6). (Debris landed f0987078, the smoke ring c53cbbfa; the white-hot first frame c1a6cdaa; the ray rings' olive tail e7bccb95.)
- **FX gaps left to r2_w4 (iteration 14):** the arc's many small side twigs (tried: at game scale they turn the bolt into a scribble; the ink ring cannot carry hairlines at 0.2 cell scale); the sheet's ink speed dashes behind the bullet rounds (under 1 px at 32 px/m; the shard carries its own since iteration 16); the ray's tendril halo is thinner than the sheet's; the plasma comet lacks the sheet's loose ember flecks (sub-pixel at 32 px/m).
- **Fixed in shared code:** `--telemetry` together with `--reel=director` crashed at quit. The ReelDirector hook has no station and `ArenaStage.telemetry_dict` read `hook.station.id`. Main has the bug too. A hook without a station is now keyed `hook_<n>`.
- **Unmeasured:** the frame cost of the riso layer and of `look_d5_fx` with nothing else running. No bench lock was taken; the machine is shared.

## Calls for the owner
- **Riso dial:** `world_riso.riso` at its default or lower (`print-3way-city-32ppm-it2.png`).
- **Paper tone:** the new light warm cream (`world_riso.tan_tone` [1.02, 0.99, 0.94], measured between today and r2_a5) vs iteration 2's darker tan (`[0.92, 0.875, 0.8]`); side by side in `print-3way-city-32ppm-it10.png`.
- **FX colour vs ink:** `fx_colour_dir` (`fx-colour-reel-ab-32ppm.mp4`).
- **Held size:** `held_size_ref` 1.2 vs off (`held-size-ab-cast-merge.png`).
- **Alley value structure:** the light lane between dark mass (iteration 7) vs the dark lane between pale roofs (iteration 3); every fill is `alley_decor.json tones`, the old values in `tones.doc` (`alley-it7-ab-48ppm-vs-r2a6.png`).
- **Pickup look:** the dashed ring vs the paper disc (`pickup-ring-ab-48ppm-vs-r2w8.png`, `--pickup-disc=on`).
- **A warm item ink:** held weapons print grey because the part print has no tan ink. Adding one would warm every held gun toward r1_w1-w6, not just the Gatling (`gatling-128ppm-vs-r1w6.png`). Not built.
- **Grain:** `world_riso.speck_k` 0.4 vs 0 (before) or higher toward r2_a5 (`print-speck-it9-2x-vs-r2a5.png`).
- **Grime splats:** `world_riso.splat_k` 0.8 vs 0 (before); `splat_cut` is the density dial (0.76 = twice as many, 0.82 = sparser). See `print-splat-it11-city0-vs-r2a5.png`. In the arena, the paper margin round the floor takes them at full density (no tile joints): `arena-reel-splat-ab-32ppm-it11.mp4` (20 s, off | on).
- **Hairline cracks:** `world_riso.crack_k` 0.6 vs 0 (before); `crack_run` is the density dial (0.55 = more and longer runs, 0.7 = sparse). See `print-crack-it12-city0-vs-r2a5.png`.
- **Energy round shapes:** the shard's arrowhead (`shard_arrow.png`) vs the lozenge (`shard.png`) and the ray's beam (`projectile_fx` "ray_beam") vs the hoop train ("ray_ring"), one value each in `weapon_art.json` (`fx-shard-arrow-it16-vs-r2w4.png`, `fx-ray-beam-it16-vs-r2w4.png`).
- **Bullet tracer shape:** the comet (`tracer_comet.png`) vs the weapon-art lane's spear head (`tracer.png`), one value in `weapon_art.json` (`fx-tracer-comet-it14-vs-r2w4.png`); the same for the plasma round (`plasma_comet.png` vs `plasma_bolt.png`, `fx-plasma-comet-it14-vs-r2w4.png`).
- **The Gatling's bulk:** `cross_k` 1.3 vs 1.0 (bottom row of `gatling-128ppm-vs-r1w6.png`).
- **The Gatling's feel:** `spin_s` 0.5 and `fire_move_mult` 0.45 (`gatling-pit-32ppm.mp4`). Setting them to 0 and 1 makes it a plain auto gun.

## Next steps
- **Merge:** after the n5-cast + n5-look merge, re-bless the look goldens once (the branches conflict only in the goldens and JOURNAL; the toner speckle's in-gate drift is folded into that re-bless).
- **Weapon art:** the Gatling's tone waits on the warm-ink Call (its silhouette is done, `cross_k` 1.3). In design the held parts are already close to r1_w1-w3 (only the tone differs), so redraw them only if the owner asks.
- **Costs:** measure the frame cost under the bench lock.
