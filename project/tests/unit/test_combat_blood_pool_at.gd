extends GutTest
## n9 world it23: CombatBlood.pool_at lays a quest kill's pool under the drawn corpse while the
## signature-kill veto still asks at the victim's own spot.

const SPOT: Vector2 = Vector2(8, 5)
const LIE: Vector2 = Vector2(9.2, 5.6)


func _blood(bus: EventBus) -> CombatBlood:
	var b: CombatBlood = CombatBlood.new()
	b.mode = "noir"
	add_child_autofree(b)
	var where: Dictionary[int, Vector2] = {1: Vector2(5, 5), 2: SPOT}
	b.listen(bus, func(id: int) -> Vector2: return where.get(id, Vector2.INF), 1)
	b.pool_at = func(id: int, at: Vector2) -> Vector2: return LIE if id == 2 else at
	return b


func test_the_pool_lies_where_pool_at_says_not_at_his_spot() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var b: CombatBlood = _blood(bus)
	bus.actor_killed.emit(1, 2, &"shot")
	b.step(1, Vector2.ZERO)
	b.step(80, Vector2.ZERO)
	assert_eq(b.kills, 1)
	assert_true(b.blood.has_pool_at(LIE * SimConst.PX_PER_M, 16.0), "under the corpse")
	assert_false(b.blood.has_pool_at(SPOT * SimConst.PX_PER_M, 8.0), "not at his spot")


func test_the_veto_asks_at_his_spot_not_the_pool() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var b: CombatBlood = _blood(bus)
	var asked: Array[Vector2] = []
	b.veto = func(px: Vector2) -> bool:
		asked.append(px)
		return px.distance_to(SPOT * SimConst.PX_PER_M) <= 1.2 * SimConst.PX_PER_M
	bus.actor_killed.emit(1, 2, &"shot")
	await wait_process_frames(2)
	b.step(80, Vector2.ZERO)
	assert_eq(b.kills, 0, "a signature kill at his spot: no standard pool, wherever he lies")
	assert_eq(asked.size(), 1)
	assert_eq(asked[0], SPOT * SimConst.PX_PER_M)
