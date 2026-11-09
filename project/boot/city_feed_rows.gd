class_name CityFeedRows
extends RefCounted
## The city's people as RigFeed rows: one row per live ped or cop within FEED_RADIUS_M of the
## focus, in snapshot order. Lives on the view side: reads a snapshot, writes no sim state, so
## parity and replay are untouched. CitySim.fill_feed_rows does it in C++ (the script's loop was
## ~390 us a riot tick in the debug build, LEDGER n10); a DLL built before that entry, or no DLL
## at all, keeps the loop. The rows are the same either way, face to the C library's float atan2
## (the DLL's and the engine's may differ in the last bit: it only turns a drawn body).

const FEED_RADIUS_M: float = CharacterRigs.RADIUS_M + 4.0
const NATIVE_CLASS: StringName = &"CitySim"
const NATIVE_FILL: StringName = &"fill_feed_rows"

var native: bool = false


func _init() -> void:
	native = (
		ClassDB.class_exists(NATIVE_CLASS) and ClassDB.class_has_method(NATIVE_CLASS, NATIVE_FILL)
	)


## Rewrites `feed` from `snap`; `aim` is where the cops point (world px). feed.count = the rows.
func fill(
	feed: RigFeed,
	snap: PackedFloat64Array,
	variants: PackedByteArray,
	focus: Vector2,
	aim: Vector2,
) -> void:
	if native:
		var r2: float = FEED_RADIUS_M * FEED_RADIUS_M
		var v: Variant = ClassDB.class_call_static(
			NATIVE_CLASS, NATIVE_FILL, snap, variants, focus, r2, aim, SimConst.PX_PER_M
		)
		var rows: Array = v
		feed.adopt_rows(rows)
	else:
		fill_script(feed, snap, variants, focus, aim)


## The native fill in GDScript: the fallback, and what the unit test holds the C++ to.
static func fill_script(
	feed: RigFeed,
	snap: PackedFloat64Array,
	variants: PackedByteArray,
	focus: Vector2,
	aim: Vector2,
) -> void:
	feed.count = 0
	var r2: float = FEED_RADIUS_M * FEED_RADIUS_M
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break  # projectile records (stride 3) follow every actor: not people
		var kind: int = int(snap[r + 1])
		if kind != SimConst.K_PED and kind != SimConst.K_COP:
			continue
		var p: Vector2 = Vector2(snap[r + 4], snap[r + 5])
		if p.distance_squared_to(focus) > r2:
			continue
		_put_person(feed, snap, r, variants, aim)  # by offset: no slice allocated a person


## The actor record at offset `r` of `a` (a snapshot) as one feed row.
static func _put_person(
	feed: RigFeed, a: PackedFloat64Array, r: int, variants: PackedByteArray, aim: Vector2
) -> void:
	var slot: int = int(a[r])
	var cop: bool = int(a[r + 1]) == SimConst.K_COP
	var mode: int = int(a[r + 2])
	var head: Vector2 = Vector2(a[r + 6], a[r + 7])
	var px: float = SimConst.PX_PER_M
	var kind: BodyPlan.Kind = BodyPlan.Kind.COP if cop else BodyPlan.Kind.PED
	var i: int = feed.put(
		feed.count, slot, kind, Vector2(a[r + 4], a[r + 5]) * px, head * a[r + 8] * px
	)
	feed.looks[i] = variants[slot] if slot < variants.size() else RigFeed.LOOK_AUTO
	feed.face[i] = head.angle()
	var fl: int = 0
	if mode == SimConst.M_DEAD:
		fl |= RigFeed.Flag.DEAD
	elif mode == SimConst.M_DOWN:
		fl |= RigFeed.Flag.DOWN
	elif mode == SimConst.M_FLEE or mode == SimConst.M_RIOT:
		fl |= RigFeed.Flag.FLEE
	if cop and mode != SimConst.M_DEAD and mode != SimConst.M_DOWN:
		fl |= RigFeed.Flag.GUN_OUT
		feed.aim[i] = aim
		if a[r + 10] > 0.0:
			fl |= RigFeed.Flag.AIMING
	feed.flags[i] = fl
