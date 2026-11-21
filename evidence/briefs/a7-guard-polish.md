# Brief a7-polish: make two film beats read without the HUD (lane `guard`, run n22)

Wall-clock HARD STOP: 05:55 local. Commit code by 05:50 at the latest (the lane's last code commit is 06:00). If short of time,
commit what is green and report what is left. Part 1 first; Part 2 only if Part 1 is committed by 05:25.

Before every Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a
time. Rendered runs windowed on the SECONDARY screen only: `--rendering-driver d3d12 --position 0,1440`. Never kill by name.
ffmpeg: `C:/ffmpeg/bin/ffmpeg`.

## What I saw in your a5 stills (I opened them)
- `wheel-katana-t163.png`: the wheel readout at lower right is small (16 px) and already fading, grey on grey: at 32 px/m 1080p
  the list is hard to read. The owner judges "the wheel with hands first" from exactly this.
- `wall-stopped-t137.png`: the smoke ring of the stopped rocket is drawn across the wall and over Rivet, so without the HUD line
  "Health 100" the frame looks like a hit. `wall-open-t371.png` looks the same. The two must look different.

## Part 0: keep the flip measurements (2 minutes, its own commit)
Copy `build/flip/blockers.md` and `build/flip/flip-table.md` verbatim to `evidence/guard-flip/` (build/ is git-ignored and dies with
the worktree) and commit those two files only.

## Part 1: the wheel readout (`project/features/player/wheel_readout_view.gd`, its own commit)
Hold the readout at full opacity for the first 0.6 s of its second, then fade over the rest (both as named consts, ticks from
`SimClock.TICK_RATE`); font 20 px, row height to match; colours from the HUD's existing palette (find what street's gauntlet HUD
and `HudWeaponSlot` use, e.g. `Ink.CREAM` text on `HudArt.INK` back; the selected row brighter with the marker bar). No teal
(teal is souls only), no red. Test: alpha 1.0 at age 0 and at age 0.5 s, below 1.0 after 0.6 s, invisible at 1 s.

## Part 2: a stopped blast looks stopped (smallest change that reads; its own commit)
Find where the blast ring / smoke is drawn for a hostile burst (grep from `RivetBlast.burst` and the existing explosion view). Pick
the smallest change that makes the wall-stopped frame differ from the open one without the HUD, for example: when the burst bursts
on a wall face (you already nudge it to the face), draw the burst as a half ring / spray on the launcher's side only, or emit the
existing debris/impact spray against the wall face and no smoke past it. Rivet's side of the wall stays clear of smoke. The sim
and its hash do not change (view only; prove: the 60 s replay hash `cbeb734ff9b97c41` and legacy pilot bytes unchanged). If the
drawing code is outside the allowlist, do not edit it: report a NEED with file:line and the proposed change, and skip to Part 3.

## Part 3: refilm the two beats and update the set
Re-run `node tools/dev/run.mjs guard_film --windowed --beat=wheel ...` and `--beat=wall` (and the full film if quicker), replace
`guard-film-32ppm.mp4` (40 s or less), `wheel-*.png`, `wall-*.png` in `C:/Users/kazda/kiro/gtai-masters/n22/guard/`, add a
before/after pair for Part 2 (`wall-stopped-before-t<N>.png` = the a5 still, kept, and the new one) and update `frames.json`
(8 to 15 entries, best first, notes with tick, HP, meter, what is visible). OPEN every new still before listing it. Delete the
`scratch/` folder there if nothing references it.

## Allowlist (any other path: stop that part, report a NEED, go on)
`project/features/player/**`, `project/features/combat/rivet_blast.gd`, `project/features/combat/fight_areas.gd`,
`project/features/arena/arena_projectiles.gd`, `project/features/arena/arena_dodges.gd`, `project/dev/guard/**`, new tests
`project/tests/unit/test_wheel_readout*.gd`, `test_rivet_blast*.gd`, `C:/Users/kazda/kiro/gtai-masters/n22/guard/**`, `build/**`, `evidence/guard-flip/**`.
Forbidden: everything else, notably `project/features/hud/**`, `project/dev/gauntlet/**`, `project/features/gauntlet/**`,
`project/features/combat/ai/**`, `project/features/combat/squad/**`, `project/data/tables/enemies.json`, `JOURNAL.md`,
`REPORT.md`, `evidence/briefs/**`.

## Law
Never delete or reword an existing comment. Debt-ratchet rises go through
`node tools/debt/debt.mjs --update --accept-regression="<what> (n22 guard)"`. Typed GDScript, warnings are errors; files about 200
lines (hard 300), functions <= 40 lines, <= 5 params; `Log` not `print`; no global RNG; views read the sim, never write it.
`node tools/gate/quick.mjs` before each commit. One commit per part, staged per path. Banned: `git stash`, `git add -A/./-u`,
`git commit -a`, `--amend`, rebase, `reset --hard`, push. Fix lint and format findings in your own edit and go on.
`node tools/mutate/mutate.mjs --file=project/features/player/wheel_readout_view.gd --max=20` after Part 1 (quote the score; view
code may score low: say which survivors are pixels only).

## Report
Commit SHAs + files, the replay hash on the last commit, the dev run verdict lines, every new output with size/duration, mutate
score, any NEED.
