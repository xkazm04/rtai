extends GutTest


func test_driving_and_door_transitions_stop_a_held_sprint() -> void:
	var actions: PlayerActions = PlayerActions.shipped()
	var pilot: StagePilot = StagePilot.new(actions)
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped(false))
	stage.vehicles = VehicleService.new()
	var car: VehicleBody = VehicleBody.new(1, VehicleProfile.new(), Vector2.ZERO, Vector2.RIGHT)
	var command: PlayerCommand = PlayerCommand.new()
	command.held = 1 << actions.bit(&"sprint")
	command.move = Vector2.RIGHT
	for driving: bool in [true, false]:
		stage.vehicles.driving = car if driving else null
		stage.vehicles.doors.car = null if driving else car
		stage.intent.move_by = pilot.motion.step(command, 6.75, actions)
		assert_ne(stage.intent.move_by, Vector2.ZERO)
		assert_true(pilot.motion.sprinting)
		pilot.motion.drive(stage, pilot, command, 6.75)
		assert_eq(stage.intent.move_by, Vector2.ZERO)
		assert_eq(pilot.motion.velocity(), Vector2.ZERO)
		assert_false(pilot.motion.sprinting)


func test_losing_a_form_while_its_number_is_held_clears_the_aim() -> void:
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped(false))
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 7))
	var actions: PlayerActions = PlayerActions.shipped()
	var pilot: StagePilot = StagePilot.new(actions)
	var deploy: GhostDeploy = pilot.ghosts.deploy
	var forms: GhostForms = pilot.ghosts.forms
	var c: PlayerCommand = PlayerCommand.new()
	c.aim = Vector2.RIGHT
	c.held = 1 << actions.bit(&"ghost_deploy_1")
	c.pressed = c.held
	deploy.step(stage, c, actions, forms)
	assert_eq(deploy.phase, GhostDeploy.Phase.AIMING)
	forms.apply_locks([])
	c.pressed = 0
	deploy.step(stage, c, actions, forms)
	assert_eq(deploy.phase, GhostDeploy.Phase.IDLE)
	assert_eq(deploy.held_form(forms), &"")
	c.held = 0
	deploy.step(stage, c, actions, forms)
	assert_true(deploy.cooldowns.is_empty())
