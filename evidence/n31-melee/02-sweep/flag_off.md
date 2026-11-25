# n31 melee 02 part 2.1 - flag off is byte-identical (tree a607e0b77 + d1aa84628, no code change)

Command (Git Bash, lane lock held, APPDATA=gtai-n31/appdata/melee, Godot 4.7.2):
`node tools/tests/run_scenarios.mjs --quiet-wait=1 --only=rivet_claw,rivet_chainsaw,rivet_katana,rivet_city_melee,rivet_city_fight,rivet_cover,rivet_deflect,rivet_vault,moves_replay,moves_street,moves_fuzz,replay_60s,brutality_kills,quest1_dent,quest1_kerf,quest1_ohm,quest1_tonnage,enemy_waves,enemy_pit,gunplay_fight,gunplay_fire,crowd_react,human_react,showcase_reel`

The subset = every scenario in `project/tests/scenarios/` whose script names melee / swipe / digest
(grep), plus the 60 s replay, the moves replay and the four quest 1 scripts.

Result line: `scenario-tests: 24 passed (headless)` (exit 0). The goldens and replay digests these
scenarios pin did not move with `--melee-sweep` absent: the part 1 sweep (`MeleeSweep.on` false) is the before.
