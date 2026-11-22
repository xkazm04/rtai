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
	for tick: int in table.form(&"tonnage").enter_ticks:
		pilot.drive(stage, TickInput.new())
	assert_true(pilot.ghosts.settled_in(&"tonnage"))


func test_story_can_preserve_mastery_independently_of_the_first_level() -> void:
	stage.watch(QuestSystem.new(CollectCallWorld.new(stage)))
	pilot.ghosts.forms.table.story_transform = false
	_press(&"power_hauler")
	assert_true(pilot.ghosts.settled_in(GhostForms.BASE))
	pilot.ghosts.forms.table.story_transform = true
	_press(&"power_hauler")
	assert_eq(pilot.ghosts.forms.phase, GhostForms.ENTERING)
	stage.watch(null)
