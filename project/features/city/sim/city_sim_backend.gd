# gdlint: disable=max-public-methods
@abstract class_name CitySimBackend
extends RefCounted
## The bubble sim's one interface, met by the native CitySim (CitySimNative wraps the
## GDExtension class) and by the permanent GDScript reference (CitySimRef, NAT-06). The API is
## coarse (NAT-02): one step() and one write_render() per frame; spawn, kill and the chunk stamps
## are the documented rare calls. All sim maths is doubles with + - * / sqrt floor (NAT-07).

@abstract func backend_name() -> StringName
@abstract func init(seed_value: int) -> void
@abstract func set_radii(ra: float, rb: float, riot: float) -> void
@abstract func stamp_chunk(cx: int, cy: int, tiles: PackedByteArray, cells: PackedByteArray) -> void
@abstract func clear_chunk(cx: int, cy: int) -> void
@abstract func cell_at(x: float, y: float) -> int
@abstract func tile_at(x: float, y: float) -> int
## spec: SimConst.SP_LEN floats laid out SP_KIND..SP_DIR. Returns the slot, or -1 when full.
@abstract func spawn(spec: PackedFloat64Array) -> int
@abstract func set_riot_centre(i: int, x: float, y: float) -> void
@abstract func kill(i: int) -> void
## A car hit person i at (vx, vy) m/s (the vehicles feature): lethal = dead, else a knockdown.
@abstract func strike(i: int, vx: float, vy: float, lethal: bool) -> void
## Render only: a car slot's state for the atlas pick (custom.y; VehicleBody.State).
@abstract func set_car_state(i: int, state: int) -> void
## One fixed tick (SIM-01): dt is SimClock.TICK_DT; cam is the bubble centre; tg the pursuit target.
@abstract func step(dt: float, camx: float, camy: float, tgx: float, tgy: float) -> void
@abstract func get_counters() -> PackedInt32Array
## Every live actor (SNAP_STRIDE floats) then every live projectile, in slot order: the parity
## and replay state (SIM-05).
@abstract func snapshot() -> PackedFloat64Array
@abstract func set_render(mms: Array[RID], clips: PackedInt32Array) -> void
@abstract func write_render(vx0: float, vy0: float, vx1: float, vy1: float) -> void
@abstract func get_render_counts() -> PackedInt32Array
## Render only (never sim state): slots drawn by a full cutout rig skip their atlas body.
@abstract func set_rig_slots(slots: PackedInt32Array) -> void
## Render only: the person quad's size in world px (the baked crowd atlas cell).
@abstract func set_person_px(px: float) -> void
## Render only: the art variant (crowd look) of every slot.
@abstract func get_variants() -> PackedByteArray
## Police flow field (WLD-09): SimConst.FS_LEN ints (computes, cells reached, last/max us).
@abstract func flow_stats() -> PackedInt32Array
## Flow-field distance in cells from (x, y) to the pursuit target, or -1.
@abstract func flow_dist(x: float, y: float) -> int
