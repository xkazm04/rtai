# JOURNAL - lane loop (n22, 2026-11-21)

## Session 1 (00:08 - 01:38)

- 00:08 START. Worktree clean at 4306049e0. No Astra lock, no previous calls. Other lanes' ifaces not tagged yet.
- 00:12 MILESTONE speed. Headless `fight_probe --encounter=pit --bot=pit`, 2400 ticks (40 sim s) per seed, shared machine (4 lanes busy, CONTENDED, no bench lock):
  1 seed 7.0 s wall, 5 seeds 18.8 s wall -> boot about 4.0 s, then 2.95 s wall per 40 sim s = **13.6 sim s per wall s** per Godot (pit, about 5 hostiles at once).
  Logs `build/dev/fight_probe-2026-11-20T23-09-24-386Z.log`; results `evidence/loop/speed-pit5.json`, `evidence/loop/speed-pit1.json`.
  Night budget at 2 jobs: about 27 sim s per wall s; a 10-wave run of about 200 sim s + 4 s boot costs about 19 s of one job, so one wall hour affords about 380 runs (2 jobs). To be re-measured on the real gauntlet scene (more hostiles in late waves).
- 00:12 ASTRA RUNNING bot-core since 00:12 (brief evidence/briefs/01-bot-core.md, out C:/Users/kazda/kiro/gtai-n22/logs/loop/astra-bot-core.out)
- 00:15 DECISION loop/test-player table: the bot profiles live in a new `project/data/tables/test_player.json` (+ schema), not under `gauntlet_*` (street's prefix) and not inside `bot/` (data is JSON tables with a schema). Rejected: constants in the bot script (the profiles must be readable and comparable in the report).
- 00:15 DECISION loop/tune branch: the tuner applies and commits only on a branch whose name starts `n22-tune` (cut from n22-loop's head in this worktree when no Godot or Astra runs), every change one commit `tune(n22): <knob> <before> -> <after>: <miss>`, reverts by `git revert`. n22-loop itself carries tools, never tuned numbers. Rejected: tuning on n22-loop (would land tuned numbers with the tools), a separate worktree (fresh worktrees lack DLLs and the import cache).
- 00:15 DECISION loop/jobs: batch `--jobs` default 1, cap 2; tonight 1, because the shared-machine rule is one Godot per lane. Rejected: the lane brief's two jobs while all four lanes run.
- 00:19 n22-guard-iface tagged at 82bb7a4f5; merge deferred until bot-core's Astra call ends (no merge under a running builder).
- 00:25 n22-street-iface tagged at 4b1634334; merge deferred until the builder call ends.
- 00:58 ASTRA bot-core 46 accepted. Commits e61a46ce0..399c0c1b5: BotProfile/test_player.json, GauntletBot brain, BotView + BotViewArena, BotDefence (guard small/front, roll or cover on large, Tonnage on unavoidable blast), BotForms, BotCover, BotPick (random/greedy), unit tests 26/26, `--changed` 3404 green, mutate bot_defence 20/20. Pit, 3 seeds x 2400 ticks: waves novice 2/2/3, average 3/3/3, expert 4/4/4; damage 36.5 / 16.0 / 4.1 HP; same seed twice: input digest 2da4599f... and result file byte-identical. Guard ticks 0 (pit had no guard action yet). Probe (`project/dev/test_player/`) uncommitted: debt ratchet dev_loc 26600 -> 26780; next call accepts it through the debt tool.
