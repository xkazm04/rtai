class_name VehicleFront
extends RefCounted
## n8 vehicles: who stands in front of a car card (render only). The cars draw in the vehicles
## band, over the actors: right for a body behind a car under a tilt (the card covers it), wrong
## for one just south of it (nearer the camera), whose body the card would paint over. Each frame
## the view hands in the people's ground points (the bubble's people and Rivet); a card with a
## living body inside its front box (south of the car's centre by less than FRONT_M, across by
## less than HALF_M) drops under the actors (VehicleCards' under layer). A card with bodies both
## behind and in front goes under too: the nearer body wins. Bucketed on a CELL_M grid.

const FRONT_M: float = 3.2
const HALF_M: float = 2.6
const CELL_M: float = 4.0
## The people query's radius around the player (m): about the camera's view at 32 px/m.
const NEAR_M: float = 48.0

## Dev films only (the "before"): no card ever drops under the actors.
static var off: bool = false

## grid cell -> the ground points in it.
var _cells: Dictionary[Vector2i, PackedVector2Array] = {}


func clear() -> void:
	_cells.clear()


func add(p: Vector2) -> void:
	var k: Vector2i = Vector2i((p / CELL_M).floor())
	var pts: PackedVector2Array = _cells.get(k, PackedVector2Array())
	@warning_ignore("return_value_discarded")
	pts.append(p)
	_cells[k] = pts


## Every living person of a people_near() record list (VehicleWorld.PERSON_STRIDE).
func add_people(recs: PackedFloat64Array) -> void:
	for r: int in range(0, recs.size(), VehicleWorld.PERSON_STRIDE):
		if recs[r + 3] < 0.5:
			add(Vector2(recs[r + 1], recs[r + 2]))


## True when someone stands in front of a car at ground point `at` (m).
func blocks(at: Vector2) -> bool:
	if off or _cells.is_empty():
		return false
	var lo: Vector2i = Vector2i(((at - Vector2(HALF_M, 0.0)) / CELL_M).floor())
	var hi: Vector2i = Vector2i(((at + Vector2(HALF_M, FRONT_M)) / CELL_M).floor())
	for y: int in range(lo.y, hi.y + 1):
		for x: int in range(lo.x, hi.x + 1):
			for p: Vector2 in _cells.get(Vector2i(x, y), PackedVector2Array()):
				var d: Vector2 = p - at
				if d.y > 0.0 and d.y < FRONT_M and absf(d.x) < HALF_M:
					return true
	return false
