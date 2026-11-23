extends GutTest

var stage: CollectCallStage
var pilot: StagePilot


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot = pilot


func _press(action: StringName) -> void:
	pilot.drive(stage, TickInput.new(1 << pilot.actions.bit(action)))
	pilot.drive(stage, TickInput.new())


func test_shipped_first_level_selects_but_never_enters_on_t() -> void:
	assert_false(pilot.ghosts.transform_unlocked)
	_press(&"power_hauler")
	_press(&"power_gearbox")
	_press(&"power_hauler")
	assert_eq(pilot.ghosts.forms.selected, &"dent")
	assert_true(pilot.ghosts.settled_in(GhostForms.BASE))
	assert_eq(pilot.ghosts.transforms, 0)


func test_mastery_table_allows_the_original_transformation() -> void:
	var table: GhostFormTable = GhostFormTable.load_default()
	table.transform_unlocked = true
	pilot.ghosts = GhostPilot.new(PowerTable.load_default(), table)
	_press(&"power_hauler")
	assert_eq(pilot.ghosts.transforms, 1)
	_press(&"ghost_deploy")
	assert_eq(pilot.ghosts.deploy.last_refusal, &"busy", "Rivet is still entering")
	for tick: int in table.form(&"tonnage").enter_ticks:
		pilot.drive(stage, TickInput.new())
	assert_true(pilot.ghosts.settled_in(&"tonnage"))
	_press(&"ghost_deploy")
	assert_eq(pilot.ghosts.deploy.last_refusal, &"busy", "Rivet is the mastered ghost")
	assert_true(pilot.ghosts.deploy.cooldowns.is_empty())


func test_rivet_stays_base_if_mastery_is_pressed_during_a_deployment() -> void:
	pilot.ghosts.transform_unlocked = true
	_press(&"ghost_deploy")
	_press(&"power_hauler")
	assert_eq(pilot.ghosts.deploy.phase, GhostDeploy.Phase.ACTIVE)
	assert_true(pilot.ghosts.settled_in(GhostForms.BASE))


func test_pilot_replay_detects_the_form_release_latch_and_remaining_lifetime() -> void:
	_press(&"ghost_deploy")
	var ghost: GhostDeploy = pilot.ghosts.deploy
	var original: PackedByteArray = _pilot_state()
	ghost.form = &"dent"
	assert_ne(_pilot_state(), original)
	ghost.form = &"tonnage"
	assert_eq(_pilot_state(), original)
	ghost._held = true
	assert_ne(_pilot_state(), original, "an active ghost can receive another Q press")
	ghost._held = false
	ghost.ticks_left -= 1
	assert_ne(_pilot_state(), original)


func _pilot_state() -> PackedByteArray:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	pilot.ghosts.write_state(out)
	return out.data_array


func test_story_can_preserve_mastery_independently_of_the_first_level() -> void:
	stage.watch(QuestSystem.new(CollectCallWorld.new(stage)))
	pilot.ghosts.forms.table.story_transform = false
	_press(&"power_hauler")
	assert_true(pilot.ghosts.settled_in(GhostForms.BASE))
	pilot.ghosts.forms.table.story_transform = true
	_press(&"power_hauler")
	assert_eq(pilot.ghosts.forms.phase, GhostForms.ENTERING)
	stage.watch(null)
