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
	## The ink flash: cream ticks (then a soot tick or two after a blast) and its size.
	var flash_ticks: int = 0
	var flash_scale: float = 1.0
	## Spray drops: x, y in metres from `at`; z = drop radius in metres.
	var drops: PackedVector3Array = PackedVector3Array()
	var tick: int = 0
	## The burn char's ash heap (metres; 0 = none), grown in from tick + ash_from.
	var ash_m: float = 0.0
	var ash_from: int = 0
	## Ticks after the kill before the spray prints (a burst sprays at the pop, not the hit).
	var spray_from: int = 0


const WALL_STEP_M: float = 0.15

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
	m.flash_ticks = row.flash_ticks
	m.flash_scale = 1.0 if row.style == &"gib" else 0.55  # the big star and soot: blasts only
	m.tick = tick
	m.ash_m = row.ash_m
	m.ash_from = row.hitstop_ticks + row.stand_ticks
	m.spray_from = row.hitstop_ticks + row.grind_ticks if row.style == &"burst" else 0
	var cone: float = row.spray_cone_deg if row.spray_cone_deg > 0.0 else row.cone_deg
	var half: float = deg_to_rad(cone) * 0.5
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


## Stops each spray drop at the first wall along its throw (showcase REQUEST 13: blood crossed
## the pit wall onto the paper margin): the ray from the kill is walked in WALL_STEP_M steps and
## a drop lands on the last free step. `push_out` is the stage's (metres in, metres out).
static func clip(m: Mark, push_out: Callable) -> void:
	for n: int in m.drops.size():
		var d: Vector3 = m.drops[n]
		var v: Vector2 = Vector2(d.x, d.y)
		var reach: float = v.length()
		var free: float = 0.0
		while free + WALL_STEP_M <= reach:
			var p: Vector2 = m.at + v * ((free + WALL_STEP_M) / reach)
			if push_out.call(p) != p:
				break
			free += WALL_STEP_M
		if free + WALL_STEP_M <= reach:
			var w: Vector2 = v * (free / reach) if reach > 0.0 else v
			m.drops[n] = Vector3(w.x, w.y, d.z)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(serial)
	for m: Mark in marks:
		out.put_double(m.at.x)
		out.put_double(m.at.y)
		out.put_32(m.drops.size())
