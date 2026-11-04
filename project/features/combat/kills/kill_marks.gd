class_name KillMarks
extends RefCounted
## What a signature kill leaves on the street (lane brutality): a scorch ring and a fan of red
## spray drops thrown along the blast, rolled once from the kill's RNG stream so the same seed
## leaves the same marks. A ring of `budget` marks: the oldest is recycled, like corpse stains.


class Mark:
	extends RefCounted
	var at: Vector2 = Vector2.ZERO
	var dir: Vector2 = Vector2.RIGHT
	var scorch_m: float = 0.0
	## Spray drops: x, y in metres from `at`; z = drop radius in metres.
	var drops: PackedVector3Array = PackedVector3Array()
	var tick: int = 0


var budget: int = 12
var marks: Array[Mark] = []
var serial: int = 0


func _init(p_budget: int = 12) -> void:
	budget = maxi(1, p_budget)


## Leaves `row`'s scorch and spray at `at`, the spray fanned along `dir` (unit).
func leave(
	row: SignatureKill, at: Vector2, dir: Vector2, tick: int, rng: RandomNumberGenerator
) -> Mark:
	var m: Mark = Mark.new()
	m.at = at
	m.dir = dir
	m.scorch_m = row.scorch_radius_m
	m.tick = tick
	var half: float = deg_to_rad(row.cone_deg) * 0.5
	for n: int in row.spray:
		var a: float = dir.angle() + rng.randf_range(-half, half)
		var reach: float = rng.randf_range(0.4, 3.6)
		var r: float = rng.randf_range(0.05, 0.22) * (1.2 - reach / 4.0)
		var v: Vector2 = Vector2.from_angle(a) * reach
		@warning_ignore("return_value_discarded")
		m.drops.append(Vector3(v.x, v.y, r))
	if marks.size() >= budget:
		marks.pop_front()
	@warning_ignore("return_value_discarded")
	marks.append(m)
	serial += 1
	return m


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(serial)
	for m: Mark in marks:
		out.put_double(m.at.x)
		out.put_double(m.at.y)
		out.put_32(m.drops.size())
