extends GutTest
## n11 combat: a city kill's pool spreads under the chest of the body that lay down nearest the
## kill (StreetDeadRests), not at the boots where the sim put him (film it19, t365 on).

const KILL: Vector2 = Vector2(100.0, 100.0)
const CHEST: Vector2 = Vector2(150.0, 80.0)


func _killed(fx: BloodFx, under: PoolUnderBody, at: Vector2) -> void:
	fx.splash(at, Vector2.RIGHT, "kill")
	under.on_bled(at, Vector2.RIGHT)


func test_the_kill_pool_moves_under_the_chest_before_it_shows() -> void:
	var fx: BloodFx = autofree(BloodFx.new())
	var under: PoolUnderBody = autofree(PoolUnderBody.new(fx))
	_killed(fx, under, KILL)
	under.step({})
	assert_eq(under.waiting(), 1, "no body lies yet: the pool waits")
	under.step({7: Vector4(KILL.x, KILL.y, CHEST.x, CHEST.y)})
	assert_true(fx.has_pool_at(CHEST, 0.5), "under the chest")
	assert_false(fx.has_pool_at(KILL, 8.0), "not at the boots")
	assert_eq([under.moved, under.late, under.waiting()], [1, 0, 0])


func test_a_pool_that_already_shows_is_never_moved() -> void:
	var fx: BloodFx = autofree(BloodFx.new())
	var under: PoolUnderBody = autofree(PoolUnderBody.new(fx))
	_killed(fx, under, KILL)
	fx.step_ticks(fx.ring.born_of(fx.ring.last_pool) - fx.tick)
	under.step({7: Vector4(KILL.x, KILL.y, CHEST.x, CHEST.y)})
	assert_false(fx.has_pool_at(CHEST, 8.0), "a showing pool does not jump")
	assert_eq([under.moved, under.late], [0, 1])


func test_a_body_already_soaked_does_not_take_the_next_kill_pool() -> void:
	var fx: BloodFx = autofree(BloodFx.new())
	var under: PoolUnderBody = autofree(PoolUnderBody.new(fx))
	var old: Vector4 = Vector4(KILL.x, KILL.y, CHEST.x, CHEST.y)
	_killed(fx, under, KILL)
	under.step({7: old})
	var next: Vector2 = KILL + Vector2(20.0, 0.0)  # the old body's feet are nearer this kill
	_killed(fx, under, next)
	under.step({7: old})
	assert_eq(under.waiting(), 1, "it waits for its own body")
	under.step({7: old, 8: Vector4(next.x + 30.0, next.y, 300.0, 300.0)})
	assert_true(fx.has_pool_at(Vector2(300.0, 300.0), 0.5), "under its own body's chest")


func test_a_body_too_far_from_the_kill_is_another_body() -> void:
	var fx: BloodFx = autofree(BloodFx.new())
	var under: PoolUnderBody = autofree(PoolUnderBody.new(fx))
	_killed(fx, under, KILL)
	var far: float = PoolUnderBody.MATCH_M * SimConst.PX_PER_M + 1.0
	under.step({7: Vector4(KILL.x + far, KILL.y, CHEST.x, CHEST.y)})
	assert_eq([under.moved, under.waiting()], [0, 1])


func test_the_rests_forget_the_oldest_body_past_memory() -> void:
	StreetDeadRests.reset()
	var plan: Sprite2D = autofree(Sprite2D.new())
	for actor: int in StreetDeadRests.MEMORY + 1:
		StreetDeadRests.publish(actor, Vector2.ZERO, plan, Vector2.RIGHT, true)
	assert_eq(StreetDeadRests.all.size(), StreetDeadRests.MEMORY)
	assert_false(StreetDeadRests.all.has(0), "the oldest is gone")
	StreetDeadRests.reset()
