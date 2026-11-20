# Brief 03 (lane tonnage): fixes from the director's review of 02, then the step films

Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png`. Look at it, then at your own review sheets
`C:\Users\kazda\kiro\gtai-masters\n20\tonnage\scratch\rig-review\*.jpg`. The director accepted brief 02: he reads as
the plate in both views, RAISE is a clear V, the POUND leaves the car and victims visible. Fix the items below, then film.

**Git: no `--amend`, no rebase, no squash: a fix is a new commit.** Merging `n20-flight` again is allowed (only that
branch). Stage per path; no stash, no `add -A`, no reset --hard, never push.
Known: `tools/godot/check.mjs` fails `--check-only` on UNCHANGED files too (autoload resolution; e.g. `ghost_rim.gd`
at base `a3eb0bf78`): not yours, do not chase it; say so in the report and rely on `run_unit.mjs --changed` + lint.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/tonnage`;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver
d3d12` for renders; windowed runs `--position 0,1440`; one Godot process at a time; free your own processes by PID.
Still visual only: no sim, replay, parity or bake digest moves; `powers.json`/`ghost_attacks.json` untouched; you may
edit only `tonnage_*`, `hauler_*`, `ram_*`, `slam_debris.gd`, `plate_sparks.gd`, `art/tonnage/**`, the Tonnage files
under `art/view/`, tests named for them, and the `tonnage` row of `ghost_hover.json`.

## 1. Fixes from review (commit each)
0. **No double body.** `n20-flight` package 1b makes `GhostDrawn` show `<card>_spec_hover.png`/`_spec_act.png` under
   spectral. Tonnage keeps its own `TonnageSpectral` drawer and its own sheet names (`tonnage_spectral_pose/act.png`)
   on purpose. After every `git merge n20-flight`, render the p70 and p55 rest frame under `--ghost-look=spectral` and
   confirm exactly ONE Tonnage body shows and no legged legacy cell leaks through. If GhostDrawn now draws something
   for Tonnage, check whether flight gave an opt-out (grep `ghost_drawn.gd` for `own_body` or similar) and set it from
   `tonnage_rig.gd`; otherwise hide `drawn.sprite()` from `tonnage_rig.gd`/`tonnage_spectral.gd`, and report it.
1. **The smoke tail.** The plate's lower body is a THICK column of teal smoke that drags low behind and below the
   torso (about as wide as the waist at the root, curling back and fading). Today it reads as a small teal cone under
   the body at 70 deg and is not visible behind him from the top view. Tune ONLY the `tonnage` row of
   `project/data/tables/ghost_hover.json` (tail `anchor_m` at the waist under the back plates, `width_m` about the
   waist width, `length_m`, `fray`, `segments`, `swing_k` so it drags on turns; `height_m`/`bob` for a deep slow bob).
   If `GhostTail` cannot draw a wide smoky column from data alone, write `NEED flight: <what exactly>` in the report
   and move on (do not edit `ghost_*` files).
2. **Fist landing marks.** Through RAISE the two fist shadows must clearly mark where the fists will land (two dark
   soft ellipses on the road at `landing(+-1)`, darkening and tightening as the wind-up runs), in the top view and
   both tilts. In the review sheet's RAISE frame they are not visible.
3. **Size.** He keeps his size. Measure the on-screen height (px, opaque bbox) of the spectral tilted figure against
   the legacy figure at the same tick and zoom (rest, p70, 64 px/m). Report both numbers. If spectral/legacy is above
   1.1 or below 0.9, correct the scale in `tonnage_spectral.gd` so it is within.
4. **Fists never read as legs: proof.** A still at 32 and 64 px/m, p70, with him flying TOWARD the camera (facing
   south: row 1 CARRY/CRUISE), the tail and shadow visible. If the arms with the fists at the bottom read as two legs
   standing on the road, raise the fists (lift the tilted cell or the CARRY height) so road shows between the fists
   and their shadows. Report what you did.

## 2. Films (the owner judges by these)
- If `tools/film/ghost_films.mjs` exists after merging `n20-flight`, use it (read its header). Otherwise drive
  `project/dev/ghost-powers/ghost_review.tscn` with `--ghost=tonnage --ghost-look=spectral --take=move|attack
  --ppm=32|64 --fixed-fps 60 --write-movie` in last night's two-panel layout (70 deg play tilt above, top view below):
  see `C:\Users\kazda\kiro\gtai-masters\n19\ghosts\tonnage_attack_32.jpg` and `INDEX.md` there.
- Output to `C:\Users\kazda\kiro\gtai-masters\n20\tonnage\`: `tonnage_move_32.mp4` (5 s+ of movement),
  `tonnage_attack_32.mp4` (5 s+ of attack incl. a slam and a ram), `tonnage_close_64.mp4`, a poster `.jpg` each
  (H.264, yuv420p).
- Stills (PNG, same dir): (a) him in game at 64 px/m beside the plate, side by side in one PNG; (b) the slam POUND
  frame from the top view at 32 px/m with every victim and the wrecked car visible; (c) the ram: the frame 6 ticks
  before contact and the contact frame, the armed fist visible in both; (d) the same ticks with
  `--ghost-look=legacy` as the before.
- `frames.json` in that dir: 8 to 15 entries, best first, `[{ "file", "title", "ppm", "before", "note" }]`, the
  plate-beside-game still first. Delete scratch renders it does not reference (keep `masters/` and `scratch/rig-review`).

## 3. Record
- One appended line in `docs/decisions.md`: `- [2026-11-20] DECISION souls/tonnage: Press Golem body = drawn tilted
  pose/act cells (5 facings x 4) + top-view cut-out parts posed by TonnagePose; fists carried at chest height, armed
  fist on the ram, double-fist pound in front with a thin 4 m ring; rejected a drawn hover cycle and tilted cut-out arms.`
- After the code commits: `node tools/mutate/mutate.mjs --file=project/features/souls/tonnage_pose.gd` and report
  killed/(killed+survived).

Report: commits, the size numbers, any NEED flight line, film and still paths, the tick numbers you picked, the
mutate score, anything not done.
