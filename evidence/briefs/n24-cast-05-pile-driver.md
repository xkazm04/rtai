# Brief 05 (lane cast): commit what is done; the pile-driver in the game; the owner's films; frames.json

You are the builder for lane `cast` of an unattended night run on RTAI (Godot 4, internal id `gtai`), worktree
`C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n24-cast`. The director reviews every diff and frame.

**Wall clock.** Hard stop 75 minutes after you start. Last code commit **23:45** at the latest (then films/stills only).
At stop-minus-10 commit what is finished, write the report, stop. Fix lint and format findings in your own edit and go on.

## 0. FIRST (before anything else, 15 minutes max): commit what is already done
Run `git status --short`. The previous call (`clamshell`, report `evidence/briefs/n24-cast-04-clamshell.out.txt`
and `C:\Users\kazda\kiro\gtai-art\foes-n24\04-build-report.md`) left the clamshell staged but uncommitted (its commit lost a race with a
director journal commit; the director will not commit while you run). Check `git status`: commit it per path.
Also uncommitted: the pile-driver hunks in `cast_cards.json` / schema / provenance (keep its row
`enabled: false` until section 1 is done), the untracked pile-driver sheets and `tools/art/cast_walker_splice.py`.
Known open faults from that report, fix them here:
- `node tools/gate/quick.mjs` full run was exit 1 with "dependency compile cascades on the arena and turret scripts".
  Find the originating parse error with `node tools/godot/check.mjs project/features/combat/squad/foe_turret_card_view.gd
  project/features/arena/arena_robot_rigs.gd project/features/combat/squad/foe_turret_view.gd` (after a Godot
  `--import`) and fix it. Do not commit the clamshell until quick is green, or the failure is shown on main
  `b3f4727c0` too (then quote it).
- Door mutation scored 0/(0+2) with 2 survivors (`foes-n24/04-mutate-door.log`): read the surviving mutants and add
  assertions to the shield card test that kill them; re-run mutate on `foe_shield_card_view.gd` (--max=20).
- The turret mutation never ran: run it after the clamshell commit.
- The scenario `rig_stress` miss (1.073 / 1.000 ms) was under load: use `node tools/tests/run_scenarios.mjs` (it
  re-runs contended misses alone) and quote its summary.
- The clamshell stills patch (`04-clamshell-stills.patch`) was rejected by the dev-code debt budget: the stills already
  exist and are accepted; do not re-apply it. Commit it in small commits, staged per path:
1. Clamshell (sentry turret): `project/features/characters/art/view/{p55,p70}/sentry_turret_{attack,fall,hit}.png` +
   `.import`; `project/features/combat/squad/foe_turret_card_view.gd` + `.uid`; `foe_turret_view.gd`;
   `project/features/arena/arena_robot_rigs.gd` (one-line call site); `project/data/tables/cast_cards.json` + schema;
   `project/tests/unit/test_cast_turret.gd` + `.uid`; `project/dev/cast/cast_turret_stills.gd` + `.uid`,
   `cast_action_plate.gd`, `cast_lineup.gd`; `tools/art/cast_turret_pack.py`, `tools/art/cast_lineup.mjs`;
   provenance lines in `steam/ai-provenance/2026-11.jsonl`.
2. Docs: `docs/art/cast-audit.md`, `docs/art/cast-checklist.md` (the standing rule, if written).
3. Before committing: `node tools/godot/check.mjs` on the changed .gd, `node tools/lint/lint.mjs`,
   `node tools/tests/run_unit.mjs --select=test_cast_turret,test_cast_shield,test_cast_lancer` (use the real
   basenames; quote the pass line), `node tools/gate/quick.mjs`.
4. Then: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_turret_card_view.gd --max=20` and the
   same for `foe_shield_card_view.gd` if it has no score yet; quote killed/(killed+survived).
5. Scenarios once (arena files changed): `node tools/tests/run_scenarios.mjs` (it re-runs CONTENDED budget misses
   alone); quote the summary line. A CONTENDED wall-clock budget miss is not a failure; an idle-machine miss is.
If the clamshell films/stills were left unfinished, they already exist and were accepted by the director:
`gtai-masters/n24/cast/clamshell_{32,64}ppm_tilt{70,55}.png`, `clamshell_{wave_32,close_64}.mp4`. Do not redo them.

## 1. The pile-driver (war machine) finished
The packed sheets in the tree were reviewed and ACCEPTED by the director on a light matte (p70 + p55: armed_walk,
attack, stomp, hit, fall; front columns spliced from the front3 takes; no plan view, no mirrored cannon, no smoke):
`project/features/characters/art/view/{p55,p70}/war_machine_{armed_walk,attack,stomp,hit,fall}.png` + `.import`,
`tools/art/cast_walker_splice.py`. Do not regenerate them unless a cell is broken in game (then say which).
- Run a Godot `--import`, check every cell at 32 and 64 px/m in game (the cast dev scene), facings against the cop's
  column order (down, down-right, right, up-right, up; left facings mirrored).
- Wire through `cast_cards.json` `war_machine` row (add a `stomp` action key if needed: schema + test), a
  `foe_war_card_view.gd` (or the existing pattern's name) in `project/features/combat/squad/`, and one-line call sites
  in shared render files only. Keep the weak-spot read (the louvres) and the stomp / cannon danger marks drawn by the
  existing views. Switch off (`enabled: false`) must render exactly main's look. Render only: no numbers change.
- Height: the war machine must stay a large walker, not a humongous boss. Measure the drawn standing height at 64 px/m
  in metres beside Rivet's 1.65 m and the cop; target about 2.4 to 2.8 m. Say the number.
- Unit test `project/tests/unit/test_cast_war_machine.gd` like the turret's (card on: rig hidden, action -> sheet cell;
  card off: main path). Commit with the art, `.import`, provenance lines (one per generated sheet, the same form as the
  existing cast lines).
- Stills `pile_{32,64}ppm_tilt{70,55}.png` beside cop and Rivet (walk, cannon tell, fire, stomp tell, slam, hit,
  wreck), like `clamshell_*`. Films `pile_wave_32.mp4` + `pile_close_64.mp4`: 1920x1080, 60 fps, 15-40 s by ffprobe,
  every beat; the machine survives long enough to show both attacks (raise its health only inside the dev film scene,
  never in tables).
- `enabled: true` only when the films exist; otherwise leave it false and say so.

## 2. One real gauntlet wave with the redrawn enemies (32 px/m)
Every film so far is a staged street. Film one real gauntlet wave in which at least two of the redrawn enemies
(lancer = rocket_trooper, door carrier = shield_robot, clamshell = sentry_turret, pile-driver = war_machine) appear
beside patrol cops: `node tools/dev/run.mjs gauntlet --windowed ...` with `--seed`, `--waves`, `--bot` (read
`project/dev/gauntlet/gauntlet.gd` KNOWN_FLAGS; find a seed/wave where they spawn by a headless run and its
`--result` file first). Use `tools/film/` to record: 32 px/m, tilt 70, 1080p60, 20-40 s, to
`gtai-masters/n24/cast/gauntlet_wave_cast_32.mp4`. Do NOT edit any gauntlet file or table (they belong to another
lane); if a flag you need does not exist, say so and skip.

## 3. The owner's comparison sheet per redrawn enemy
For each of lancer, door carrier, clamshell, pile-driver: a 15-25 s clip at 32 px/m, tilt 70, 1080p60, the enemy
standing beside a patrol cop and beside Rivet (scale), then walking, attacking (tell + fire), hit, dying, from the
cast dev scene (staged beats are fine: it is a scale-and-animation sheet): `<enemy>_beside_32.mp4`. Plus a
before/after pair at the same tick and zoom: main's placeholder (row `enabled: false`) beside the new card
(`enabled: true`): `<enemy>_before_after_64.png` (left before, right after, labelled). If time is short, do the
before/after pairs first (they are cheap), then the clips in order lancer, door, clamshell, pile-driver.

## 4. frames.json and the after-table
- `C:\Users\kazda\kiro\gtai-masters\n24\cast\frames.json`, 8-15 entries, best first:
  `[{ "file", "title", "ppm", "before", "note" }]` (`before`: the file name of the before image, or null).
  Delete scratch renders in that folder it does not reference, but keep the audit lineups and every mp4.
- `docs/art/cast-audit.md`: an "after" table for each redrawn enemy, the same checklist items as the audit, PASS/FAIL
  per item with the evidence path per PASS. Honest: a minor fault stays a FAIL with one line why.
- A new audit lineup with the redrawn enemies beside cop and Rivet: `audit_after_lineup_32ppm_tilt70.png` and
  `_64ppm_tilt70.png` (same tool and layout as `audit_lineup_*`).

## 5. One decision line (append only, one line, at the end of `docs/decisions.md`)
`- [2026-11-22] DECISION art/wave-admission (n24 cast): a character enters a gauntlet wave or the prologue only when
its equipped in-game figure passes every item of docs/art/cast-checklist.md (patrol cop reference) at both pitches
and 32/64 px/m; until then its cast card stays `enabled: false` and it keeps main's look. Rejected: shipping
half-drawn sheets behind the placeholder rig.` (one physical line; adjust only if the checklist path differs).
Commit it alone: `cast: decision line for wave admission`.

## Setup and law
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/cast` before every Godot run;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12`
to render; `--position 0,1440` on any window. One Godot at a time; kill only your own PIDs, never by name.
Allowed paths: `project/features/characters/art/view/**/{rocket_trooper,shield_robot,sentry_turret,war_machine}_*`;
new `project/features/characters/cast_*.gd`, `project/features/combat/squad/foe_*view*.gd` (existing foe views: render
switches only); `project/data/tables/cast_cards.json` + schema; `project/tests/unit/test_cast_*`; `project/dev/cast/**`;
`tools/art/cast_*`; `docs/art/cast-*.md` (+ one pointer line in a docs/art index); one-line call sites in shared render
files (`arena_*`, `street_*`, `foe_looks.gd`, `arena_robot_rigs.gd`), each listed in your report;
`steam/ai-provenance/2026-11.jsonl` (append); `C:\Users\kazda\kiro\gtai-art\foes-n24\**`;
`C:\Users\kazda\kiro\gtai-masters\n24\cast\**`. Any other path: stop and report a NEED. Forbidden: numbers in
`enemies.json`, `weapons.json`, `combat.json`; `input_actions.json`; `project/features/player/**`; `rivet_walk*`,
`rivet_run8*`; `project/features/souls/**`; `project/features/gauntlet/**`; `project/dev/gauntlet/**`;
`gauntlet.json`; `melee_*`; `signature_kills.json`; `project/features/combat/kills/**`; `combat_arena.gd` (one-line
call sites only, listed); `docs/decisions.md` (except the one line of section 5), `STANDARDS.md`, `AGENTS.md`; JOURNAL.md, REPORT.md, `evidence/briefs/`.
AGENTS.md / STANDARDS.md: typed GDScript, ~200 lines per file (300 hard), functions <= 40 lines, <= 5 params, `Log`
not `print`, data JSON with a schema. `node tools/lint/lint.mjs`, `node tools/godot/check.mjs`,
`node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` before each commit. If the debt ratchet prints
`tighten:`, run `node tools/debt/debt.mjs --update` and commit the baseline.
Commit `.uid`/`.import` with sources; run a Godot `--import` after new art. Stage per path; never amend, rebase, stash,
`add -A`, `commit -a`, push. Commit messages start `cast: `. After a code commit:
`node tools/mutate/mutate.mjs --file=<your main new .gd> --max=20` and quote the score.
Colour law: red is blood only; cops are blue; vermilion only for danger/objectives/Rivet's collar; teal only for souls;
amber for heat and the hazard bands. Never a real person's likeness. Do not change who these enemies are.

## Report back
Commits (sha + message), files, the one-line call sites, checks and results (unit pass line, scenarios summary, lint,
quick gate), mutate scores, measured pile-driver height in metres, film and still paths with ffprobe durations and
resolutions, the gauntlet seed/wave filmed and which redrawn enemies appear in it, what is left uncommitted (should be
nothing), what is left undone.
