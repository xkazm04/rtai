extends GutTest
## n31 ghost 09: Tonnage's dump kicks the camera once, on the dump tick.


class SpyCam:
	extends CameraRig
	var seen: Array[Vector2i] = []
	var ids: Array[StringName] = []

	func kick(id: StringName, tick: int) -> void:
		ids.append(id)
		seen.append(Vector2i(tick, 0))


func _ghost() -> GhostDeploy:
	return GhostDeploy.new(GhostAttacks.shipped(), null)


func _land(g: GhostDeploy, tick: int) -> void:
	g.strike.release_tick = tick
	g.strike.release_form = HaulerStage.GHOST


func test_table_names_real_camera_ids() -> void:
	var kick: TonnageDumpKick = TonnageDumpKick.shipped()
	var cam: CameraRig = CameraRig.new()
	assert_eq(kick.shake_id, &"crash")
	assert_true(cam.shakes.has(kick.shake_id))


func test_one_dump_one_kick_at_the_dump_tick() -> void:
	var kick: TonnageDumpKick = TonnageDumpKick.shipped()
	var cam: SpyCam = SpyCam.new()
	var g: GhostDeploy = _ghost()
	for tick: int in range(100, 140):
		if tick == 127:
			_land(g, tick)
		assert_eq(kick.step(g, tick, cam, false), tick == 127, "tick %d" % tick)
	assert_eq(kick.kicks, 1)
	assert_eq(cam.seen, [Vector2i(127, 0)] as Array[Vector2i])
	assert_eq(cam.ids, [&"crash"] as Array[StringName])


func test_no_kick_during_the_charge() -> void:
	var kick: TonnageDumpKick = TonnageDumpKick.shipped()
	var cam: SpyCam = SpyCam.new()
	var g: GhostDeploy = _ghost()
	for tick: int in range(100, 127):
		assert_false(kick.step(g, tick, cam, false))
	assert_eq(cam.seen.size(), 0)


func test_reduced_motion_never_kicks_and_does_not_replay_later() -> void:
	var kick: TonnageDumpKick = TonnageDumpKick.shipped()
	var cam: SpyCam = SpyCam.new()
	var g: GhostDeploy = _ghost()
	_land(g, 127)
	assert_false(kick.step(g, 127, cam, true))
	assert_false(kick.step(g, 128, cam, false))
	assert_eq(cam.seen.size(), 0)


func test_a_second_dump_kicks_again_and_a_stale_one_does_not() -> void:
	var kick: TonnageDumpKick = TonnageDumpKick.shipped()
	var cam: SpyCam = SpyCam.new()
	var g: GhostDeploy = _ghost()
	_land(g, 50)
	assert_false(kick.step(g, 200, cam, false), "a view attached late ignores an old dump")
	_land(g, 300)
	assert_true(kick.step(g, 301, cam, false))
	assert_eq(kick.kicks, 1)


func test_hold_forms_do_not_kick() -> void:
	var kick: TonnageDumpKick = TonnageDumpKick.shipped()
	var g: GhostDeploy = _ghost()
	_land(g, 10)
	g.strike.release_form = DentStage.GHOST
	assert_false(kick.step(g, 10, SpyCam.new(), false))


## n31 ghost 12: Ohm's drop discharge kicks with its own, lighter row id.
func test_ohm_discharge_kicks_with_its_own_row_id() -> void:
	var kick: TonnageDumpKick = TonnageDumpKick.shipped()
	var cam: SpyCam = SpyCam.new()
	var g: GhostDeploy = _ghost()
	_land(g, 40)
	g.strike.release_form = OhmStage.GHOST
	assert_true(kick.step(g, 40, cam, false))
	assert_eq(cam.ids, [&"hit"] as Array[StringName])
	var rig: CameraRig = autofree(CameraRig.new())
	assert_true(rig.shakes.has(&"hit"))
	var row: GhostAttacks.DeployRow = GhostAttacks.shipped().deploy[HaulerStage.GHOST]
	assert_eq(row.dump_shake, &"crash")
	assert_eq(row.dump_hitstop, &"boss_hit")
