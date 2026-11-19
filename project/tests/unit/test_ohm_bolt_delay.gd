extends GutTest

var _bus: EventBus
var _data: DataStore
var _stage: CollectCallStage
var _pilot: StagePilot


func _option(value: String) -> void:
	LaunchArgs.parse(PackedStringArray(["--ohm-bolt-delay=" + value]))
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(_bus, _data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)
	_stage.arena.rivet.facing = Vector2.RIGHT
	LaunchArgs.parse()
	_pilot.ghosts.forms.selected = OhmStage.GHOST
	_press(&"power_hauler")
	_wait(_pilot.ghosts.forms.table.form(OhmStage.GHOST).enter_ticks)


func _press(action: StringName) -> void:
	_stage.tick += 1
	var buttons: int = 1 << _pilot.actions.bit(action) if action != &"" else 0
	buttons |= PlayerCommand.pack_aim(Vector2.RIGHT, _pilot.actions)
	_pilot.drive(_stage, TickInput.new(buttons, 0, 0))
	_stage.intent.clear()


func _wait(ticks: int) -> void:
	for i: int in ticks:
		_press(&"")


func _guard(off: Vector2, hp: float) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + off
	g.max_hp = hp
	g.hp = hp
	return g


func test_delayed_bolt_uses_decision_aim_and_strikes_on_tick_three() -> void:
	_option("on")
	var guard: Fighter = _guard(Vector2(5.0, 0.0), 5.0)
	_press(&"melee")
	var decision: int = _stage.tick
	for age: int in 3:
		assert_eq(_pilot.ohm.bolts, 0, "wind-up age %d" % age)
		assert_eq(guard.hp, 5.0)
		_stage.tick += 1
		_pilot.ohm.drive(_stage, false, false, Vector2.LEFT)
	assert_eq(_pilot.ohm.bolt_tick, decision + 3)
	assert_eq(_pilot.ohm.bolt_aim, Vector2.RIGHT)
	assert_eq(guard.hp, 5.0 - _pilot.ohm.num(&"human_damage"))
	_wait(3)
	assert_eq(_pilot.ohm.bolts, 1)


func test_hit_during_windup_cancels_the_bolt() -> void:
	_option("on")
	var guard: Fighter = _guard(Vector2(5.0, 0.0), 5.0)
	_press(&"melee")
	_wait(1)
	_stage.arena.rivet.take(0.25, _stage.tick, Vector2.LEFT)
	_wait(5)
	assert_eq(_pilot.ohm.bolt_tick, -1)
	assert_eq(_pilot.ohm.struck, 0)
	assert_eq(guard.hp, 5.0)


func test_leaving_ohm_during_windup_cancels_the_bolt() -> void:
	_option("on")
	_press(&"melee")
	_press(&"power_hauler")
	_wait(5)
	assert_eq(_pilot.ohm.bolts, 0)


func test_windup_length_comes_from_the_attack_row() -> void:
	_option("on")
	var attacks: GhostAttacks = _pilot.ohm.attacks
	attacks.block(OhmStage.GHOST)["bolt_windup_ticks"] = 5
	LaunchArgs.parse(PackedStringArray(["--ohm-bolt-delay=on"]))
	_pilot.ohm.cast = OhmCast.new(attacks)
	LaunchArgs.parse()
	_press(&"melee")
	var decision: int = _stage.tick
	_wait(4)
	assert_eq(_pilot.ohm.bolts, 0)
	_wait(1)
	assert_eq(_pilot.ohm.bolt_tick, decision + 5)


func test_delayed_cast_pose_and_cadence_follow_the_sim() -> void:
	_option("on")
	var rig: OhmRig = add_child_autofree(OhmRig.new())
	var o: OhmStage = _pilot.ohm
	_press(&"melee")
	for age: int in 3:
		GhostActs.prepare_ohm(rig, o, _stage.arena.rivet, _stage.tick)
		assert_eq(rig.drawn.act_col(), GhostDrawn.WINDUP_COL)
		_wait(1)
	GhostActs.prepare_ohm(rig, o, _stage.arena.rivet, _stage.tick)
	assert_eq(rig.drawn.act_col(), GhostDrawn.CUT_COL)
	var first: int = o.bolt_tick
	var gap: int = PowerDef.ticks(o.num(&"bolt_gap_s"))
	_wait(gap - 4)
	_press(&"melee")
	_wait(3)
	assert_eq(o.bolt_tick, first + gap)
	assert_eq(o.bolts, 2)


func test_flag_off_keeps_the_instant_hit_and_legacy_state_bytes() -> void:
	_option("off")
	var guard: Fighter = _guard(Vector2(5.0, 0.0), 5.0)
	_press(&"melee")
	var gap: int = PowerDef.ticks(_pilot.ohm.num(&"bolt_gap_s"))
	assert_eq(_pilot.ohm.bolt_tick, _stage.tick)
	assert_eq(guard.hp, 5.0 - _pilot.ohm.num(&"human_damage"))
	for age: int in 5:
		var actual: StreamPeerBuffer = StreamPeerBuffer.new()
		_pilot.ohm.write_state(actual)
		var legacy: StreamPeerBuffer = StreamPeerBuffer.new()
		for field: int in [1, 1, 0, gap - age, _pilot.ohm.powers.active_left]:
			legacy.put_32(field)
		assert_eq(actual.data_array, legacy.data_array, "legacy bytes at bolt age %d" % age)
		_wait(1)
