# Brief n22-foes-04: the war machine (mini-boss), then the tier sanity test

Lane `foes` of night run n22 (combat gauntlet). You are the builder. Cwd: `C:\Users\kazda\kiro\gtai-wt\n22-foes`, branch `n22-foes`. Briefs 01 to 03 (`evidence/briefs/n22-foes-0{1,2,3}-*.md`) landed the interface, the rocket trooper, `--foe-mix`, `FoeArmor`, the sentry turret and the shield robot: read `git log --oneline -15` first, and read the files those commits added under `project/features/combat/squad/` before you write a line: reuse their tell, aim-line, burst and armour machinery; do not build a second copy. Brief 01's Environment, Files and Law sections and brief 02's Files additions bind this brief too.

## Clock (wall clock, check `date` often)
START is the time you read this; write it down. Part A committed by START+50 min. Part B committed by START+62. **Hard stop START+70** (the wrapper kills the session at START+75). Fix lint and format findings in your own edit and go on. Do not stop to ask; decide, and list decisions in your report.

## Environment
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/foes` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot run; `--rendering-driver d3d12` to render; windowed runs `--position 0,1440`. One Godot at a time in this lane; kill only your own PIDs.

## Part A: the war machine (mini-boss every fifth wave)
Owner's words: "each wave the enemy design and difficulty should harden (from regular police player can one-shot to war machines and various types of combat robots)". The war machine's answer: Tonnage's damage reduction, walls, and hitting between tells. **It must not be a damage sponge with no pattern: its tells and its pause after each attack are the fight.** It is not a boss from `bosses.json`; do not touch `project/features/bosses/**`.

Row today (`war_machine`, tier 5): hp 60, speed 1.8, turn 70 deg/s, `weapon: war_cannon` (large, 28 + splash 18 in 5 m), `alt_weapon: stomp` (large, splash 24 in 3.5 m). New rows' numbers are yours to tune.

1. **A walker with a pattern** (new owned file, e.g. `project/features/combat/squad/foe_walker.gd`, wired the way the trooper and turret are): it walks slowly toward a range band (about 8 to 14 m from Rivet) and turns slowly (`turn_deg_s`), so a Rivet who circles gets its rear.
2. **Cannon shell at range** (Rivet beyond the stomp reach): a **tell of about 1.2 s (>= 60 ticks)**: the barrel lowers / an aim line plus a **ground ring at the locked landing point the size of the splash radius**; at the end it locks Rivet's position then (not a prediction) and fires one slow `large` shell that bursts at the point (or on the first wall: walls stop it, reuse the rocket's flight and wall stop). Moving out of the ring or behind a wall avoids it.
3. **Stomp when Rivet is close** (inside about 4 m): a **tell of about 0.8 s (>= 45 ticks)** with a ground ring of `splash_radius_m` around its feet growing to full size; then a blast around itself. Rolling or walking out of the ring avoids it.
4. **Recover after every attack**: about 1.2 s (>= 60 ticks, a row key such as `recover_s`) in which it neither attacks nor turns, shown by a visible cue (amber vents for heat are allowed; vermilion only for the danger rings; never teal). That pause is the window to hit it.
5. **Armour**: front arc takes `shield_front_mult` (set about 0.5 on an arc key); **rear arc takes more** (a new optional row key, e.g. `rear_mult` about 1.5 on the rear 90 degrees; absent = 1.0, so every other row is unchanged), blasts full. All through the existing `FoeArmor` call at `CombatArena.damage` (no new call site). `FoeArmor.k` stays exactly 1.0 for the six original archetypes.
6. **No stagger-lock**: hits never interrupt a tell (it is a mini-boss), but a hit during the recover pause is how a player wins; a test proves that hitting it during a tell does not cancel the attack.
7. **Look**: the scaled machine plan from `FoeLooks`, bigger than the shield robot (a walker silhouette; steel and hazard stripes), a visible barrel showing where it faces, so a still at 32 px/m tells front from rear.
8. **Tune for a real fight, not a sponge**: with the `--player=average` profile in `foe_duel`, target a kill between 12 and 30 s and Rivet hurt in most seeds; against `perfect` Rivet should usually win without dying. Tune hp, tells, recover and splash of `war_machine` / `war_cannon` / `stomp` only, and list every number you moved (old -> new).
9. Tests `project/tests/unit/test_foe_walker.gd`: cannon tell >= 60 ticks and its ring is shown before the shell; stomp tell >= 45 ticks; a recover pause >= 60 ticks after each attack with no shot and no turn; a Rivet who leaves the ring during either tell takes no damage, one who stays does (once guard's blast on Rivet is merged; until then assert the burst event and its radius, and say so); a wall between stops the shell; front 0.5x, rear 1.5x, blast 1x; a hit during a tell does not cancel it; position moves toward the range band and the speed stays <= `speed_mps`.
10. Duel: `foe_duel --enemy=war_machine --seeds=20` with all three `--player` profiles: per profile hurt share, mean damage, enemy-died share, median kill tick, share of Rivet's damage dealt during recover and from the rear. Write `evidence/foes/duel-war_machine.json`.
11. Film (as brief 02: arena, `--foe-mix=war_machine,swat,swat` (a small escort), 32 px/m, `--res=1920x1080`, 20 to 40 s, `--movie`, `--rev=HEAD`, stills at the cannon tell with its ring, the stomp ring, the recover pause and a rear hit; one 64 px/m still of the walker) to `C:\Users\kazda\kiro\gtai-masters\n22\foes\war_machine\`; append to `C:\Users\kazda\kiro\gtai-masters\n22\foes\frames.json`.
12. Run lint, `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`, the scenario suite (unchanged, incl. the 60 s replay); commit `foes: war machine walks, shells at range, stomps up close, pauses after each attack`.
13. `node tools/mutate/mutate.mjs --file=<the walker file> --max=20 --lines=<changed lines>`; quote killed/(killed+survived); add assertions for real survivors and re-run once if time allows.

## Part B: tier sanity (one unit test)
`project/tests/unit/test_foe_tiers.gd`: walks every row of `enemies.json` `archetypes` and checks `tier` is an int in 1..5 and matches the roster's loaded value; the brief's tiers hold (`patrol_cop` 1, `riot_cop` 2, `swat` 2, `contractor` 2, `robot_thug` 3, `robot_gunner` 3, `rocket_trooper` 2, `sentry_turret` 3, `shield_robot` 4, `war_machine` 5); every weapon in the `weapons` block resolves to a size through guard's `EnemyRounds` (explicit `round` on every NEW weapon row; absent on old rows means small); each new enemy's tell(s) last >= 20 ticks, read from the same numbers the behaviour uses (not a copy). Commit `foes: tier sanity test over every enemy row`.

## Files
As briefs 01 to 03. Forbidden: other lanes' files (brief 01 list), `project/features/bosses/**`, `project/data/tables/bosses.json`. Any other path: stop that item, report `NEED <lane>: <file> <why>`.

## Law
As brief 01: existing rows' and weapons' numbers do not change; the 60 s replay, quest 1 and every existing scenario stay byte-identical; 60 Hz tick, registry RNG; typed GDScript, `Log`, ~200-line files (hard 300), functions <= 40 lines, <= 5 params; `.uid` with new scripts and one `--import` before committing; stage per path; no stash / add -A / commit -a / reset --hard / amend / rebase / push; do not touch `JOURNAL.md` or `REPORT.md`. Never fake a frame.

Report: commits (sha + subject), call sites outside owned folders, test/scenario/quick-gate results, duel summaries, every tuned number (old -> new), film paths, mutation scores, decisions, anything undone.
