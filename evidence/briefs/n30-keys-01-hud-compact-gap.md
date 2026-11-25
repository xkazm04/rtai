# Brief n30-keys-01-hud-compact-gap: the handheld HUD's chip 1 plate stops crowding chip 2 (lane keys, next run)

Written by the n29 keys director at 07:06 (session 7), not launched: the n29 lane was frozen and gated with reels before
the fault was seen (`gtai-masters/n29/keys/hud/hud_handheld_pair_crop_3x.png`, right half). Fill the wall clock at launch.
Builder: sonnet, one call, about 30 minutes plus the pre-commit hook (~12 min on a shared machine).

## The fault (measured, n29-01e, deck 1280x800, `GhostFormLayout.compact()`)
Chip 1's number plate is on screen now (left edge x 9) but is pushed right by the clamp in `GhostChipNumber.anchor`
(`project/features/souls/ghost_chip_number.gd`), and in the compact layout plates 1 and 2 end 3 px apart: it reads "12".
Arithmetic from the code (fallback font, number_size 24, plate about 26.5 px wide):
- compact: margin 12, gap 42, chip_r 19. Slot 0 centre x 33; raw plate centre 33 - 1.2*19 = 10.2, left -3.0, clamped to
  `number_min_x()` = max(8, 12 - 6 + 3) = 9, so the centre moves +12.0 to 22.2 (plate 9..35.5). Slot 1 centre 75, plate
  centre 52.2, left 39.0. **Gap 3.5 px.**
- desktop: `GhostFormHud.GAP` 72 (tests use `full.gap = 72.0`), the same clamp leaves about 40 px between plates: fine.
Changing `margin` does not help (`number_min_x` moves with it). The cause is the compact `gap` 42 against a 24 px number.

## Do
1. Pick ONE of these (DECISION line in `docs/decisions.md`, the other stays one value away):
   - A (preferred): `compact().gap` 42 -> 50: plate 2's left moves to 47.0, gap about 11.5 px; the strip grows 8 px per chip
     (4 chips: +32 px on a 1280 px screen). Check `card_w` and the Madness bar width follow (they read `gap`). Never 58: `GhostFormHud._ready` (line 42) swaps a gap of exactly `GAP` 58 for the desktop 72.
   - B: a layout field `number_dx: float = -1.2` (compact -0.85) read by `anchor()`: chips 2-4 plates move 6.6 px right,
     gap about 10 px, strip size unchanged. Needs the anchor tests' offset to read the field.
2. A unit test in `project/tests/unit/test_ghost_chip_number.gd` over both layouts and labels "1".."4" (and the longest key
   name the input map can give, e.g. "F10" if present): for every adjacent slot pair, plate(n+1).left - plate(n).right
   >= 8 px, and plate 1's left >= `number_min_x()`. It must FAIL on the n29 code (compact gap 42): say so in the report.
3. `node tools/tests/run_unit.mjs --select=test_ghost_chip_number,test_ghost_form_layout,test_ghost_form_hud` green, then
   `node tools/gate/quick.mjs`, commit (code + test in one commit, staged per path).
4. Mutate: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_form_layout.gd --lines=<the compact lines>
   --tests=test_ghost_chip_number,test_ghost_form_layout --max=20`; quote killed/(killed+survived).
5. Evidence: re-render the 1280x800 pair exactly as `evidence/n29-keys/hud.md` section n29-01e did (two throwaway
   snapshots, the dev capture's size check relaxed and `--device` added to the gauntlet entry's KNOWN_FLAGS in the
   SNAPSHOTS only; or, if the Director has by then let `bond_film_capture.gd` accept the window size, run it straight):
   before = the n29 merge commit, after = HEAD, same tick ~619. Measure plate 1 left, plate 1-2 gap (bar >= 8 px), every
   plate inside the strip box. Write `gtai-masters/<run>/keys/hud/hud_handheld_pair2_crop_3x.png` and LOOK at it: "1" and
   "2" must read as two plates, each under its own avatar's lower-left rim. Also re-render the 1080p pair to show the
   desktop strip unchanged (diff 0 px in the strip box under option A or B).

## Allowlist
`project/features/souls/ghost_form_layout.gd`, `ghost_chip_number.gd` (option B only), their `.uid`s,
`project/tests/unit/test_ghost_chip_number.gd`, `test_ghost_form_layout.gd`, `test_ghost_form_hud.gd`,
`evidence/<lane>/hud.md`, `docs/decisions.md` (one appended line), `gtai-masters/<run>/keys/hud/**`, `build/**`, snapshots.
Any other path: stop and write a NEED. Combat owns the rest of `project/features/souls/**`. Banned: amend, rebase,
`git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Godot only through `runGodot`, one at a time, `APPDATA` per lane,
windows at `--position 0,1440`. Fix lint and format findings in your own edit and go on. Commit by 25 minutes in; report
and END at 60 minutes.
