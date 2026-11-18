extends GutTest
## n18 police item 6: on the slice boot quest 1's own HeatMeter drives the city's sim police
## (CityHeat.mount_quest, heat.json city.quest1): the sim runs at the stage's level (the quest opens
## at start_heat 2) and the city's foot cops are claimed for the last-seen point while the stage
## patrols stay. Before item 6 the quest's sim ran at heat -1 (the pre-n18 police) and nobody was
## engaged.

const TICKS: int = 240


func test_quest_1_heat_drives_the_city_sim_police() -> void:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var was: bool = Quest1Session.on_city
	Quest1Session.on_city = true
	var s: Quest1Session = Quest1Session.open(bus, data)
	Quest1Session.on_city = was
	assert_not_null(s, "quest 1 opens on the city")
	if s != null:
		var engaged: int = 0
		for t: int in TICKS:
			s.step()
			engaged = maxi(engaged, s.city.sim.flow_stats()[SimConst.FS_ENGAGED])
		assert_not_null(s.stage.city_heat, "the city heat is mounted")
		assert_eq(s.city.sim.heat_level(), s.stage.heat.level, "the sim runs at the stage's level")
		assert_gt(s.stage.heat.level, 0, "the quest opens hot")
		assert_false(s.stage.patrol_pos.is_empty(), "the stage patrols stay")
		gut.p(
			(
				"quest 1: sim heat %d, up to %d city foot cops engaged"
				% [s.city.sim.heat_level(), engaged]
			)
		)
		assert_gt(engaged, 0, "city foot cops answer the quest's heat")
		s.world.free()
	bus.free()
	data.free()
