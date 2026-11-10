extends GutTest
## Attack skips at every position, changing eligibility, and long runs of failed attempts.
## Fixtures use synthetic counter snapshots; no city assets or tuned quotas are involved.

const STREET: Array[int] = [
	CitySpawnPlan.COPS, CitySpawnPlan.POLICE_CARS, CitySpawnPlan.CARS, CitySpawnPlan.PEDS
]
const RIOT: Array[int] = [
	CitySpawnPlan.RIOTERS, CitySpawnPlan.COPS, CitySpawnPlan.POLICE_CARS, CitySpawnPlan.CARS
]
const SLOTS: Array[int] = [
	SimConst.CN_PEDS, SimConst.CN_COPS, SimConst.CN_PCARS, SimConst.CN_CARS, SimConst.CN_PEDS
]


func test_every_consecutive_window_rotates_only_among_unfilled_street_kinds() -> void:
	# Each slot independently has quota zero, quota one already met, or quota one missing.
	for pattern: int in 81:
		_check_windows(STREET, pattern)


func test_every_consecutive_window_rotates_only_among_unfilled_riot_kinds() -> void:
	# Keep the riot quota positive so this exercises the riot branch in every pattern.
	for pattern: int in 27:
		_check_windows(RIOT, pattern * 3 + 1)
		_check_windows(RIOT, pattern * 3 + 2)


func test_one_remaining_kind_survives_many_skips_and_stops_exactly_at_its_quota() -> void:
	for kinds: Array[int] in [STREET, RIOT]:
		for survivor: int in kinds:
			var quotas: PackedInt32Array = PackedInt32Array([0, 0, 0, 0, 0])
			var counters: PackedInt32Array = _counters()
			for cat: int in kinds:
				quotas[cat] = 1
				counters[SLOTS[cat]] = 1
			counters[SLOTS[survivor]] = 0
			var plan: CitySpawnPlan = CitySpawnPlan.new(_targets(quotas), counters)
			for attempt: int in 257:
				assert_eq(plan.next(), survivor, "full neighbors cannot hide the last deficit")
			assert_eq(plan.made, 0, "failed attempts must not fill the quota")
			plan.add(survivor)
			for attempt: int in 17:
				assert_eq(plan.next(), -1, "the final successful addition ends the plan")
			assert_eq(plan.made, 1)


func test_a_quota_met_mid_rotation_is_skipped_without_giving_its_neighbor_extra_turns() -> void:
	var targets: CityTargets = CityTargets.street(3, 3, 1)
	targets.cops = 3
	var plan: CitySpawnPlan = CitySpawnPlan.new(targets, _counters())
	assert_eq(plan.next(), CitySpawnPlan.COPS)
	assert_eq(plan.next(), CitySpawnPlan.POLICE_CARS)
	plan.add(CitySpawnPlan.POLICE_CARS)
	var expected: Array[int] = [CitySpawnPlan.CARS, CitySpawnPlan.PEDS, CitySpawnPlan.COPS]
	for cycle: int in 19:
		for cat: int in expected:
			assert_eq(plan.next(), cat, "retiring the middle slot must preserve cyclic order")
	assert_eq(plan.made, 1, "turns after retirement are still failed attempts")


func test_uneven_quotas_keep_rotating_as_successes_retire_each_kind() -> void:
	# Move the long tail and the single spawn through every position, in both branches.
	for kinds: Array[int] in [STREET, RIOT]:
		for offset: int in kinds.size():
			var quotas: PackedInt32Array = PackedInt32Array([0, 0, 0, 0, 0])
			var amounts: Array[int] = [1, 257, 2, 31]
			for index: int in kinds.size():
				quotas[kinds[index]] = amounts[(index + offset) % amounts.size()]
			_check_retiring_queue(kinds, quotas)


func test_riot_counts_all_existing_peds_and_never_opens_a_second_ped_quota() -> void:
	for population: int in [0, 1, 2, 7]:
		var targets: CityTargets = CityTargets.riot(2, 1)
		targets.peds = 257
		var counters: PackedInt32Array = _counters()
		counters[SimConst.CN_PEDS] = population
		var plan: CitySpawnPlan = CitySpawnPlan.new(targets, counters)
		var missing: int = maxi(0, targets.rioters - population)
		if missing > 0:
			assert_eq(plan.next(), CitySpawnPlan.RIOTERS)
			plan.add(CitySpawnPlan.RIOTERS)
		assert_eq(plan.next(), CitySpawnPlan.COPS)
		plan.add(CitySpawnPlan.COPS)
		for remaining: int in maxi(0, missing - 1):
			assert_eq(plan.next(), CitySpawnPlan.RIOTERS)
			plan.add(CitySpawnPlan.RIOTERS)
		for attempt: int in 33:
			assert_eq(plan.next(), -1, "ordinary peds cannot create extra riot demand")
		assert_eq(plan.made, missing + 1)


func _check_windows(kinds: Array[int], pattern: int) -> void:
	var quotas: PackedInt32Array = PackedInt32Array([0, 0, 0, 0, 0])
	var counters: PackedInt32Array = _counters()
	var active: Array[int] = []
	var digits: int = pattern
	for cat: int in kinds:
		var status: int = digits % 3
		digits = floori(float(digits) / 3.0)
		quotas[cat] = mini(status, 1)
		counters[SLOTS[cat]] = 1 if status == 1 else 0
		if status == 2:
			active.append(cat)
	var plan: CitySpawnPlan = CitySpawnPlan.new(_targets(quotas), counters)
	var window: Array[int] = []
	for attempt: int in 67:
		var cat: int = plan.next()
		var context: String = "kinds=%s pattern=%d call=%d" % [kinds, pattern, attempt]
		if active.is_empty():
			assert_eq(cat, -1, context)
			continue
		assert_has(active, cat, "only an unfinished kind gets a turn: " + context)
		window.append(cat)
		if window.size() > active.size():
			window.remove_at(0)
		if window.size() == active.size():
			for eligible: int in active:
				assert_eq(window.count(eligible), 1, "every sliding window is fair: " + context)
	assert_eq(plan.made, 0, "next alone cannot consume any deficit")


func _check_retiring_queue(kinds: Array[int], quotas: PackedInt32Array) -> void:
	var plan: CitySpawnPlan = CitySpawnPlan.new(_targets(quotas), _counters())
	var queue: Array[int] = kinds.duplicate()
	var remaining: PackedInt32Array = quotas.duplicate()
	var successes: int = 0
	for attempt: int in 4096:
		if queue.is_empty():
			break
		var expected: int = queue[0]
		queue.remove_at(0)
		var actual: int = plan.next()
		assert_eq(actual, expected, "queue order after skips/retirements, call %d" % attempt)
		if actual != expected:
			return
		# Failed attempts yield their turn but preserve their remaining quota.
		if attempt % 7 != 0:
			plan.add(actual)
			remaining[actual] -= 1
			successes += 1
		if remaining[expected] > 0:
			queue.append(expected)
	assert_true(queue.is_empty(), "every deficit must eventually be filled")
	assert_eq(plan.made, successes, "only successful additions consume the budget")
	for cat: int in kinds:
		assert_eq(remaining[cat], 0, "each quota must be filled exactly")
	for attempt: int in 33:
		assert_eq(plan.next(), -1, "completion remains stable after a long uneven rotation")


func _counters() -> PackedInt32Array:
	var counters: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	counters.resize(SimConst.CN_COUNT)
	counters.fill(0)
	return counters


func _targets(quotas: PackedInt32Array) -> CityTargets:
	var targets: CityTargets = CityTargets.new()
	targets.rioters = quotas[CitySpawnPlan.RIOTERS]
	targets.cops = quotas[CitySpawnPlan.COPS]
	targets.police_cars = quotas[CitySpawnPlan.POLICE_CARS]
	targets.cars = quotas[CitySpawnPlan.CARS]
	targets.peds = quotas[CitySpawnPlan.PEDS]
	return targets
