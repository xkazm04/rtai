# d8 chars: REPORT (2026-11-06, freeze 18:30)

Lane `chars`, branch `d8-chars`. Rivet and the four ghosts under the 55-degree view (`--view=tilt`),
plus the shared view code (`ViewMode`, `RigHeadCard`, `RigDepthSort`, `GhostCard`, `view.json`).
Masters: `C:\Users\kazda\kiro\gtai-masters\d8\chars\` (`frames.json`, 15 entries, best first).
Details, measurements and dead ends: `JOURNAL.md`.

**Everything new is keyed by the view row's `art` (`p55`).** `top` draws today's art bit-identically,
and view70's `p70` art sits beside it. The before for every film is the study row `tilt_basecards`:
the same 55 pitch, with no p55 art.

## What works (with evidence)

| Item | Commit | Evidence (masters) |
|---|---|---|
| **Rivet's p55 bust card**: head with the logo visor, the vermilion hazard collar and the riveted tan chest. 5 drawn facings + 3 mirrored, cut from `rivet_55.png` by `tools/art/rivet_bust.py`, re-inked where the mask cut through the art | 54c05d12, 1fcba322 | `rivet_bust55_walk_sprint_roll_claw_tilt_64ppm.mp4` (64 px/m), before/after at 32 px/m (`..._before_after_tilt_32ppm_x2.mp4`, `rivet_bust55_reel_claw_pistol_...`), pistol at 64 px/m before/after `rivet_bust55_pistol_before_after_tilt_64ppm_x3_slow2.mp4` |
| **Rivet in every hold class**: all 19 director-reel chapters (claw, sidearm, long gun, tube, heavy, chainsaw, thrown, blades) | (art above) | `rivet_bust55_all_holds_tilt_48ppm_director_reel.png` |
| **Rivet's hit reactions under tilt**: the card dips on each hit and takes the hit flash | (on_tint) | `rivet_bust55_hits_to_death_servo_tilt_48ppm_x3.mp4` |
| **Per-view art route**: the view row's `art` key, `RigHeadCard.rows_of(art)`, `SET_CARDS[art]`, live rebuild when the art changes (for view70's combined view), `ViewMode.set_pitch` + `revision` | 8e557502, 01387fb6, e0e73ffc | unit `test_rig_head_card`, `test_view_mode` |
| **Tonnage**: stands on its legs under tilt; the p55 facing card (gunmetal, teal seams, hazard press head) over the walking pistons, soul halo 0.35 | 19063ada, 4eb02025, 93bd317e | `tonnage_card55_before_after_tilt_48ppm_ghostreel.mp4` |
| **Dent**: the p55 bust card, printed to his in-game tan | 8902c1d2 | `dent_bust55_before_after_tilt_48ppm_x2_ghostreel.mp4` |
| **Ohm**: the p55 card (shell, goggles, cable beard with copper tips) over the cane and guard arms, halo 0.45 | 12b205eb, f0ce9dd5 | `ohm_card55_before_after_tilt_32ppm_x2_ghostreel.mp4`, `ohm_card55_halo_tilt_64ppm_t2_t4_t6.png` |
| **Kerf v2** (Rivet-tall, thin, blade forearms with bright cyan edges): the card replaces the hover body under tilt, halo 0.4, a 12 deg lean into the glide | f2e781dc, 0d417c52 | `kerf_card55_before_after_tilt_32ppm_x2_ghostreel.mp4` |
| **Draw order (owed by the view REPORT)**: ghost cards depth-sort with the rigs, and the whole host takes the card's level. `--order-probe` counts ghost-card pairs. Ghost reel 600 ticks: Tonnage wrong pairs 18/26 -> 3/26, Kerf 28/28 -> 0/28, rig pairs 0 wrong before and after | 34651864, e5f2a9bd | `kerf_card55_draworder_before_after_tilt_64ppm_*.png` |
| **Street cast**: p55 cards for SWAT, the patrol cap, the riot helmet, the robot thug and all five ped heads (hair, bald, and since d0bec791 hat, hood, cap from the library's new A-graded sheets), cut from the assets library's keyed 55 sheets (`tools/art/street_head.py`, no image job). No head of the street cast reads top-down under tilt any more | d58d379a, 69574457, bd142385, d0bec791 | `cop_cap55_before_after_tilt_48ppm_pit_seed3.mp4`, `cop_cap_riot55_..._x3_reactline_t5.png`, `street_hat_hood55_before_after_tilt_48ppm_x3_city.png` |
| **view70 REQUEST it3**: `RigHeadCard.drop` renames the dropped card first, so a card rebuilt in the same frame keeps the name `head_card` | 2dd6e236 | unit `test_a_dropped_card_gives_up_its_name_for_the_rebuild` |
| **Combined clip** (74 s: Rivet 64, Rivet reel, Tonnage, Dent, Ohm, Kerf, cops) | - | `chars_d8_set_tilt_combined.mp4` |

### Gates

The gate numbers are in the last section.

- `top` is unchanged: the city block (`--arena=city --bot=rivet --seed=2 --rigs`, 301 frames of video and audio) matches main 0bea8b93's framemd5, and so does the Kerf ghost reel (400 frames).
- The director reel goes 19/19 chapters down with 0 SCRIPT ERROR, in `top` (headless) and in `tilt` (48 px/m, rendered).

## What does not work / not done

- **Rivet has no death pose to judge.** The quest stage (`collect_call_stage.gd _respawn`) and the dev arena both respawn him the same tick his hp hits 0. His rig has a DEATH sprawl clip (`RigClips.die`), but nothing calls it for Rivet. Raised as a call below.
- **The flamethrower's back tank and the rocket tube's breech draw over Rivet's visor** when he faces screen right under tilt. That is weapons' `rivet_held_view.gd`. The REQUEST is in JOURNAL iteration 10 and has no answer yet. Still: `rivet_bust55_tank_tube_over_visor_tilt_48ppm_x4.png`.
- **Draw order left over:**
  - Tonnage's walking legs still ride the ghost view's fixed z (3/26 wrong pairs).
  - At depth level 2, a card host can pass the ghost FX (rare crowd case). Capping it made Kerf 0/28 -> 6/28 wrong, so I reverted it.
  - The King's accents are not in the probe. bosses own KingAccents.
- **Street heads:**
  - The hoodie-cap card is built and unit-loaded, but it did not appear in the two city crowds I filmed (seeds 2 and 5), so it is not judged in game.
  - The hat card's collar is tan, while the coat-hat ped's coat draws dark (still above).
- **The card at 32 px/m:** the 192 px cell is drawn at about 25 px, so the collar stripes alias a little. Mipmaps and a 48 px strip both came out softer, so I kept the crisp one.

## What blocked

- **The image lock:** the asset lane held it for most of iteration 3, so the Dent and Tonnage sheets slipped one session.
- **Billing:** iterations 1-2 died at launch on billing.
- **This session's export templates:** `appdata/chars/Godot/export_templates` was an empty plain folder, not the junction. I replaced it with a junction to the shared templates. Export now takes 11 s.

## Calls for the owner

Each call below is one data value away. The exe is `build/export/windows/RTAI.exe` (the `windows-showcase` preset, which boots into the arena). Arena flags go after `--`. For a before, swap `--view=tilt` for `--view=tilt_basecards`.

1. **Card facing count: 5 drawn + 3 mirrored (built) or 8 drawn.**
   - The mirror flips the collar's hazard-stripe slant and the skull seam on the left facings (checked on the strip; the visor is symmetric, so it survives the flip).
   - 8 drawn costs one image round per character.
   - See: `rivet_bust55_walk_sprint_roll_claw_tilt_64ppm.mp4`, and `RTAI.exe -- --bot=reel --reel=director --chapter=claw_combo --ppm=64 --view=tilt --rigs`.
2. **Rivet's scale under tilt:** the bust row width is 1.25 x the collar part (`SET_CARDS["p55"]["rivet"][2]`), anchor 0.66. Built: 1.25.
3. **Dent: tan (built, his in-game crash dummy) or the 55 sheet's all-teal Dent.**
   - The teal strip is `p55/dent_bust_card_teal.png`, one path in `SET_CARDS`. Teal Dent would also need teal limb parts.
   - See: `dent_bust55_before_after_tilt_48ppm_x2_ghostreel.mp4`, and `RTAI.exe -- --bot=ghosts --ghost=dent --ppm=48 --view=tilt --rigs`.
4. **The ghosts' teal glow at height:** the soul halo alpha is Ohm 0.45, Tonnage 0.35 and Kerf 0.4 (`CARD_HALO_A` in each rig; 0 = the bare card). Built: those values.
   - See: `ohm_card55_halo_tilt_64ppm_t2_t4_t6.png`, and `RTAI.exe -- --bot=ghosts --ghost=ohm --ppm=64 --view=tilt --rigs`.
5. **Kerf v2: the thin card at 32 px/m (built, 0.8 m wide, about 60 px tall) or a wider card.**
   - The lean into the glide is 12 deg (built); `KerfRig.CARD_LEAN` 0 keeps him upright.
   - The v2 sheet itself still waits for your look.
   - See: `kerf_card55_before_after_tilt_32ppm_x2_ghostreel.mp4`, and `RTAI.exe -- --bot=ghosts --ghost=kerf --ppm=32 --view=tilt --rigs`.
6. **Ohm's arms: on the ground (built; the cane and the guard arms stay rig parts, so the attack telegraphs keep moving) or lifted to the card's hand height.**
   - See: the Ohm stills above.
7. **The street cop tone: the rig's navy (built) or the 55 sheet's brighter police blue.**
   - To switch, re-run `tools/art/street_head.py` without the `navy` fix.
   - See: `cop_cap_riot55_before_after_tilt_48ppm_x3_reactline_t5.png`, and `RTAI.exe -- --bot=react_line --ppm=48 --view=tilt --rigs`.
8. **NEW: Rivet's death beat.** Today he vanishes and wakes in the Toner Room on the same tick.
   - Option: play his existing DEATH sprawl (`RigClips.die`) for about 1 s under a fade before the respawn cut. That is a sim timing change (a respawn delay), so it would need a replay/golden re-bless.
   - Default built: none (unchanged).
   - See the cut: `rivet_bust55_hits_to_death_servo_tilt_48ppm_x3.mp4`, and `RTAI.exe -- --boss=servo --bot=boss --bot-stand --seed=4 --ppm=48 --view=tilt --rigs`.

## Registry rules applied

- **depth-ordered-layered-art:** the bust card rides the head's z, and the torso hides under it. The ghost card's host takes the card's depth level. Order was measured with `--order-probe` before and after.
- **sprite-and-atlas-production:** each strip is equal cells, a multiple of FRAMES, and unit-tested to load. Cards are cut by script from keyed sheets with a tolerance of 12 or more.
- **concept-scene-parity:** every call was judged on live game frames at 32/48/64 px/m, with the same seed before and after.
- **motion-quality-gating:** everything was judged in motion (director reel, ghost reel, boss arena, city block), with gates in both views.
- **generative-artifact-gating:** cards are cut from owner-accepted sheets. Red and violet were hue-shifted out (blood red is reserved). There is a provenance line per AI asset in `steam/ai-provenance/2026-11.jsonl`.

## Next steps

1. When weapons answer the tank/tube REQUEST, re-film the flamethrower and rocket_launcher chapters at 48 tilt.
2. Rivet's death beat, if the owner wants it (call 8).
3. Judge the cap card in a crowd that has a hoodie-cap ped, and tone the hat card's collar to the coat.
4. Tonnage's legs into the depth sort; the King's accents in the order probe (with bosses).
5. If the owner picks 8 drawn facings: one image round for Rivet's left facings.

## Gates on the freeze head

Taken by iteration 13 on `2dd6e236` (APPDATA `gtai-d8/appdata/chars`, 17:33-17:40):

- `node tools/evidence/run.mjs --no-bench`:
  - lint 15/15 PASS;
  - scenarios 52 passed;
  - parity bit-exact over 1200 steps, planted mutation caught at step 629;
  - selftest PASS: look goldens 11/11 (worst 0.27), block goldens 5/5 (worst 0.22), world lock 0.00 %, no new off-doctrine accents;
  - export-audit 539 loaded / 0 failed.
- Unit: 1423 passed, 0 failed. The runner marked the step FAIL only because I created REPORT.md mid-run ("tree changed during run": `?? REPORT.md`). The clean re-run is below.
- Bench: not run (`--no-bench`, as briefed).
- Exe: `windows-showcase` exported in 11 s to `build/export/windows/RTAI.exe` (242 MB, + `gtai_sim.windows.template_release.x86_64.dll`).
  - Export: `APPDATA=C:/Users/kazda/kiro/gtai-d8/appdata/chars "$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
  - Smoke: `RTAI.exe --quit-after 900 -- --bot=reel --reel=director --chapter=pistol --ppm=48 --view=tilt --rigs` -> 2/2 down, 0 SCRIPT ERROR.

Re-taken on `d0bec791`, the freeze head's code (17:51-17:55):

- Unit (no-arg): 1423 passed, 0 failed (also on 9c039a76).
- Lint: 15/15.
- Exe re-exported at 17:53. Smoke runs, each 0 SCRIPT ERROR:
  - `RTAI.exe --quit-after 400 -- --arena=city --bot=rivet --seed=5 --rigs --ppm=48 --view=tilt --crowd=400`
  - the pistol chapter: 2/2 down.
