extends GutTest

const SLOT_FORMS: Array[StringName] = [&"dent", &"kerf", &"ohm", &"tonnage"]

var ctx: WorldContext
var stage: CollectCallStage
var actions: PlayerActions
var pilot: StagePilot
var deploy: GhostDeploy


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	ctx = World.build_context(bus, data, 7)
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(ctx)
	stage.arena.rivet.pos = Vector2.ZERO
	actions = PlayerActions.shipped()
	_reset_pilot()


func _reset_pilot() -> void:
	pilot = StagePilot.new(actions)
	stage.pilot = pilot
	deploy = pilot.ghosts.deploy


func _drive(bits: int = 0, move: int = 0) -> void:
	stage.tick += 1
	stage.intent.clear()
	var word: TickInput = TickInput.new(bits | PlayerCommand.pack_aim(Vector2.RIGHT, actions), move)
	pilot.drive(stage, word)
	if stage.vehicles != null:
		stage.vehicles.step(stage.tick, word)


func _key(slot: int) -> int:
	return 1 << actions.bit(StringName("ghost_deploy_%d" % slot))


func _park(at: Vector2) -> VehicleBody:
	stage.vehicles = VehicleService.new()
	stage.vehicles.setup(ctx)
	stage.vehicles.doors.enabled = false
	return stage.vehicles.spawn_parked(&"sedan", at, Vector2.RIGHT)


func test_each_number_aims_and_releases_its_own_form() -> void:
	for i: int in SLOT_FORMS.size():
		_reset_pilot()
		var id: StringName = SLOT_FORMS[i]
		var selected: StringName = SLOT_FORMS[(i + 1) % SLOT_FORMS.size()]
		pilot.ghosts.forms.selected = selected
		var bit: int = _key(i + 1)
		_drive(bit)
		assert_eq(deploy.phase, GhostDeploy.Phase.AIMING)
		assert_eq(deploy.form, id)
		assert_almost_eq(deploy.spot.x, deploy.strike.attacks.deploy[id].range_m, 0.001)
		_drive(bit)
		assert_true(deploy.cooldowns.is_empty())
		_drive()
		assert_eq(deploy.phase, GhostDeploy.Phase.ACTIVE)
		assert_eq(deploy.strike.release_form, id)
		assert_eq(deploy.cooldowns[id], deploy.strike.attacks.deploy[id].cooldown_ticks)
		assert_eq(pilot.ghosts.forms.selected, selected)


func test_one_is_consumed_on_enter_and_exit_and_other_keys_do_nothing_inside() -> void:
	var car: VehicleBody = _park(Vector2(2, 0))
	var use: int = _key(1) | (1 << actions.bit(&"car"))
	_drive(use)
	assert_same(stage.vehicles.driving, car)
	assert_eq(deploy.phase, GhostDeploy.Phase.IDLE)
	_drive(use)
	_drive()
	_drive(_key(3) | (1 << actions.bit(&"sprint")), 127)
	assert_false(pilot.motion.sprinting)
	assert_eq(stage.intent.move_by, Vector2.ZERO)
	_drive()
	assert_eq(deploy.phase, GhostDeploy.Phase.IDLE)
	_drive(use)
	assert_null(stage.vehicles.driving)
	_drive(use)
	_drive()
	assert_eq(deploy.phase, GhostDeploy.Phase.IDLE)
	assert_true(deploy.cooldowns.is_empty())
	assert_eq(deploy.last_refusal, &"")


func test_one_away_from_the_car_is_immediately_dent() -> void:
	var car: VehicleBody = _park(Vector2(20, 0))
	_drive(_key(1) | (1 << actions.bit(&"car")))
	assert_null(stage.vehicles.driving)
	assert_eq(deploy.phase, GhostDeploy.Phase.AIMING)
	car.pos = Vector2(2, 0)
	_drive(_key(1) | (1 << actions.bit(&"car")))
	_drive()
	assert_eq(deploy.strike.release_form, &"dent")


func test_locked_number_is_silent_but_does_not_block_car_use() -> void:
	pilot.ghosts.forms.apply_locks([])
	_drive(_key(1))
	assert_eq(deploy.phase, GhostDeploy.Phase.IDLE)
	_drive()
	assert_true(deploy.cooldowns.is_empty())
	assert_eq(deploy.last_refusal, &"")
	var car: VehicleBody = _park(Vector2(2, 0))
	_drive(_key(1) | (1 << actions.bit(&"car")))
	assert_same(stage.vehicles.driving, car)
	_drive()
	assert_true(deploy.cooldowns.is_empty())


func test_blocked_door_does_not_consume_a_quick_dent_release() -> void:
	var car: VehicleBody = _park(Vector2.ZERO)
	stage.vehicles.doors.enabled = true
	var use: int = _key(1) | (1 << actions.bit(&"car"))
	_drive(use)
	assert_null(stage.vehicles.doors.car)
	assert_null(stage.vehicles.driving)
	_drive()
	assert_eq(deploy.strike.release_form, &"dent")
	assert_false(car.soul_hijacked)


func test_previous_button_hash_extends_only_for_numbered_inputs() -> void:
	var old: StreamPeerBuffer = StreamPeerBuffer.new()
	pilot._previous = 1 << 32
	pilot.write_state(old)
	var idle: StreamPeerBuffer = StreamPeerBuffer.new()
	pilot._previous = 0
	pilot.write_state(idle)
	assert_eq(old.data_array, idle.data_array, "old selected-deploy input kept its 32-bit layout")
	var wide: StreamPeerBuffer = StreamPeerBuffer.new()
	pilot._previous = _key(1)
	pilot.write_state(wide)
	assert_eq(wide.data_array.size(), idle.data_array.size() + 4)
	var other: StreamPeerBuffer = StreamPeerBuffer.new()
	pilot._previous = _key(4)
	pilot.write_state(other)
	assert_ne(wide.data_array, other.data_array)
