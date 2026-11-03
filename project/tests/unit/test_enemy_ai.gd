extends GutTest
## features/combat/ai: the archetype table, the squad tokens, staggers and the tackle rule.


func test_the_table_loads_five_archetypes_with_weapons() -> void:
	var r: EnemyRoster = EnemyRoster.shipped()
	assert_true(r.ok(), str(r.errors()))
	assert_eq(r.archetypes.size(), 5)
	for id: StringName in r.archetypes:
		assert_not_null(r.archetype(id).weapon, String(id))
	assert_true(r.archetype(&"riot_cop").weapon.melee)
	assert_eq(r.archetype(&"robot_thug").hit_fx, &"sparks")


func test_accuracy_falls_with_range() -> void:
	var a: EnemyRoster.Archetype = EnemyRoster.shipped().archetype(&"swat")
	assert_gt(a.accuracy(2.0), a.accuracy(30.0))
	assert_almost_eq(a.accuracy(2.0), a.acc_near, 0.0001)


func test_at_most_max_shooters_hold_a_token() -> void:
	var pit: EnemyPit = PitLayout.build(3, false)
	PitLayout.squad(pit, PitLayout.many(&"patrol_cop", 5))
	for e: EnemyAgent in pit.agents:
		e.sees = true
	EnemySquad.assign(pit.agents, pit.rivet_pos, pit.roster)
	assert_eq(EnemySquad.holders(pit.agents, false), pit.roster.max_shooters)


func test_a_hit_staggers_a_cop_and_cancels_the_windup() -> void:
	var pit: EnemyPit = PitLayout.build(3, false)
	PitLayout.squad(pit, [&"swat"])
	var e: EnemyAgent = pit.agents[0]
	e.token = true
	e.enter(EnemyAgent.State.WINDUP, 30)
	pit.hurt(e, 1.0, Vector2.LEFT)
	assert_eq(e.state, EnemyAgent.State.STAGGER)
	assert_false(e.token)
	assert_eq(e.pose(pit.tick), &"stagger")


func test_a_robot_thug_shrugs_off_a_hit_and_a_tackle() -> void:
	var pit: EnemyPit = PitLayout.build(3, false)
	PitLayout.squad(pit, [&"robot_thug"])
	var e: EnemyAgent = pit.agents[0]
	e.enter(EnemyAgent.State.WINDUP, 30)
	pit.hurt(e, 1.0, Vector2.LEFT)
	assert_eq(e.state, EnemyAgent.State.WINDUP)
	assert_false(pit.knock(e, 60))


func test_the_riot_shield_soaks_hits_from_the_front() -> void:
	var pit: EnemyPit = PitLayout.build(3, false)
	PitLayout.squad(pit, [&"riot_cop", &"riot_cop"])
	var front: EnemyAgent = pit.agents[0]
	var back: EnemyAgent = pit.agents[1]
	front.facing = Vector2.LEFT
	back.facing = Vector2.LEFT
	pit.hurt(front, 1.0, Vector2.RIGHT)
	pit.hurt(back, 1.0, Vector2.LEFT)
	assert_gt(front.hp, back.hp)
