extends GutTest
## n31 ghost 26: a refused ghost press is counted once per press edge (GhostDeploy.refusals and
## refused_form, view-only) so the HUD chip can answer it.

var stage: CollectCallStage
var pilot: StagePilot
var ghost: GhostDeploy
var key: int


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	stage.arena.rivet.pos = Vector2.ZERO
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	key = 1 << pilot.actions.bit(&"ghost_deploy")


func _drive(bits: int = 0) -> void:
	stage.tick += 1
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 6.0)
	pilot.drive(stage, TickInput.new(aim | bits))


func test_a_cooldown_press_is_counted_once_and_names_the_form() -> void:
	pilot.ghosts.forms.selected = &"tonnage"
	_drive(key)
	assert_eq(ghost.refusals, 0, "an accepted press is no refusal")
	assert_true(ghost.cooldowns.has(&"tonnage"))
	_drive()
	while ghost.phase != GhostDeploy.Phase.IDLE:
		_drive()
	assert_true(ghost.cooldowns.has(&"tonnage"), "still cooling")
	_drive(key)
	assert_eq(ghost.last_refusal, &"cooldown")
	assert_eq(ghost.refusals, 1)
	assert_eq(ghost.refused_form, &"tonnage")
	for tick: int in 10:
		_drive(key)
	assert_eq(ghost.refusals, 1, "holding the key is one press")
	_drive()
	_drive(key)
	assert_eq(ghost.refusals, 2, "a second press edge counts again")


func test_a_kerf_press_with_no_target_is_counted_and_spends_no_cooldown() -> void:
	pilot.ghosts.forms.selected = &"kerf"
	_drive(key)
	assert_eq(ghost.last_refusal, &"no_target")
	assert_eq(ghost.refusals, 1)
	assert_eq(ghost.refused_form, &"kerf")
	assert_false(ghost.cooldowns.has(&"kerf"))
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)


func test_the_counter_never_enters_the_replay_state() -> void:
	pilot.ghosts.forms.selected = &"kerf"
	var before: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(before)
	_drive(key)
	_drive()
	var after: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(after)
	assert_eq(ghost.refusals, 1)
	assert_eq(after.data_array, before.data_array)
