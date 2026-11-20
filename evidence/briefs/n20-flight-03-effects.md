# n20 flight, package 3: the shared effects on a hovering body (transformation, soul line, aura, apparition)

Same law as packages 1 and 2 (read their briefs in `evidence/briefs/` if this is a fresh session): visual
only, no sim/replay/parity/bake digest moves; `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/flight`;
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
`--rendering-driver d3d12` for anything that renders; windowed runs `--position 0,1440`; one Godot at a time;
never kill by name; stage per path; no stash / add -A / reset --hard / commit -a; never push. Names and
signatures already committed in the Spectral look interface never change (four lanes code against them).
Flight owns `project/features/souls/ghost_*.gd|gdshader`, `soul_*`, `power_*`, the souls README,
`ghost_hover.json` schema + new fields, `project/dev/ghost-powers/ghost_review*` and `ghost_reel*`,
`project/features/hud/ghost_chip_face.gd`, `project/features/souls/art/shared/`, and `tools/film/ghost_films*`.
Never edit `tonnage_*`, `hauler_*`, `ram_*`, `kerf_*`, `ohm_*`, `dent_*` (incl. `dent_body.gd`),
`gearbox_link.gd`, `slam_debris.gd`, `plate_sparks.gd`, nor another lane's row in `ghost_hover.json` /
`ghost_forms.json`. If a fix needs one of those files, stop and list it in your report as `NEED <lane>: <file> <why>`.

## Why
The transformation in and out, the soul line, the aura and the apparition were built for bodies that stand
on legs. Under `--ghost-look=spectral` the body now hovers (lifted by `GhostFlight.body_offset()`), has a tail
and a ground shadow with a teal pool, and (package 2) the legacy drawn sprite fades below `fade_from`. Each
effect must be checked on that hovering body and fixed where it no longer fits. The legacy look must stay
pixel-identical (prove it with one legacy still before/after at the same tick).

## Work, in this order (commit each on its own)
00. **Film titles are mojibake** (package 2's tonnage film at 02:42 already shows clean ` / ` separators and
   `70°`: if your caption fix is committed and every `flight_*` film/still now has clean titles, skip this item
   and say so; otherwise finish it). `tools/film/ghost_films.mjs`
   lines ~106-110 contain double-encoded text where `·` and `°` should be (the films show
   `Ă„â€šĂ˘â‚¬Ĺˇ...`). Write those characters as JS escapes (`·`, `°`) so the source stays ASCII,
   add a test asserting the title strings contain no byte above U+00FF except those two, and check the
   ffmpeg drawtext really renders `·` and `°` with `film.ttf` (look at a frame). The tick label also clips
   (`64 px/rr Movement` overlaps: give the second title an x after the first one's measured width or one
   joined string). Re-cut every `flight_*` film and still made so far from their existing captures if kept,
   else re-film. Commit: `Write film title glyphs as escapes so they render`.
0. **HUD chip face (small, first; kerf waits on it).** In `project/features/hud/ghost_chip_face.gd`: when
   `GhostLook.of(id) == GhostLook.SPECTRAL` and `res://features/hud/art/ghost_chips/<id>_spectral.png` exists
   (ResourceLoader.exists), load it; otherwise `<id>.png` exactly as today (legacy byte-identical). The ghost
   lanes ship their own `<id>_spectral.png`. Unit test both branches (use a form id whose spectral file exists
   or a test hook for the path; never add a fake PNG to the art folder). README "Spectral look": one line on
   the chip name. Commit: `Load a spectral HUD chip face when a form draws its spectral look`.
0b. **The tail must read (the owner judges this first).** In package 2's stills (`flight_ohm_turn_64_t163.png`,
   `flight_kerf_turn_64_t163.png`, `flight_dent_move_32.jpg` in `C:\Users\kazda\kiro\gtai-masters\n20\flight\`)
   the ribbon is nearly invisible: at 64 px/m in the play tilt Ohm shows NO tail body at all, only a few thin
   chevron wisps 2-3 m away; Kerf and Dent show thin faint streaks. Look at the four plates again
   (`C:\Users\kazda\kiro\gtai-masters\n20\concepts\{tonnage_b,dent_a,kerf_a,ohm_c}.png`): the vapour is a
   dense, bright, glowing mass at the root (as wide as the body's waist, near-white teal core), opaque enough
   to hide the floor behind it for the first third, then breaking into ragged tongues and thinning to nothing.
   Raise the shader's root opacity and brightness (core alpha near 0.9 for the first 30%), make the strands
   overlap into one mass at the root and split only toward the tip, widen the defaults, and make sure the
   ribbon is drawn in the tilt views at all facings (check toward-camera and away facings, where today it
   may be hidden behind or under the sprite). Add a thin dark ink edge (1 px at 32 px/m, `#0B2E2C` at ~0.5
   alpha) on the outer contour of the root half so it reads on the light arena floor like the inked art.
   Ohm's and Tonnage's rows are the ghost lanes' rows: change only DEFAULTS and the shader, plus rows whose
   current values are still the package-1 defaults (check `git log -p` on the json).
   Proof: 64 px/m stills at t163 for all four, both views, before (current) / after; say per ghost whether
   it now reads as the plate's vapour. The legacy fade on Ohm leaves only a dome fragment in the tilt view at
   t163: lower Ohm's default `fade_from` so the torso and arms stay (fade only below the belt).
0c. **Left over from package 2 (you hit the 75-minute cap; your work was all committed, thank you):**
   package 2's evidence item 4 (the zero-foot-contact test for all four forms under spectral, plus the legacy
   run of the same drive that does fire, so the test can fail) and item 6 (mutate on `ghost_hover.gd`, quote
   killed/(killed+survived)). Do the test after 0b; the mutate run at the very end.
1. **A transformation take in the review film.** Add `--take=morph` to `project/dev/ghost-powers/ghost_review.gd`
   (keep its `KNOWN_FLAGS` complete): Rivet in base stands about 1 s, presses the real transform input for
   the `--ghost` form (through the same input path the pilot uses, so `GhostForms` runs its real stages), the
   form hovers and turns a little for about 3 s, then transforms back and Rivet stands 1 s. Both views
   (`--view=tilt70` and the top view). Teach `tools/film/ghost_films.mjs` (if package 2 committed it) the
   take `morph` (`<ghost>_morph_32.mp4`). Run the two looks at one tick and look at the frames.
2. **Transformation in and out under spectral** (`ghost_morph_fx.gd`, `ghost_form_view.gd`, `ghost_flight.gd`):
   - IN: the body rises from the ground to its hover height across stage 1 (lift 0 -> `height_m`), the tail
     grows from nothing out of the body (length 0 -> rest), the shadow core shrinks and the teal pool opens
     as it lifts. OUT: the reverse (it sinks, the tail is drawn back in, Rivet stands). Drive this from
     `GhostForms.k()`/`stage()` that the view already reads (render only; the form's sim timings do not move).
     Add whatever you need as a method on `GhostFlight` (suggested `GhostFlight.set_emerge(k: float)` 0..1,
     1 = full flight, default 1 so nothing else changes) and document it in the README "Spectral look".
   - The burst ring and steam stay on the ground plane (squashed by the view's ground factor, at the true
     ground point); the seams and sparks sit on the body (at `body_offset()`), not at its feet. Check in the
     70 degree tilt that the ring is under the body and the seams are on it.
3. **Soul line** (`ghost_soul_line.gd` / `.gdshader`): its eight outline copies are children of the drawn
   sprite with their own material; under the package-2 fade the copies would still outline the legs in teal.
   Make the copies fade with the figure (same `fade_from`, same tick-driven edge), so a faded-out leg has no
   teal outline. Verify on a 64 px/m tilt70 still of Kerf and Ohm (the drawn ones) under spectral.
4. **Aura vs the shadow pool**: `GhostAura` (used by `dent_body.gd`, Dent's file) and `GhostShadow`'s teal pool
   now draw two pools. Decide in `ghost_aura.gd` only: under `GhostLook.spectral(form)` the aura draws nothing
   (give it a `form_id: StringName` var defaulting to `&""` = today's behaviour; it cannot know the form
   otherwise), and write `NEED dent: dent_body.gd set _aura.form_id = &"dent"` in your report. Same for any
   other duplicate ground glow you find (grep the souls feature for pools/rings drawn under a light form).
5. **Apparition** (`ghost_apparition.gd`, the ghost speaking beside Rivet in base, dev `--apparition`): under
   spectral the speaking ghost hovers (its own `GhostFlight`: lift, bob, tail, shadow) instead of standing,
   with the legacy fade applied. Film or still it once in both looks (the review driver may need an
   `--apparition` passthrough; or use `dev/ghost-forms/voice_quest1.gd` with `tools/dev/run.mjs`).
5b. **Tail rise sign** (tonnage asks for a column that drags low and curls back): make sure `tail.rise_m` = 0 and
   negative values work (the tip stays on or near the ground, never under it in the top view), unit-tested.
6. **Hit reaction** (`GhostRecoil`, its lean per form is law: Tonnage 4 degrees, the others 12): check that the
   hit lean applies to the hovering body (it should rock the lifted body, not the ground point) and that the
   tail swings with it. Fix only the drawing.

7. **Director's notes on package 2's frames** (kerf tilt70 t125 at 32 px/m): (a) wisps that peel off drift
   2 to 5 m behind the body and at 32 px/m read as stray bird/chevron glyphs on the floor: keep them within
   about one tail length of the tip, make them soft puffs (not V strokes) that fade before they detach far;
   (b)+(c) the three dots and the teal ring outline under Kerf are Kerf's legacy `_aura` (charge pips + ring):
   already removed under spectral on n20-kerf (f36c0a161). Do nothing for Kerf; check whether Ohm's,
   Tonnage's or Dent's views draw a similar ring under spectral and list it as a NEED line if so (not yours).
   Re-shoot the same still after.

## Evidence (look at every frame yourself)
- For each of 1..5: a before (legacy) / after (spectral) still pair at the same tick and zoom, both views,
  64 px/m, under `C:\Users\kazda\kiro\gtai-masters\n20\flight\` named `flight_<what>_<ghost>_<view>_64_t<tick>.png`.
- `flight_<ghost>_morph_32.mp4` for kerf and tonnage under spectral (and `before\` legacy for kerf).
- Unit tests for `set_emerge` (0 = on the ground, no tail length; 1 = today's flight) and the aura opt-out.
- Checks before each commit: `node tools/godot/check.mjs <changed files>`, `node tools/lint/lint.mjs`,
  `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`. One legacy still at a fixed tick
  must stay pixel-identical (say so with the compare result).
- After the last code commit: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_flight.gd`;
  quote killed/(killed+survived).

## Order and time
00, 0, 0b first (titles, chip, tail), then 1, 2, 3. 4-6 if time allows. Stop by the
70-minute mark with everything committed. Report: commits (sha + line), checks and results, every
still/film path with one line of what you judged in it, NEED lines for other lanes, what is still weak.
