extends GutTest
## FightAreasArt thins a fire patch's flames over a fresh corpse (showcase REQUEST 27).


func test_no_clear_right_after_the_kill() -> void:
	var dead: Array[Vector3] = [Vector3(0.0, 0.0, 0.0)]
	assert_eq(FightAreasArt.clear(Vector2.ZERO, dead), 0.0)


func test_full_clear_on_the_corpse_and_none_out_of_reach() -> void:
	var dead: Array[Vector3] = [Vector3(1.0, 1.0, 1.0)]
	assert_almost_eq(FightAreasArt.clear(Vector2(1.0, 1.0), dead), 1.0, 0.001)
	var far: Vector2 = Vector2(1.0 + FightAreasArt.CLEAR_M + 0.1, 1.0)
	assert_eq(FightAreasArt.clear(far, dead), 0.0)


func test_clear_falls_off_with_distance() -> void:
	var dead: Array[Vector3] = [Vector3(0.0, 0.0, 1.0)]
	var near: float = FightAreasArt.clear(Vector2(0.4, 0.0), dead)
	var mid: float = FightAreasArt.clear(Vector2(1.0, 0.0), dead)
	assert_gt(near, mid)
	assert_gt(mid, 0.0)


func test_corpses_ramp_after_the_kill() -> void:
	var hostiles: Array[Fighter] = []
	var g: Fighter = Fighter.new()
	g.pos = Vector2(2.0, 3.0)
	g.hp = 0.0
	g.hurt_tick = 100
	hostiles.append(g)
	assert_eq(FightAreasArt.corpses(hostiles, 100 + FightAreasArt.CLEAR_AFTER).size(), 0)
	var mid: int = 100 + FightAreasArt.CLEAR_AFTER + FightAreasArt.CLEAR_RAMP / 2
	var half: Array[Vector3] = FightAreasArt.corpses(hostiles, mid)
	assert_eq(half.size(), 1)
	assert_almost_eq(half[0].z, 0.5, 0.001)
	var late: Array[Vector3] = FightAreasArt.corpses(hostiles, 100 + 600)
	assert_almost_eq(late[0].z, 1.0, 0.001)
	assert_eq(Vector2(late[0].x, late[0].y), g.pos)


func test_away_points_off_the_strongest_corpse() -> void:
	var dead: Array[Vector3] = [Vector3(0.0, 0.0, 1.0), Vector3(5.0, 0.0, 1.0)]
	var push: Vector2 = FightAreasArt.away(Vector2(0.5, 0.0), dead)
	assert_almost_eq(push.x, 1.0, 0.001)
	assert_eq(FightAreasArt.away(Vector2(20.0, 0.0), dead), Vector2.ZERO)


func test_burn_flames_trail_behind_the_run_off_the_body() -> void:
	var pos: Vector2 = Vector2(3.0, 4.0)
	var flames: PackedVector2Array = FightAreasArt.burn_flames(pos, Vector2(2.0, 0.0))
	assert_eq(flames.size(), FightAreasArt.BURN_FLAMES)
	for f: Vector2 in flames:
		assert_lt(f.x, pos.x, "every flame trails behind a human running +x")
		assert_gt(f.distance_to(pos), FightAreasArt.BURN_BACK_M - 0.001, "no flame on the body")
	var still: PackedVector2Array = FightAreasArt.burn_flames(pos, Vector2.ZERO)
	assert_gt(still[1].y, pos.y, "a standing burner trails his flames down-screen")
