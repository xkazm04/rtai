# n30 combat call 17: a deeper rim ink so the explosion rim reads over the amber blast floor (token value only)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start.
**Hard clock: commit by 15:45, report and END by 15:58** (your session dies at ~16:20; never end uncommitted, and never end with
the rim patch still applied: restore first, step 5).
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: another builder (c18, blast floor specks) runs beside you. Before every Godot launch wait
until no file in `$LOCALAPPDATA/gtai/runs/*.json` names `n23-street` (re-check every 30 s). Only shipped tools launch Godot.

## Why
Owner pick: "the explosion light rim amber through a new palette token". Token `amber` (#EDAB42, `project/data/tables/palette.json`)
+ `lights.json` explosion `alt_token: amber` landed; `evidence/n30/lights/rim.patch` (the Director applies it after the merge) makes
the rim print in that ink. c12 proved it on screen (`evidence/n30/lights/rim_proof.md`): at t486 64 px/m the rim moves cream ->
amber (mean RGB of changed px 255,241,187 -> 255,235,161) but reads WEAKLY over the nuke's own amber floor, and at 32 px/m it is
barely visible. #EDAB42 is light; a deeper, more saturated amber should contrast. Your job: pick that value by measurement.

## Read first
`evidence/n30/lights/rim_proof.md` (commands, measure script `build/n30rim/measure.py` if still there, the disc, the table),
`project/tests/unit/test_light_explosion_amber.gd` (pins AMBER = #EDAB42 and classify 0), `project/core/render/palette_tokens.gd`
(`classify`, `verm_gate`).

## Do
1. `git apply evidence/n30/lights/rim.patch` (patch in the working tree, NOT committed).
2. For each candidate token value, edit `palette.json` `amber` `hex` (or whatever the colour key is), run ONE take:
   `node evidence/n29/red/take.mjs build/n30rim2/<name> 482,486,490 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
   (a windowed take may not reimport changed data; palette.json is JSON read at run time, but if two candidates give identical
   pixels, run `"$GODOT_BIN" --headless --path project --import` through `node tools/godot/check.mjs`-style launcher or the
   unit runner's import, and say what you did). Candidates (every one must keep `r - max(g,b) < 0.31` = under verm_gate, and
   classify 0; check it by arithmetic first):
   - A `#EDAB42` (current; c12's after = reuse `build/n30rim/after2` if it exists, else take it)
   - B `#D9922C` (r-max = 0.28)
   - C `#C27A1F` (r-max = 0.28, darker)
   Plus the unpatched before (reuse `build/n30rim/before` if it exists).
3. Measure each at t482/486/490 inside the disc (c12's method): changed px vs before, mean RGB of changed px, amber class count,
   and CONTRAST of the rim ring vs the floor just outside it (mean luminance and mean saturation of the ring band vs a ring
   20-40 px outside the disc edge); vermilion (`r-max(g,b) >= 0.31`) added, red added, teal added: bars 0 / 0 / 0.
4. LOOK at every frame at t486 (open the PNGs). Pick the value that reads as a distinct amber ring over the floor with vermilion
   added 0. Make `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/explosion_rim_ink_abc_64.png` (t486, before | A | B | C,
   labelled, cropped to the disc + 40 px). If none beats A by eye, keep A and say so (a finding, not a failure).
5. RESTORE the patch: `git apply -R evidence/n30/lights/rim.patch`; `git status --short project` must show only `palette.json`
   (if you picked B or C) and nothing else; delete any untracked test/uid the patch created.
6. If B or C won: keep that hex in `palette.json`, update its `doc` r-max number, update `AMBER` in
   `test_light_explosion_amber.gd`; `node tools/tests/run_unit.mjs --select=test_light_explosion_amber,test_palette_tokens,test_light_layer`
   (drop names that do not exist; quote the line); `git apply --check evidence/n30/lights/rim.patch` must still exit 0 (if the patch
   touches the test's AMBER line and no longer applies, regenerate that hunk and say so).
   `node tools/lint/lint.mjs` clean on your files.
7. `evidence/n30/lights/rim_ink.md`: commands, the table (per candidate per tick), the contrast numbers, what you saw, the pick.
   Append ONE entry to `C:/Users/kazda/kiro/gtai-masters/n30/combat/frames.json` (re-read just before writing; `{file,title,ppm,before,note}`).
   Commit (`n30 combat: rim ink <hex> (ring vs floor contrast X -> Y at t486, vermilion added 0)` or, if A kept,
   `n30 combat: rim ink candidates measured, #EDAB42 kept`).

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`); never `git add -A/./-u`, no stash, no amend, no rebase,
no reset --hard. End messages with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook (it may take
~12 min: start the commit by 15:35). If the hook fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale:
run an import and commit again. Do not touch docs/decisions.md, JOURNAL.md, REPORT.md. Fix lint and format findings in your own
edit and go on.

## Allowlist
Commit only: `evidence/n30/lights/**`, `project/data/tables/palette.json` (the `amber` row only),
`project/tests/unit/test_light_explosion_amber.gd`. Temporarily edited, restored before commit: the rim.patch paths. Write freely:
`build/**`, the masters dir. Any other path: stop and report a NEED. Other lanes' worktrees: never. Do not touch
`project/features/combat/**` effect files (c18's).

## Report and END
Table, contrast, pick, test line, `git apply --check` line, `git status --short` after restore, commit hash, what you could not do.
