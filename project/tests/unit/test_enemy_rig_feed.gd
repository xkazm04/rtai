extends GutTest
## EnemyRigFeed: enemy states become RigFeed flags and clips the cast rig plays.


func _pit() -> EnemyPit:
	var pit: EnemyPit = PitLayout.build(9, false)
	PitLayout.squad(pit, [&"patrol_cop", &"riot_cop"])
	return pit


func test_rows_carry_position_in_pixels() -> void:
	var pit: EnemyPit = _pit()
	var feed: RigFeed = RigFeed.new()
	assert_eq(EnemyRigFeed.write(pit, feed, 1, 32.0), 2)
	assert_eq(feed.count, 3)
	assert_eq(feed.pos[1], pit.agents[0].pos * 32.0)
	assert_true(feed.has_flag(1, RigFeed.Flag.GUN_OUT), "a pistol cop holds the gun out")
	assert_false(feed.has_flag(2, RigFeed.Flag.GUN_OUT), "the baton cop does not")


func test_windup_aims_and_hit_shoves_along_the_blow() -> void:
	var pit: EnemyPit = _pit()
	var cop: EnemyAgent = pit.agents[0]
	cop.enter(EnemyAgent.State.WINDUP, 30)
	var feed: RigFeed = RigFeed.new()
	assert_eq(EnemyRigFeed.write(pit, feed, 0, 32.0), 2)
	assert_true(feed.has_flag(0, RigFeed.Flag.AIMING))
	pit.hurt(pit.agents[1], 1.0, Vector2.DOWN)
	assert_eq(EnemyRigFeed.write(pit, feed, 0, 32.0), 2)
	assert_eq(feed.clip[1], RigClips.Clip.HIT)
	assert_almost_eq(feed.clip_arg[1], Vector2.DOWN.angle(), 0.001)


func test_death_sets_dead_and_the_death_clip() -> void:
	var pit: EnemyPit = _pit()
	pit.hurt(pit.agents[0], 99.0, Vector2.RIGHT)
	var feed: RigFeed = RigFeed.new()
	assert_eq(EnemyRigFeed.write(pit, feed, 0, 32.0), 2)
	assert_true(feed.has_flag(0, RigFeed.Flag.DEAD))
	assert_eq(feed.clip[0], RigClips.Clip.DEATH)


func test_place_spawns_hot_at_the_spots_and_row_matches_write() -> void:
	var pit: EnemyPit = PitLayout.build(9, false)
	var spots: PackedVector2Array = PackedVector2Array([Vector2(3.0, 2.5), Vector2(8.0, -5.0)])
	PitLayout.place(pit, [&"robot_thug", &"patrol_cop"], spots)
	assert_eq(pit.agents[1].pos, Vector2(8.0, -5.0))
	assert_eq(pit.agents[0].state, EnemyAgent.State.ENGAGE, "a staged spawn starts hot")
	var a: RigFeed = RigFeed.new()
	var b: RigFeed = RigFeed.new()
	assert_eq(EnemyRigFeed.write(pit, a, 0, 32.0), 2)
	EnemyRigFeed.row(pit.agents[1], pit.tick, b, 0, 32.0)
	assert_eq(b.pos[0], a.pos[1])
	assert_eq(b.flags[0], a.flags[1])
