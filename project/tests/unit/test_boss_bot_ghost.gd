extends GutTest
## The boss bot's ghost: G picks the ghost in GhostPilot's order, then Q takes the soul.


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
