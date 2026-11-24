# Brief n28-cast-07: the contractor card draws, cadence and feet measured, checklist (on only if all pass)

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop HARDSTOP local** (check `date` often). **Start your first commit by COMMIT1; start your last commit by
LASTCOMMIT.** Part 1 is DONE (`cd738c9a6`: the generic `CastCards.current` -> `FoeCastView.feed` -> `CastCardPose` /
`CastFarCard` path draws him once the row is on; quest 1 contractors skip at `arena_rigs.gd:150`). This call starts at part 2.
Never leave finished work uncommitted; if a part is not green by the last-commit time, commit nothing
half-made, list the paths in your report.

Read first, in full: `evidence/briefs/n28-cast-03-contractor.md` (bars, Films path, owned-file ALLOWLIST, FORBIDDEN list,
Repo law, the "Added 19:25" lessons). It all binds this call. Done so far: `930b3b9f3` (ten cut sheets; hit/fall ship as
`contractor_cast_hit/fall.png` because quest 1 reads `contractor_hit/fall.png`: keep it so), `c6792df55` (row
`enabled: false`, `CastContractorAnchors`, `WALK_STEP_M` 0.2202 = 13.6 drawings/s at 3 m/s, which FAILS the 5-10 bar). Read
the audit's "Contractor, n28: state" notes at the end of `docs/art/cast-audit.md`.

Env, every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Never run `Godot_*.exe`
directly (not even `--import`): `tools/dev/run.mjs`, the film tools, gate, mutate, or `node -e` with `runGodot`. One Godot at
a time; rendering `--rendering-driver d3d12`; windowed `--position 0,1440`. Fold takes into as few launches as possible.

## Work, in order (commit each part)
1. **The card draws.** Find how a wave contractor is drawn today (patrol look 5 on the human rig; `git grep -n contractor --
   project/features project/data/tables`) and how the lancer / rocket-trooper human rows become cards on that path
   (`foe_cast_view.gd`, `CastCards`, `StreetQuestCards`). Make the `contractor` row draw his card through that SAME path when
   `enabled: true` (dev flag or a test can force it on); with `enabled: false` everything draws exactly as on main.
   Quest 1's contractor (`contractor_hit/fall.png`, `street_quest_*`) must not change. Tests: row on -> his sheets; row off ->
   today's drawing. Commit.
2. **Cadence and feet.** Director's decision: sweep `CastContractorAnchors.WALK_STEP_M` over 0.22 .. 0.32 (at least 0.22,
   0.26, 0.30) and pick the smallest step with <= 10 drawings/s at his gameplay speed (enemies.json `contractor` speed 3 m/s;
   cite also the speed he actually walks at in a fight if the sim moves him slower, e.g. strafing) while the sole stays <= 2 px
   over a contact and the body jump <= 12 px at 32 px/m (`tools/art/cast_feet.mjs` right and down-right, 70 and 55), plus
   stop, turn and reversal (extend `test_cast_walk_reversal.gd` or the gunner's `cast_gunner_transitions.py` path). Quote
   every sweep point in a table. If no step passes all three, keep the best one, keep him OFF, and say exactly which bar
   fails. Commit with the audit rows.
3. **Checklist, in ONE frozen-exposure Godot launch** (copy the gunner's poses harness, `project/dev/cast/cast_gunner_poses*`
   and `tools/art/cast_gunner_poses.mjs`): size at 32 px/m 70 deg beside the patrol cop (43/45) and Rivet (77/75); live 64 px/m
   rim (`tools/art/cast_mulroney_edge.py`, bar 0 like the warden/gunner) on walk, attack, hit, fall; shadow toggle (patrol 236,
   order 150-350); ink runs from the sheets (gunner's ink tool; patrol 3,3,4 / 3,3,3, within 2 px); live palette of hat (white)
   and vest (pale lemon, not orange: hue >= 45 on the live frame). Audit table (point, number, verdict) like the gunner's.
   Deliver `contractor_beside_64ppm_tilt70.png` (beside patrol cop and Rivet, front three-quarter and back) to
   `C:\Users\kazda\kiro\gtai-masters\n28\cast\`. Commit.
4. Only if every point passes: films via `tools/film/cast_gunner_films.mjs`'s path (a contractor variant under `tools/film/`):
   `contractor_close_64.mp4` (walk, aim tell, fire, hit 0.20 s, fall to rest; dropped hat beside him at p55) and
   `contractor_fight_32.mp4` (Rivet against three contractors, card on), both 1920x1080, 60/1, 15-40 s (`ffprobe`). Look at
   frames at 1 fps around tell, fire, hit and rest yourself and describe them; check the rest shows ONE gun (the game's pickup;
   the fall cells draw none). Then `enabled: true` + a `docs/decisions.md` line, flip the test. Update `frames.json` (valid
   JSON array). Commit.

## Checks
Before each commit: `node tools/tests/run_unit.mjs --changed` (quote its summary line in your report; the pre-commit hook does
NOT run GUT: tonight a placement change broke `test_cast_door` and nobody saw it) and `node tools/gate/quick.mjs
--files=<changed>` (if it fails with "Failed to compile depended scripts" on files unchanged since main, show `death_pose.gd`
fails the same way and rely on GUT). Fix lint and format findings in your own edit and go on. If the hook fails on
`tools/film/kill_reel_*.break.test.mjs`, run an `--import` through runGodot and commit again. Never stash, `add -A/./-u`,
`commit -a`, amend, rebase, push. Do not edit root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`. Rendering only (no
behaviour/speed change). No image generation. Never fake a number or a frame; look at every frame you deliver.

## Report (then END)
Commits; the card path used; the sweep table and the chosen step; feet/jump/cadence numbers; checklist table; film paths +
ffprobe lines + what you saw; `--changed` summary line; on/off and why; what is uncommitted.
