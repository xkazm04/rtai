extends GutTest
## t-1 (n11 Call 1): a full category must not hand its turn to the next kind twice in a row.
## next() skips full kinds; the turn has to advance past the kind it returned, not by one.


func _counters() -> PackedInt32Array:
	var counters: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	counters.resize(SimConst.CN_COUNT)
	counters.fill(0)
	return counters


func test_a_full_kind_does_not_give_the_next_kind_two_turns() -> void:
	var targets: CityTargets = CityTargets.street(0, 1, 1)
	targets.cops = 1
	var counters: PackedInt32Array = _counters()
	counters[SimConst.CN_COPS] = 1
	var plan: CitySpawnPlan = CitySpawnPlan.new(targets, counters)
	var got: Array[int] = []
	for attempt: int in 4:
		got.append(plan.next())
	var want: Array[int] = [
		CitySpawnPlan.POLICE_CARS, CitySpawnPlan.CARS, CitySpawnPlan.POLICE_CARS, CitySpawnPlan.CARS
	]
	assert_eq(got, want, "failed attempts alternate between the two unfilled kinds")


func test_unfilled_kinds_get_equal_turns_whatever_is_full() -> void:
	var targets: CityTargets = CityTargets.street(5, 5, 5)
	targets.cops = 5
	var counters: PackedInt32Array = _counters()
	counters[SimConst.CN_PCARS] = 5
	var plan: CitySpawnPlan = CitySpawnPlan.new(targets, counters)
	var turns: Dictionary[int, int] = {}
	for attempt: int in 30:
		var cat: int = plan.next()
		var seen: int = turns.get(cat, 0)
		turns[cat] = seen + 1
	assert_false(turns.has(CitySpawnPlan.POLICE_CARS), "a full kind gets no turn")
	for cat: int in [CitySpawnPlan.COPS, CitySpawnPlan.CARS, CitySpawnPlan.PEDS]:
		var count: int = turns.get(cat, 0)
		assert_eq(count, 10, "each of three unfilled kinds gets a third of 30 turns")
