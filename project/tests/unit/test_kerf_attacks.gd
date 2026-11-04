extends GutTest
## Lane ghost-powers: Kerf's blink (ghost_attacks.json `kerf`) on quest 1's stage through the bound
## pilot: Q takes the soul, the melee press blinks behind the target inside the aim cone and cuts
## it (weapon kerf_slice: a human dies, a robot takes robot_damage), nothing in the cone = a plain
## dash, and the chain spends its charges (no blink at zero) and gets one back per recharge_s.

var _bus: EventBus
var _data: DataStore
var _stage: CollectCallStage
var _pilot: StagePilot
var _kills: Dictionary[int, StringName] = {}


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(_bus, _data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_pilot.kerf = KerfStage.shipped()
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)
	_stage.arena.rivet.facing = Vector2.RIGHT
	_kills.clear()
	@warning_ignore("return_value_discarded")
	_stage.arena.kill_landed.connect(_on_kill)


func _on_kill(v: Fighter, weapon: StringName, _d: Vector2, _a: Vector2, _k: StringName) -> void:
	_kills[v.id] = weapon


func _press(action: StringName, aim: Vector2 = Vector2.RIGHT) -> void:
	var buttons: int = 1 << _pilot.actions.bit(action) if action != &"" else 0
	buttons |= PlayerCommand.pack_aim(aim, _pilot.actions)
	_pilot.drive(_stage, TickInput.new(buttons, 0, 0))
	_stage.intent.clear()


func _guard(off: Vector2) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + off
	return g


func _wait(ticks: int) -> void:
	for i: int in ticks:
		_press(&"")


func test_the_blink_cuts_the_target_in_the_cone_and_lands_behind_it() -> void:
	var target: Fighter = _guard(Vector2(6.0, 0.5))
	var aside: Fighter = _guard(Vector2(0.0, 5.0))  # 90 degrees off the aim: outside the cone
	var start: Vector2 = _stage.arena.rivet.pos
	_press(&"power_hauler")
	_wait(2)
	_press(&"melee")
	assert_false(target.alive(), "the human in the cone is cut down")
	var weapon: StringName = _kills.get(target.id, &"")
	assert_eq(weapon, &"kerf_slice", "by the Kerf slice (the split kill)")
	assert_true(aside.alive(), "the one outside the cone is left")
	var past: float = (_stage.arena.rivet.pos - start).length()
	assert_gt(past, start.distance_to(target.pos), "Rivet lands beyond the target")


func test_a_robot_takes_robot_damage() -> void:
	var robot: Fighter = _stage.arena.spawn_boss(_stage.arena.rivet.pos + Vector2(5.0, 0.0))
	robot.max_hp = 6.0
	robot.hp = 6.0
	_press(&"power_hauler")
	_wait(2)
	_press(&"melee")
	var k: float = _pilot.kerf.num(&"robot_damage")
	assert_almost_eq(robot.hp, 6.0 - k, 0.001, "a robot takes robot_damage, not the one-shot")


func test_no_target_is_a_dash_and_the_chain_runs_dry_then_recharges() -> void:
	var kerf: KerfStage = _pilot.kerf
	var n: int = int(kerf.num(&"charges"))
	var gap: int = PowerDef.ticks(kerf.num(&"gap_s"))
	_press(&"power_hauler")
	var start: Vector2 = _stage.arena.rivet.pos
	_press(&"melee")
	assert_almost_eq(
		(_stage.arena.rivet.pos - start).length(), kerf.num(&"dash_m"), 0.01, "a plain dash"
	)
	for i: int in n - 1:
		_wait(gap)
		_press(&"melee")
	assert_eq(kerf.blinks, n, "every charge spent")
	_wait(gap)
	var at: Vector2 = _stage.arena.rivet.pos
	_press(&"melee")
	assert_eq(_stage.arena.rivet.pos, at, "no blink at zero charges")
	_wait(PowerDef.ticks(kerf.num(&"recharge_s")))
	assert_eq(kerf.charges, 1, "one charge back after recharge_s")
