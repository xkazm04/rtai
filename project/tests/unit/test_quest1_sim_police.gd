extends GutTest
## n18 police item 6, `--sim-police` (StagePolice.sim_police): on the city quest 1's scripted stage
## patrols leave and the city's sim cops replace them (heat.json city.quest1_sim_police_cops kept
## by the city patrol); a sim cop with Rivet in sight is the patrol that sees him while he is hot.
## Off (the default) the stage patrols stay (test_quest1_city_heat).

const TICKS: int = 240


func after_each() -> void:
	StagePolice.sim_police = false


func test_sim_police_replaces_the_stage_patrols() -> void:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var was: bool = Quest1Session.on_city
	Quest1Session.on_city = true
	StagePolice.sim_police = true
	var s: Quest1Session = Quest1Session.open(bus, data)
	Quest1Session.on_city = was
	assert_not_null(s, "quest 1 opens on the city")
	if s != null:
		var stage: CollectCallStage = s.stage
		assert_false(stage.layout.patrols.is_empty(), "the layout has stage patrols to replace")
		for t: int in TICKS:
			s.step()
		var cops: int = s.city.sim.get_counters()[SimConst.CN_COPS]
		gut.p(
			(
				"--sim-police: %d stage patrols, %d sim cops after %d ticks"
				% [stage.patrol_pos.size(), cops, TICKS]
			)
		)
		assert_true(stage.patrol_pos.is_empty(), "the stage patrols left")
		var want: int = stage.city_heat.tune.quest1_sim_police_cops
		assert_eq(stage.city_heat.patrol.want, want, "the city patrol keeps the replacements")
		assert_gte(cops, want, "the sim cops are on the street")
		var at: Vector2 = stage.arena.rivet.pos
		var sees: bool = CityHeat.cop_sees(s.city.sim, at, stage.heat.sight_m)
		assert_eq(
			StagePolice.seen(stage), sees or _guard_sees(stage), "a sim cop's sight is the patrols'"
		)
		s.world.free()
	bus.free()
	data.free()


func _guard_sees(stage: CollectCallStage) -> bool:
	for h: Fighter in stage.arena.hostiles:
		if h.alive() and h.pos.distance_to(stage.arena.rivet.pos) <= stage.heat.sight_m * 2.0:
			return true
	return false
