extends GutTest


class OneCell:
	extends StageCells

	func _init() -> void:
		super(null)

	func solid(x: int, y: int) -> bool:
		return x == 2 and y == 1


func test_crowding_counts_each_neighbour_including_the_one_metre_boundary() -> void:
	var positions: Array[Vector2] = [Vector2.ZERO, Vector2.RIGHT, Vector2(1, 1)]
	var counts: PackedInt32Array = FightProbeGeometry.neighbours(positions)
	assert_eq(counts, PackedInt32Array([1, 2, 1]))
	positions[2] = Vector2(1, 1.01)
	assert_eq(FightProbeGeometry.neighbours(positions), PackedInt32Array([1, 1, 0]))


func test_cover_requires_occlusion_and_euclidean_proximity_to_a_box_or_cell() -> void:
	var boxes: Array[Rect2] = [Rect2(2, 1, 1, 1)]
	var empty: Array[Rect2] = []
	var close: Vector2 = Vector2(0.5, 1)
	assert_true(FightProbeGeometry.in_cover(close, false, boxes, null))
	assert_false(FightProbeGeometry.in_cover(close, true, boxes, null))
	assert_false(FightProbeGeometry.in_cover(Vector2(0.5, 0.5), false, boxes, null))
	assert_true(FightProbeGeometry.in_cover(close, false, empty, OneCell.new()))
	assert_false(FightProbeGeometry.in_cover(Vector2.ZERO, false, empty, OneCell.new()))


func test_flank_uses_circular_mean_and_strict_sixty_degrees() -> void:
	var p: Array[Vector2] = [
		Vector2.RIGHT.rotated(deg_to_rad(179)) * 10, Vector2.RIGHT.rotated(deg_to_rad(-179))
	]
	var mean_dir: Vector2 = FightProbeGeometry.mean_bearing(Vector2.ZERO, p)
	assert_true(mean_dir.is_equal_approx(Vector2.LEFT))
	assert_false(FightProbeGeometry.flanking(mean_dir.rotated(PI / 3), mean_dir))
	assert_true(FightProbeGeometry.flanking(mean_dir.rotated(deg_to_rad(61)), mean_dir))
	assert_false(FightProbeGeometry.flanking(Vector2.RIGHT, Vector2.ZERO))


func test_observed_and_plain_fights_match_including_immediate_hits() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var plain: CombatArena = _fight(bus)
	var original: CombatArena = _fight(bus)
	var seen: Array[int] = [0]
	@warning_ignore("return_value_discarded")
	original.struck.connect(
		func(_v: Fighter, _dir: Vector2, _lethal: bool, _w: StringName) -> void: seen[0] += 1
	)
	var measured: FightProbeArena = FightProbeArena.attach(original)
	measured.squad = measured.hostiles
	for tick: int in 180:
		plain.step(tick)
		measured.step(tick)
	var expected: StreamPeerBuffer = StreamPeerBuffer.new()
	var actual: StreamPeerBuffer = StreamPeerBuffer.new()
	plain.write_state(expected)
	measured.write_state(actual)
	assert_eq(actual.data_array, expected.data_array)
	assert_gt(measured.rounds, 0)
	assert_gt(measured.hits, 0)
	assert_eq(measured.hits, seen[0])
	assert_eq(measured.costs.size(), 180)


func test_digest_catches_a_planted_position_change_even_on_a_dead_hostile() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var a: FightProbeArena = FightProbeArena.attach(_fight(bus))
	a.hostiles[0].hp = 0.0
	var good: FightProbeSample = FightProbeSample.new(a)
	var planted: FightProbeSample = FightProbeSample.new(a)
	good.digest_tick()
	planted.digest_tick()
	a.tick += 1
	good.digest_tick()
	a.hostiles[0].pos.x += 0.001
	planted.digest_tick()
	assert_ne(good.hash_ctx.finish(), planted.hash_ctx.finish())


func _fight(bus: EventBus) -> CombatArena:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), bus, RngRegistry.new(7).stream(&"combat")
	)
	var guard: Fighter = arena.spawn_guard(Vector2.ZERO)
	guard.pos = Vector2(0.1, 0)
	return arena
