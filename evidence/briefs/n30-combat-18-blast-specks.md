# n30 combat call 18: the vermilion specks on the nuke blast floor's ink edges (find, fix if ours, measure)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start.
**Hard clock: find + measure by 15:30; fix committed by 15:50; report and END by 16:00** (your session dies at ~16:20; never end
uncommitted, never end with an uncommitted product edit: either commit it with its evidence or `git checkout --` it).
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: another builder (c17, rim ink) runs beside you and temporarily applies
`evidence/n30/lights/rim.patch` + edits `palette.json`. Before every Godot launch wait until no file in
`$LOCALAPPDATA/gtai/runs/*.json` names `n23-street` (re-check every 30 s). Only shipped tools launch Godot. Because c17 may have
the rim patch applied while you take, measure only the FLOOR (outside the light disc, or at ticks after the light is gone: the
nuke's light lives t478-513; take e.g. t520, t540, t580) and say which ticks.

## Why
Colour law: red is blood only; vermilion only for danger, objectives and Rivet's collar; amber for fire and heat. At 64 px/m the
mini nuke's amber blast floor prints its ink edges with VERMILION specks/outline (seen in
`C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/explosion_light_seen_64.png` and `explosion_rim_patched_pair_64.png`). The
print (`project/assets/shaders/grade_ink.gdshader`, `project/core/render/**`) is NOT ours; the effect art IS (combat owns weapon and
impact effect files and atlas cells: `project/features/combat/weapons/art/**`, `fight_nuke_art.gd`, `rivet_blast.gd`, ...).
Known from the nuke round (c07b, `evidence/n30/rounds/band.md`): tweaking a sprite's dark edge px to dark amber-brown made the
in-game vermilion count WORSE (the downscale blends amber with ink one px out). So find the cause first, then fix the cause.

## Do
1. Find what draws the blast floor (start at `project/features/combat/weapons/fight_nuke_art.gd`, `weapon_fx_warm.gd`,
   `weapon_fx_shell.gd`, `rivet_blast.gd`; grep for the colours). Write down: file:line of the floor colours (or the texture),
   and how the print turns its edge into vermilion (read `grade_ink.gdshader` / `palette_tokens.gd` `classify`/`verm_gate`: which
   input colours land in the vermilion accent: hue/sat/value window).
2. Before: `node evidence/n29/red/take.mjs build/n30floor/before 520,540,580 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
   (read take.mjs first; the take runs to its timeout after the stills, harmless). Also the rocket's blast if it has a floor:
   find its ticks in `evidence/n30/lights/explosion_rim.md` (~t68-104). Count per frame in the blast floor box: vermilion
   (`r - max(g,b) >= 0.31`), red (the `is_red` rule in `evidence/n29/red/`), amber (hue 25-50, sat >= 0.45), teal. Make a crop.
3. If the cause is in a combat-owned file and a colour/value change there moves the floor's edge OUT of the print's vermilion
   window while it still reads as fire (amber/ember, dark soot edge): make that change (smallest: one colour constant or a value
   cap), take the same ticks -> `build/n30floor/after`. Bars: vermilion in the floor box -> 0 (or state the count), red 0, teal 0,
   amber within 10 % of before, px outside the blast floor box changed 0. LOOK at before | after (open them): the floor must still
   read as a hot amber blast floor. Unit tests that name the file: `node tools/tests/run_unit.mjs --changed` (quote the line);
   `node tools/godot/check.mjs <file>`; lint clean. Commit the change + `evidence/n30/floor/specks.md` (cause, file:line, table,
   what you saw) + still `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/nuke_floor_specks_pair_64.png` (before | after,
   labelled, cropped) and append ONE entry to `gtai-masters/n30/combat/frames.json` (re-read just before writing).
   Then `node tools/mutate/mutate.mjs --file=<the file> --lines=<changed lines> --max=6` (cap ~10 min; quote killed/total).
4. If the cause is in the print or core/render (not ours), or no in-window change keeps it reading as fire: no product commit;
   write `evidence/n30/floor/specks.md` with the cause, the counts, the crop, and a one-paragraph NEED for the Director (what to
   change in which file, with the expected effect); commit that.

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`); never `git add -A/./-u`, no stash, no amend, no
rebase, no reset --hard. End messages with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook (may take
~12 min). If the hook fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run an import, commit again.
Do not touch docs/decisions.md, JOURNAL.md, REPORT.md. Fix lint and format findings in your own edit and go on. Banned in sim code:
global randf/randi, frame delta. Balance values do not change.

## Allowlist
Commit only: `evidence/n30/floor/**`, `project/features/combat/weapons/art/**`, `project/features/combat/weapons/fight_nuke_art.gd`,
`project/features/combat/rivet_blast.gd` and tests under `project/tests/unit/` that name the file you change. NEVER commit
`palette.json`, `lights.json`, `project/core/**`, `project/assets/shaders/**`, `evidence/n30/lights/**` (c17's). Any other path:
stop and report a NEED. Other lanes' worktrees: never.

## Report and END
Cause (file:line), table before/after, what you saw, test line, mutate score, commit hash(es), what you could not do.
