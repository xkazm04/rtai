# Rivet's moving feet after the repair

At tilt 70 all seven wheel selections step in profile and three-quarter view at both 32 and 64 px/m. The five that slid now alternate soles against the floor ruler. Wheel slot 0 was already playing the bare grid. Walk is 2.4 m/s and run is 3.2 m/s, on opposite sides of the engine's 2.5 m/s threshold.

| Wheel selection | Before | After, seen in the matched frames | Walk / run art |
|---|---|---|---|
| hands (slot 0) | Stepped | Empty claw, same boots and cadence. | Bare pair |
| pistol | Stepped | Pistol and wrist are painted into the original poses. | Pistol pair |
| gloria | Slid | Feet alternate. A single slim Gloria follows the palm through its swing. The narrow profile reads best at 64 px/m. | Bare pair + Gloria |
| rocket_launcher | Slid | The orange-nosed tube moves with the claw. Both boots separate in the three-quarter run. | Bare pair + launcher |
| assault-rifle | Slid | The stock and barrel stay together at the palm while the boots change lead. The carry uses one claw. | Bare pair + rifle |
| chainsaw | Slid | The housing and toothed bar follow the gripping claw through the step. | Bare pair + saw |
| electro_baton | Slid | The electrode tip stays above the stepping boots. The slim baton is easiest to distinguish in profile at 64 px/m. | Bare pair + baton |

The bare pair is `rivet_walk8.png` / `rivet_run8.png`. The pistol pair is `rivet_walk_eq_pistol.png` / `rivet_run8_eq_pistol.png`. Each pitch has its own directory. No borrowed pose showed a second weapon or a pale rim. The large weapons share the bare-claw carry. A bespoke shoulder brace or second supporting hand would need new drawings.

## Contact measurements

The profile captures use the same floor and speeds as the [baseline](slide_before.md). With the five repaired selections, `tools/film/foot_slide.py` measured the following absolute net displacement of the planted sole from contact to release. The original fixed boots travelled about 2.4 m walking or 3.2 m running in one second. The original baton tip obscured that measurement.

| Tilt 70 | Walk mean / maximum | Run mean / maximum |
|---|---:|---:|
| 32 px/m | 1.5 / 3.1 cm | 4.8 / 8.6 cm |
| 64 px/m | 1.1 / 2.1 cm | 5.3 / 8.7 cm |

The original bare run still holds a drawing for 13–14 ticks at 3.2 m/s. At 64 px/m the sole moved an average of 67.1 cm within a held run drawing before later drawings corrected the net stance displacement. That cadence also applies to the five repaired carries.

Two additional takes exercised all 18 arsenal IDs at 64 px/m. Each played a walk and a run in two directions. All 144 pose selections reported an animated grid and an on-screen rig. The 13 borrowed carries reported their actual held part. The five drawn carries used the weapon in their grid. The [left-facing p55 sheet](C:/Users/kazda/kiro/gtai-masters/n24/motion/checks/p55_left.png) shows the weapon profiles, including Gloria and the baton. The [right-facing p70 sheet](C:/Users/kazda/kiro/gtai-masters/n24/motion/checks/p70_right.png) shows how the steeper pitch foreshortens those two parts.

## Weapon and image checks

Option (a) cut through the wrist and torso where the pistol overlapped Gloria. In the [64 px/m masking trial](C:/Users/kazda/kiro/gtai-masters/n24/motion/trials/masked_family_64.png), the floor shows through the painted figure. Option (b) uses the bare gait and places the real held sprite at a measured palm position in each drawing. A small sample of the painted fingers covers the grip. The `borrowed_grid` setting selects this treatment.

Pistol, plasma rifle, katana, Gatling and flamethrower matched the baseline PNG bytes on every captured tick at both zooms, 1,440 of 1,440 frames. Empty hands matched on another 288. The comparison used the four real rig probes at tick 86 with the exported `judgeTick` from `tools/film/compare.mjs`, its pixel comparator at zero tolerance, and a byte comparison across ticks 40–183. The stock weapon shot stands still, so the adjacent `compare_captures.mjs` feeds the kit the moving captures. [Comparison results](C:/Users/kazda/kiro/gtai-masters/n24/motion/comparisons.json)

The [before film](C:/Users/kazda/kiro/gtai-masters/n24/motion/before/legs_32.mp4) and [after film](C:/Users/kazda/kiro/gtai-masters/n24/motion/after/legs_32.mp4) each contain 1,584 H.264 frames at 1920 × 1080, 60 fps, 26.4 seconds. Each weapon has a same-tick before/after image at each zoom under [motion masters](C:/Users/kazda/kiro/gtai-masters/n24/motion/), named `legs_<weapon>_<ppm>.png`. The before and after folders also contain native PNGs, strips, foot tracks and capture manifests.
