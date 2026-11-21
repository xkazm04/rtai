# n22-street brief 03: bonuses that really reach Rivet, the pick screen, the HUD

Lane `street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`, branch `n22-street`. The interface, the
seeded street, the run loop and the composer are committed (read `git log --oneline -15` and
`project/features/gauntlet/`, `project/dev/gauntlet/` first). Never rename anything from the interface commit.

**Wall-clock hard stop: 02:58 (stop working, write the final message). Commit deadline: 02:50.** Commit each item when it works. Fix lint and
format findings in your own edits and go on. Never amend, never rebase. No `git stash`, no `git add -A/./-u`,
no `commit -a`, no `reset --hard`, no tags. Stage per path. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
(`--rendering-driver d3d12` for rendering, `--position 0,1440` on any windowed run: never the main display).
One Godot process at a time; free your own by PID. Mutate: `--max=20 --lines=<changed>`.

## Allowlist (any other path: stop that item and report `NEED <owner lane>: <file> <why>`)
As before: `project/dev/gauntlet/**`, `project/features/gauntlet/**` except `bot/**` (lane loop's),
`gauntlet.json`, `gauntlet_bonuses.json` + schemas, `project/tests/unit/test_gauntlet_*.gd`,
`test_stat_mods.gd`, translation rows for your new `tr()` keys (name the file), one appended line in
`docs/decisions.md` per decision. Forbidden: `project/features/player/**`, `project/features/combat/**`,
`project/features/souls/**`, `arena_projectiles.gd`, `arena_dodges.gd`, `enemies.json`, `weapons.json`,
`combat.json`, `input_actions.json`, `TickInput`, `tools/gauntlet/**`.

## Items, in order
0. **Composer fix (director's review of 14076ccc8).** The owner's words: the war machine is "a mini-boss every
   fifth wave". In `GauntletComposer.compose`, a boss wave (`wave % boss_every == 0`) takes `war_machine`
   whenever that row exists, regardless of `tier_unlock_wave` and of budget (it is the wave's centrepiece;
   the escort is the remaining budget, floored at 0); the fallback (highest unlocked tier) only applies when
   the row does not exist. `war_machine` never appears on a non-boss wave. Update `test_gauntlet_composer.gd`
   (wave 5 and 10 hold exactly one `war_machine`; waves 1-4 none). One commit.
1. **The draw** (`project/features/gauntlet/gauntlet_draw.gd`, pure): after each cleared wave n, three
   distinct bonus ids from `gauntlet_bonuses.json`, weighted by `weight`, only rows with `min_wave <= n`, never
   something already held (a held weapon, a stat row already taken is fine to offer again only if the table
   says so: decide, record it, default no repeat of the same row id; an unlocked form is never offered again).
   It replaces `GauntletWaves._draw()` (which today crashes on a pool under three: `randi_range(0, -1)`, and
   `offered[choice]` with choice -1 on an empty offer; an empty offer means no pick row, never a crash).
   Draws from its own seeded stream (`gauntlet_picks`; note `GauntletPilot` already uses `gauntlet_picks` for
   the pilot's own choice: give the draw a distinct stream name, e.g. `gauntlet_offers`, and keep it), so offers depend only on the seed and the history.
   Fewer than three eligible: offer what there is. Unit test `test_gauntlet_draw.gd`: weights respected over
   many draws (a chi-like bound, deterministic seed), `min_wave` respected, no duplicates within an offer, no
   held item offered, same seed = same offers.
2. **Applying a pick** (`gauntlet_bonus_apply.gd` or similar). Each kind must measurably change Rivet:
   - `weapon`: arm it on Rivet through `ArenaArsenal.arm()` / the runtime grant path (read how the arena's
     launch flags and pickups call it). Until lane guard's wheel is merged, the newest weapon becomes the one
     in hand (record it as a DECISION; note in a comment that guard's wheel takes over).
   - `stat`: `StatMods.add(ref, k)`, then re-apply all mods to the session: `hp_max` -> `rivet.max_hp`
     (raise current hp by the same amount), `regen` -> this session's `tuning.rivet["repair_per_s"]`, `speed`
     -> this session's `tuning.rivet["walk_mps"]` (check where Rivet's controller reads walk speed: if it
     caches it at open, set it where it is cached, from your files only; if impossible, `NEED guard`),
     `damage` -> multiply every hostile's `damage_k` by `mods.value(&"damage")` when it spawns (`damage_k` is
     the share of a hit the victim takes, so this scales what Rivet deals; multiply, never assign, so another
     lane's armour factor survives), `guard_meter` -> recorded only (lane guard reads it; write
     `NEED guard: read StatMods guard_meter for meter_max` in the final message). Apply from the shipped base
     values every time (base * k), never compound on an already scaled value. `CombatTuning.shipped()` gives a
     fresh instance per call: confirm the session's tuning is not shared with anything else.
   - `ghost`: unlock the form for this run (`GhostLocks`; Rivet starts with all forms locked).
   Unit/integration test `test_gauntlet_bonus_apply.gd`: a +25 % speed pick moves Rivet measurably further in
   the same ticks (headless session); +25 % hp_max raises max hp to 125; a weapon pick puts the weapon in hand;
   a ghost pick makes `GhostLocks.allows` true for that form; damage pick: a hostile spawned after it takes
   k-times the hit.
3. **The pick screen** (human only; `project/dev/gauntlet/gauntlet_pick_view.gd` or under features if it is
   shipped UI): three cards in the style of `ArenaWaveCards.Card` / `GhostCard` (reuse them, do not fork):
   title, kind, plain number for stats (`+20 % speed`, `+25 % max health`), keys 1 to 3 or a click, the sim
   paused on the tick while it is up (the SimLoop does not step). Keys through InputMap actions (no raw
   keycodes): if no suitable action exists in `input_actions.json`, use the UI's own `ui_*` or write
   `NEED guard: input actions pick_1..3` and accept the click plus a dev-only key read inside
   `project/dev/gauntlet/` (record it). Every string through `tr()`. A bot gets `pilot.pick(offered)`; record
   `picks[{wave, offered[3], taken}]` in the run.
4. **HUD** (`project/dev/gauntlet/gauntlet_hud.gd`): wave number, wave timer (s, one decimal), and a reserved
   empty slot under the health bar for guard's meter (a named Control lane guard can fill: name it in the
   final message). Reuse the arena HUD's health bar if one exists. Text through `tr()`.
5. **Evidence**: a headless run `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10
   --result=...` still passes byte-identically twice, now with `picks` and `mods` filled; seed 8 gives
   different offers. A windowed still of the pick screen at 32 px/m tilt 70, 1080p
   (`--rendering-driver d3d12 --position 0,1440`), saved to
   `C:\Users\kazda\kiro\gtai-masters\n22\street\pick_screen_32.png`, and a still of each segment template
   (`segment_<id>_32.png`) in the same folder (a dev still script under `project/dev/gauntlet/` is fine). Look
   at every still yourself: describe what each shows in the final message.

## Final message
Commits, files, test counts, verdict lines, byte-compare, the stat-effect numbers measured in the test, every
still path with a one-line description, mutate score on `gauntlet_draw.gd`, every NEED, anything undone.

## Known since this brief was written
- Lane guard's head (not its iface tag, which is all you have) gives `PlayerGuard.meter_k: float = 1.0` and the
  HUD reads `meter()` 0..1 and `broken()` on `StagePilot.guard` (null under legacy). Do not merge guard's head.
  Write the HUD slot so a one-line call site can feed it `guard.meter()`; name that line in your final message.
- Your 02 run: waves 9 and 10 took 50 and 75 s with hands only. Once picks apply, the fallback walker should
  use what it is given (a weapon in hand fires; it is fine if it stays simple). Report the seed-7 wave seconds
  after item 2 next to the old ones.
- Order of priority if time runs short: 0, 1, 2, 5 (headless part), 4, 3, 5 (stills). Commit each as it lands.
