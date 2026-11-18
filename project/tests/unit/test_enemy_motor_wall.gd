extends GutTest
## The data-only EnemyPit has a different motor from the street fight's Fighter.
## Walk each shipped body round the same pit wall on a patrol goal, independent of gun range.


func test_all_roster_bodies_walk_round_the_pit_wall() -> void:
	var pit: EnemyPit = PitLayout.build(20261109, false)
	pit.cover.append(Rect2(5.0, 6.7, 14.0, 0.6))
	pit.rivet_pos = Vector2(-18, -12)
	var goal: Vector2 = Vector2(12, 11)
	for kind: StringName in pit.roster.archetypes:
		var e: EnemyAgent = pit.spawn(kind, Vector2(12, 4))
		var reached: int = -1
		var crossed_solid: bool = false
		for tick: int in range(1, 901):
			var before: Vector2 = e.pos
			var walk: Vector2 = EnemyMotor.arrive(e, goal, e.arch.speed_mps)
			EnemyMotor.move(e, walk, goal, [], pit)
			crossed_solid = crossed_solid or EnemySenses.blocked(before, e.pos, pit.cover)
			if e.pos.distance_to(goal) <= 0.3:
				reached = tick
				break
		gut.p("pit wall %s reached 0.3 m at %d" % [kind, reached])
		assert_gt(reached, 0, String(kind))
		assert_false(crossed_solid, String(kind))
