# Brief n29-10-collar-transplant: p55 sprint collar rows 6 and 8 from the accepted rigid rows, mirrored (lane keys, run n29)

Art builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
Base brief `evidence/briefs/n29-04c-collar-rows-live.md` (bars, commit law, evidence, allowlist: all hold).
Resume `C:/Users/kazda/kiro/gtai-art/rivet-n29/collar_p55_rows/STATE.md` (read whole) and its `scripts/` (`comp_row.py`
= neck-only composite with the identity proof, `neck.py` masks, `pair.py` judge crops).

## Wall clock (run `date +%H:%M` first and often)
`06:03` launched. **Commit the sheet by `06:50`** (the pre-commit hook can take 12 min: start `git commit` by 06:38).
Evidence commit by `07:05`. **Report and END by `07:08`**, committed or not. Never end with uncommitted product work you judged good.

## Why
`project/features/characters/art/view/p55/rivet_run8.png` rows 1, 2, 4, 5 wear the rigid flat hazard collar (vermilion/black
straight diagonal stripes on a stiff ring). Rows 3, 6, 7, 8 still wear the soft twisted rope. Image edits of rows 3, 6, 7, 8
failed twice each: **no image jobs in this call (0 images)**. The new route: the rows are 8 facings; mirror pairs share
the same facing seen from the other side. Row 8 is the back-left facing = row 4 mirrored (STATE 04:57 says so and used
it as the reference). Row 6 is likely row 2 mirrored: prove it. Take the accepted collar pixels (generated art, already shipped)
from the donor row, flip horizontally, register onto the target row's neck per cell, and composite neck-only. This is a
transplant of shipped generated pixels, not script-drawn shapes: no drawn stripes, no fills, no gradients.

## Steps
1. Pairs: for each target row t in {6, 8} and donor d in {2, 4}, per cell k (same cycle phase k; also try k+4 mod 8 in case
   the mirror swaps the leading leg), the IoU of target alpha vs mirrored donor alpha after best integer shift. Pick the donor
   and phase map with the highest mean IoU; write the table to `evidence/n29-keys/collar_p55_transplant.md`. Need IoU >= 0.85
   on the head-shoulder band; if a target has no donor >= 0.85, skip that row (report).
2. Neck registration per cell: the neck mask from `neck.py` on the target (where the rope is) and on the mirrored donor
   (where the rigid collar is); shift (integer, search +-6 px) to best overlap the two collar masks; optional uniform scale
   0.95-1.05 only if it raises the mask IoU by >= 0.03.
3. Composite: inside the union of the target's rope mask and the shifted donor collar mask, clipped to the target's alpha,
   take the donor's pixels; outside it, the target unchanged. Pixels of the target's rope mask the donor collar does not
   cover: take the donor's pixel at that place (head/body underneath), never paint. Alpha identical to the shipped sheet.
4. Proof (bars): 0 changed px outside the mask (json beside the comp); alpha identical; teal px 0 in the mask; mask colours
   within the rigid rows' range (orange about 225-234, 85-112, 23-39; dark about 36,16,12).
5. Judge yourself on 4x nearest crops, rows 4, 5, 6, 8 stacked (shipped above, new below) and at in-game size 64 px/m:
   one stiff flat ring, straight stripes, no seam step between the collar and the helmet/shoulder, no doubled edge, no
   hole. Any seam you can see at 64 px/m: fix the registration or reject that row. Write what you saw.
6. Pass: install over `p55/rivet_run8.png`, Godot `--import` (the .import should stay unchanged), append one provenance line to
   `steam/ai-provenance/2026-11.jsonl` (derived from the row 2/4 generated sources, no new generation; copy the n29 row 4
   line's shape), `node tools/gate/quick.mjs` if quick, commit "keys n29: Rivet's p55 sprint rows 6 and 8 wear the rigid
   collar, mirrored from rows 2 and 4" (only the rows that passed). Stage per path.

## Evidence (after the sheet commit, separate commit)
- `C:/Users/kazda/kiro/gtai-masters/n29/keys/collar/collar_p55_rows68_neck_4x.png` (shipped | new, rows 6, 8 all cells) and
  `collar_p55_all_rows_64.png` (all 8 rows, one cell each, at 64 px/m in-game size: before row | after row).
- Drift re-measured with the n27 setup (`evidence/n27-keys/p55_sprint_drift.md`, 3.83 cm at 64): must hold within 0.1 cm
  (body pixels do not move, so it should be identical: show it).
- `evidence/n29-keys/collar_p55_transplant.md`: pair table, registration per cell, proof, drift, what you saw.
- STATE.md: a dated line per step.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot is shared with
another builder (sword run k) through the mutex `build/n29-godot.lock`: before EVERY Godot step (an --import, a test run, a
capture, and every git commit because the pre-commit hook runs Godot) take it with
`(set -o noclobber; echo "collar10 $(date +%H:%M)" > build/n29-godot.lock)` (fails while held: re-try every 60 s; older than
25 min = stale, delete it) and `rm build/n29-godot.lock` as soon as that step ends. Windowed runs: `--position 0,1440`.
Fix lint and format findings in your own edit and go on. If the hook fails only on `tools/film/kill_reel_*.break.test.mjs`
or `tools/merge/clash.test.mjs`: `--import`, commit again once. Never skip the hook. No amend, no rebase, no stash,
no `git add -A/./-u`. Python with `-I`.

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p55/rivet_run8.png(.import)`, `steam/ai-provenance/2026-11.jsonl` (append one line),
`evidence/n29-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n29/collar_p55_rows/**`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/collar/**`, `build/**`.
Forbidden: every other sheet, `rivet_motion.json` (another builder edits it), code, tests, every other table, the HUD files,
`project/features/souls/**`, `project/features/combat/**`, `project/boot/prologue/**`, cast art, `native/`, `JOURNAL.md`,
`REPORT.md`, `docs/decisions.md`, other lanes' worktrees. Never delete anything in Temp you did not create.

## Report (short), then END
Rows fixed / skipped (with what you saw at 64 px/m), pair table, identity proof, commit shas, drift, stills, what you ran.
