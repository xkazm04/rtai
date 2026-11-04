extends GutTest
## Lane brutality, showcase REQUEST 26: the ray gun's cap is knocked off the dust heap to one side
## of the shot (hat_kick_mps), so the remains no longer read as one round token; the rocket's hat
## (no kick) is thrown as before.


func _kills() -> SignatureKills:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	table.gore_full = SignatureKillTable.gore_from_args("full")
	return SignatureKills.new(table, RngRegistry.new(11).stream(&"brutality"))


func _hat_at_rest(weapon: StringName) -> Vector2:
	var k: SignatureKills = _kills()
	var e: KillEvent = KillEvent.make(1, Vector2.ZERO, Vector2.RIGHT, weapon)
	e.human = true
	assert_true(k.on_kill(e), "%s takes its signature kill" % weapon)
	for t: int in 600:
		k.step(t)
	for i: int in GibSim.CAPACITY:
		if k.gibs.kill_of[i] >= 0 and k.gibs.piece[i] == SignatureKill.HAT:
			return k.gibs.pos[i]
	return Vector2.INF


func test_the_ray_gun_row_kicks_the_cap() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"ray_gun")
	assert_gt(row.hat_kick_mps, 0.0)


func test_the_ray_cap_lands_off_the_heap_to_one_side() -> void:
	var hat: Vector2 = _hat_at_rest(&"ray_gun")
	assert_ne(hat, Vector2.INF, "the cap is thrown")
	assert_gt(absf(hat.y), 0.3, "off to one side of the shot line (the heap is 0.26 m wide)")
	assert_lt(hat.length(), 2.0, "knocked off, not blown away")
