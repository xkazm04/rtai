extends GutTest
## Lane human-reactions: the robot thug's power-down death (death_robot) is its own pose, holds a
## corpse on the spot, and never reaches a human through death_map.

var _table: ReactTable
var _rig: CutRig


func before_each() -> void:
	_table = ReactTable.shipped()
	_rig = CutRig.new()
	_rig.actor_id = 11
	_rig.facing = 0.0


func after_each() -> void:
	_rig.free()


func test_the_robot_powers_down_on_the_spot() -> void:
	var pipe: DeathPipe = DeathPipe.make(_table)
	assert_eq(pipe.kill_robot(_rig, Vector2.LEFT), &"death_robot")
	var r: HumanReact = _rig.react
	for _i: int in 120:  # 2 s: the 0.9 s death, then the corpse held
		r.pre(_rig, SimClock.TICK_DT)
		assert_lte(r.slide.length(), 0.2 * HumanReact.PX_M + 0.001, "no slide past travel_m")
	assert_true(r.active(), "a death never clears")
	assert_eq(r.kind, &"death_robot")
	assert_almost_eq(_rig.c_sprawl, DeathPose.ROBOT_LIE, 0.001, "lies pitched forward")
	assert_almost_eq(r.tint, DeathPose.ROBOT_DIM, 0.001, "the paint darkened")
	assert_gt(absf(r.head_rot), 0.4, "the head dropped last")


func test_the_knees_give_before_it_pitches() -> void:
	assert_eq(DeathPipe.make(_table).kill_robot(_rig, Vector2.LEFT), &"death_robot")
	var r: HumanReact = _rig.react
	for _i: int in 15:  # 0.25 s of 0.9
		r.pre(_rig, SimClock.TICK_DT)
	assert_gt(_rig.c_tuck, 0.4, "knees given")
	assert_lt(_rig.c_sprawl, 0.05, "not yet pitched")


func test_no_damage_class_kills_a_human_with_the_robot_death() -> void:
	assert_gt(_table.length(&"death_robot"), 0.5)
	for c: String in ["light", "medium", "heavy", "melee", "blast", "burn", "shock", "nope"]:
		assert_ne(_table.death_for(StringName(c)), &"death_robot", c)
