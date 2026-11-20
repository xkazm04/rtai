# JOURNAL - lane loop (n22, 2026-11-21)

## Session 1 (00:08 - 01:38)

- 00:08 START. Worktree clean at 4306049e0. No Astra lock, no previous calls. Other lanes' ifaces not tagged yet.
- 00:12 MILESTONE speed. Headless `fight_probe --encounter=pit --bot=pit`, 2400 ticks (40 sim s) per seed, shared machine (4 lanes busy, CONTENDED, no bench lock):
  1 seed 7.0 s wall, 5 seeds 18.8 s wall -> boot about 4.0 s, then 2.95 s wall per 40 sim s = **13.6 sim s per wall s** per Godot (pit, about 5 hostiles at once).
  Logs `build/dev/fight_probe-2026-11-20T23-09-24-386Z.log`; results `evidence/loop/speed-pit5.json`, `evidence/loop/speed-pit1.json`.
  Night budget at 2 jobs: about 27 sim s per wall s; a 10-wave run of about 200 sim s + 4 s boot costs about 19 s of one job, so one wall hour affords about 380 runs (2 jobs). To be re-measured on the real gauntlet scene (more hostiles in late waves).
- 00:12 ASTRA RUNNING bot-core since 00:12 (brief evidence/briefs/01-bot-core.md, out C:/Users/kazda/kiro/gtai-n22/logs/loop/astra-bot-core.out)
