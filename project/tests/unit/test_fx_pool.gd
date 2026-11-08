extends GutTest
## FxPool.step reads each kind's constants from a FxKindRow (put once), not from the kind
## Dictionary every tick: the MultiMesh it writes must stay bit-identical to the Dictionary path
## (the reference below is the pre-row step, verbatim, over FxPool.custom_of).

const TICKS: int = 260


func test_row_step_writes_the_dictionary_paths_buffer_bit_for_bit() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	var kinds: Array[Dictionary] = []
	for id: StringName in fx.kinds:
		kinds.append(fx.kinds[id])
	assert_gt(kinds.size(), 5, "the real fx.json kinds")
	var pool: FxPool = FxPool.new(512)
	var ref: FxPool = FxPool.new(512)
	var ref_kinds: Array[Dictionary] = []
	@warning_ignore("return_value_discarded")
	ref_kinds.resize(512)
	var mm: MultiMesh = _mm(512)
	var mm_ref: MultiMesh = _mm(512)
	var n: int = 0
	for tick: int in TICKS:
		for j: int in 3:  # three spawns a tick, every kind, steps of 1 and 2 ticks
			var k: Dictionary = kinds[(tick * 3 + j) % kinds.size()]
			var count: int = k["count"]
			for c: int in count:
				n += 1
				if pool.alive >= 511:
					break
				var at: Transform2D = Transform2D(0.37 * n, Vector2(n % 97, n % 53) * 7.0)
				var v: Vector2 = Vector2.from_angle(0.11 * n) * (40.0 + n % 13)
				var s: float = fmod(n * 0.6180339, 1.0)
				ref_kinds[ref.alive] = k
				pool.put(k, at, v, tick, s)
				ref.put(k, at, v, tick, s)
		var steps: int = 1 + tick % 2
		pool.step(steps, tick, mm)
		_ref_step(ref, ref_kinds, steps, tick, mm_ref)
		assert_eq(pool.alive, ref.alive, "alive at tick %d" % tick)
		if mm.buffer != mm_ref.buffer:
			fail_test("buffer differs at tick %d" % tick)
			return
	assert_gt(pool.alive, 50, "a full pool exercised")
	pass_test("bit-identical over %d ticks" % TICKS)


## The pre-row FxPool.step (6342fcd0), verbatim, over its own kind list.
func _ref_step(p: FxPool, ks: Array[Dictionary], steps: int, tick: int, mm: MultiMesh) -> void:
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
		i += 1
	mm.visible_instance_count = p.alive


func _mm(cap: int) -> MultiMesh:
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.instance_count = cap
	return mm
