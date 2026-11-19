extends GutTest


func _stage(overrides: Dictionary, city: bool, brain: String = "squad") -> ArenaStage:
	var plan: ArenaPlan = ArenaPlan.shipped()
	plan.pit["max_shooters"] = 3
	plan.pit["squad_mix"] = ["contractor"]
	plan.pit["squad_mix_full"] = ["robot_gunner", "swat"]
	plan.city_squad = overrides
	var options: ArenaArgs = ArenaArgs.parse(["--enemy-brain=" + brain])
	var stage: ArenaStage = ArenaStage.new(plan, ArenaStations.new(), options)
	if city:
		stage.cells = StageCells.shipped()
	var bus: EventBus = autofree(EventBus.new())
	stage.setup(WorldContext.new(bus, null, null, RngRegistry.new(1)))
	return stage


func test_shipped_plan_reads_the_optional_city_squad() -> void:
	var t: DataTable = DataTable.open(ArenaPlan.TABLE, ArenaPlan.SCHEMA)
	var city: Dictionary = t.object(t.raw, "city")
	var expected: Dictionary = city.get("squad", {})
	assert_eq(ArenaPlan.shipped().city_squad, expected)


func test_city_squad_inherits_each_omitted_field() -> void:
	var absent: ArenaStage = _stage({}, true)
	assert_eq(absent.arena.squad_ai.pit.roster.max_shooters, 3)
	assert_eq(absent.pit.squad_mix, [&"contractor"])
	var slots: ArenaStage = _stage({"max_shooters": 4}, true)
	assert_eq(slots.arena.squad_ai.pit.roster.max_shooters, 4)
	assert_eq(slots.pit.squad_mix, [&"contractor"])
	var mix: ArenaStage = _stage({"squad_mix": ["swat", "patrol_cop"]}, true)
	assert_eq(mix.arena.squad_ai.pit.roster.max_shooters, 3)
	assert_eq(mix.pit.squad_mix, [&"swat", &"patrol_cop"])


func test_pit_guard_and_mixed_keep_their_own_rules() -> void:
	var overrides: Dictionary = {"max_shooters": 4, "squad_mix": ["patrol_cop"]}
	var flat: ArenaStage = _stage(overrides, false)
	assert_eq(flat.arena.squad_ai.pit.roster.max_shooters, 3)
	assert_eq(flat.pit.squad_mix, [&"contractor"])
	var mixed: ArenaStage = _stage(overrides, true, "mixed")
	assert_eq(mixed.arena.squad_ai.pit.roster.max_shooters, 3)
	assert_eq(mixed.pit.squad_mix, [&"robot_gunner", &"swat"])
	assert_null(_stage(overrides, true, "guard").arena.squad_ai)
