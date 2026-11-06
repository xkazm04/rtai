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


## GhostPilot: G picks the ghost (order tonnage, dent, kerf, ohm), Q transforms, and the attack
## waits for the settled form.
func _take() -> void:
	while _pilot.ghosts.forms.selected != KerfStage.GHOST:
		_press(&"power_gearbox")
		_press(&"")
	_press(&"power_hauler")
	for i: int in _pilot.ghosts.forms.table.form(KerfStage.GHOST).enter_ticks + 1:
		_press(&"")


func test_the_blink_cuts_the_target_in_the_cone_and_lands_behind_it() -> void:
	var target: Fighter = _guard(Vector2(6.0, 0.5))
	var aside: Fighter = _guard(Vector2(0.0, 5.0))  # 90 degrees off the aim: outside the cone
	var start: Vector2 = _stage.arena.rivet.pos
	_take()
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
	_take()
	_wait(2)
	_press(&"melee")
	var k: float = _pilot.kerf.num(&"robot_damage")
	assert_almost_eq(robot.hp, 6.0 - k, 0.001, "a robot takes robot_damage, not the one-shot")


func test_no_target_is_a_dash_and_the_chain_runs_dry_then_recharges() -> void:
	var kerf: KerfStage = _pilot.kerf
	var n: int = int(kerf.num(&"charges"))
	var gap: int = PowerDef.ticks(kerf.num(&"gap_s"))
	_take()
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


## The owner's call (path_cut_m): the built 0 cuts only the target; above 0 the body standing on
## the blink line falls to the same pass.
func test_path_cut_spares_the_body_on_the_line_unless_set() -> void:
	for width: float in [0.0, 0.6]:
		var target: Fighter = _guard(Vector2(6.0, 0.0))
		var on_line: Fighter = _guard(Vector2(3.0, 0.3))  # 5.7 deg off the aim: not the pick
		_pilot.kerf.attacks.block(KerfStage.GHOST)["path_cut_m"] = width
		_take()
		_wait(2)
		_press(&"melee")
		assert_false(target.alive(), "the pick is cut (path_cut_m %s)" % width)
		assert_eq(on_line.alive(), width == 0.0, "the body on the line (path_cut_m %s)" % width)
		before_each()


## n7-melee KerfView's sight (view only): it names the body the next press cuts, dims on the
## blink and is full again once gap_s has run; the aim it reads stays out of the sim state.
func test_the_sight_names_the_next_cut_and_refills_with_the_gap() -> void:
	var kerf: KerfStage = _pilot.kerf
	var first: Fighter = _guard(Vector2(6.0, 0.5))
	var second: Fighter = _guard(Vector2(10.0, 0.4))
	_take()
	_wait(2)
	assert_eq(kerf.pick(_stage, kerf.sight_aim), first, "the sight is on the nearer cut")
	assert_eq(kerf.ready_k(), 1.0, "full before the first blink")
	_press(&"melee")
	assert_false(first.alive(), "the first is cut")
	assert_eq(kerf.ready_k(), 0.0, "dim on the blink tick")
	assert_eq(kerf.pick(_stage, kerf.sight_aim), second, "the sight moves on to the next")
	_wait(PowerDef.ticks(kerf.num(&"gap_s")))
	assert_eq(kerf.ready_k(), 1.0, "full again once the gap has run")
	var before: PackedByteArray = _state(kerf)
	kerf.sight_aim = Vector2.DOWN
	assert_eq(_state(kerf), before, "the sight's aim is not sim state")


func test_the_sight_alpha_floors_fills_and_needs_a_charge() -> void:
	var floor_a: float = KerfView.sight_alpha(1.0, 0.0, 3)
	assert_gt(floor_a, 0.0, "the next target is named at once")
	assert_lt(floor_a, KerfView.sight_alpha(1.0, 0.5, 3), "it brightens as the gap refills")
	assert_eq(KerfView.sight_alpha(1.0, 1.0, 3), 1.0, "full when ready")
	assert_eq(KerfView.sight_alpha(1.0, 1.0, 0), 0.0, "none without a charge")
	assert_eq(KerfView.sight_alpha(0.0, 1.0, 3), 0.0, "sight_k 0 = none (the before)")


func _state(kerf: KerfStage) -> PackedByteArray:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	kerf.write_state(out)
	return out.data_array
