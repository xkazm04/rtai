extends GutTest
## features/souls DentStage on quest 1's stage (no car service): in the settled Dent form the fire
## press still answers with a reach that misses (miss_tick, miss_to along the aim, the view's
## fraying tether), and nothing else in the sim moves; outside Dent the press is not a reach.

var _bus: EventBus
var _data: DataStore
var _stage: CollectCallStage
var _pilot: StagePilot


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(_bus, _data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)


func _press(action: StringName) -> void:
	var buttons: int = 1 << _pilot.actions.bit(action) if action != &"" else 0
	_pilot.drive(_stage, TickInput.new(buttons, 0, 0))
	_stage.intent.clear()


func _ticks(n: int) -> void:
	for i: int in n:
		_press(&"")


func _into_dent() -> void:
	var forms: GhostForms = _pilot.ghosts.forms
	_press(&"power_hauler")
	_ticks(forms.table.form(&"tonnage").enter_ticks)
	_press(&"power_gearbox")
	_ticks(forms.table.switch_ticks)
	assert_true(_pilot.ghosts.settled_in(&"dent"))


func test_fire_in_dent_without_cars_is_a_miss_along_the_aim() -> void:
	_into_dent()
	var dent: DentStage = _pilot.ghosts.dent
	_press(&"fire")
	assert_eq(dent.misses, 1, "one reach")
	assert_null(dent.car, "nothing seized")
	assert_eq(dent.seizes, 0)
	var rivet: Fighter = _stage.arena.rivet
	var ahead: float = (dent.miss_to - rivet.pos).dot(rivet.facing.normalized())
	assert_almost_eq(ahead, dent.num(&"aim_m"), 0.01, "the reach goes aim_m along his facing")


func test_fire_in_base_is_no_reach() -> void:
	_press(&"fire")
	assert_eq(_pilot.ghosts.dent.misses, 0)
