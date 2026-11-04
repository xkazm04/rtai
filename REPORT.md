# n5-look REPORT (draft 2026-11-04 23:05; rewritten at the 08:40 report)

Branch `n5-look`, cut from main `a1275c82`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n5\look\` (`frames.json`, 15 entries).
Detail and every measurement: `JOURNAL.md`. Decisions: `docs/decisions.md` (lines tagged n5-look).

## What works (with its evidence)

1. **The print, toward the riso middle ground** (r2_a5 + r1_a1). It's a riso layer inside `look_d5`, set by one dial (`world_riso.riso`); `--look=today` gives the old print for A/B.
   - What's in the layer: world-locked fine halftone, small per-plate misregistration, paper fibre, the tan stained sheet (`tan_k`, `stain_k`), and grain toned down (0.5 -> 0.3, not removed).
   - The building cast shadow went from 1.1 m to 0.45 m, so there are no long casts.
   - Blood stays the only deep red: the tan and the stains apply to neutral pixels only.
   - Evidence: `print-3way-city-{32,64}ppm-it2.png` (today | ours | target), `print-pan-today-vs-riso-32ppm.mp4` (the shimmer check: the residual after the camera shift matches today's, 1.29 %), `arena-reel-today-vs-riso-it2-32ppm.mp4` (the fight is identical tick for tick).
   - The look goldens were re-blessed once, with a decisions line.
   - Frame cost was CONTENDED, so the riso delta is unresolved below the ~0.1 ms noise. Statically it adds 2 screen fetches plus about 5 lattice fetches, with no new full-screen pass.
2. **The alley stage** (`--arena=alley`, 48 px/m). It's an east-west lane north of the range: asphalt, puddles, dumpsters, bag piles, fire escapes from above, roofs with a brick lip, and a chain-link fence. Cop waves come in from both ends (AlleyHook).
   - Evidence: `alley-it7-ab-48ppm-vs-r2a6.png` (iteration 3 | iteration 7 | target) and `alley-fight-vs-r2a6-48ppm-it7.mp4` (20 s beside r2_a6). Iteration 7 flipped the value structure toward the target: a light concrete lane between dark roofs and a dark brick lip, dark dumpsters, grey pools, bags and litter; every fill is `alley_decor.json tones`; bags are tied sacks, and the south side passage is closed (hub cops had queued in it).
3. **Weapon FX in the sheet's colours** (r2_w4).
   - The colours: muzzle yellow-orange; blast orange-yellow with a white core; arc violet-white; plasma white-hot with gold; ray acid green; shards pale crystal with a cyan-white glint. The tracer is its own hot-yellow family.
   - No blood red and no teal in any of them. In the live fight the cells draw on their own canvas under `look_d5_fx`; `fx_colour_dir ""` switches back to ink.
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
   - Evidence: `gatling-128ppm-vs-r1w6.png`, `gatling-pit-32ppm.mp4` (3 waves, 8 kills, 0 deaths), `gatling-belt-tracer-ab-128ppm.png`.
7. **Pickups lie inside a dashed paper loot ring** over a faint wash, as in r2_w8, instead of an opaque paper disc. `--pickup-disc=on` brings the disc back for A/B.
   - The small pickups draw at least 1.05 m (`weapon_art.json pickup_min_span_m`), so they fill the ring as on the sheet; the big ones keep their length. 0 gives true size.
   - Evidence: `pickup-ring-ab-48ppm-vs-r2w8.png` (bottom row: the span before and after).
8. **Tooling:** lint now runs gdformat/gdlint in batches of 200. Before, past ~810 files the file list overran the Windows command line and both tools failed with no output.

**Combat did not regress.** The director reel (`--bot=reel --reel=director --loadout=pistol`, 7200 ticks) brings down every one of its 16 chapters, last checked on 2b9f6b38 after the alley change.

**Gates on 192b7e8c:**
- lint 13/13;
- unit 949/950 (the one failure is the known `test_noir_shadows` flake; it passes 2/2 alone);
- scenarios 46/0.

The last full evidence gate was green on 27c48341.

## What doesn't (yet)
- **Pickups:** the ring and the fill now follow r2_w8 (see item 7 above); the side views themselves (gunmetal tone) do not yet.
- **Held parts:** in design they are close to r1_w1-w3 (the hand cannon's cylinder, the SMG's feed box, the pistol's slide); only the tone differs, rust-tan against gunmetal.
- **The Gatling:**
  - its housing prints grey and slimmer than the target's chunky tan body;
  - there is no director-reel chapter for it (left out on purpose, so the approved reel keeps its timings).
- **FX gap to r2_w4:** the blast has no debris chunks. (Its first frame now has the white-hot core inside the orange-yellow burst: c1a6cdaa.) (The ray rings' olive tail is fixed: e7bccb95.)
- **Fixed in shared code:** `--telemetry` together with `--reel=director` crashed at quit. The ReelDirector hook has no station and `ArenaStage.telemetry_dict` read `hook.station.id`. Main has the bug too. A hook without a station is now keyed `hook_<n>`.
- **Unmeasured:** the frame cost of the riso layer and of `look_d5_fx` with nothing else running. No bench lock was taken; the machine is shared.

## Calls for the owner
- **Riso dial:** `world_riso.riso` at its default or lower (`print-3way-city-32ppm-it2.png`).
- **FX colour vs ink:** `fx_colour_dir` (`fx-colour-reel-ab-32ppm.mp4`).
- **Held size:** `held_size_ref` 1.2 vs off (`held-size-ab-cast-merge.png`).
- **Alley value structure:** the light lane between dark mass (iteration 7) vs the dark lane between pale roofs (iteration 3); every fill is `alley_decor.json tones`, the old values in `tones.doc` (`alley-it7-ab-48ppm-vs-r2a6.png`).
- **Pickup look:** the dashed ring vs the paper disc (`pickup-ring-ab-48ppm-vs-r2w8.png`, `--pickup-disc=on`).
- **The Gatling's feel:** `spin_s` 0.5 and `fire_move_mult` 0.45 (`gatling-pit-32ppm.mp4`). Setting them to 0 and 1 makes it a plain auto gun.

## Next steps
- **Merge:** after the n5-cast + n5-look merge, re-bless the look goldens once (the branches conflict only in the goldens and JOURNAL).
- **Weapon art:** the pickup side views toward r2_w8 (cleaner gunmetal) and a chunkier tan Gatling housing. In design the held parts are already close to r1_w1-w3 (only the tone differs), so redraw them only if the owner asks.
- **FX:** debris chunks for the blast.
- **Costs:** measure the frame cost under the bench lock.
