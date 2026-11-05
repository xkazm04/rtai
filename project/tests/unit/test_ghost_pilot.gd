extends GutTest
## features/souls GhostPilot through the bound StagePilot on quest 1's stage: Q enters the
## selected ghost (Tonnage first) and plays the whole transformation before the form settles,
## G in a form switches straight to the next ghost (the teal flash, one SoulPowers: one form at a
## time), Q in a form goes back to base, and a light form moves at its own top speed.

var _bus: EventBus
var _data: DataStore
var _stage: CollectCallStage
var _pilot: StagePilot
var _walked: float = 0.0


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(_bus, _data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)


func _press(action: StringName, move_x: int = 0) -> void:
	var buttons: int = 1 << _pilot.actions.bit(action) if action != &"" else 0
	_pilot.drive(_stage, TickInput.new(buttons, move_x, 0))
	_walked += _stage.intent.move_by.length()
	_stage.intent.clear()


func _ticks(n: int, move_x: int = 0) -> void:
	for i: int in n:
		_press(&"", move_x)


func _forms() -> GhostForms:
	return _pilot.ghosts.forms


func test_q_enters_tonnage_and_settles_after_enter_s() -> void:
	_press(&"power_hauler")
	assert_eq(_forms().phase, GhostForms.ENTERING)
	assert_eq(_forms().current(), GhostForms.BASE, "no form (no attacks) mid-transformation")
	_ticks(_forms().table.form(&"tonnage").enter_ticks)
	assert_true(_pilot.ghosts.settled_in(&"tonnage"))
	assert_true(_pilot.ghosts.owns_melee(), "Tonnage owns the melee press")


func test_g_in_a_form_switches_to_the_next_and_q_returns_to_base() -> void:
	_press(&"power_hauler")
	_ticks(_forms().table.form(&"tonnage").enter_ticks)
	_press(&"power_gearbox")
	assert_eq(_forms().phase, GhostForms.SWITCHING)
	assert_true(_pilot.ghosts.powers.is_active(&"gearbox"), "Dent's power runs, Tonnage's ended")
	assert_false(_pilot.hauler.form.on, "the tank is off once the switch starts")
	_ticks(_forms().table.switch_ticks)
	assert_true(_pilot.ghosts.settled_in(&"dent"))
	_press(&"power_hauler")
	assert_eq(_forms().phase, GhostForms.EXITING)
	_ticks(_forms().table.form(&"dent").exit_ticks)
	assert_eq(_forms().current(), GhostForms.BASE)
	assert_true(_forms().check().is_empty(), "every transformation played whole")


func test_a_press_mid_transformation_is_refused() -> void:
	_press(&"power_hauler")
	_ticks(3)
	_press(&"power_gearbox")
	_press(&"power_hauler")
	assert_eq(_forms().history.size(), 1, "G and Q mid-morph were refused")


func test_kerf_runs_faster_than_rivet_walks() -> void:
	_press(&"power_gearbox")  # Tonnage -> Dent
	_ticks(1)
	_press(&"power_gearbox")  # Dent -> Kerf
	assert_eq(_forms().selected, &"kerf")
	_press(&"power_hauler")
	_ticks(_forms().table.form(&"kerf").enter_ticks)
	_ticks(30, TickInput.AXIS_MAX)  # up to speed
	_walked = 0.0
	_ticks(60, TickInput.AXIS_MAX)
	var walk: float = _stage.arena.tuning.rivet["walk_mps"]
	var moved: float = _walked
	assert_eq(_forms().current(), &"kerf")
	assert_gt(moved, walk * 1.4, "Kerf covers ground faster than Rivet's walk (%.1f m)" % moved)
