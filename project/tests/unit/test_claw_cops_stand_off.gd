extends GutTest


func _cops(at: PackedVector2Array) -> Array[Fighter]:
	var out: Array[Fighter] = []
	for i: int in at.size():
		out.append(Fighter.make(Fighter.Kind.GUARD, 3000 + i, at[i], 1.0))
	return out


func test_cops_on_rivet_are_pushed_to_the_ring() -> void:
	var me: Vector2 = Vector2(5, 5)
	var fs: Array[Fighter] = _cops(
		PackedVector2Array(
			[me + Vector2(0.3, 0), me + Vector2(0.2, 0.1), me, me + Vector2(0, -0.4)]
		)
	)
	ArenaClawCops.stand_off(fs, me, ArenaClawCops.STANDOFF_M, ArenaClawCops.SPACING_M)
	for f: Fighter in fs:
		assert_almost_eq(f.pos.distance_to(me), ArenaClawCops.STANDOFF_M, 0.001)


func test_the_ring_is_inside_the_claw_reach() -> void:
	assert_lt(ArenaClawCops.STANDOFF_M, 1.4, "the claw (reach 1.4 m) must still land")


func test_far_cops_and_the_dead_are_left_alone() -> void:
	var me: Vector2 = Vector2.ZERO
	var fs: Array[Fighter] = _cops(PackedVector2Array([Vector2(4, 0), Vector2(0.2, 0)]))
	fs[1].hp = 0.0
	ArenaClawCops.stand_off(fs, me, ArenaClawCops.STANDOFF_M, ArenaClawCops.SPACING_M)
	assert_eq(fs[0].pos, Vector2(4, 0))
	assert_eq(fs[1].pos, Vector2(0.2, 0), "a dead cop lies where he fell")


func test_planted_fault_no_ring_leaves_the_pile_up() -> void:
	var me: Vector2 = Vector2.ZERO
	var fs: Array[Fighter] = _cops(PackedVector2Array([Vector2(0.3, 0), Vector2(0.3, 0.05)]))
	ArenaClawCops.stand_off(fs, me, 0.0, 0.0)
	assert_lt(fs[0].pos.distance_to(me), ArenaClawCops.STANDOFF_M, "ring 0 = the old pile-up")
