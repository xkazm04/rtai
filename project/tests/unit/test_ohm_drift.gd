extends GutTest


func test_roll_repeats_every_144_ticks_at_idle_and_cruise() -> void:
	for cruise: float in [0.0, 0.5, 1.0]:
		var amplitude: float = deg_to_rad(lerpf(3.0, 1.5, cruise))
		assert_almost_eq(OhmDrift.sway(36, cruise), amplitude, 0.000001)
		assert_almost_eq(OhmDrift.sway(108, cruise), -amplitude, 0.000001)
		for tick: int in 144:
			var roll: float = OhmDrift.sway(tick, cruise)
			assert_lte(absf(roll), amplitude)
			assert_eq(OhmDrift.sway(tick + 144, cruise), roll)


func test_cloth_trails_the_turn_and_the_staff_leads_then_settles() -> void:
	var mount: Node2D = add_child_autofree(Node2D.new())
	var spirit: OhmSpirit = OhmSpirit.new()
	mount.add_child(spirit)
	var drawn: GhostDrawn = GhostDrawn.new("ohm", 1.55, 126.0, 180.0)
	var charge: OhmCharge = OhmCharge.new()
	mount.rotation = deg_to_rad(160.0)
	spirit.pose(drawn, charge, null, false, 0)
	var rest: float = spirit._staff.rotation
	assert_eq(spirit._hem.rotation, 0.0)
	assert_eq(spirit._beard.rotation, 0.0)
	mount.rotation = deg_to_rad(-110.0)
	spirit.pose(drawn, charge, null, false, 1)
	assert_gte(spirit._hem.rotation, -deg_to_rad(25.0))
	assert_lt(spirit._hem.rotation, spirit._beard.rotation)
	assert_lt(spirit._beard.rotation, 0.0)
	assert_gt(spirit._staff.rotation, rest)
	assert_lt(spirit.rotation, OhmDrift.sway(1, 0.0))
	assert_almost_eq(
		spirit.rotation + spirit._staff.rotation, rest + OhmDrift.sway(1, 0.0), 0.00001
	)
	var error: float = spirit._hem.rotation
	spirit.pose(drawn, charge, null, false, 1)
	assert_eq(spirit._hem.rotation, error)
	for tick: int in range(2, 61):
		spirit.pose(drawn, charge, null, false, tick)
		assert_lte(absf(spirit._hem.rotation), deg_to_rad(25.0))
		assert_lte(absf(spirit._beard.rotation), deg_to_rad(25.0))
		assert_gte(spirit._hem.rotation, error)
		error = spirit._hem.rotation
	assert_eq(spirit._hem.rotation, 0.0)
	assert_eq(spirit._beard.rotation, 0.0)
	assert_almost_eq(spirit._staff.rotation, rest, 0.00001)
	assert_almost_eq(spirit.rotation, OhmDrift.sway(60, 0.0), 0.00001)


func test_fork_reaches_ahead_and_bobs_against_the_flight_bob() -> void:
	var mount: Node2D = add_child_autofree(Node2D.new())
	var spirit: OhmSpirit = OhmSpirit.new()
	mount.add_child(spirit)
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(OhmStage.ID))
	var drawn: GhostDrawn = GhostDrawn.new("ohm", 1.55, 126.0, 180.0)
	drawn.flight = flight
	var charge: OhmCharge = OhmCharge.new()
	var at: Vector2 = Vector2.ZERO
	flight.step(at, 0.0, 0)
	for tick: int in range(1, 69):
		at.x += 4.5 * SimConst.PX_PER_M * SimClock.TICK_DT
		flight.step(at, 0.0, 1)
		spirit.pose(drawn, charge, null, false, tick)
		if tick in [22, 67]:
			var fork: Vector2 = spirit._fork.points_on(spirit)[2]
			fork *= PlayerScale.k() / 531.25
			assert_almost_eq(fork.x, 1.46, 0.015)
			var bob_px: float = (fork.y - OhmSpirit.REST_FORK_M.y) * 32.0
			assert_almost_eq(bob_px, -2.5 if tick == 22 else 2.5, 0.2)
