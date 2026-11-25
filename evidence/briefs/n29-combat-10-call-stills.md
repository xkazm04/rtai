# n29 combat call 10: side-by-side stills for two owner calls (no Godot, no repo product files)

Wall clock: started 07:10. Hard stop 07:35: report and END. No Godot at all (the lane's gate is running).

## Goal
REPORT "Calls for the owner" needs a side-by-side still per call. Two calls have none:
- Call 3: Rivet's rocket and nuke shell keep their red nose band. Files (read only):
  `project/features/combat/weapons/art/fx/rocket.png`, `.../fx/nuke_shell.png` (find the exact path with `git ls-files | grep -E "fx/(rocket|nuke_shell)\.png"`).
- Call 5: Mertz's vermilion gloves stay (cast art). Source still: `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_elec_tazer_after2_64.png`.

## What to make (Python with Pillow, `python -I`, script saved as `evidence/n29/red/call_stills.py`)
1. `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/call_rocket_band_pair_8x.png`: for each of rocket.png and nuke_shell.png,
   LEFT the shipped sprite, RIGHT the same sprite with only its reddish pixels (hue <= 24 or >= 345, s > 0.5, v > 0.45)
   moved to amber #edab42 keeping value and alpha (a mock of the alternative, NOT shipped). Scale nearest-neighbour so each
   sprite is at least 160 px tall; dark background #15121a; a 20 px label row "shipped (kept)" / "amber mock (not shipped)".
   Print reddish px count per sprite before and after the mock.
2. `.../stills/call_mertz_gloves_64.png`: the tazer still with a 2 px cream box around each glove region (find them as the
   reddish clusters R>170 G<110 B<90 of >= 20 px near Mertz; print their bboxes and px counts), plus a 3x nearest-neighbour crop
   of the box area beside it. Label "vermilion gloves = cast art (NEED cast)".
3. LOOK at both outputs (Read the PNG) before you finish; say in the report what you see.
4. Append two entries to `C:/Users/kazda/kiro/gtai-masters/n29/combat/frames_all.json` (keep JSON valid, same keys:
   `file`, `title`, `ppm` (8x sprite: "sprite 8x"; gloves: 64), `before`, `note`). Do NOT edit `frames.json`.

## Commit
Only `evidence/n29/red/call_stills.py` in the repo: `git add -- evidence/n29/red/call_stills.py` and
`git commit -m "n29 red: call stills script (rocket band mock, Mertz gloves)" -- evidence/n29/red/call_stills.py`
with the trailer line `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Commit by 07:30. No amend, no rebase,
no stash, no `git add -A/./-u`. The pre-commit hook skips lint for evidence paths; if it fails, report it, do not skip it.

## Allowlist
Write only: `evidence/n29/red/call_stills.py`, the two PNGs and `frames_all.json` in the masters dir. Any other path: stop
and report a NEED. Read anything. Other lanes' worktrees (`n23-controls`, `n23-prologue`, `n25-yard`) are forbidden.

## Report (short)
Files, commit hash, the px counts, the glove bboxes, what you saw in each PNG, anything you could not do. Then END.
