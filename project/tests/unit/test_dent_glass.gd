extends GutTest


func test_six_shards_at_rest_ten_at_speed_and_two_ticks_of_white() -> void:
	var flight: GhostFlight = GhostFlight.make(&"dent")
	add_child_autofree(flight)
	var body: Node2D = Node2D.new()
	flight.mount(body)
	var glass: DentGlass = DentGlass.new()
	flight.tail.add_child(glass)
	for tick: int in 3:
		flight.step(Vector2.ZERO, 0.0, 1)
		glass.sync(flight, body.position + flight.body_offset(), 0.0, tick)
		assert_eq(glass._vertices.size(), 6 * 8)
		glass._shard(0)
		assert_eq(glass._colours[4] == Color.WHITE, tick < 2)
	var end: Vector2 = Vector2.RIGHT * 7.0 * SimConst.PX_PER_M * SimClock.TICK_DT
	flight.step(end, 0.0, 1)
	glass.sync(flight, end + flight.body_offset(), 0.0, 3)
	assert_eq(glass._vertices.size(), 10 * 8)
	glass._shard(0)
	var held: PackedVector2Array = glass._vertices.duplicate()
	glass.sync(flight, end + flight.body_offset(), 0.0, 3)
	glass._shard(0)
	assert_eq(glass._vertices, held)
