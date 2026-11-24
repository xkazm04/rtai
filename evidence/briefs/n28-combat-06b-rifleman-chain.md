# Brief n28-combat-06b: blade6's third rifleman fires; an in-game electro chain hop still

Lane `combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd), branch `n28-combat`.
**HARD STOP and commit deadline: see the end (wall clock). At the hard stop write your report and END, even mid-task.**
Never stop to ask: pick what best serves the owner's words, note it, go on. Fix lint/format findings in your own edit and go on.

## A. blade6's third rifleman (dev take only)
n27 (`docs/day/2026-11-24/n27-pressure/REPORT.md` "What does not"): the `blade6` take fires in pairs from rifleman 1 then 2;
the third stands, so the film shows two shooters, not three. Owner's run brief: "let blade6's third rifleman fire".
- Find why in `project/dev/gauntlet/pressure_rifles.gd` (cadence lines ~37-45, 68-82; line 81 = which rifleman fires,
  a mutate survivor nobody pins) and the blade6 take setup (`project/dev/gauntlet/**`). Make the three fire in turn on
  `blade6` (keep `blade6_spaced` and `guard6` byte-identical: they are the measured contrasts). Dev take only: no product
  enemy behaviour, no balance value.
- Pin it: a `test_pressure_takes` case that names which rifleman fired (each of the three fires at least once on seed 1),
  which also kills the line 81 survivor. Update every pin the change moves (fired counts, returns) with the new numbers.
- Re-measure the blade6 share on the same seeds/ticks as n27 (`evidence/n27-pressure/takes/` deflect files; read how they
  were made) -> `evidence/n28/deflect/blade6_three.md`: fired, turned back, returns that hit, share with Wilson 95 %, beside
  n27's 1300 / 334 / 91 / 27.2 % [22.7, 32.3].
- One appended `docs/decisions.md` line: `- [2026-11-24] DECISION n28 combat: the blade6 take's third rifleman fires (dev take; n27's take fired from two of three); share re-measured <n> vs n27 27.2 %. Rejected: leaving it (the film showed two shooters).`
- Re-film `deflect_6m_32.mp4` through `node tools/gauntlet/pressure_films.mjs` (its `deflect_6m` entry; read its usage;
  one encode, crf 26 as it says) to `C:/Users/kazda/kiro/gtai-masters/n28/combat/films/deflect_6m_32.mp4` (replace;
  ffprobe it: 1920x1080, 60 fps, 15-40 s); look at one frame where all three riflemen are in shot.
- Mutate: `node tools/mutate/mutate.mjs --file=project/dev/gauntlet/pressure_rifles.gd --max=12 --lines=<changed lines> --tests=test_pressure_takes` (budget 10 min); quote the score.

## B. An in-game electro chain hop still (only if A is committed)
Item 3's chain evidence is a dev view (`stills/electro_chain_pair_48dev.png`). Find a game take where the electro gun's
chain hops between two targets (a crowd of thugs/cops; `tools/film/owner_takes.mjs` takes list, `electric_stills.gd`,
the gauntlet with the electro gun; grep `WeaponFxElectro.chain` callers for what triggers a hop) and render the same tick
with and without `--electro-cells` at 64 px/m -> `stills/electro_chain_{before,after}_64.png` + `electro_chain_pair_64.png`
(before left). Look at them. Add to `frames.json` (keep existing entries; at most 15 entries total, best first: drop the
two `_48dev` entries if the game pair lands).

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=600` (1000 for renders, `--rendering-driver d3d12`; windowed only at `--position 0,1440`). One Godot at a time; kill only your own PIDs, never by name. `mem-budget: waiting` is not a hang.
- Typed GDScript, ~200 lines a file (hard 300), functions <= 40 lines, <= 5 params, `Log` not print. `node tools/gate/quick.mjs`
  before every code commit; ~12 min for the pre-commit hook; on a `tools/film/kill_reel_*.break.test.mjs` failure run a
  Godot `--import` and commit again (never skip the hook). Stage per path (`git commit -- <paths>`); banned: `git stash`,
  `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push. Commit messages end with
  `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop that part, report `NEED <what>`)
`project/dev/gauntlet/**`, `project/tests/unit/test_pressure_takes.gd`, `tools/gauntlet/**`, `tools/film/**` (take/still
helpers only), `docs/decisions.md` (one appended line), `evidence/n28/**`, `C:/Users/kazda/kiro/gtai-masters/n28/combat/`.
Forbidden: every product file outside the list (enemies.json, combat.json, weapons.json values, features/**), other worktrees,
root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; why the third never fired and the fix; the share table n27 beside n28; film ffprobe; chain still paths; mutate score; what was left.
