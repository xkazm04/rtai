# n31 ghost 21 - Kerf deploys as one press: lock, 0.2 s wind-up with a sighting line, blink + cut; view faces the target

Builder tag: `g21-kerf-drop`. **First commit within 25 minutes; hard stop 55 minutes after launch** (last commit START 15 min before; hook ~12 min). Report and END. Launch time: see the addendum at the end.
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -20`, the prep `C:\Users\kazda\kiro\gtai-art\ghost-n31\kerf-beats\state.md` (whole: chain with file:line, beat plan, section 4 code changes, section 6 hold pins, section 7 open questions), and how Dent was done: `git show --stat 87ac21445` and g17's commits (`git log --grep="ghost 17"`).

## Why
Owner: "Tonnage deployment does not need visualization of placement ... expecting the same issue will be for other ghosts". Tonnage, Ohm and Dent are one press now. Kerf (key 3) still holds a marker and cuts on release.

## Director decisions (JOURNAL 01:47; do not reopen)
- One press locks the hostile `GhostDeploySpot.kerf_target` picks (cursor snap 2 m, else nearest the 35 degree cone line, range 9, clear line). The lock follows the target through the wind-up.
- Wind-up `charge_s` 0.2 (12 ticks); the deploy row gets `press_mode` "drop" and a `no_target` value "refuse" (alt "whiff" = blink dash_m along the aim, spends the cooldown). Refuse = no cooldown spent, `last_refusal` set; a dry cue if an existing sound id fits (read `audio` tables; no new asset), else none and say so.
- Kerf arrives beside Rivet (DentLane origin rule), faces the target (NOT the row-0 lock: extend g17's `_faces_camera` exception list), holds act COCK through the wind-up, BLINKS behind the target (`behind_m`) on C and plays CUT then RECOVER there to the fade. The thin sighting line from Kerf to the target during the wind-up is the ghost's own beam: teal allowed (reuse KerfView's sight line if it can be drawn from the deploy view; else a 2 px teal line at 0.6 alpha with an ink under-stroke).
- Boss cap unchanged. Kills: the strike's weapon stays `deploy_kerf`; write `evidence/n31/ghost/kerf_deploy_kills.patch` (`"also_weapons": ["deploy_kerf"]` on the `kerf_split` row of `signature_kills.json`, git diff format, NOT committed) and report `NEED melee`.

## Do (in order, commit each)
1. Row + strike + tests: kerf row drop fields, the lock at the press, the cut on C = P + 12 at the locked target's current position (if it died or left range 9 + 2 m during the wind-up: the cut whiffs, cooldown spent), refusal with no target. Pin the hold flow in every test the prep lists (state.md section 6: `test_ghost_deploy_attacks.gd` `_release` and the Kerf tests, `test_ghost_deploy.gd:128`; grep `kerf` across `project/tests` for any more) in the SAME commit. New `project/tests/unit/test_kerf_drop.gd`: locked target cut on C (not before), a target that walks during the wind-up is still cut (lock follows), refusal spends no cooldown, a dead target -> whiff. `node tools/tests/run_unit.mjs --select=<touched>` green. Commit.
2. View: arrival beside Rivet, facing the target, COCK -> blink on C -> CUT/RECOVER; the sighting line. A 64 px/m still pair (wind-up C-4, cut C+2) through a new dev probe `project/dev/ghost_n31/ghost_n31_kerf_beats*` (copy g17's Dent probe); Read both. Commit. Copy them to `C:\Users\kazda\kiro\gtai-masters\n31\ghost\kerf-view-{windup,cut}-64ppm.png` + frames.json entries.
3. One `docs/decisions.md` line: `- [2026-11-26] DECISION ghost n31 Kerf drop: one press locks the target (snap 2 m / cone 35 / range 9), wind-up 0.2 s with the sighting line, blink + cut on the 12th tick, no target = refused without cooldown (no_target refuse|whiff), arrival beside Rivet, faces the target`. Commit.
4. If 20+ minutes remain: full unit suite + scenarios once (re-pin a moved digest once with a dated decisions line naming "n31 ghost Kerf drop"). Else report "suite not run".
The ground art (3 images being generated in `C:\Users\kazda\kiro\gtai-art\ghost-n31\kerf-beats\out\`) is the NEXT call's (KerfDropMarks); do not start it.

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Lane Godot lock `build/n31/godot.lock` per run (`g21-kerf-drop <pid>`; never delete another's; wait for it). Godot only through the repo tools. Windowed runs `--position 0,1440`.
- Allowlist: `project/features/souls/**` (Kerf deploy, strike, spot, row loader, deploy body/view/effects; NOT the Dent files another builder may be editing: `dent_drop_marks.gd`, `dent_drop_beats.gd`; coordinate on `ghost_deploy_effects.gd`: see the addendum), `project/data/tables/ghost_attacks.json` (+ schema), `project/tests/unit/test_kerf_*.gd`, `test_ghost_deploy*.gd`, `test_ghost_number_keys.gd`, `test_rivet_input_interrupts.gd` (hold pins only), `project/dev/ghost_n31/ghost_n31_kerf_beats*`, `docs/decisions.md` (one line), `tools/debt/baseline.json` via the debt tool, `evidence/n31/ghost/**`, `build/n31/**`, masters ghost folder. NOT `project/features/combat/**`, `project/dev/gauntlet/**`, other lanes' files. Any other path: STOP, report a NEED.
- Typed GDScript, ~200 lines/file (hard 300), <= 40 lines/function, <= 5 params, `Log` not `print`. New `.gd` -> `--import`, commit the `.uid`. Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard, --no-verify. Commit messages end with a blank line then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Report
Commits, stills and what you saw, tests, suite + scenarios, the patch path, NEED lines, what was not done.

## Added 02:26 (director) - launch times and neighbours
Launched 02:26. **First commit by 02:51, last commit START by 03:06, hard stop 03:21: report and END.** Parts 1 and 2 are the must; 3 is one line; 4 only if 20+ minutes remain.
- The Kerf images exist (3/3 accepted) but belong to the next call; do not use them.
- A parallel builder `g18b-dent-marks` owns `ghost_deploy_effects.gd`, `dent_drop_marks.gd`, `dent_drop_beats.gd`, `test_dent_*`, `test_ghost_deploy_effects*`, `ghost_n31_dent_beats*`, `project/features/souls/art/dent_*`. Do NOT edit those; draw Kerf's sighting line from the deploy body/view side or a new small file (e.g. `kerf_sight_line.gd`). If you truly need a hook in `ghost_deploy_effects.gd`, report it as a NEED for the next call instead. Never stage its paths.
- g17's scenarios run may hold `build/n31/godot.lock` (`g17-dent-view <pid>`) when you start: WAIT, never delete it. Lock helper: copy `build/n31/g17lock.sh` to `build/n31/g21lock.sh` with your tag `g21-kerf-drop`.
- `docs/decisions.md`: before appending, `git diff --quiet docs/decisions.md` must be clean (else wait 1 min and retry); append, then commit it alone at once.
- Ohm and Dent ship as drop: the shared drop code (`_drop_row`, `DentLane`, the body's `_faces_camera` list) is the pattern; read it before adding Kerf's branch. Every test that pins the old Kerf hold flow goes in your FIRST commit (grep `kerf` and `\"3\"`/`ghost_deploy_3` across `project/tests`).
- Mutate: skip (the director runs it later).
