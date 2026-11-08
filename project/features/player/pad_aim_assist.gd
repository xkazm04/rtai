class_name PadAimAssist
extends RefCounted
## n9-handheld: wires the gunplay lane's pad aim assist (AimAssist, weapons.json `aim_assist`:
## the owner's decision 2, light and pad only) into the live input on a row with `aim_assist`
## (the handheld rows; the desktop row has none, so a desktop run is untouched). Until n9 nothing
## called AimAssist.bend(): a pad aimed raw everywhere (LEDGER section 5).


## On an `aim_assist` row: `live`'s right-stick heading bends toward the living hostiles and the
## boss of the arena `arena_of` returns (read each tick: a stage builds its arena in setup), from
## Rivet's position. No-op elsewhere.
static func wire(live: LiveInput, arena_of: Callable) -> void:
	if not DeviceProfile.shared().aim_assist:
		return
	live.assist = WeaponTable.shipped().aim_assist
	live.aim_origin = func() -> Vector2:
		var a: CombatArena = arena_of.call()
		return origin_of(a)
	live.aim_targets = func() -> Array[RangeTarget]:
		var a: CombatArena = arena_of.call()
		return targets_of(a)
	Log.info("device", "pad aim assist on (weapons.json aim_assist)")


## `live` after wire(): a session builds and wires its live input in one line.
static func wired(live: LiveInput, arena_of: Callable) -> LiveInput:
	wire(live, arena_of)
	return live


static func origin_of(arena: CombatArena) -> Vector2:
	return arena.rivet.pos if arena != null else Vector2.ZERO


## `arena`'s living hostiles and boss as RangeTargets (position and team only: bend() reads both).
static func targets_of(arena: CombatArena) -> Array[RangeTarget]:
	var out: Array[RangeTarget] = []
	if arena == null:
		return out
	var fighters: Array[Fighter] = arena.hostiles.duplicate()
	if arena.boss != null:
		fighters.append(arena.boss)
	for f: Fighter in fighters:
		if f.alive():
			out.append(RangeTarget.make(f.id, f.pos, 1.0, f.radius_m))
	return out
