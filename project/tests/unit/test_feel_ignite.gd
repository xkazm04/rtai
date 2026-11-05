extends GutTest
## Lane n7-ranged (brief item 5, the flamer's ignition read): the flamethrower's puffs do not kick
## the camera, but the first puff after the trigger rested does (hit_feel.json ignite_kick_px);
## --feel=off means none.


func _cam() -> FeelCam:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	return FeelCam.attach(arena, null, HitFeel.shipped())


## Kicks started by `ticks` puffs of the flamer, one per tick from `from`.
func _puffs(cam: FeelCam, from: int, ticks: int) -> int:
	var before: int = cam.kicks
	for t: int in range(from, from + ticks):
		@warning_ignore("return_value_discarded")
		cam.fire(&"flamethrower", Vector2.RIGHT, t)
	return cam.kicks - before


func test_the_flamer_kicks_once_as_it_lights_not_per_puff() -> void:
	var cam: FeelCam = _cam()
	assert_gt(cam.feel.ignite_px(&"flamethrower"), 0.0, "the flamer has an ignition kick")
	assert_eq(_puffs(cam, 100, 60), 1, "a second of fire: one kick, on the first puff")
	assert_eq(_puffs(cam, 190, 30), 1, "rested 30 ticks (over the idle window): lights again")
	assert_eq(_puffs(cam, 225, 30), 0, "a 6-tick gap is the same stream: no new kick")


func test_off_means_no_ignition_kick() -> void:
	var cam: FeelCam = _cam()
	cam.feel.enabled = false
	assert_eq(_puffs(cam, 100, 30), 0)
