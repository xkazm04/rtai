# Brief 03 (lane polish): Tonnage polish: smoke column, slam ring, HUD chip face

Hard stop: 70 minutes after you start (write the stop time down at the start). Last commit 10 minutes before it.
Order of value: smoke column > slam ring > chip. Each is its own commit with its before/after stills. If you run
short, commit what is green and report exactly where you stopped.

## Environment (every Godot / gate / film run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time; windowed runs use `--position 0,1440`; kill only your own PIDs. Nobody rebuilds native.

## Look first
- The owner's plate: `C:/Users/kazda/kiro/gtai-masters/n20/concepts/tonnage_b.png`. The smoke column hangs from
  **under the hump, between the two arms**, and rises/drifts back from there as soft billowing smoke. The slam
  (bottom-right inset) shows a bright teal ring line on the street around the impact.
- n20 stills: `C:/Users/kazda/kiro/gtai-masters/n20/tonnage/tonnage_tail_fix_rest_64.png` (today: the column leaves the
  belly near road level on the back-left and one cone side is a straight hard edge, about x 380),
  `tonnage_tail_fix_turn_64.png`, `tonnage_tail_fix_cruise_top_32.png`, `tonnage_chip_hud.png` (HUD bottom-left:
  the chip's hump and striped fists read, the visor face does not), and the n20 films `tonnage_attack_32.mp4`,
  `tonnage_close_64.mp4` in that folder.
- `docs/day/2026-11-20/tonnage/REPORT.md` and `JOURNAL.md` (how the n20 lane built it), `project/features/souls/README.md`
  section "Spectral look".

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
- `project/features/souls/tonnage_*.gd`, `hauler_*.gd`, `slam_*.gd`, `ghost_tail*.gd`, `ghost_tail.gdshader`,
  `ghost_vapour.gd` (shared flight pieces: polish owns them tonight; a change there must not alter Dent's, Ohm's or
  Kerf's tails: keep their outputs identical, prove it with their existing tests)
- Tonnage's row only in `project/data/tables/ghost_hover.json` (and its schema only if a new key is truly needed)
- `project/features/hud/art/ghost_chips/tonnage_spectral.png` (+ `.import`) and the `tools/art/tonnage_*` script that
  cuts it
- tests `project/tests/unit/test_tonnage_*.gd`, `test_ghost_tail*.gd`, `test_ghost_vapour*.gd`, `test_slam_*.gd` (+ `.uid`)
- one line appended to `docs/decisions.md` per real choice
Do NOT touch: `powers.json`, `ghost_attacks.json`, reach, timing, hit boxes, damage, the sim. The ring's radius is the
sim's 4 m reach: only its line weight, brightness and colour may change.

## 1. Seat the smoke column under the hump
- Move the tail root so the column leaves from under the hump between the arms (as on the plate), not from the
  belly near the road. Today's row: `tail.anchor_m [-0.8, 0]`, `rise_m -0.24`, `width_m 2.15`, `spread_m 0.28`,
  `fray 0.15`, `strands 2`. Try anchor/rise first (data only); if the cone still has a straight hard side, soften it in
  Tonnage's vapour/tail drawing (a feathered edge, a wobble on both sides, a second offset strand), not by widening.
- It must still read as smoke: not a leg, not a ribbon, not sparks. Check in both tilts (70, 55) and the top view,
  at rest, cruise and a hard turn.
- Before/after at the same tick and zoom: `C:/Users/kazda/kiro/gtai-masters/n21/polish/tonnage/tonnage_tail_{rest,turn}_64_{before,after}.png`
  and `tonnage_tail_cruise_top_32_{before,after}.png`. The n20 lane made those stills with
  `tools/film/ghost_films.mjs --ghost=tonnage --look=spectral --stills=...`; read its JOURNAL for the exact commands
  and ticks, and use the same ticks.
- A unit test pins the new root position (the tail's first point relative to the body, in both tilts).
- Commit: "Seat Tonnage's smoke column under the hump".

## 2. The 4 m slam ring reads on the strike frame at 32 px/m
- Find where the landing ring is drawn (`tonnage_view.gd` / `HaulerMarks` / `slam_*`). Make it thicker or brighter
  (both if needed) so that on the strike frame of `tonnage_attack_32` it reads through the cracks, the wrecked car and
  the victims; it stays a **line** (not a disk, not a fill), soul teal, radius unchanged.
- Before/after still of the strike frame at 32 px/m, same tick: `tonnage/tonnage_ring_strike_32_{before,after}.png`
  and a 64 px/m pair.
- A test pins the new width/alpha values (and that the radius still equals the reach from the data).
- Commit: "Thicken Tonnage's slam ring on the strike frame".

## 3. HUD chip: the visor face reads
- `project/features/hud/art/ghost_chips/tonnage_spectral.png`: ink the visor slot darker in the cut (and give the
  visor's teal glow line its contrast), or re-cut the chip from a three-quarter cell where the face is larger. Use
  the existing cut script (`tools/art/tonnage_spectral_*.py`), never a hand edit. Keep the chip size and framing of
  the other chips.
- Before/after at the HUD's real size and at 4x: `tonnage/tonnage_chip_{before,after}.png`.
- Godot `--import` before committing. Commit: "Ink Tonnage's chip visor".

## After each commit
- `node tools/tests/run_unit.mjs --changed` green; `node tools/gate/quick.mjs` green.
- Last: `node tools/mutate/mutate.mjs --file=features/souls/tonnage_spectral.gd --max=20 --lines=<your changed lines or,
  if you did not change it, lines 47-189>` and quote killed/(killed+survived). If the score is low, add tests that pin
  what is drawn (landing-mark position, width and alpha through the wind-up; cell roll and lift) and run it again.
  n20's score was 27.5%.
  Target 70%: n20 left 29 survivors in the presentation code (the combat-tick hook, the ground-shadow ink discs, the
  fist landing-mark placement with its width and alpha through the wind-up, the art-set choice by pitch, the cell's
  roll, stretch and lift). Pin those drawn outputs at fixed ticks (read the values, assert exactly or within 1e-3),
  commit ("Pin what Tonnage's spectral body draws") and run the mutate once more. Also kill the 3 `tonnage_pose.gd`
  survivors (n20: lines :71, :113, :129) if they are still alive.
- Then re-film Tonnage: `node tools/film/ghost_films.mjs --ghost=tonnage --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n21/polish/tonnage`
  (move, attack, close takes as the tool defaults) and report the paths.

## Repo law (binding)
- AGENTS.md / STANDARDS.md. Typed GDScript, functions <= 40 lines, files about 200 lines (hard 300), <= 5 params,
  `Log` not `print`, no frame delta in sim code, RNG only through the registry.
- Stage per path. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Fix lint and format findings in your own edit and go on.
- No sim, replay, parity or bake digest may move. Look goldens: re-bless only a golden your own item moved, and
  name it in the commit message.
- Colour law: teal only for souls; red is blood only; amber for heat/overload.
- Do not redesign what the owner accepted: no bow wave on the ram, the 0.55 strike fade stays, the teal ground pool stays.

## Report back
Per item: what changed (files, values before -> after), commit hash, the still paths; test results; the mutate line;
film paths; anything not done and why.
