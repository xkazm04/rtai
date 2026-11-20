extends GutTest


func test_attack_take_chains_four_slices_then_blinks_into_clear_space() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var session: ArenaSession = ArenaSession.open(bus, data)
	var take: GhostReviewInput = GhostReviewInput.new(session, &"kerf", true)
	session.world.loop().set_input(take)
	for tick: int in GhostReviewInput.START:
		session.step()
	var presses: Array[int] = []
	for t: int in 300:
		var pad: TickInput = take.sample(session.tick())
		var cmd: PlayerCommand = PlayerCommand.decode(pad, 0, session.actions)
		if cmd.is_held(session.actions, &"melee"):
			presses.append(t)
		var arena: CombatArena = session.stage.arena
		var before: Vector2 = arena.rivet.pos
		if t == 250:
			assert_eq(session.pilot.kerf.slices, 4)
			for guard: Fighter in arena.hostiles:
				var offset: Vector2 = guard.pos - before
				if guard.alive() and offset.length() <= 9.0:
					assert_gt(absf(cmd.aim.angle_to(offset)), deg_to_rad(35.0))
		session.step()
		if t == 250:
			assert_almost_eq(arena.rivet.pos, before + cmd.aim * 4.0, Vector2.ONE * 0.01)
	assert_eq(presses, [28, 77, 126, 200, 250])
	assert_eq(session.pilot.kerf.slices, 4)
	session.world.loop().set_input(session.live)
	session.close()
