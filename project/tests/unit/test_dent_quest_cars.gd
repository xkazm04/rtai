extends GutTest
## Quest 1's ghost cars (collect_call_city.json ghost_cars, ArenaCars.attach_at): the city layout
## parks them, and on quest 1's stage (CollectCallStage, no ArenaStage) Dent's fire press seizes
## the car on his aim, drives it and heats it, where before it could only miss.

var _bus: EventBus
var _data: DataStore
var _stage: CollectCallStage
var _pilot: StagePilot


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	var ctx: WorldContext = World.build_context(_bus, _data, 1)
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(ctx)
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)
	var svc: VehicleService = autofree(VehicleService.new())
	svc.setup(ctx)
	_stage.vehicles = svc


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


func test_city_layout_parks_the_ghost_cars() -> void:
	assert_eq(StageLayout.shipped(true).ghost_cars.size(), 3, "three cars on quest 1's street")
	assert_eq(StageLayout.shipped(false).ghost_cars.size(), 0, "none on the invented arena")


func test_fire_in_dent_seizes_the_quest_car_on_the_aim() -> void:
	_into_dent()
	var rivet: Fighter = _stage.arena.rivet
	var car: VehicleBody = _stage.vehicles.spawn_parked(
		&"sedan", rivet.pos + rivet.facing.normalized() * 6.0, Vector2.RIGHT
	)
	var dent: DentStage = _pilot.ghosts.dent
	_press(&"fire")
	assert_eq(dent.seizes, 1, "the car on the aim is seized")
	assert_eq(dent.misses, 0, "no miss with a car in reach")
	assert_eq(dent.car, car)
	assert_true(car.soul_hijacked, "the teal plate shows")
	var at: Vector2 = car.pos
	_ticks(30)
	assert_gt(dent.heat, 0.0, "the seized car heats")
	assert_ne(car.pos, at, "Dent drives it")
