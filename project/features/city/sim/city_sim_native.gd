class_name CitySimNative
extends CitySimBackend
## Adapter over the native CitySim (GDExtension, native/binding). The class is looked up by name,
## never by type, so every script still compiles where the library is not built (the Linux CI
## jobs, a fresh clone): available() says whether it loaded. One call per frame (NAT-02).

const CLASS_NAME: StringName = &"CitySim"

var _o: Object = null


static func available() -> bool:
	return ClassDB.class_exists(CLASS_NAME) and ClassDB.can_instantiate(CLASS_NAME)


## The native backend when the library loaded, else the GDScript reference.
static func best() -> CitySimBackend:
	return CitySimNative.new() if available() else CitySimRef.new()


func _init() -> void:
	if available():
		_o = ClassDB.instantiate(CLASS_NAME)


func backend_name() -> StringName:
	return &"native" if _o != null else &"missing"


func init(seed_value: int) -> void:
	_call(&"init", [seed_value])


func set_radii(ra: float, rb: float, riot: float) -> void:
	_call(&"set_radii", [ra, rb, riot])


func stamp_chunk(cx: int, cy: int, tiles: PackedByteArray, cells: PackedByteArray) -> void:
	_call(&"stamp_chunk", [cx, cy, tiles, cells])


func clear_chunk(cx: int, cy: int) -> void:
	_call(&"clear_chunk", [cx, cy])


func cell_at(x: float, y: float) -> int:
	var c: Variant = _call(&"cell_at", [x, y])
	return c if c is int else 0


func tile_at(x: float, y: float) -> int:
	var t: Variant = _call(&"tile_at", [x, y])
	return t if t is int else 0


func spawn(spec: PackedFloat64Array) -> int:
	var slot: Variant = _call(&"spawn", [spec])
	return slot if slot is int else -1


func set_riot_centre(i: int, x: float, y: float) -> void:
	_call(&"set_riot_centre", [i, x, y])


func kill(i: int) -> void:
	_call(&"kill", [i])


func step(dt: float, camx: float, camy: float, tgx: float, tgy: float) -> void:
	_call(&"step", [dt, camx, camy, tgx, tgy])


func get_counters() -> PackedInt32Array:
	var c: Variant = _call(&"get_counters", [])
	return c if c is PackedInt32Array else PackedInt32Array()


func snapshot() -> PackedFloat64Array:
	var s: Variant = _call(&"snapshot", [])
	return s if s is PackedFloat64Array else PackedFloat64Array()


func set_render(mms: Array[RID], clips: PackedInt32Array) -> void:
	_call(&"set_render", [Array(mms), clips])


func write_render(vx0: float, vy0: float, vx1: float, vy1: float) -> void:
	_call(&"write_render", [vx0, vy0, vx1, vy1])


func get_render_counts() -> PackedInt32Array:
	var c: Variant = _call(&"get_render_counts", [])
	return c if c is PackedInt32Array else PackedInt32Array()


func flow_stats() -> PackedInt32Array:
	var s: Variant = _call(&"flow_stats", [])
	return s if s is PackedInt32Array else PackedInt32Array()


func flow_dist(x: float, y: float) -> int:
	var d: Variant = _call(&"flow_dist", [x, y])
	return d if d is int else -1


func _call(method: StringName, args: Array) -> Variant:
	return _o.callv(method, args) if _o != null else null
