extends GutTest
## The boss bot's ghost: G picks the ghost in GhostPilot's order, then Q takes the soul.

const FLOOR: Rect2 = Rect2(-40, -40, 80, 80)


func _presses(ghost: StringName, action: StringName) -> Array[int]:
	var actions: PlayerActions = PlayerActions.shipped()
	var g: BossBotGhost = BossBotGhost.new(ghost)
	var out: Array[int] = []
	for t: int in BossBotGhost.FIRST_AT:
		if g.buttons(t, null, Vector2.ZERO, actions) & (1 << actions.bit(action)):
			out.append(t)
	return out


func test_ohm_is_three_picks_then_the_soul() -> void:
	assert_eq(_presses(&"ohm", &"power_gearbox"), [40, 42, 44] as Array[int])
	assert_eq(_presses(&"ohm", &"power_hauler"), [BossBotGhost.TAKE_AT] as Array[int])


func test_tonnage_takes_the_soul_with_no_pick() -> void:
	assert_eq(_presses(&"tonnage", &"power_gearbox").size(), 0)
	assert_eq(_presses(&"tonnage", &"power_hauler").size(), 1)


func _car(at: Vector2) -> VehicleBody:
	return VehicleBody.new(1, VehicleProfile.new(), at, Vector2.RIGHT)


func test_dent_walks_to_a_car_before_the_soul() -> void:
	var actions: PlayerActions = PlayerActions.shipped()
	var g: BossBotGhost = BossBotGhost.new(&"dent")
	var far: Array[VehicleBody] = [_car(Vector2(20, 0))]
	assert_eq(g.car_goal(far, Vector2.ZERO, FLOOR), Vector2(20, 0))
	for t: int in BossBotGhost.FIRST_AT:  # planted: no car in reach, so no G and no Q yet
		assert_eq(g.buttons(t, null, Vector2.ZERO, actions), 0)
	var near: Array[VehicleBody] = [_car(Vector2(5, 0))]
	assert_eq(g.car_goal(near, Vector2.ZERO, FLOOR), Vector2(5, 0))
	var g_at: int = -1
	for t: int in range(100, 100 + BossBotGhost.FIRST_AT):
		if g.buttons(t, null, Vector2.ZERO, actions) & (1 << actions.bit(&"power_gearbox")):
			g_at = t
			break
	assert_eq(g_at, 100 + BossBotGhost.SELECT_AT)


func test_dent_seizes_once_then_fights() -> void:
	var g: BossBotGhost = BossBotGhost.new(&"dent")
	var car: VehicleBody = _car(Vector2(5, 0))
	car.soul_hijacked = true
	var other: VehicleBody = _car(Vector2(8, 0))
	assert_eq(g.car_goal([car, other] as Array[VehicleBody], Vector2.ZERO, FLOOR), Vector2.INF)
	car.state = VehicleBody.State.WRECK
	assert_eq(g.car_goal([car, other] as Array[VehicleBody], Vector2.ZERO, FLOOR), Vector2.INF)


func test_dent_skips_a_car_off_the_floor() -> void:
	var g: BossBotGhost = BossBotGhost.new(&"dent")
	var off: VehicleBody = _car(Vector2(3, 0))  # planted: the nearest car, but on another pad
	var on: VehicleBody = _car(Vector2(-20, 0))
	var area: Rect2 = Rect2(-30, -10, 30, 20)
	assert_eq(g.car_goal([off, on] as Array[VehicleBody], Vector2.ZERO, area), Vector2(-20, 0))
	assert_eq(g.car_goal([off] as Array[VehicleBody], Vector2.ZERO, area), Vector2.INF)


func test_other_ghosts_have_no_car_goal() -> void:
	var g: BossBotGhost = BossBotGhost.new(&"ohm")
	var cars: Array[VehicleBody] = [_car(Vector2(5, 0))]
	assert_eq(g.car_goal(cars, Vector2.ZERO, FLOOR), Vector2.INF)
