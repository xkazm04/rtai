# Builder n31-melee-03-fatalities (opus): signature kills where the owner plays

Read `evidence/briefs/n31-common.md` first: it is binding. Tag: `03`.
HARD STOP: commit each finished part by 25 min into the call; report and END 55 min after launch.

## The owner
"No fatal animations on advanced melee weapons against humans (chainsaw should always cause fatality to shieldless
cops)." The kills exist and are data-complete (`data/tables/signature_kills.json`: `chainsaw_grind`, `katana_split`,
`plasma_sword_split`, `baton_overload`, `claw_rake_kill`, plus gun rows) but only the dev station `brutality_pit`
feeds them (`features/combat/kills/brutality_hook.gd`). In the gauntlet every kill is the generic death.

## Scout findings (read-only research, cite-checked by a scout; verify before relying)
- Gauntlet sim: `features/gauntlet/gauntlet_session.gd:39-41`: `GauntletCombat.install(...)` REPLACES
  `stage.arena` - a hook set up before it listens to a dead arena. Append a `BrutalityHook` after
  `street.setup(...)`, call `hook.setup(s.stage, s.world.context())`, keep it in a field (e.g. `s.kills_hook`).
  `ArenaStage.step` steps every hook; `ArenaStage.write_state` folds every hook's state -> every gauntlet replay/tape
  digest moves: re-pin once with a dated `docs/decisions.md` line ("n31 melee item 3 moved <digests>").
- Gauntlet view: nothing calls `hook.attach_view(view)` in the gauntlet (only `dev/arena/arena_game.gd:198`).
  `project/dev/gauntlet/**` is READ-ONLY tonight, so do it from a file we may touch: `features/gauntlet/gauntlet_view.gd`
  (GauntletView extends CollectCallView, has `print_stage`) - when it binds the session, loop
  `session.stage.hooks` and call `attach_view(self)` (check GauntletStreet's attach_view override is a no-op or
  already called elsewhere - never call one hook's attach twice). BrutalityHook's `_game = view.get_parent()` is the
  gauntlet node, whose child `ArenaRigs` (a RigHost) `_find_rigs` finds lazily: fine.
- `--gore=reduced`: read through `ArenaArgs.parse()` (user args after `--`), but `dev/gauntlet/gauntlet.gd`'s own
  `KNOWN_FLAGS` rejects `--gore` (quit 2). That file is read-only: write `NEED director: add "--gore" to
  project/dev/gauntlet/gauntlet.gd KNOWN_FLAGS` in the report; meanwhile make the feed also honour
  `LaunchArgs.value("--gore")` (before `--`; `--gore` is already a LaunchArgs KNOWN_FLAG) so the switch works.
- Selection: `SignatureKillTable.for_weapon(weapon, archetype)` is deterministic; a missing variant falls back to
  the base row. Kill weapon ids: `chainsaw`, `electro_baton`, `katana`, `plasma_sword`, `claw`. The chainsaw kills a
  bitten human at RECOVERY with kind FINISH (`melee_contact.gd:~47`) and `vs_shield: through`: a riot cop dies to the
  saw shield or not. OWNER RULE: a chainsaw kill on a human without a shield is ALWAYS `chainsaw_grind`; a riot cop
  only once his shield is down or the saw has gone through it - check that the riot cop's death is drawn sensibly
  (shield plates) and say what plays.
- Card foes: `KillEvent.human` is false for robots/boss/machines (no row; shutdown rows only). Mulroney / warden are
  body human: they take the base row, drawn via `KillCardFall` (their own fall sheet) where no `*` cells exist.
  `MeleeLethal.human` excludes NAMED / brain_owned / machine / `never_finish`. List which foe gets what.
- Quest 1 (`boot/quest1.tscn` -> `boot/quest1_game.gd`, `boot/collect_call/quest1_session.gd`,
  `collect_call_stage.gd`): a plain CombatArena (`kill_landed` fires), no hooks array, no KillView. BrutalityHook's
  `setup` is typed ArenaStage. Smallest install: a small sim system in `Quest1Session.open` owning a
  `SignatureKills` connected to `stage.arena.kill_landed` (stream `brutality`, its state folded into
  `CollectCallStage.write_state` if World does not fold systems), and a `KillView` on the print stage's actor layer in
  `Quest1Game._casts()`. Quest 1's SCRIPT and lines must not change; its digests may move only by the kill state
  (dated decisions line). If the quest view is the sprite cast (no rigs), the body would not hide: then gate the
  quest feed to the rig/cards view and say so. DO QUEST 1 ONLY AFTER the gauntlet part is committed.

## Build, in order
1. Gauntlet feed + view attach + gore switch + a GUT/integration test: a headless gauntlet session where the
   chainsaw kills a patrol cop -> `SignatureKills.by_style` / consumed records `chainsaw_grind`; with
   `--gore=reduced` nothing is consumed. Commit.
2. Proof table: a tool `tools/melee/fatality_table.mjs` (reuse `tools/melee/play_baseline.mjs`'s probe
   `project/dev/melee_n31/play_baseline*` - extend telemetry with the hook's `telemetry()` and per-kill (weapon,
   archetype, row id or "generic")) running waves 1-4 per melee weapon, seeds 1..5 -> `evidence/n31-melee/03-fatal/
   table.md`: weapon x victim kind -> what plays (counts), and "chainsaw on a shieldless cop = chainsaw_grind"
   share over >= 40 kills (bar 100 %). Commit.
3. Quest 1 install (if time). Commit.
4. Decisions line; report NEEDs.
Do not change `player_melee.gd`, `melee_combo.gd`, `melee_sweep.gd`, `melee_swing.gd`, `rivet_swipe_view.gd` (builder
02's item). Frame cost and films are the next call.
