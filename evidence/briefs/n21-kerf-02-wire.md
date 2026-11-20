# n21-kerf brief 02: wire the Swarf Ronin into the game (body + flight), film the move

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-kerf`, branch `n21-kerf`. VISUAL night: abilities,
numbers, hit boxes, the sim and every digest stay exactly as they are. Only what is drawn changes.

**Wall-clock hard stop: 13:30. Commit deadline: 13:25.** Commit in small steps as each part works (the
tilt body first, then the top rig, then the films). Fix lint and format findings in your own edits and go on.
Never amend, never rebase. No `git stash`, no `git add -A/./-u`, no `commit -a`, no `reset --hard`. Stage per path.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf`. Godot:
`C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe` (`--rendering-driver d3d12`
for anything that renders, `--position 0,1440` on any windowed run). One Godot process at a time. Free your own
processes by PID, never by name.

## Allowlist (any other path: stop and report `NEED <owner>: <file> <why>` in your final message)
- `project/features/souls/kerf_*.gd` (+ `.uid`), new `kerf_*` files you create there
- `project/features/souls/art/kerf/**`, the `kerf_*` files under `project/features/souls/art/view/p70/` and `p55/`
- `project/tests/unit/test_kerf_*.gd` (+ `.uid`), new `test_kerf_*` tests
- Kerf's row in `project/data/tables/ghost_hover.json` (only the `kerf` row; NOT its `look` in `ghost_forms.json`:
  Kerf stays `legacy` by default in this package)
- `project/dev/ghost-powers/kerf_beat.gd`
- `tools/art/kerf_n21_*` ; `docs/decisions.md` (append one line at a time)
- scratch and evidence under `C:\Users\kazda\kiro\gtai-masters\n21\kerf\`
Polish owns `ghost_*`, `soul_*`, `power_*` and the other ghosts' files, `tools/film/ghost_films.mjs` and the
dev ghost-powers tools other than `kerf_beat.gd`. You may READ and RUN them, not edit them.

## Where things are
- The plate (the target): `C:\Users\kazda\kiro\gtai-masters\n21\concepts\kerf_b.png`. LOOK at it, and look
  at it again whenever you judge a frame.
- The new art landed in brief 01 (commits f96b2f2e7 top parts, 0c312d279 tilt sheets): `project/features/souls/art/view/p70|p55/kerf_sp_fly.png`
  and `kerf_sp_act.png` (5 facing rows x 4 pose columns, packed like Dent's `dent_sp_fly/act.png`), top-view parts
  in `project/features/souls/art/kerf/ronin/` (`head, torso, upperarm, blade, tail_straight, tail_curled` +
  `parts.json` + `cut.json` with per-cell slot centroids). Read `docs/art/prompts/n21/kerf/README.md` for the
  scale numbers. Fly columns: HOVER, CRUISE, TURN, HIT. Act columns: COCK, CUT, RECOVER, BLINK.
- Today Kerf's spectral body is n20's Gantry Wraith: `kerf_spectral.gd` (`KerfSpectral`, built by `kerf_rig.gd`
  when `GhostLook.spectral(&"kerf")`), `kerf_beams.gd` (three trailing beams = charges), `kerf_tilt_eye.gd`
  (lens shutter on the tilt cell), art in `art/kerf/spectral/` and `art/view/p70|p55/kerf_hover.png`.
  `kerf_echo.gd` (after-image), `kerf_slot.gd` (the cut line), `kerf_victim.gd`, `kerf_hit.gd` stay and are re-fit.
  Read `docs/day/2026-11-20/kerf/REPORT.md` for what n20 built and why.
- The accepted model for a legless humanoid ghost is Dent: `dent_spectral_drawn.gd` (tilt pose drawer on two
  GhostSheets, pose choice from `GhostHover`) and `dent_spectral_top.gd` (bird's-eye cut-out rig on
  `PartLibrary`). Read both and build Kerf the same way, in your own `kerf_*` files (do not edit Dent's).
- Flight's shared pieces (hover, tail, shadow, light pool, `own_body`): `project/features/souls/README.md`,
  section "Spectral look".

## The work
1. **Tilt body (70 and 55).** A new drawer `kerf_ronin_drawn.gd` (or inside `kerf_spectral.gd` if it stays
   under 200 lines) on `GhostSheet.of(GhostDrawn.path_of(art, "kerf", "sp_fly"), 4)` and `"sp_act"`. Pose choice,
   pure and unit-tested:
   - HIT while the hurt window is open (the same window `KerfHit` uses);
   - after a blink (`KerfStage.trail_tick`, the latest entry; `trail_cut[-1] == Vector2.INF` is a plain blink,
     anything else was a slice): a slice shows CUT for the first `KerfSpectral.LUNGE_TICKS` ticks then RECOVER
     for as many again; a plain blink shows BLINK for `LUNGE_TICKS`;
   - COCK while a target is locked and he is slow (this is n20's "the idle is the wind-up": he faces the target
     octant, as n20's tilt cell did);
   (the fly HIT cells came out close to HOVER: both have the blades raised. Keep the HIT cell, KerfHit's
   12-degree lean and flinch, and if HIT and HOVER still look alike at 32 px/m add a short pale teal rim pulse on
   the body for the flinch ticks, as n20's REPORT suggested. Say what you did.)
   - TURN when `absf(hover.yaw_rate_dps)` is above a threshold (start from Dent's 150 and tune by eye: Kerf turns
     sharp, so TURN should show on real hard turns only, never flicker; mirror the cell for turns the other way
     as Dent's `swing_flip` does);
   - CRUISE at speed (keep n20's 3.0 m/s mood threshold), else HOVER.
   Size: the same person size as Dent (same head size on screen at the same px/m). Seat the cell on the flight
   mount the way Dent's drawer does (no feet: the alpha-mass centre). Keep Kerf's 12-degree hit lean (`KerfHit`,
   `GhostRecoil.LEAN_BY_FORM`).
2. **Top view.** A new rig `kerf_ronin_top.gd` like `DentSpectralTop` on `PartLibrary.of("kerf/ronin")`: head
   (wedge forward, lens leading), torso, two upper arms, two blades. The blades are the top-view silhouette: two
   crescents swept BACK and out like a swallow's wings, the tips pointing backward, never forward. Per pose: HOVER
   half open (about 50 degrees off the spine), CRUISE swept close (about 20 degrees), BLINK flat back, COCK the
   right blade drawn across the front, CUT the right blade thrust straight ahead along the facing, RECOVER
   between. Ease the arm angles over a few ticks (no pops). Tail ribbon: `tail_curled` at rest, `tail_straight`
   at speed, cross-faded on `hover.speed_mps` (fully straight at 12 m/s), its root under the torso.
3. **Flight.** No weight: keep Kerf's `ghost_hover.json` row (lag 1, bank 12). Remove the three beams
   (`KerfBeams`) from the spectral path: the drawn ribbon replaces them. Show flight's shared tail again (n20 hid
   it) as the vapour that continues from the ribbon's end: in Kerf's `ghost_hover.json` row re-anchor `tail.anchor_m`
   to the ribbon tip and make it narrow and short (it must read as a thin wisp after the ribbon, not a second
   tail). If the shared tail cannot be made to read that way through Kerf's row alone, keep it hidden and say so.
4. **After-image.** Re-bind `KerfEcho` to the new sprites (tilt sprite and top rig parts) so a blink still leaves
   the after-image in the pose he left in. Do not change its timing or look.
5. **Remove dead code and art** in your own files only: `kerf_beams.gd`, `kerf_tilt_eye.gd`, `art/kerf/spectral/`,
   `art/view/p70|p55/kerf_hover.png`, and their tests, if nothing else uses them after the change (grep;
   `kerf_glide.gd` is the camera whip and stays). The LEGACY look (`--ghost-look=legacy`, today's default for Kerf)
   must stay byte-identical: render one legacy frame of `ghost_review.tscn` (`--ghost=kerf --ghost-look=legacy`)
   at two ticks before and after your change and compare the PNGs; quote the result.
6. **Tests.** Update `test_kerf_spectral.gd`, `test_kerf_slot.gd`, `test_kerf_hit.gd` (and delete
   `test_kerf_beams.gd` with its class) to the new body; add a pure test for the pose choice and one that no
   blade tip in the top rig points forward of the shoulders in HOVER/CRUISE/BLINK. Run
   `node tools/tests/run_unit.mjs --changed` until green, then `node tools/tests/run_unit.mjs --select=<every
   test_kerf_* and test_ghost_* basename>`. Then `node tools/gate/quick.mjs`.

## Evidence (into `C:\Users\kazda\kiro\gtai-masters\n21\kerf\`)
Use `ghost_review.tscn` with `--ghost=kerf --ghost-look=spectral` and its `--shot-tick` / `--shot=<abs.png>`
(see the README) and `tools/film/ghost_films.mjs` (read its plan and flags).
- `kerf_plate_vs_game.png`: the plate (left) beside an in-game 64 px/m still of him in HOVER, tilt 70 (right).
- `kerf_guard_32.png`: at 32 px/m, Kerf hovering next to a guard, three panels: tilt 70, tilt 55, top; plus the
  same x3 nearest-neighbour. The question: does he read as a person with two blade arms?
- `kerf_poses_64.png`: tilt 70 and top at 64 px/m for HOVER, CRUISE, TURN, HIT (one row per view).
- `kerf_move_32.mp4` + `kerf_move_32.jpg` poster: the ghost films tool's movement take for Kerf, tilt 70 above,
  top below, 32 px/m, `--ghost-look=spectral`. If the tool cannot film Kerf, say why (NEED polish) and film with
  `ghost_review.tscn` + Movie Maker yourself.
- Same-tick before/after: n20's `C:\Users\kazda\kiro\gtai-masters\n20\kerf\kerf_move_32.mp4` is the before; make
  `kerf_move_before_after_32.png` from one tick of each.

## Mutate
After the code commit: `node tools/mutate/mutate.mjs --file=project/features/souls/kerf_spectral.gd --max=20`
(changed lines only; and the same for your new drawer). Quote killed/(killed+survived).

## Final message
Files changed, commits, test and gate results with counts, legacy byte-compare result, mutate scores, the
TURN threshold you chose, what you did with the shared tail, every evidence path, and anything left undone.
