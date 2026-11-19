# Brief 01b `vault-fix` (follow-up to 01 vault-core; same session)

Same environment lines as brief 01 (APPDATA, GODOT_BIN, one Godot process, `--position 0,1440`).
I read your commits f7c866628..HEAD. Good work on the probe, data and fuzz. Four things go back before the
view package:

1. **Restore every doc comment you removed** in `boot/collect_call/stage_pilot.gd` and
   `features/player/player_motion.gd` (the class headers, the `## rivet-arsenal ...`, `## features/souls ...`,
   `## n11 ...`, `## The walk, sprint and roll ...`, `## Kept for the dev arena's teleport ...`, the `_fire`
   `# n10 r-2` note, every one; `git show 28302bd3c:<path>` has them). They carry the project's history and other
   lanes merge against them. Add one line of your own to each class header naming the vault. If a file goes
   over a size limit, move vault code out to `player_vault.gd`, never delete others' docs. Check the other
   files you touched for the same.

2. **The sim position must travel continuously.** Today `advance()` jumps from `takeoff` to `touchdown` at the
   midpoint (about 1.5 m in one tick over a cover_low): the camera, the enemies' aim and the rig all read
   `rivet.pos`, so the vault will look and play like a teleport. Make the path continuous from start to landing
   (an eased curve over `ticks`; a per-tick step no larger than about 2x the mean), and add
   `PlayerVault.airborne() -> bool` (the ticks on which his circle overlaps the vaulted obstacle's footprint)
   and `PlayerVault.lift() -> float` (0..1 arc for the view, 1 at the apex). Change the rule the tests and the
   fuzz check to: on every non-airborne tick his circle overlaps no solid; on every airborne tick it overlaps
   only the one obstacle being vaulted, whose height is <= `max_height_m`, and no building, void, or other
   solid. Keep the per-tick fuzz assert; print airborne tick count too.
   You reported why you teleported: `collect_call_stage.gd:109` collides Rivet after `ArenaBodies.resolve`
   every tick. Guard that one line: skip it while `pilot != null and pilot.motion.vault.airborne()` (one-line
   call site in boot/, allowed; nothing else in that file). Note `ArenaBodies.resolve` gets Rivet's velocity
   from his displacement: with a continuous path his vault speed is about 8 m/s, near the 7.5 m/s tackle line,
   so a vault into a person may tackle them as the sprint does; that is acceptable, say what you observe. The
   rig hiding the gun during the vault is the ai lane's `arena_rigs.gd`: leave it, I route it.

3. **Interrupted vaults finish clear.** `stop()` (a death, quest 1's hide branch, anything) during a vault
   must not leave him over the obstacle: put him on the landing (validated clear at the start) and go to
   RECOVER. A unit test: kill Rivet on an airborne tick, his position is the landing and clear.

4. `guard_move()` calls the stage's private `_collide()` from another class, and it changes ordinary walking
   whenever the vault flag is on. Tell me in the report the concrete case it fixes (positions, which solids),
   and either (a) prove it with a unit test that fails without it and keep it, calling a public method (add a
   small public `collide_preview(p) -> Vector2` to `collect_call_stage.gd` that returns `_collide(p)`; that file
   is boot/, allowed for this one call site), or (b) drop it if the case only arises with the vault's own
   teleport, which item 2 removes.

5. The staged flag commit: `launch_args.gd` is the shared append-only KNOWN_FLAGS list for all five lanes
   tonight, so its growth is sanctioned. Do not condense anyone's comments. Run
   `node tools/debt/debt.mjs --update --accept-regression="n19 lanes append KNOWN_FLAGS (move: --vault, --no-vault)"`
   (read `tools/debt/README.md` first for the exact form), commit the baseline with the flag lines and the
   `player_motion.gd` flag read in one commit.

Then re-run: quick gate, lint, `run_unit.mjs --changed`, `--fast`, your scenario + quest 1 / replay scenarios.
Commit each item separately (`move: ...`, with the Co-Authored-By line). Report the step sizes per tick of a
cover_low vault, the airborne window, the fuzz counts, and the guard_move answer.
