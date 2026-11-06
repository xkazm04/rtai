class_name StunCrowd
extends RefCounted
## n7-melee: the cap on stun marks when many bodies are stunned at once (Ohm's mass arc stuns up
## to 6 on one tick). Only the `full` newest stunned bodies draw the full marks (ShockJolt's
## crawl and WeaponFxElectro's two head sparks); the rest draw a lighter set (human_reactions.json
## stun_crowd). View only: reads the arena's stun state, no RNG, never hashed.

## (full, arcs, spits, sparks); full 0 = no cap. Loaded once (the views draw every frame).
static var _cap: Vector4i = Vector4i(-1, 0, 0, 0)


static func cap() -> Vector4i:
	if _cap.x < 0:
		_cap = ReactTable.stun_crowd()
	return _cap


## The ids of `arena`'s living stunned hostiles past the cap (empty when there is no cap).
static func light_of(arena: CombatArena) -> Dictionary[int, bool]:
	var full: int = cap().x
	if full <= 0 or arena == null or arena.areas == null:
		return {}
	var stunned: Array[Vector2i] = []
	for h: Fighter in arena.hostiles:
		var e: FighterFx = arena.areas.effect(h)
		if e != null and h.alive() and e.stun_ticks > 0:
			stunned.append(Vector2i(h.id, e.stun_ticks))
	return light_ids(stunned, full)


## The ids past the `full` newest of `stunned` ((id, stun ticks left) each; more ticks left =
## stunned later, ties to the lower id). Empty when full is 0 (no cap).
static func light_ids(stunned: Array[Vector2i], full: int) -> Dictionary[int, bool]:
	var out: Dictionary[int, bool] = {}
	if full <= 0 or stunned.size() <= full:
		return out
	var s: Array[Vector2i] = stunned.duplicate()
	s.sort_custom(_newer)
	for i: int in range(full, s.size()):
		out[s[i].x] = true
	return out


static func _newer(a: Vector2i, b: Vector2i) -> bool:
	return a.y > b.y or (a.y == b.y and a.x < b.x)
