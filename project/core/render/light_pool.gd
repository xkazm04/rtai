class_name LightPool
extends RefCounted
## The fixed light slots behind LightLayer: a budget of `cap` lights, no allocation after init.
## When full, a timed light (a muzzle flash, a blast) evicts the oldest timed one; a held light
## (headlight, siren, fire) is refused instead of evicting anything.

## World px per metre (the city scale; core cannot reach features/city for SimConst).
const PX_PER_M: float = 32.0

var kind: Array[StringName] = []
var xf: Array[Transform2D] = []
var born: PackedInt32Array = PackedInt32Array()
var life: PackedInt32Array = PackedInt32Array()
var used: PackedByteArray = PackedByteArray()


func _init(cap: int) -> void:
	@warning_ignore("return_value_discarded")
	kind.resize(cap)
	@warning_ignore("return_value_discarded")
	xf.resize(cap)
	@warning_ignore("return_value_discarded")
	born.resize(cap)
	@warning_ignore("return_value_discarded")
	life.resize(cap)
	@warning_ignore("return_value_discarded")
	used.resize(cap)


func take(timed: bool) -> int:
	var oldest: int = -1
	for i: int in used.size():
		if used[i] == 0:
			return i
		if timed and life[i] > 0 and (oldest < 0 or born[i] < born[oldest]):
			oldest = i
	return oldest


func set_light(h: int, k: StringName, at: Transform2D, tick: int, ticks: int) -> void:
	kind[h] = k
	xf[h] = at
	born[h] = tick
	life[h] = ticks
	used[h] = 1


func free_light(h: int) -> void:
	if h >= 0 and h < used.size():
		used[h] = 0


func move(h: int, at: Transform2D) -> void:
	if h >= 0 and h < used.size() and used[h] == 1:
		xf[h] = at


## Expires timed lights, writes the live ones into `mm`; returns how many are drawn.
func write(mm: MultiMesh, kinds: Dictionary[StringName, Dictionary], tick: int) -> int:
	var n: int = 0
	for i: int in used.size():
		if used[i] == 0:
			continue
		var age: int = tick - born[i]
		if life[i] > 0 and age >= life[i]:
			used[i] = 0
			continue
		var k: Dictionary = kinds[kind[i]]
		var fade: float = 1.0 - float(age) / float(life[i]) if life[i] > 0 else 1.0
		var hz: float = k["flicker_hz"]
		var alt: bool = hz > 0.0 and floori(age * SimClock.TICK_DT * hz * 2.0) % 2 == 1
		var col: Color = k["alt_color"] if alt else k["color"]
		var radius: float = k["radius_m"]
		var strength: float = k["intensity"]
		var steps: float = k["steps"]
		var cone: float = k["cone_deg"]
		col.a = strength * fade
		mm.set_instance_transform_2d(n, xf[i].scaled_local(Vector2.ONE * radius * PX_PER_M))
		mm.set_instance_color(n, col)
		mm.set_instance_custom_data(n, Color(steps, deg_to_rad(cone), 0.0, 0.0))
		n += 1
	mm.visible_instance_count = n
	return n
