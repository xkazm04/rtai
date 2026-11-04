extends GutTest
## Lane showcase (arena --riot): from wave 2 the pit's first guard is a riot cop with gunplay's
## armored hp, the rest stay plain humans; off by default (the waves and the goldens do not move).


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


## Steps the pit until wave `upto` stands, killing every earlier wave; returns that wave.
func _waves(pit: ArenaPit, arena: CombatArena, upto: int) -> Array[Fighter]:
	arena.rivet.pos = pit.zone.get_center()
	for tick: int in 2000:
		pit.step(arena, tick)
		if pit.wave >= upto and not pit.standing.is_empty():
			return pit.standing.duplicate()
		for f: Fighter in pit.standing:
			f.hp = 0.0
	return []


func _pit(riot: bool) -> ArenaPit:
	var pit: ArenaPit = ArenaPit.from_plan(ArenaPlan.shipped(), ArenaStations.shipped())
	pit.riot_hp = ArenaPit.armored_hp() if riot else 0.0
	return pit


func test_armored_hp_is_gunplays_armored_row() -> void:
	assert_almost_eq(ArenaPit.armored_hp(), 2.5, 0.001, "armored 250 over human 100")


func test_the_second_wave_leads_with_a_riot_cop() -> void:
	var arena: CombatArena = _arena()
	var pit: ArenaPit = _pit(true)
	var first: Array[Fighter] = _waves(pit, arena, 1)
	assert_false(first.is_empty(), "wave 1 came")
	assert_false(pit.riot.has(first[0].id), "wave 1 is plain")
	var second: Array[Fighter] = _waves(pit, arena, 2)
	assert_eq(second.size(), 3)
	var human: float = arena.tuning.human["hp"]
	assert_true(pit.riot.has(second[0].id), "the wave's first guard is a riot cop")
	assert_almost_eq(second[0].max_hp, human * 2.5, 0.001)
	assert_almost_eq(second[0].hp, second[0].max_hp, 0.001)
	assert_almost_eq(second[1].max_hp, human, 0.001, "the rest stay human")


func test_planted_off_by_default_no_riot_cop() -> void:
	var arena: CombatArena = _arena()
	var pit: ArenaPit = _pit(false)
	var second: Array[Fighter] = _waves(pit, arena, 2)
	assert_false(second.is_empty())
	assert_true(pit.riot.is_empty(), "no --riot: no riot cop")
	assert_almost_eq(second[0].max_hp, arena.tuning.human["hp"], 0.001)
