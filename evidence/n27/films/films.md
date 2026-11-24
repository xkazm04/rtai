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

## Film 1: bond_film
Entry `project/dev/ghost-forms/bond_film.tscn` (+ `bond_film_64.tscn`): the gauntlet bot film scene with
`--bond-prefill=<N>` (every ghost's bond to master_at - N through `GhostBond.record`; the gauntlet owns no ghost at the
start so all four are filled), `BondFilmPick` (the rest screen held 150 frames on a hand with a mastery card, 30 to the
dim-select, the hand without it held 90, the second pick selected 60 frames before it is taken), `BondFilmLog` (read-only
bond/entry log), `BondFilmCapture` (native 1920x1080 jpg per drawn frame inside a sim tick window; env
`GTAI_FILM_DIR/FROM/TO`). Sim is paused while the offer is drawn, only the presentation waits. The bot's own T press
(`power_hauler`) is used: no press was added.
Seed choice (headless, expert, `--waves=4 --bond-prefill=6`, seeds 1-6): seeds 1 and 2 reach `master_tonnage` at the
wave 2 rest and then T; 3-6 never fill a bond in 4 waves. Seed 2 kept: second pick is Ghost Ohm.

- headless: `godot --headless --path project res://dev/ghost-forms/bond_film.tscn -- --bot=expert --pick=greedy --seed=2 --waves=4 --bond-prefill=6 --result=<abs>`
- film: `node evidence/n27/films/render_bond.mjs C:/Users/kazda/kiro/gtai-masters/n27/melee/films/bond_mastery.mp4 32 2 6 1650 2990`
  (d3d12, `--windowed --position 0,1440 --resolution 1920x1080 --fixed-fps 60`) -> ffprobe `1920,1080,60/1,28.816667,1729`.
  Log: bond full t1765, mastered t2463 (frame 3027), T (entering tonnage) t2884. Rendered before the final gdformat/line
  length pass (a lambda became a method; no behaviour change).
- stills: `... render_bond.mjs x 64 1 16 1400 2300 --waves=3`, `x 64 1 30 1400 3500 --waves=4`, `x 64 2 6 2430 2480`
  (jpg frames in `build/n27-films/bond-64-*`), cropped with ffmpeg into `stills/bond_chip_ring_64.png`, `bond_offer_64.png`.
- Finding: with a prefill the chip shows no ring at all until the first release (ring redraws only with the strip); in
  real play the value only changes on a release so it is not seen. The mastery card has no illustration.
- debt: `dev_loc` baseline raised with `--accept-regression` (new dev entry).
- The brief's "work `claw_shock_robots` ffprobe": `1920,1080,60/1,27.200000,1632`.
