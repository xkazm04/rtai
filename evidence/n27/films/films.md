# n27 melee films (lane melee, branch n27-melee)

Env for every Godot run: `APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/melee`,
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12`,
`--position 0,1440` (owner_takes.mjs sets both).

## Step 0
`--import`, then `node tools/tests/run_unit.mjs --select=test_ghost_number_keys,test_ghost_bond,test_ghost_bond_input,test_ghost_form_hud,test_ghost_deploy_bot,test_gauntlet_mastery,test_bot_pick_mastery,test_ghost_boss_cut`
-> 50 passed, 0 failed. No test needed fixing for the merged keys lane.

## Film 2: claw_shock
Tool: `tools/film/owner_take.gd` loadout `claw_shock` (hands wheel, melee held 80 ticks, release = discharge; the shield
robot gets a second charge, release at age 100), `tools/film/owner_takes.mjs` take `claw_shock` (gap 250 ticks, 1232 native
frames, then the first finish again at quarter speed, 100 frames x4).

- `node tools/film/owner_takes.mjs C:/Users/kazda/kiro/gtai-masters/n27/melee 64 claw_shock` -> `closeups/claw_shock_64.png`
  (copied to `stills/`), 180 native frames, kill t106.
- `node tools/film/owner_takes.mjs C:/Users/kazda/kiro/gtai-masters/n27/melee 32 claw_shock` -> `films/claw_shock_robots.mp4`
- ffprobe: `1920,1080,60/1,27.200000,1632` (h264 + mov_text subtitles)
- take.json: robot thug kill t106, robot thug t356, robot gunner t606, shield robot overloaded t856 / killed t956,
  war machine stunned 29 ticks, HP 26 -> 25.5, alive.
- `node --test tools/film/melee.test.mjs` -> 1 pass.
