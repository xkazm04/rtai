# Brief n22-foes-05: time to kill per player weapon class, then the weakest looks

Lane `foes` of night run n22 (combat gauntlet). You are the builder. Cwd: `C:\Users\kazda\kiro\gtai-wt\n22-foes`, branch `n22-foes`. Briefs 01 to 04 (`evidence/briefs/n22-foes-0*.md`) landed the tiers, the four new enemies (rocket trooper, sentry turret, shield robot, war machine), `--foe-mix`, `FoeArmor`, `foe_duel` with three player profiles, and the tier test: read `git log --oneline -20` first. Brief 01's Environment, Files and Law sections and brief 02's Files additions bind this brief too.

## Clock (wall clock, check `date` often)
START is the time you read this; write it down. Part A committed by START+30 min. Part B committed by **06:00 at the latest** (the run's last-code deadline), even if START+70 is later. **Hard stop START+70 or 06:05, whichever is earlier.** Fix lint and format findings in your own edit and go on. Do not stop to ask; decide, and list decisions in your report.

## Environment
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/foes` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot run; `--rendering-driver d3d12` to render; windowed runs `--position 0,1440`. One Godot at a time in this lane; kill only your own PIDs.

## Part 0 (five minutes, first): decision lines
Append these lines, one at a time and unchanged in meaning, at the end of `docs/decisions.md` (shared, append-only; never edit another line), and commit them alone as `docs: n22 foes decisions`:
- `- [2026-11-21] DECISION enemies/tier: every enemies.json row carries a required int tier 1..5 (patrol_cop 1, riot_cop 2, swat 2, contractor 2, robot_thug 3, robot_gunner 3, rocket_trooper 2, sentry_turret 3, shield_robot 4, war_machine 5); contractor got 2 like swat (a one-hit rifleman who uses cover). Rejected: leaving contractor untiered.`
- `- [2026-11-21] DECISION enemies/new rows: the four n22 enemies carry explicit_spawn true, so they stay out of EnemyRoster.archetypes and every legacy pit wave and replay is byte-identical; they are reached by id (roster.archetype, ArenaSquad.spawn_member, --foe-mix). Rejected: adding them to the weighted roster (moves every legacy wave).`
- `- [2026-11-21] DECISION enemies/splash keys: new enemy weapon rows use guard's round, splash_radius_m and splash_damage names (weapons.json shape), not a foes-only blast key, so the guard merge is identical. Rejected: blast_m.`
- `- [2026-11-21] DECISION combat/armour: front plates, rear weakness and shield-robot moving cover are one FoeArmor.impact call in CombatArena.damage, exactly 1.0 for the six original rows and for blasts on the shield robot. Rejected: per-brain damage_k from Rivet's bearing (wrong for side shots).`
- `- [2026-11-21] DECISION enemies/blast on Rivet: until guard's enemy blast lands, a foes rocket or shell hurts Rivet only on a direct hit (it is a normal hostile round in arena.shots); its burst (FoeRocketFlight.burst signal, at the locked point or the first wall) is drawn but deals no area damage to Rivet. Guard's blast consumes the same round/splash keys at the Director's merge. Rejected: foes editing arena_projectiles.gd (guard-owned).` (If the war machine's stomp or shell already deals area damage through its own owned code by the time you read this, write the line to say exactly what is true, checked in the code.)

## Part A: a time-to-kill table for every enemy row against every player weapon class
`project/dev/gunplay/ttk_bench_run.gd` measures weapons against generic `weapons.json` targets; it does not know enemy rows, armour or tells. Build a dev entry in the same manner, owned and new: `project/dev/enemy_ai/foe_ttk.gd` (+ a runner if a `-s` script needs one, like `ttk_bench.gd`), run through `node tools/dev/run.mjs foe_ttk --out=<abs json>`:
- For each enemy row in `enemies.json` (all ten) and each player weapon class Rivet can hold in the arena (`WeaponTable.playable()`, plus hands melee if the arena has it; group by class if the table carries one, otherwise one row per weapon), spawn ONE enemy through the real `CombatArena` + `ArenaSquad` (the same path `foe_duel_trial.gd` uses) at 8 m, Rivet firing every time the weapon allows with no aim error, from the **front** and from the **rear** (Rivet placed behind the enemy's facing; the enemy is held still, its brain off, so this is a pure damage-and-armour measure). Record seconds to kill (median of 10 registry-seeded trials) or `null` if not killed in 30 s, plus the hit share.
- Write `evidence/foes/ttk.json` (`"schema": "gtai.foe-ttk/1"`) and a Markdown table `evidence/foes/ttk.md` (rows: enemies by tier; columns: weapon classes; cells `front / rear` seconds). The front/rear gap must show the armour of the turret, the shield robot and the war machine, and a 1-hit human must die to any weapon's first hit.
- Commit `foes: time to kill per enemy and player weapon, front and rear`.

## Part B: the weakest looks and stills (the owner judges by the films)
Read `C:\Users\kazda\kiro\gtai-masters\n22\foes\frames.json` and look at every still it names. Known gaps (from the director's review):
1. **Rocket trooper** wears the plain swat look: at 32 px/m it does not read apart from a swat, and the kneel does not show. Give it a distinct placeholder in owned look code (`FoeLooks`, `FoeOrdnanceView` or a new `foe_*_view.gd`): a launcher tube on the shoulder along its facing (steel with a hazard band, drawn in the ink style), and during the tell a visibly lower, wider kneeling silhouette (or a ground brace mark). Cops stay blue; vermilion only for the aim line; no teal.
2. Its 64 px/m still has the trooper at the frame edge: refilm so the trooper is centred at the tell.
3. **Shield robot** (director's review of `shield_robot/t405.png`, `squad/t230.png`): it is no bigger than Rivet on screen, though it is the heavy robot; scale its look so its footprint is clearly larger than Rivet's at 32 px/m (look only: hitbox, radius and every number stay). Its shove tell at t405 barely reads: during `telegraph_ticks` show a vermilion danger wedge or bar along the shove path (`reach_m` long), gone when the lunge ends. Refilm its tell still.
4. **War machine** (director's review of `war_machine/t175.png`, `t414.png`): the mini-boss is about Rivet's size on screen. Scale its look so its footprint is about twice Rivet's at 32 px/m and clearly bigger than the shield robot (look only; hitbox, radius and every number stay). Refilm its stills (cannon ring, stomp ring, recover vents, a rear hit) with the camera framed on the fight.
5. Any other entry whose subject is smaller than Rivet on screen, off-centre, or half outside the play area: fix and refilm it the same way.
Refilm the rocket trooper (32 px/m, 1080p, 15 to 30 s, `--movie`, `--rev=HEAD`, framed on the fight inside the pit, no other enemies walking in), replace its entries in `frames.json` (best first, 8 to 15 entries in total over all four enemies) and delete stills it no longer references. Commit `foes: rocket trooper carries a launcher and kneels visibly`.

## Then, while the clock allows (no new mechanics)
Re-run `node tools/mutate/mutate.mjs --max=20` with `--lines=` on whichever new behaviour file has the lowest score in the earlier reports (`build/mutate/*.json`), add assertions for real survivors, commit, and quote before -> after.

## Files
As briefs 01 to 04, plus `project/dev/enemy_ai/foe_ttk*.gd`, `evidence/foes/ttk.*`. Forbidden: other lanes' files (brief 01 list), `project/features/bosses/**`. Any other path: stop that item, report `NEED <lane>: <file> <why>`.

## Law
As brief 01: existing rows' and weapons' numbers do not change; the 60 s replay, quest 1 and every existing scenario stay byte-identical; 60 Hz tick, registry RNG; typed GDScript, `Log`, ~200-line files (hard 300), functions <= 40 lines, <= 5 params; `.uid` with new scripts and one `--import` before committing; stage per path; no stash / add -A / commit -a / reset --hard / amend / rebase / push; do not touch `JOURNAL.md` or `REPORT.md`. Never fake a frame.

Report: commits (sha + subject), the ttk table inline, test/scenario/quick-gate results, film paths, mutation scores, decisions, anything undone.
