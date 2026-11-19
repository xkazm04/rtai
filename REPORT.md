# n19 lane `move`: Rivet's vault and cover (DRAFT, written 03:15; final at 07:40)

Director: Claude Opus 5.5. Builder: GPT-6.2 Astra. Branch `n19-move`, cut from `int-n19` at `28302bd3c`.
Masters and frames live in `C:/Users/kazda/kiro/gtai-masters/n19/move/` (not in git); best-first list in its `frames.json`.

> DRAFT. Every TODO is checked by the director before the freeze. Numbers marked (Astra) come from the builder's
> report and have not been re-run by the director yet.

## What works

| Item | Evidence | Number |
|---|---|---|
| Vault (on by default; `--no-vault` turns it off) | `project/features/player/player_vault.gd`, `vault_probe.gd`, `vault_city.gd`; scenario `rivet_vault` (pit arena + city block, aimed and free approaches); masters `cells/vault/sheets/p70_64_crate.png` | 1,080 attempts, 514 landed, 0 forbidden overlaps (director run, 23:47) |
| Cover (on by default; `--no-cover`) | `player_cover.gd`, `cover_query.gd`, `cover_view.gd`, `cover_upper_card.gd`; scenario `rivet_cover`; `cells/cover/sheets/p70_64_low.png`, `p55_64_high.png` | 800 presses, 488 snaps, 360 peeks, 312 refused (director run, 23:47) |
| Replay identity | `project/tests/scenarios/scenario_moves_replay.gd` (vault, snap, peek, fire, leave: 215 ticks) | TODO director re-run |
| Flags switch off cleanly | `project/tests/unit/test_moves_off.gd` pins flag-off stage bytes to the pre-vault locomotion | TODO |
| Drawn cells | `project/features/characters/art/rivet/moves/`, `tools/art/move_cells_cut.py`, 8 of 10 image_gen masters accepted | p55/p70 at x1.0 and x1.5 |
| Walk-slide measurement + proposal | `tools/film/foot_slide.py`, `project/features/player/stride_match.gd`, `gtai-masters/n19/move/walk/INDEX.md` | planted-step drift 14.2 -> 0.7 cm at 2.4 m/s (p55 pistol, 64 px/m) (Astra) |
| Solid fuzz (both moves, free input) | TODO `scenario_moves_fuzz` (brief 09) | TODO |

## What does not
- Cover snaps only to arena **station** boxes, because the arena's shot-stop rule (`ArenaWalls.blocks`) knows only stations. City props stop no shot today, so cover refuses in the open city and in quest 1 instead of faking protection. Quest 1's hide stays its own case (the p55 hide card is a dumpster with Rivet inside, not wall cover).
- Bare `--replay` of an arena recording exits 1 at tick 60: boot (`project/boot/world.gd`) picks city systems and the replay header (`project/core/replay/replay_log.gd`) records no session type or move flags. The recording reproduces inside an arena session. Not move-owned.
- The walk keeps visible ride inside one held drawing (47.1 -> 33.7 cm) after the cadence match: the armed walk has 4 cells.
- TODO car enter/exit (brief 08).

## What blocked or slowed you
- Waiting on Astra with no Godot allowed: about 30 min of idle director time at 02:10-02:40.
- An Astra call started from the director's own shell died with the director session (vault-view, 23:20): about 38 min of builder time lost until calls were launched detached.

## Calls for the owner
- Cover peek distance: `peek_m` 0.8 (shipped, Rivet's own diagonal shots clear the box) vs about 0.45 (a tighter half-body peek). TODO side-by-side still.
- Vault into a guard: peak 12.2 m/s, guard shoved 1.74 m. Keep as a tackle, or stop the vault at a body? TODO still.
- `NEED anim`: `project/features/characters/rivet_walk.gd` one line calling `StrideMatch.profile_cycle` (see Merge notes).
- TODO car doors: sim phase on (moves city digests: gfx re-bless) or cosmetic only.

## Merge notes
- One-line call sites in other lanes' files: `project/features/characters/rivet_frames.gd` (2 lines, anim), `project/features/arena/prop_occlusion.gd` (4 added lines, ai), `project/features/arena/arena_rigs.gd` (3 lines, ai), `project/boot/collect_call/collect_call_stage.gd` (airborne guard on `_collide`, `collide_preview`), `project/boot/launch_args.gd` (4 appended flags).
- Conflicts at 03:15: with n19-ai in `launch_args.gd` (keep both blocks) and `prop_occlusion.gd` (take ai's `_hits_of`, add `h.rig = rigs[i]` after its `h.area = area`); `tools/debt/baseline.json` with every lane (`node tools/debt/merge_baseline.mjs`).

## Next steps
TODO

## Astra ledger
| Call | Minutes | Verdict |
|---|---|---|
| vault-core | 23 | accepted with follow-up |
| vault-fix | 16 | accepted |
| vault-view | 38 | abandoned (cut with the director session; all work committed) |
| cover-core | 22 | accepted with follow-up |
| cover-view | 53 | accepted |
| move-cells | 43 | accepted with follow-up |
| cells-fix (+ flip-on) | 75 | accepted |
| tidy-walk | 26 | accepted |
| solid-fuzz | TODO | TODO |
