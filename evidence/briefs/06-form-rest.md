# Brief 06 (lane tonnage): the rest of the form: HUD chip, transformation, hit reaction, the 55 degree tilt

Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png`. Look at it first, and again at every frame you judge.

All rules of `evidence/briefs/03-films.md`, `04-glow-arm.md` and `05-smoke-flight.md` still bind. In short:
git: no amend, no rebase, no squash, no stash, no `add -A/./-u`, no `reset --hard`, never push; a fix is a NEW commit; stage per path;
`export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/tonnage`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`,
`--rendering-driver d3d12` for anything that renders, `--position 0,1440` on any windowed run; one Godot process at a time; kill only by PID;
visual only (no `powers.json` number, hit box, reach, sim/replay/parity/bake digest moves); `tools/godot/check.mjs` false-fails on
unchanged files (ghost_rim.gd autoload chain): rely on `run_unit.mjs --changed` + `lint.mjs`. Mutate ALWAYS with `--max=40`.

Your files: `project/features/souls/tonnage_*.gd`, `hauler_*.gd`, `ram_*.gd`, `slam_debris.gd`, `plate_sparks.gd`,
`project/features/souls/art/tonnage/**`, the Tonnage files under `art/view/p70` and `p55`, the `tonnage` rows of
`ghost_hover.json` and `ghost_forms.json`, tests named for those files, new files prefixed `tonnage_`
(including `project/features/hud/art/ghost_chips/tonnage_spectral.png` and `tools/art/tonnage_chip_cut.py`).
NOT yours: `ghost_*.gd` (flight), `ghost_chip_face.gd` (flight), other ghosts' files. One-line call sites in a flight
file only if unavoidable, and name them in your report. Need something from flight: write `NEED flight: <file> <what>` in the report.

## 0. Merge flight (if it has new commits)
`git log --oneline HEAD..n20-flight`. If there are commits, `git merge n20-flight` (package 3: `4362c8109` spectral HUD chip loading,
tail 0b dense vapour + ink edge, `set_emerge` transformation, hit lean on the hovering body, rise sign, maybe a `--take=morph` in
`ghost_review.gd` and `tools/film/ghost_films.mjs`). Keep our `tonnage` row values on a conflict, take flight's everything else.
`node tools/tests/run_unit.mjs --changed`. Then render the p70 rest frame (tick 72, 64 px/m, spectral) and check: exactly one body,
the smoke column still reads as the plate's (thick, low, curling back), the hanging wisps are not legs. If flight's new tail
defaults changed our column, re-tune our row only.

## 0b. The tail is NOT yet smoke (director's look at 05's renders, `build/tonnage05/final/tilt70-spectral-64-move-163.png` and `-attack-72.png`)
What I saw: (a) behind him a spray of short jagged teal scribbles that read as electric sparks (Ohm's language, not Tonnage's) — that is
`fray` 0.82 + `wisps` 5 at this width; (b) a single thin pale line arcing from under the body down to the ground and across the
kerb, like a loose cable. TRACED (director, 04:0x): this is OURS, `RamWake.draw` (`project/features/souls/ram_wake.gd:49-50`, ink 5 px +
cream 2 px swept arcs from the nose to the flanks, at the GROUND point, on whenever speed > 0.8 x ram_mps — i.e. at every cruise).
Under spectral the armed fist is the ram tell (the owner: "the ram reads only through a thin bow ... no body commitment"), so:
under `GhostLook.spectral(&"tonnage")` RamWake draws nothing (strength 0; keep the legacy look exactly as it is; one const/branch,
so it is one value to bring back). Keep the dust streaks only if they read as dust off the fists' shadows, not as lines; default off.
Test: under spectral `RamWake.strength(...)` (or whatever gate you add) is 0 at 4.2 m/s; under legacy unchanged.
The jagged sparks are ours too: the main column row (`fray` 0.82) and/or `TonnageVapour.CHEST` (`fray` 0.92).
The plate's column is a SOFT, DENSE, BRIGHT teal mass, widest at the waist, with rounded billowing edges and one up-curl at the end.
Do: after merging flight's 0b, set `fray` low (0.1-0.25), `wisps` 0-2 (and only as soft puffs near the tip), `strands` 2, width as wide
as the waist, and check at 64 px/m p70 AND 32 px/m top that it reads as one soft column. If the pale cable line is still there after
flight's 0b, write `NEED flight: ghost_tail.gd <the cable line: what draws it, which tick/still>` and set our row so it is least visible.
Also check `tonnage_vapour.gd` (the hanging wisps): if it is the thin line, make it a soft short puff column that fades out a metre
above the road, or turn it off (one const) and say so. Before/after stills at tick 72 p70 64 px/m and tick 125 top 32 px/m:
`tonnage_tail_fix_*.png` / `_before.png`.

## 1. HUD chip (small, do it first)
`GhostChipFace.face(&"tonnage")` (flight `4362c8109`; until merged see that commit) loads `art/ghost_chips/tonnage_spectral.png`
under the spectral look. Make it WITHOUT a new image: write `tools/art/tonnage_chip_cut.py` modelled on `tools/art/ghost_chip_cut.py`
(read it: SIZE 84, square crop round the figure, own transparent silhouette, no disc) that cuts the CARRY cell of the
facing-the-camera row (row 0) of `project/features/souls/art/view/p55/tonnage_spectral_pose.png` (cells 384x320; check the packer
`tools/art/tonnage_spectral_pack.py` for the layout). Crop so the hump, visor and both press fists fit with ~4 px of air; the
chip is 84 px, so the hazard stripes and the visor slot must still be visible. Commit the PNG + `.import` + `.uid` if any, add one
provenance line in `steam/ai-provenance/2026-11.jsonl` (derived from the p55 pose master; copy the format of the existing lines)
and an `art_src` manifest entry if the existing chips have one (check `art_src/*.manifest.json` for `ghost_chips`).
Evidence: a 1080p HUD still under `--ghost-look=spectral` with the tonnage chip, and the same under legacy:
`C:\Users\kazda\kiro\gtai-masters\n20\tonnage\tonnage_chip_hud.png` / `tonnage_chip_hud_legacy.png` (any dev driver that shows the
ghost HUD; `node tools/dev/run.mjs <entry> --dry-run` lists flags; if none shows it, a 4x contact of the chip beside the other three
chips on dark and light ground is acceptable: `tonnage_chip_contact.png`). Test: under spectral `face(&"tonnage")` resolves to the
spectral file (only if flight's test does not already cover a form with a real file; then one assert in a tonnage test).

## 2. Transformation in and out
Rivet transforms into Tonnage and back (`GhostForms` stages; `HaulerStage`/`RivetPlan.FORMS` `morph_k()`). Under spectral our
`TonnageSpectral` owns the body (`drawn.own_body`), so flight's emerge (`GhostFlight.set_emerge(k)` if package 3 landed: lift, tail
and pool grow from 0) does not by itself scale or reveal OUR cells. Make the IN read as the plate's genie rising out of Rivet: across
the morph the Press Golem body grows from Rivet's size and fades in from the ground up (the tail and lift come from flight's emerge),
the fists unfold last (start tucked against the chest, swing out to carry in the last third); OUT is the reverse, ending on Rivet
standing with nothing of the golem left. Render only: the stage timings do not move. Drive it from what the rig already gets
(`morph_k()` / the stage the view reads); tick-driven, no delta.
- Before you code, film/still what happens TODAY under spectral at the morph (in and out): if flight's `--take=morph` exists, use
  `node tools/film/ghost_films.mjs --ghost=tonnage --look=spectral --takes=morph ...`; otherwise a still sequence with
  `ghost_review.tscn` and the transform input (read `ghost_review.gd` flags). Name: `tonnage_morph_before_*.png`.
- After: `tonnage_morph_32.mp4` + `.jpg` poster (both views: 70 deg above, top below) and a 6-frame strip at 64 px/m p70
  `tonnage_morph_strip_64.png` (IN at k = 0, 0.2, 0.4, 0.6, 0.8, 1.0). Look at it: no frame may show a legged legacy body, a double
  body, or the golem at full size on frame 1.
- Test: at morph k = 0 the golem is not drawn (or alpha 0), at 1 it is at full scale with the fists at carry.

## 3. Hit reaction
Law: Tonnage's hit lean is 4 degrees (`GhostRecoil.LEAN_BY_FORM`; never edit that value). Today `TonnagePose.lean_k = 1 - armed_k` suppresses
the lean while the ram fist is armed. Extend the same idea to the slam: during the wind-up and the strike the lean must not fight the
double-fist clap (scale it down while the act runs, back to 1 in recovery). Then check the recoil cell under fire at rest and at cruise:
the RECOIL column must read as a flinch of the same golem (same size, fists pulled in), not a pop. If flight's package 3 moved the lean onto the
hovering body, make sure ours is not applied twice (one lean, not two). Test: lean_k < 0.25 at the slam strike, 1 at rest.
Evidence: `tonnage_hit_slam_64.png` (a hit landing during the wind-up, p70) with `_before`; `tonnage_recoil_64.png` re-rendered.

## 4. The 55 degree tilt
Everything so far was judged mostly at 70 degrees. Render at `--view=tilt` (55 deg, 64 px/m, spectral) and put next to the plate:
rest (tick 72), RAISE (tick 118), POUND (tick 123), ram armed (tick 247), contact (259):
`tonnage_p55_contact_64.png` as one 5-panel strip. Fix in OUR art or rig anything that reads wrong only at 55 (an oblique facing,
a fist that hangs like a leg, a cell offset). Say in the report what you saw.

## 5. Evidence and housekeeping
- Re-film after 1-4: `node tools/film/ghost_films.mjs --ghost=tonnage --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n20/tonnage --takes=move,attack,close --stills=163`
  (real speed). Update `frames.json` (8 to 15 entries, best first: plate still, slam strike top view, ram armed lead, smoke column, morph strip,
  p55 strip, chip, recoil...). Delete scratch it does not reference.
- `node tools/tests/run_unit.mjs --changed` and `node tools/lint/lint.mjs` green before each commit.
- After the last code commit: `node tools/mutate/mutate.mjs --file=features/souls/tonnage_spectral.gd --max=40` (or the file holding the
  morph code) and report killed/(killed+survived); add a test for any survivor you can kill in 10 minutes.
- One `docs/decisions.md` line (append, one line) for the morph design.
- Session 05 (killed at its cap, no report) left mutate on `tonnage_spectral.gd` at 13.2% = 5/(5+33) (`build/mutate/features-souls-tonnage_spectral.json`
  lists the survivors). If time remains after item 5, add tests that kill the survivors guarding what the owner sees (cell choice per
  facing/pose, the lean scale, own_body/legacy branching) and re-run with `--max=40`. Report both scores.
- Stop by the 70-minute mark with everything committed.

## Order (commit each on its own)
0, 0b (the tail is what the owner judges first), 1 chip, 3 hit lean, 4 p55 strip, then 2 morph. Flight's transformation emerge
(`set_emerge`) may not have landed yet (flight expects package 3's tail commit around 04:30, emerge later): `git log HEAD..n20-flight`
before item 2 and merge if new commits are there. If emerge is still missing, do the morph on our body only (scale/fade/fists from
`morph_k()`), which must work with or without emerge, and say in the report what the tail/lift do at the morph today.
Re-film (item 5) once at the end, not after every item.

Report: commits (sha + line), checks run and results, every still/film path, the mutate score, NEED lines, what is not done.
