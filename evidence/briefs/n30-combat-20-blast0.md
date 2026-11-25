# n30 combat call 20: the same soot-seam fix on blast_0.png (frame 0), measured on the rocket

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start.
**Hard clock: commit by 16:05 (start the commit hook by 15:55), report and END by 16:12.** Never end with an uncommitted product
edit: commit it with its evidence or `git checkout -- project/features/combat/weapons/art/fx/blast_0.png`.
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: builder c19 (rim wide) runs beside you with `evidence/n30/lights/rim.patch` applied
temporarily (shader, light_pool, lights.json...). Before every Godot launch wait until no file in `$LOCALAPPDATA/gtai/runs/*.json`
names `n23-street` (re-check every 30 s). Never stage, commit, restore or revert c19's paths. Measure only the ROCKET blast (it
draws no light: FlashBudget refuses it), so c19's patch cannot touch your pixels.

## Why / read first
`evidence/n30/floor/specks.md` (c18, commit 8809bb21d): the FX item print snaps every amber->ink blend of the blast cells to VERM;
`blast_1.png` was repainted by `evidence/n30/floor/fix.py <HEAD png> <out> half` (grain -> cell amber, fringe -> soot grey alpha
128). `blast_0.png` (frame 0, blast ages 0-3) has the same fringe (30 texels snap VERM, ~70 px at 3.8x in c18's model). Apply the
same fix to it.

## Do
1. Model first: `python -I evidence/n30/floor/snap.py` / `sim.py` on blast_0 (read them for args): VERM texels and blends before
   and after the fix. If fix.py needs a parameter for this cell (its amber may differ), make the smallest change to fix.py and
   say so.
2. Before: the rocket's frame-0 ticks (blast at t64, frame 0 = ages 0-3 -> t64-67; c18 measured t68 as frame 0 too: check):
   `node evidence/n29/red/take.mjs build/n30floor0/before 65,66,67,68 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
   (reuse c18's before stills if they hold these ticks). Apply fix.py to blast_0.png, run an import
   (`"$GODOT_BIN" --headless --path project --import` launched through a shipped tool, or the unit runner, which imports first:
   a windowed take does NOT reimport a changed PNG), take the same ticks -> `build/n30floor0/after`.
3. Count with `evidence/n30/floor/count.py` in the rocket box (860,340)-(1340,760): vermilion (not blood), red, amber, teal,
   px changed outside the box. Bars: floor vermilion -> 0, red 0 added, teal 0, amber within 5 %, outside the box 0.
   LOOK at before | after (open them). Still
   `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/rocket_blast0_specks_pair_64.png` (labelled, cropped).
4. Unit tests that reach blast_0.png (`node tools/tests/test_map.mjs project/features/combat/weapons/art/fx/blast_0.png`, then
   `--select=` those; quote the line). Lint: `node tools/lint/lint.mjs`.
5. Append `## blast_0 (c20)` to `evidence/n30/floor/specks.md` (commands, model numbers, table, what you saw). Append ONE entry
   to `gtai-masters/n30/combat/frames.json` (re-read just before writing). Commit blast_0.png (+ its .import only if it changed)
   + specks.md (+ fix.py if changed): `n30 combat c20: blast_0 fringe to soot (rocket frame 0 vermilion N -> 0)`.

## Commits
Stage per path, `git commit -m "..." -- <paths>`; never `git add -A/./-u`, no stash, no amend, no rebase, no reset --hard. End
with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook (~12 min). If it fails on
`tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: import, commit again. Do not touch docs/decisions.md,
JOURNAL.md, REPORT.md. Fix lint and format findings in your own edit and go on.

## Allowlist
Commit only `project/features/combat/weapons/art/fx/blast_0.png` (+ `.import`), `evidence/n30/floor/**`. Write freely `build/**`,
the masters dir. Anything else: stop and report a NEED.

## Report and END
Model numbers, table, what you saw, test line, commit hash, what you could not do.
