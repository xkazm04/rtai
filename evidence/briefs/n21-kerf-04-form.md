# n21-kerf brief 04: the rest of the form (transformation, hit, HUD chip, form card), then the flip

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-kerf`, branch `n21-kerf`. VISUAL night: no sim, replay,
parity or bake digest may move.

**Wall-clock hard stop: 16:20. Commit deadline: 16:15.** Commit in small steps. Fix lint and format
findings in your own edits and go on. Never amend, never rebase. No `git stash`, no `git add -A/./-u`, no
`commit -a`, no `reset --hard`. Stage per path. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf`. Godot:
`C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe` (`--rendering-driver d3d12`
for rendering, `--position 0,1440` on any windowed run). One Godot process at a time; free your own by PID.
Mutate capped: `node tools/mutate/mutate.mjs --file=<file> --max=20` on changed lines only.

## Allowlist (any other path: stop and report `NEED <owner>: <file> <why>`)
`project/features/souls/kerf_*` and `art/kerf/**`, Kerf's files under `art/view/p70|p55`,
`project/tests/unit/test_kerf_*`, Kerf's rows in `ghost_forms.json` and `ghost_hover.json`,
`project/dev/ghost-powers/kerf_beat.gd`, `project/features/hud/art/ghost_chips/kerf_*`, `tools/art/kerf_n21_*`,
`docs/decisions.md` (append one line), scratch under `C:\Users\kazda\kiro\gtai-masters\n21\kerf\`.
For the flip only: `project/tests/unit/test_ghost_card.gd` line 92 (pin to legacy; a one-line call site, the
director names it in JOURNAL) and any other test that reads Kerf's legacy body by default (pin each with
`GhostLook.override_for_test(&"legacy")` and list them).

## The work, in order
1. **Transformation in and out** through flight's shared stages (`GhostFlight.set_emerge`): the Swarf Ronin must
   fade in and out with no legacy frame, no double body, no stray echo, no legs at any frame. Film
   `kerf_morph_32.mp4` + poster with `tools/film/ghost_films.mjs` (the morph take) and a strip
   `kerf_transform_strip_32.png` (8 frames across the emerge, tilt 70 above, top below).
2. **Hit reaction**: check the HIT cell + `KerfHit` lean and flinch at 32 and 64 px/m; strip `kerf_hit_strip.png`
   (hit tick, +3, +8, +15; tilt 70 and top). Lean 12 degrees (`GhostRecoil.LEAN_BY_FORM`), unchanged.
3. **HUD chip**: the current `project/features/hud/art/ghost_chips/kerf_spectral.png` is still n20's rejected
   dart (a craft with cables). Replace it (same path, same pixel size) with a chip cut from the p55 toward HOVER cell (the
   head, shoulders and the two raised blades), the way Dent's `dent_spectral.png` was cut
   (`tools/art/dent_chip_cut.py`: read it, write your own `tools/art/kerf_n21_chip.py`). Same size as the other
   spectral chips. Still `kerf_hud_chip.png`.
4. **Form card**: if the ghost form card shows the old Kerf, give it the new body the way the other spectral forms
   do (read how Dent's card gets its spectral look; if that path is polish's file, write NEED polish and stop
   this item).
5. **Films** (`--ghost-look=spectral`, tilt 70 above, top below, poster `.jpg` each, into
   `C:\Users\kazda\kiro\gtai-masters\n21\kerf\`): re-shoot `kerf_move_32`, `kerf_attack_32`, `kerf_close_64` on
   the final code, plus `kerf_morph_32`.
6. **The flip** (only if 1-5 are done and the tests are green): set Kerf's `look` to `spectral` in
   `ghost_forms.json`; pin `test_ghost_card.gd:92` and every other test that reads Kerf's legacy body by
   default; run the FULL unit suite `node tools/tests/run_unit.mjs` (no flags) and quote passed/failed/skipped;
   run the scenarios (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`) and quote the
   count and the 60 s replay digest (it must be unchanged). If anything is red that you cannot fix inside your
   allowlist, revert the flip (a new commit, not an amend) and say why. One `docs/decisions.md` line for the
   flip.

## Final message
Files changed, commits, test/scenario counts and digests, mutate scores, flipped or not (and why), every
evidence path, anything left undone.

## What the director already knows (15:08)
- Body, flight and both attacks are accepted (commits up to 56c31b555). Do not change them; this brief adds only
  the rest of the form. n20 built the same four items for the dart (`docs/day/2026-11-20/kerf/REPORT.md`, rows
  4, 4b, 4c): reuse its hooks (`KerfHit`, the morph path, the chip loader), re-fit them to the Ronin.
- After any new PNG lands, run a Godot `--import` (headless) before committing: the film tool tests fail on
  unimported assets. Commit the `.import` with the PNG. Add a provenance line in
  `steam/ai-provenance/2026-11.jsonl` only if a NEW generated image ships (a chip cut from an existing sheet is
  derived art: note its source sheet in the cutter's manifest instead).
- Time order if short: 3 (chip) and 1 (transform) first, then 2, then 5; 4 may become a NEED. Start item 6 (the
  flip) only if everything before it is green by 16:00; otherwise leave the row `legacy` and say so.
- `project/tests/unit/test_ghost_card.gd` is polish's file: the one-line pin at line 92 is the only edit you
  may make there. Name every other test you pin, one line each, in the final message.
