extends GutTest

# The split view owns rig and world dependencies. Resolve it in the initialized GUT project.
var plasma: GDScript


func before_all() -> void:
	plasma = load("res://features/combat/kills/kill_plasma_art.gd")


func _drop(index: int, line: Vector2, seed_angle: float) -> Vector3:
	return plasma.call(&"drop", index, line, seed_angle)


func _heat(age: int) -> float:
	return plasma.call(&"heat", age)


func test_drops_follow_a_repeatable_rotated_fan() -> void:
	var line: Vector2 = Vector2.from_angle(1.2)
	var left: float = 0.0
	var right: float = 0.0
	for seed_angle: float in [-2.5, 0.0, 1.75]:
		for index: int in 19:
			var sample: Vector3 = _drop(index, line, seed_angle)
			var offset: Vector2 = Vector2(sample.x, sample.y)
			var turn: float = line.angle_to(offset)
			assert_eq(sample, _drop(index, line, seed_angle))
			assert_between(turn, -0.700001, 0.700001)
			assert_between(offset.length(), 0.329999, 2.010001)
			assert_between(sample.z, 0.044999, 0.130001)
			var base: Vector3 = _drop(index, Vector2.RIGHT, seed_angle)
			assert_true(offset.is_equal_approx(Vector2(base.x, base.y).rotated(line.angle())))
			assert_almost_eq(sample.z, base.z, 0.000001)
			left = minf(left, turn)
			right = maxf(right, turn)
	assert_lt(left, -0.68)
	assert_gt(right, 0.68)
	assert_true(_drop(0, Vector2.RIGHT, 0.0).is_equal_approx(Vector3(0.33, 0, 0.13)))
	assert_ne(_drop(3, line, 0.0), _drop(3, line, 1.75))


func test_ground_print_keeps_the_pattern_and_clips_at_the_world_wall() -> void:
	var mark: KillMarks.Mark = KillMarks.Mark.new()
	mark.at = Vector2(7, -3)
	mark.dir = Vector2.DOWN
	mark.drops = PackedVector3Array([Vector3(2, 3, 0.1)])
	var free: KillMarks.Mark = plasma.call(&"ground_print", mark, Callable())
	var wall_y: float = mark.at.y + 0.42
	var push_out: Callable = func(p: Vector2) -> Vector2: return Vector2(p.x, minf(wall_y, p.y))
	var clipped: KillMarks.Mark = plasma.call(&"ground_print", mark, push_out)
	assert_eq(free.at, mark.at)
	assert_eq(clipped.dir, mark.dir)
	assert_almost_eq(clipped.blot_m, 0.51, 0.000001)
	assert_eq(free.drops.size(), 19)
	assert_eq(clipped.drops.size(), free.drops.size())
	var blocked: int = 0
	var untouched: int = 0
	for i: int in free.drops.size():
		var d: Vector3 = free.drops[i]
		var c: Vector3 = clipped.drops[i]
		assert_eq(d, _drop(i, mark.dir, mark.at.x + mark.at.y))
		assert_eq(c.z, d.z)
		assert_lte(mark.at.y + c.y, wall_y + KillMarks.WALL_STEP_M)
		if mark.at.y + d.y > wall_y + KillMarks.WALL_STEP_M:
			var end: Vector2 = Vector2(c.x, c.y)
			assert_true(end.normalized().is_equal_approx(Vector2(d.x, d.y).normalized()))
			assert_lte(mark.at.y + c.y, wall_y)
			assert_gt(mark.at.y + c.y + KillMarks.WALL_STEP_M, wall_y)
			blocked += 1
		elif mark.at.y + d.y <= wall_y:
			assert_eq(c, d)
			untouched += 1
	assert_gt(blocked, 0)
	assert_gt(untouched, 0)
	assert_eq(mark.drops, PackedVector3Array([Vector3(2, 3, 0.1)]))


func test_edge_heat_is_clamped_and_cools_linearly_on_ticks() -> void:
	assert_eq(_heat(-1), 1.0)
	for tick: int in 41:
		assert_almost_eq(_heat(tick), (40 - tick) / 40.0, 0.000001)
	assert_eq(_heat(41), 0.0)


func test_attach_collects_only_direct_edges_of_the_two_halves() -> void:
	var parent: Node2D = _parent()
	var parts: Array[Node2D] = []
	@warning_ignore("return_value_discarded")
	parts.resize(SignatureKill.PIECE_IDS.size())
	var expected: Array[KillCutEdge] = []
	for i: int in [SignatureKill.BODY, SignatureKill.HALF_A, SignatureKill.HALF_B]:
		parts[i] = Node2D.new()
		parent.add_child(parts[i])
		var edge: KillCutEdge = KillCutEdge.new()
		parts[i].add_child(edge)
		edge.add_child(KillCutEdge.new())
		if i != SignatureKill.BODY:
			expected.append(edge)
	var at: Vector2 = Vector2(2, -3)
	var dir: Vector2 = Vector2.from_angle(0.75)
	plasma.call(&"attach", parent, parts, at, dir, 0.6)
	var art: Node = parent.get_child(-1)
	var actual: Script = art.get_script()
	assert_eq(actual, plasma)
	if actual != plasma:
		return
	var edges: Array[KillCutEdge] = art.get(&"edges")
	assert_eq(edges, expected)
	assert_eq((art as Node2D).position, at * 64.0)
	var clock: RefCounted = parent.get(&"kills")
	clock.set(&"tick", 83)
	art.call(&"_process", 0.0)
	for edge: KillCutEdge in expected:
		assert_eq(edge.heat, 0.75)
	assert_eq((parts[SignatureKill.BODY].get_child(0) as KillCutEdge).heat, 1.0)


func test_attach_accepts_a_missing_half() -> void:
	var parent: Node2D = _parent()
	var parts: Array[Node2D] = []
	@warning_ignore("return_value_discarded")
	parts.resize(SignatureKill.PIECE_IDS.size())
	parts[SignatureKill.HALF_B] = Node2D.new()
	parent.add_child(parts[SignatureKill.HALF_B])
	var edge: KillCutEdge = KillCutEdge.new()
	parts[SignatureKill.HALF_B].add_child(edge)
	plasma.call(&"attach", parent, parts, Vector2.ZERO, Vector2.UP, 0.0)
	var art: Node = parent.get_child(-1)
	var actual: Script = art.get_script()
	assert_eq(actual, plasma)
	if actual == plasma:
		var edges: Array[KillCutEdge] = art.get(&"edges")
		assert_eq(edges.size(), 1)
		assert_eq(edges[0], edge)


func _parent() -> Node2D:
	var split: GDScript = load("res://features/combat/kills/kill_split_fx.gd")
	var timeline: GDScript = load("res://features/combat/kills/signature_kills.gd")
	var root: Node2D = split.new()
	var parent: Node2D = autofree(root)
	var clock: RefCounted = timeline.new(SignatureKillTable.new(), null)
	clock.set(&"tick", 73)
	parent.set(&"ppm", 64.0)
	parent.set(&"kills", clock)
	return parent
