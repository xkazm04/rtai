class_name StreetDeadRests
extends RefCounted
## n11 combat (the kill's pool at the boots): where each street body lies, published by
## StreetDeadPlan.draw once its lying sprite is placed, so what is laid UNDER the body (the kill's
## pool, CityBlood's PoolUnderBody) goes under the drawn chest, not at the feet where the sim put
## him. View-side only; the sim, the pickups and the replay never read it.

## Rests kept (the oldest is forgotten first), as StreetDeadPlan.MEMORY.
const MEMORY: int = 256
## The pool's spot from the lying sprite's centre toward the head (share of the standing height
## at the lying scale): a plan pose's centre is the pelvis. 0 = the sprite's centre.
const CHEST_K: float = 0.12
## A body lying in its own fall grid (StreetFallBetween.LIE_IN_GRID) has the FEET at its cell
## centre, the figure reaching toward the head. Its figure's middle per column (cell px from the
## cell centre, unflipped): the median over the six packed grids' lying rows (cop patrol, riot,
## SWAT, suit, worker, thug: each within about 25 px of it), measured 2026-11-10.
const GRID_MID: PackedVector2Array = [
	Vector2(1.0, 103.0),
	Vector2(100.0, 56.0),
	Vector2(122.0, 2.0),
	Vector2(112.0, -48.0),
	Vector2(103.0, -56.0)
]
## The pool lies this share of the way from the feet past that middle (1 = the middle, the belly).
const GRID_CHEST_K: float = 1.1

## actor id -> Vector4(feet x, feet y, chest x, chest y) in world px.
static var all: Dictionary[int, Vector4] = {}


## Body `actor` stands (stood) at `feet` and lies as `plan` (a plan pose at `lying` x the standing
## card, or its own grid's lying row when `grid`), head along `head`.
static func publish(actor: int, feet: Vector2, plan: Sprite2D, head: Vector2, grid: bool) -> void:
	var reach: float = CHEST_K * StreetWalkerFall.STILL_PX * plan.global_scale.x
	var chest: Vector2 = plan.global_position + head * reach
	if grid:
		var mid: Vector2 = GRID_MID[clampi(plan.frame_coords.x, 0, GRID_MID.size() - 1)]
		mid.x *= -1.0 if plan.flip_h else 1.0
		chest = plan.global_transform * (mid * GRID_CHEST_K)
	if not all.has(actor) and all.size() >= MEMORY:
		@warning_ignore("return_value_discarded")
		all.erase(all.keys()[0])
	all[actor] = Vector4(feet.x, feet.y, chest.x, chest.y)


## Forgets every rest (a new city).
static func reset() -> void:
	all.clear()
