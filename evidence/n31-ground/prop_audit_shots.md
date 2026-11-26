# Which prop classes stop shots (n31-18, read from code, nothing run)

Every solid box goes through one list: `ArenaWalls.SOLID = [wall_high, cover_high, cover_low]` (`project/features/arena/arena_walls.gd:8`); `ArenaWalls.from_stations` boxes exactly those kinds, so a prop kind outside the list (cone, lane marks, firing line, anything drawn as fixture/debris/arch/span) has no box and stops nothing. `ArenaDodges.cull` (`project/features/arena/arena_dodges.gd:18-31`) then asks `walls.blocks(pos, pos + vel * TICK_DT)` for every shot, both sides' (cover works both ways).

| class | counts in the audit (gauntlet / yard) | ordinary bullets / bolts / cones | rockets and splash rounds | thrown (bottles) | blast reaching Rivet (`RivetBlast.falloff`) | Rivet and enemies walk |
|---|---|---|---|---|---|---|
| `wall_high` | 18 / 0 yard boxes (the yard fences are `wall_high` too, not in the dressing table) | stopped, the shot is erased | stopped: bursts on the first face (`ArenaProjectiles.burst_at_wall`) | pass over (`WeaponSpec.Kind.THROWN` skips the cull, lands at its aim point) | blocks | blocked (pushed out) |
| `cover_high` | 14 / 0 | stopped | bursts on the face | pass over | blocks | blocked |
| `cover_low` | 10 / 14 | stopped (same `SOLID` list: low cover is NOT lower than a bullet) | bursts on the face | pass over | blocks only while Rivet is in cover (`PlayerCover.active_on`); otherwise `HIGH = [wall_high, cover_high]` only, so a splash passes a low box | blocked (a crouched Rivet vaults it: `move_cells`) |
| everything else (`cone`, fixtures, debris, `arch_*`, `span_*`, dressing-only art) | 27 fixtures / 31 debris + 6 arches + 6 spans + 2 fixtures | pass through | pass through | pass through | pass through | walkable |

Consequence for the audit: a drawn structure that is not in `layout.cover` (the six conveyor arches and six overhead spans) stops no bullet either, so a shot crosses a conveyor's drawn machines; and every `cover_low` box (yard crates, pallets, the 6 `conveyor_*` footings, gauntlet planters and carts) blocks a bullet at its footprint whatever its drawn height. The invisible-wall verdicts in `prop_audit_before.md` / `prop_audit_strip.md` are therefore invisible shot walls as well as invisible movement walls.
