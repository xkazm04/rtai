class_name PlayerScale
extends RefCounted
## n11 (the owner's "increase size of all player's characters to 150%"): the drawn size of Rivet and
## the ghost bodies, one data value (player_scale.json `k`; 1 = the before). Render only: hitboxes,
## collision and the sim's reach do not read it, so doors, alleys and determinism are unchanged.

const TABLE: String = "res://data/tables/player_scale.json"
const SCHEMA: String = "gtai.player-scale/1"

static var _k: float = -1.0


static func k() -> float:
	if _k < 0.0:
		var t: DataTable = DataTable.open(TABLE, SCHEMA)
		_k = t.num(t.raw, "k")
	return _k


## Scales the ghost bodies that draw at their own px per metre.
static func fit(bodies: Array[Node2D]) -> void:
	for body: Node2D in bodies:
		body.scale = Vector2.ONE * k()
