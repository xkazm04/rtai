# Brief n28-06-molotov-sword: molotov and plasma sword on their own p70 grids, by the homing shard's route

You are the builder (in-session subagent; builder.mjs is out of account). Worktree
`C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n28-keys`): **`cd` there in every shell command**. Repo law:
`AGENTS.md`, `STANDARDS.md`.

**HARD STOP: report and END by {END} whatever the state. Commit the first weapon by {COMMIT1}; the second by {COMMIT2}
only if it passes in time (otherwise leave its round resumable, nothing under project/, and say so).** Check `date`
often. Small commits, staged per path, `git commit -- <paths>`. No amend, rebase, stash, `add -A/./-u`, `commit -a`,
`reset --hard`, push. Fix lint and format findings in your own edit and go on. No subagents, no model CLI except the image
tool `C:/Users/kazda/kiro/gtai-art/gen.mjs`. Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys`,
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, `GTAI_GODOT_EST_MB=600`
(1000 for renders), `--rendering-driver d3d12`, windowed `--position 0,1440`, one Godot at a time, never raw, free your own
processes by PID only.

## The route (accepted twice: homing shard 3ea5cf48c, then mini-nuke / ray gun in brief n28-03)
Read `C:/Users/kazda/kiro/gtai-art/rivet-n28/homing_shard/STATE.md`, the n28-03 rounds' `STATE.md`
(`.../rivet-n28/mini_nuke/`, `.../ray_gun/`) and `evidence/n28-keys/grid_homing_shard.md`. Same scripts, one round per
weapon (`.../rivet-n28/molotov/`, `.../plasma_sword/`) with a resumable `STATE.md`. One sheet-sized edit per sheet
(2 images per weapon; at most 2 more per weapon for failing rows; cap 8 for this call).

These two are one-hand weapons. **Donor: the plasma rifle's p70 walk and run sheets** (the owner's words; legs and stride
are the donor's by construction). Image 2 = the weapon's equipped strip `p70/rivet_eq_<weapon>.png` (+ `_left`): the prompt
says the weapon is held **in one hand exactly as in image 2** (molotov: the bottle in one claw, its rag wick lit only as on
the strip; plasma sword: the hilt in one hand, the blade as on the strip), the other arm as on the strip, the legs, boots
and soles pixel-identical to image 1, the held part inside its cell, the collar a rigid orange-and-black hazard collar with
straight stripes (never rope or cloth). Colour law on the weapon: no red; no teal; amber only for the molotov's flame.
**Fallback, only if the rifle donor fails a row on the arms** (a two-handed pose left, an extra hand, a rifle remnant):
re-edit that row with the pistol's (molotov) or the katana's (plasma sword) p70 sheet as image 1, and record which rows
used which donor; the stride rows then are that donor's (copy its `rivet_motion.json` rows for that weapon).

Bars, wiring, checks and commit message exactly as n28-03 (16/16 rows, dome 3 %, sole 2 px, same leading boot, no extra
limb, no remnant, tone 2, foot_slide walk <= 2 / run <= 7 cm at 32 px/m beside the donor's, `test_rivet_grid_stride.gd`
pins, provenance, `run_unit.mjs --changed`, `quick.mjs --no-godot`). "Before" from a temp worktree at your start sha
(`git worktree add build/wt-before-<w> <sha>`, `git worktree remove` afterwards); row labels in plain ASCII.

## Then, if both weapons are committed before {CLIP}: the five-weapon clip
`C:/Users/kazda/kiro/gtai-masters/n28/keys/five_weapons_32.mp4`: 32 px/m, tilt 70, 1080p60, 25-40 s, Rivet walking and
sprinting in 8 directions with each of the five (homing shard, mini-nuke, molotov, plasma sword, ray gun) in turn
(ffprobe in your report); a frames.json entry. Only weapons whose grids are committed.

## Evidence per weapon (commit separately after its grids)
`grid_<weapon>_64.png` / `_32.png` (stop-gap | new | donor, 8 facings, walking 6.75 / sprinting 9.3 m/s, same tick) to
`C:/Users/kazda/kiro/gtai-masters/n28/keys/`, `frames.json` entries appended, `evidence/n28-keys/grid_<weapon>.md`.

## Allowlist (anything else: stop and report a NEED line)
`project/features/characters/art/view/p70/rivet_walk_eq_{molotov,plasma_sword}*`, `rivet_run8_eq_{molotov,plasma_sword}*`,
`project/data/tables/rivet_motion.json` (rows of these two only), `project/tests/unit/test_rivet_grid_stride.gd` (their
pins), `steam/ai-provenance/2026-11.jsonl` (append), `evidence/n28-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n28/**`,
`C:/Users/kazda/kiro/gtai-masters/n28/keys/**`, `build/**`. If the sword's strike/windup strips need a grid hook in code:
stop and report a NEED (do not edit code).
Forbidden: every other weapon's art, the donors' art (read only), `weapons.json`, `weapon_art.json`,
`project/features/combat/**`, `project/dev/gauntlet/**`, `project/boot/prologue/**`, `ghost_*.json`, `combat.json`,
`enemies.json`, `native/`, other worktrees, `main`.

## Report and END (final message)
`IMAGES n` per weapon, donor per row, rows passed, table paths, foot_slide beside the donor's, commit shas, still/clip
paths + ffprobe, STATE.md "next".
