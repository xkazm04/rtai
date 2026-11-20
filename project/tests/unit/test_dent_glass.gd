extends GutTest


func test_six_shards_at_rest_ten_at_speed_and_two_ticks_of_white() -> void:
	var flight: GhostFlight = GhostFlight.make(&"dent")
	add_child_autofree(flight)
	var body: Node2D = Node2D.new()
	flight.mount(body)
	var glass: DentGlass = DentGlass.new()
	flight.tail.add_child(glass)
	glass.position = Vector2(2, 3)
	for tick: int in 3:
		flight.step(Vector2.ZERO, 0.0, 1)
		glass.sync(flight, tick)
		assert_eq(glass._vertices.size(), 6 * 8)
		glass._shard(0)
		assert_eq(glass._colours[4] == Color.WHITE, tick < 2)
	var end: Vector2 = Vector2.RIGHT * 7.0 * SimConst.PX_PER_M * SimClock.TICK_DT
	flight.step(end, 0.0, 1)
	glass.sync(flight, 3)
	assert_eq(glass._vertices.size(), 10 * 8)
	var ribbon: PackedVector2Array = flight.tail.points()
	for i: int in ribbon.size():
		assert_almost_eq(glass.to_global(glass._points[i]), ribbon[i], Vector2.ONE * 0.001)
	glass._shard(0)
	var held: PackedVector2Array = glass._vertices.duplicate()
	glass.sync(flight, 3)
	glass._shard(0)
	assert_eq(glass._vertices, held)
