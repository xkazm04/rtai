extends GutTest
## FxPool.step reads each kind's constants from a FxKindRow (put once), not from the kind
## Dictionary every tick: what the MultiMesh shows must stay bit-identical to the Dictionary path
## (the reference below is the pre-row step, verbatim, over FxPool.custom_of). A headless
## MultiMesh keeps no data, so both sides are compared through FxPool.mirror.

const TICKS: int = 260
const CAP: int = 512

var _pool: FxPool = null
var _ref: FxPool = null
var _ref_kinds: Array[Dictionary] = []
var _want: PackedFloat32Array = PackedFloat32Array()
var _n: int = 0


func before_each() -> void:
	_pool = FxPool.new(CAP)
	_ref = FxPool.new(CAP)
	_n = 0
	@warning_ignore("return_value_discarded")
	_ref_kinds.resize(CAP)
	@warning_ignore("return_value_discarded")
	_pool.mirror.resize(CAP * FxPool.MIRROR_STRIDE)
	@warning_ignore("return_value_discarded")
	_want.resize(CAP * FxPool.MIRROR_STRIDE)


func test_row_step_writes_the_dictionary_paths_buffer_bit_for_bit() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	var kinds: Array[Dictionary] = []
	for id: StringName in fx.kinds:
		kinds.append(fx.kinds[id])
	assert_gt(kinds.size(), 5, "the real fx.json kinds")
	var mm: MultiMesh = _mm(CAP)
	var mm_ref: MultiMesh = _mm(CAP)
	var full_writes: int = 0
	for tick: int in TICKS:
		for j: int in 3:  # three spawns a tick, every kind, steps of 0 (a frame with no tick), 1, 2
			_spawn(kinds[(tick * 3 + j) % kinds.size()], tick)
		var steps: int = tick % 3
		_pool.step(steps, tick, mm)
		_ref_step(steps, tick, mm_ref)
		full_writes += _ref.alive
		assert_eq(_pool.alive, _ref.alive, "alive at tick %d" % tick)
		var n_live: int = _ref.alive * FxPool.MIRROR_STRIDE
		if _pool.mirror.slice(0, n_live) != _want.slice(0, n_live):
			fail_test("the shown instances differ at tick %d" % tick)
			return
	assert_gt(_pool.alive, 50, "a full pool exercised")
	pass_test("bit-identical over %d ticks, %d instance writes" % [TICKS, full_writes])


## One spawn of `k` into both pools, moved as FxSystem.spawn does (a splat, 0 m/s, lies still).
func _spawn(k: Dictionary, tick: int) -> void:
	var count: int = k["count"]
	var speed: float = k["speed_mps"]
	for c: int in count:
		_n += 1
		if _pool.alive >= CAP - 1:
			return
		var at: Transform2D = Transform2D(0.37 * _n, Vector2(_n % 97, _n % 53) * 7.0)
		var v: Vector2 = (
			Vector2.from_angle(0.11 * _n) * speed * FxPool.PX_PER_M * (0.6 + _n % 5 * 0.1)
		)
		var s: float = fmod(_n * 0.6180339, 1.0)
		_ref_kinds[_ref.alive] = k
		_pool.put(k, at, v, tick, s)
		_ref.put(k, at, v, tick, s)


## The pre-row FxPool.step (6342fcd0), verbatim, over its own kind list; shows into _want.
func _ref_step(steps: int, tick: int, mm: MultiMesh) -> void:
	var p: FxPool = _ref
	var ks: Array[Dictionary] = _ref_kinds
	var i: int = 0
	while i < p.alive:
		var k: Dictionary = ks[i]
		var life: float = k["life_ticks"]
		var age: int = tick - p.born[i]
		if age >= int(life):
			ks[i] = ks[p.alive - 1]
			p._swap_out(i)
			continue
		var drag: float = k["drag"]
		for s: int in steps:
			p.pos[i] += p.vel[i] * SimClock.TICK_DT
			p.vel[i] *= maxf(0.0, 1.0 - drag * SimClock.TICK_DT)
		var size_m: float = k["size_m"]
		var grow: float = k["grow"]
		var size: float = size_m * FxPool.PX_PER_M * (1.0 + grow * age * SimClock.TICK_DT) * 0.5
		var col: Color = k["color"]
		var fade_from: float = k.get("fade_from", 0.0)
		col.a = clampf((1.0 - float(age) / life) / (1.0 - fade_from), 0.0, 1.0)
		mm.set_instance_transform_2d(i, Transform2D(p.rot[i], Vector2.ONE * size, 0.0, p.pos[i]))
		mm.set_instance_color(i, col)
		mm.set_instance_custom_data(i, FxPool.custom_of(k, age, p.seed_of[i]))
		var xf: Transform2D = Transform2D(p.rot[i], Vector2.ONE * size, 0.0, p.pos[i])
		FxPool.mirror_write(_want, i, xf, col, FxPool.custom_of(k, age, p.seed_of[i]))
		i += 1
	mm.visible_instance_count = p.alive


func _mm(cap: int) -> MultiMesh:
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.instance_count = cap
	return mm
