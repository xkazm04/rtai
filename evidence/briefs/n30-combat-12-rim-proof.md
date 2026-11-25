# n30 combat call 12: prove the explosion rim patch on screen, ship it as an applicable patch file (not applied)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start. **Hard clock: patch file +
evidence committed by 15:00, report and END by 15:10** (your session dies at 15:15; never end uncommitted, and never end with
the product files still patched: restore them first, see step 5).
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: before every launch wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names
`n23-street` (another builder, c10, may still be filming the bond; re-check every 30 s). Only shipped tools launch Godot (runGodot).

## Why
The owner picked "the explosion light rim amber through a new palette token". The token `amber` and `lights.json` explosion
`alt_token: amber` landed (`d4b6aabcc`), but nothing reaches a pixel: `project/core/render/light_pool.gd` uses `alt_color` only
for a strobe and `project/assets/shaders/light_ink.gdshader` prints one ink per light. `project/core/render/**` and the shader are
on no lane's file list, so the lane does NOT commit them: the Director applies the change after the merge. Your job is to make
that a one-command, proven step: the exact patch, its test, and a before | after still of the real blast.

## Read first
`evidence/n30/lights/rim_patch.md` (the patch text, the test, the doc line), `evidence/n30/lights/explosion_rim.md` (`## Probe
(c04b)`: the take command and the tick table: the nuke's light draws t480-513, full strength t480-496).

## Do
1. Before (HEAD, unpatched): one take with the probe's command, no probe logging:
   `node evidence/n29/red/take.mjs build/n30rim/before 486 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
   (read `take.mjs` for how to ask for several ticks in one run; take 482, 486, 496 if it allows it in one process).
2. Apply the patch from `rim_patch.md` by hand, exactly: shader lines 36-37, `light_pool.gd` (`write` + `pack_rgb`), `lights.json`
   explosion `"rim": true` (sorted keys), the schema property, the stale comment in `arena_combat_lights.gd:6`, the new test
   `project/tests/unit/test_light_pool_rim.gd`, and one assert in `test_light_explosion_amber.gd`. Parse-check with
   `node tools/godot/check.mjs` on the changed `.gd` files and run
   `node tools/tests/run_unit.mjs --select=test_light_pool_rim,test_light_explosion_amber,test_light_pool,test_light_layer`
   (drop names that do not exist; quote the pass/fail line). `node tools/lint/lint.mjs` on the changed files (gdformat/gdlint clean).
3. After: the same take(s) with the patch in the working tree -> `build/n30rim/after`. Measure per tick, in the light's disc
   (centre and radius from the on/off diff bbox in `explosion_rim.md`, ~395 px radius at 64 px/m): px changed before -> after
   (max channel diff > 24), and inside the changed region count px by class: amber (hue 25-50 deg, sat >= 0.45), pale yellow
   (hue 40-65, sat < 0.45), vermilion (`r - max(g,b) >= 0.31`), red (`is_red` rule used in `evidence/n29/red/`), teal; before
   and after. Bars: red added 0, teal added 0, vermilion added 0; px outside the disc changed 0.
4. LOOK at both frames (open the PNGs) and write in one sentence what the ring looks like before and after. Make
   `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/explosion_rim_patched_pair_64.png` (t486, before | after, labelled,
   cropped to the disc + 40 px). If the ring is not visibly amber over the nuke's own amber floor, say so plainly (that is a
   finding, not a failure) and also crop the same pair to the disc's outer half.
5. Write the patch file, then RESTORE: `git diff -- <the modified tracked paths> > evidence/n30/lights/rim.patch`, then append
   the new test file as a new-file diff (`git diff --no-index /dev/null project/tests/unit/test_light_pool_rim.gd >> ...`; fix the
   header paths so `git apply` takes it; include its `.uid` only if Godot made one: then add it the same way). Restore with
   `git checkout -- <each modified path>` and delete the new test file + uid. Prove it: `git status --short` shows no product
   path, and `git apply --check evidence/n30/lights/rim.patch` exits 0 on the clean tree (quote it).
6. `evidence/n30/lights/rim_proof.md`: commands, test line, the per-tick table (changed px, class counts before/after), what
   you saw, and the Director's two commands (`git apply evidence/n30/lights/rim.patch`, then the test select line). Append one
   entry to `C:/Users/kazda/kiro/gtai-masters/n30/combat/frames.json` (re-read it just before writing; `{file,title,ppm,before,note}`,
   note: "patch not merged; Director applies rim.patch"). Commit `evidence/n30/lights/rim.patch` + `rim_proof.md`
   (`n30 combat: explosion rim patch proven on screen (applies clean, N px amber at t486), for the Director`).

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`); never `git add -A/./-u`, no stash, no amend, no
rebase, no reset --hard. End messages with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook
(it may take ~12 min: start the commit by 14:55 at the latest). Do not touch docs/decisions.md, JOURNAL.md, REPORT.md.
Fix lint and format findings in your own edit and go on.

## Allowlist
Commit only: `evidence/n30/lights/**`. Edit temporarily (restored before the commit, never committed): the patch's own paths
listed in step 2. Write freely: `build/**`, the masters dir. Any other path: stop and report a NEED. Other lanes' worktrees:
never.

## Report and END
Test line, per-tick table, what you saw, `git apply --check` line, `git status --short` after restore, commit hash, what you could
not do.

## Overlap guard
c10 (bond film, `evidence/n30/bond/**`) may still be running. Do not apply the patch (step 2) until c10's film is on disk
(`C:/Users/kazda/kiro/gtai-masters/n30/combat/films/bond_natural_32.mp4` exists and no ledger file names n23-street) or until
14:45, whichever comes first; until then do step 1 and read. If at 14:45 c10 is still filming, apply anyway and say so.
