class_name CityPatrol
extends RefCounted
## n18 living police: the streamed city's foot patrol. The spawner's street targets keep no foot
## cops (they came only with a riot), so the heat ladder would have nobody to send. This keeps the
## heat table's city.patrol_cops cops on sidewalk cells of the bubble (one try a tick, a fill on
## the first), on headings along the axes, from its own RNG stream (replay-safe). Cops leave the
## bubble like every actor (the sim's tier pass) and are replaced at the ring.

const STREAM: StringName = &"city_patrol"
const ART_COP: int = 7
const DX: Array[float] = [1.0, 0.0, -1.0, 0.0]
const DY: Array[float] = [0.0, 1.0, 0.0, -1.0]
## The ring new patrol cops appear in (the fill starts at FILL_R0), m from the bubble centre.
const R0: float = 50.0
const R1: float = 140.0
const FILL_R0: float = 10.0
const FILL_TRIES: int = 2000

## Foot cops kept in the bubble (all of them count, a riot's too).
var want: int = 0
var _rng: RandomNumberGenerator
var _filled: bool = false


func _init(rng: RandomNumberGenerator, p_want: int) -> void:
	_rng = rng
	want = p_want


## One tick: a try at the ring (the whole bubble and many tries on the first call).
## Returns the cops spawned.
func tick(sim: CitySimBackend, cam: Vector2) -> int:
	if want <= 0:
		return 0
	var tries: int = 1 if _filled else FILL_TRIES
	var r0: float = R0 if _filled else FILL_R0
	_filled = true
	var made: int = 0
	var have: int = sim.get_counters()[SimConst.CN_COPS]
	for k: int in tries:
		if have + made >= want:
			break
		if _try(sim, cam, r0):
			made += 1
	return made


func _try(sim: CitySimBackend, cam: Vector2, r0: float) -> bool:
	var a: float = _rng.randf() * TAU
	var r: float = lerpf(r0, R1, _rng.randf())
	var x: float = cam.x + cos(a) * r
	var y: float = cam.y + sin(a) * r
	var d: int = _rng.randi_range(0, 3)
	if sim.cell_at(x, y) != SimConst.C_WALK:
		return false
	var spec: Array = [SimConst.K_COP, x, y, DX[d], DY[d], ART_COP, 0, 3.4, 0.0, 0]
	return sim.spawn(PackedFloat64Array(spec)) >= 0
