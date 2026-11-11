extends GutTest
## n17 npc-react: a landed gib piece is drawn at the angle its spin will reach, so it never creeps.


func _landed(spin: float) -> GibSim:
	var g: GibSim = GibSim.new()
	g.kill_of[0] = 0
	g.spin[0] = spin
	g.ang[0] = 0.4
	g.drag[0] = 6.0
	g.vel[0] = Vector2(1.5, 0.0)
	return g


func test_a_landed_pieces_drawn_angle_never_moves_while_the_sim_turns_it() -> void:
	var g: GibSim = _landed(3.0)
	var drawn: float = g.ang[0] + KillRestSpin.left(g, 0)
	var sim_moved: float = 0.0
	for t: int in 120:
		var before: float = g.ang[0]
		g.step()
		sim_moved += absf(g.ang[0] - before)
		assert_almost_eq(g.ang[0] + KillRestSpin.left(g, 0), drawn, 1e-4, "tick %d" % t)
	assert_gt(sim_moved, 0.5, "the sim really turned it (the creep the view hides)")
	assert_eq(g.spin[0], 0.0, "and it has stopped")
	assert_almost_eq(g.ang[0], drawn, 1e-4, "the drawn angle was where it ends")


func test_a_flying_or_held_piece_is_drawn_as_the_sim_has_it() -> void:
	var g: GibSim = _landed(3.0)
	g.z[0] = 0.5
	assert_eq(KillRestSpin.left(g, 0), 0.0, "in the air")
	g.z[0] = 0.0
	g.vz[0] = 2.0
	assert_eq(KillRestSpin.left(g, 0), 0.0, "bouncing")
	g.vz[0] = 0.0
	g.wait[0] = 5
	assert_eq(KillRestSpin.left(g, 0), 0.0, "held by a grind")


func test_no_spin_no_turn() -> void:
	assert_eq(KillRestSpin.turn_left(0.0), 0.0)
	assert_lt(KillRestSpin.turn_left(-2.0), 0.0, "turns the way it spins")
