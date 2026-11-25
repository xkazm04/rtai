# n30 combat call 19: a wider rim variant (bands <= 2) as a second patch file, proven at t482/486 (no product commit)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start.
**Hard clock: commit by 16:05, report and END by 16:12** (your session dies ~16:20; never end with a product path modified:
`git apply -R` first).
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: builder c18 (blast floor specks, edits `project/features/combat/weapons/art/fx/blast_1.png`
and maybe other fx art) may still run. Before every Godot launch wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names
`n23-street` (re-check every 30 s). Never stage, commit, restore or revert c18's paths (`project/features/combat/**`,
`evidence/n30/floor/**`). Your takes run on whatever fx art is in the tree: compare only before/after pairs you take
back to back, and say which blast_1.png state they saw (`git status --short project/features`).

## Why
`evidence/n30/lights/rim.patch` makes the explosion light print its lowest lit band (band <= 1) in the amber alt ink; c12/c17
(`rim_proof.md`, `rim_ink.md`) found it reads weakly over the nuke's amber floor, and a deeper ink did not help (c17: the shader
mix, not the token). The variant: the rim covers bands <= 2 (one value in the shader: `step(band, 1.0)` -> `step(band, 2.0)`).

## Do
1. `git apply evidence/n30/lights/rim.patch`. Take A (patched as is):
   `node evidence/n29/red/take.mjs build/n30rim3/A 482,486 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
2. Edit the patched shader line `step(band, 1.0)` -> `step(band, 2.0)` (and its comment: "its two lowest lit bands"). Take W the same
   way -> `build/n30rim3/W`. (Reuse c17's unpatched before if blast_1.png is unmodified, else take one: `build/n30rim3/before`, patch reversed.)
3. Measure at t482/486 (c17's method; script `build/n30rim2/m.py` if present): changed px vs before, mean RGB of changed, ring and
   floor lum/sat, vermilion/red/teal added (bars 0/0/0). LOOK at t486 before | A | W; make
   `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/explosion_rim_wide_64.png` (labelled, cropped to the disc + 40 px).
4. Write the variant patch: with W's edit in the tree, `git diff -- <the 7 modified tracked paths>` + the new test file as in
   `rim.patch` (copy rim.patch's new-file hunks for `test_light_pool_rim.gd` and its `.uid` verbatim) ->
   `evidence/n30/lights/rim_wide.patch`. Restore: `git apply -R evidence/n30/lights/rim.patch` will fail on the edited shader line,
   so first undo your step-2 edit by hand, then `git apply -R evidence/n30/lights/rim.patch`; delete untracked test + uid if left.
   Prove: `git status --short project` shows only c18's paths (if any); `git apply --check evidence/n30/lights/rim_wide.patch`
   exit 0 and `git apply --check evidence/n30/lights/rim.patch` exit 0.
5. Append `## Wide variant (c19)` to `evidence/n30/lights/rim_ink.md`: commands, table, what you saw, both check lines. Append ONE
   entry to `gtai-masters/n30/combat/frames.json` (re-read just before writing). Commit
   `evidence/n30/lights/rim_wide.patch` + `rim_ink.md` (`n30 combat: rim wide variant (bands <= 2) proven at t486, for the owner`).

## Commits
Stage per path, `git commit -m "..." -- <paths>`; never `git add -A/./-u`, no stash, no amend, no rebase, no reset --hard. End with
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook. Do not touch docs/decisions.md, JOURNAL.md, REPORT.md.
Fix lint and format findings in your own edit and go on.

## Allowlist
Commit only `evidence/n30/lights/**`. Temporarily edited, restored before commit: the rim.patch paths. Write freely: `build/**`, the
masters dir. Anything else: stop and report a NEED.

## Report and END
Table, what you saw, both `git apply --check` lines, `git status --short project` after restore, commit hash, what you could not do.
