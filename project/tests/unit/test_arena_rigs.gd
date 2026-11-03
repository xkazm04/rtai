extends GutTest
## ArenaRigs (dev flag --rigs) turns the arena's fighters into the cast rig feed: an armed fighter
## holds its gun out and aimed, a shot plays the SHOOT recoil, the dead lie down. Render only.


func _rigs() -> ArenaRigs:
	var r: ArenaRigs = ArenaRigs.new()
	autofree(r)
	autofree(r.rigs)
	return r


func _armed(id: int) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, id, Vector2(3.0, 4.0), 10.0)
	f.weapon = &"rifle"
	return f


func test_a_burst_round_is_a_shot() -> void:
	assert_true(ArenaRigs.fired(Vector2i(20, 3), Vector2i(20, 2)))


func test_a_burst_starting_is_not_yet_a_shot() -> void:
	assert_false(ArenaRigs.fired(Vector2i(0, 0), Vector2i(30, 3)))


func test_rivet_rearming_the_trigger_is_a_shot() -> void:
	assert_true(ArenaRigs.fired(Vector2i(0, 0), Vector2i(12, 0)))
	assert_false(ArenaRigs.fired(Vector2i(12, 0), Vector2i(11, 0)))


func test_armed_fighter_holds_the_gun_out_and_aimed() -> void:
	var r: ArenaRigs = _rigs()
	r._put(0, _armed(7), BodyPlan.Kind.COP)
	var f: RigFeed = r.rigs.feed
	assert_true(f.has_flag(0, RigFeed.Flag.GUN_OUT))
	assert_true(f.has_flag(0, RigFeed.Flag.AIMING))
	assert_eq(f.pos[0], Vector2(3.0, 4.0) * SimConst.PX_PER_M)


func test_a_shot_plays_the_recoil_once() -> void:
	var r: ArenaRigs = _rigs()
	var g: Fighter = _armed(7)
	r._put(0, g, BodyPlan.Kind.COP)
	g.burst_left = 2
	g.cooldown = 30  # the burst starts: no round yet
	r._put(0, g, BodyPlan.Kind.COP)
	assert_eq(r.rigs.feed.clip[0], RigClips.Clip.NONE)
	g.burst_left = 1
	r._put(0, g, BodyPlan.Kind.COP)
	assert_eq(r.rigs.feed.clip[0], RigClips.Clip.SHOOT)
	r._put(0, g, BodyPlan.Kind.COP)
	assert_eq(r.rigs.feed.clip[0], RigClips.Clip.NONE)


func test_the_dead_lie_down_and_do_not_shoot() -> void:
	var r: ArenaRigs = _rigs()
	var g: Fighter = _armed(7)
	r._put(0, g, BodyPlan.Kind.COP)
	g.hp = 0.0
	g.burst_left = 0
	g.cooldown = 40
	r._put(0, g, BodyPlan.Kind.COP)
	var f: RigFeed = r.rigs.feed
	assert_true(f.has_flag(0, RigFeed.Flag.DEAD))
	assert_true(f.has_flag(0, RigFeed.Flag.DOWN))
	assert_eq(f.clip[0], RigClips.Clip.NONE)
