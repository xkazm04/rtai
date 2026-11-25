# Brief n29-combat-03c-bolt-jag: the bold current gets lightning-sized kinks

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END,
committed.** Never stop to ask: at a fork pick what best serves the owner's words, report it, go on. Fix lint and format
findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` briefly.

## Why
Commits a33cfc186 / 142f7a1fa / 49befa075 (read `evidence/n29/electric/bolt.md`) gave the electro bolt, chain hop and stun one
bold width (10 px opaque amber body, 4 px cream core, 13 px ink outline; `WeaponFxElectro.BODY_PX/CORE_PX/INK_EXTRA_PX`,
`add_path`). The director LOOKED at `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/electro_bolt_pair_64.png` and
`electro_hop_pair_64.png`: width and colour now read, but the path is **nearly straight** (kink amplitude
`ElectricArc.AMP_M` 0.075 m): it reads as a striped rope, not lightning. The old cells zigzag swings about 0.25-0.3 m.

## What
A. One const in `WeaponFxElectro`, e.g. `JAG_K: float = 3.0`, and a static helper (e.g. `amplify(path, k)`) that scales every
   interior point's perpendicular offset from the straight line between the path's two ends by `JAG_K` (ends fixed, no RNG,
   pure function). Apply it to the bolt path (`WeaponFxBolt.plan`) and the chain hop path (`chain_plan`) after
   `ElectricArc.shape`. Do NOT touch `electric_arc.gd` (kills and wrecks keep their accepted arcs). Tune `JAG_K` by looking
   (2.5-4): at 64 px/m the swing across the line should be about the cells zigzag's (measure both in the stills: px of the
   largest swing, quote them). Same-plan-within-a-3-tick-cell must still hold.
   Tests in `project/tests/unit/test_weapon_fx_electro.gd`: ends unchanged; an interior point's offset is exactly `JAG_K` x
   the shape's; deterministic. `run_unit.mjs --select=test_weapon_fx_electro,test_electric_arc` green; `node tools/gate/quick.mjs`
   (its standalone parse of `weapon_fx_electro.gd` fails even unchanged: compare against base, do not chase). Commit A with ONE
   appended `docs/decisions.md` line (`- [2026-11-25] DECISION n29 combat: ...` the JAG_K value and why).
B. Re-render the take exactly as `bolt.md` says (`electro_gun_hop`, both arms, 64 px/m stills at ticks 114 and 121 and the
   32 px/m films): overwrite `stills/electro_bolt_{cells,current,pair}_64.png`, `stills/electro_hop_pair_64.png`,
   `films/electro_bolt_{cells,current,pair}_32.mp4` (ffprobe each; singles 1920x1080 60 fps 15-40 s). Keep the previous
   current-arm bold stills as `stills/electro_bolt_pair_64_flat.png` and `stills/electro_hop_pair_64_flat.png` first (copy before
   overwriting). Red/vermilion and teal counts in the effect box as last time. Update `frames.json` (re-read first; keep all
   other entries) and `bolt.md`. Commit B.
C. If time remains: re-run mutate on `weapon_fx_electro.gd` with `--lines=<your changed lines plus 28-33,134-146> --max=20
   --tests=test_weapon_fx_electro` (budget 10 min), quote the score in bolt.md, commit.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000`.
  `--rendering-driver d3d12` for renders; windowed only at `--position 0,1440`. Godot only through the film / dev / test tools.
  **One Godot at a time for the lane**: another builder (kill card scale) works beside you; check
  `tasklist //FI "IMAGENAME eq Godot*"` before each run and wait for one you did not start. Never kill a process you did not
  start, never by name. `mem-budget: waiting` = the 16 GB cap: wait.
- Pre-commit hook up to ~12 min; if it fails on `tools/film/kill_reel_*.break.test.mjs`, Godot `--import` and commit again. Never
  skip it. Typed GDScript, functions <= 40 lines, <= 5 params. Stage per path. Banned: `git stash`, `git add -A/./-u`,
  `git commit -a`, `reset --hard`, amend, rebase, push. `docs/decisions.md`: another builder may have appended a line: commit
  both, they are legitimate. Never touch the other builder's files (`project/features/combat/kills/**`,
  `test_kill_card_scale.gd`). Commit trailer: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
- Never delete anything in Temp you did not create.

## Allowlist (any other path: stop and report `NEED <what>`)
`project/features/combat/weapons/art/weapon_fx_electro.gd`, `weapon_fx_bolt.gd`, `project/tests/unit/test_weapon_fx_electro.gd`,
`docs/decisions.md` (one line), `evidence/n29/electric/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/combat/`.

## Report and END (short)
Commits; JAG_K; measured swing px (cells vs current); colour counts; paths + ffprobe; units; mutate; what was left.

## Wall clock (binding)
Started 04:24. Commit A by **04:45**. Commit B by **05:02**. HARD STOP **05:08**: report and END, committed.
