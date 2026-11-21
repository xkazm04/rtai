extends GutTest


func _draw(seed_value: int) -> GauntletDraw:
	var table: DataTable = DataTable.new()
	table.raw["rows"] = [
		{"id": "swift", "kind": "stat", "ref": "speed", "weight": 3, "min_wave": 1},
		{"id": "fast", "kind": "stat", "ref": "speed", "weight": 1, "min_wave": 1},
		{"id": "ohm", "kind": "ghost", "ref": "ohm", "weight": 2, "min_wave": 2},
		{"id": "blade", "kind": "weapon", "ref": "katana", "weight": 1, "min_wave": 2},
		{"id": "other_blade", "kind": "weapon", "ref": "katana", "weight": 1, "min_wave": 3},
	]
	return GauntletDraw.new(RngRegistry.new(seed_value), table)


func test_first_slot_follows_the_three_to_one_weights() -> void:
	var draw: GauntletDraw = _draw(19)
	var swift: int = 0
	for sample: int in 4000:
		var ids: Array[StringName] = draw.offer(1, [], [])
		assert_eq(ids.size(), 2)
		assert_ne(ids[0], ids[1])
		swift += int(ids[0] == &"swift")
	assert_between(swift, 2850, 3150)


func test_history_ownership_unlocks_and_exhaustion() -> void:
	var draw: GauntletDraw = _draw(7)
	var history: Array[Dictionary] = [{"taken": &"swift"}, {"taken": &"blade"}]
	assert_eq(draw.offer(0, [], []), [])
	assert_eq(draw.offer(1, history, []), [&"fast"])
	assert_eq(draw.offer(3, history, [&"ohm"]), [&"fast"])
	history.append({"taken": &"fast"})
	assert_eq(draw.offer(3, history, [&"ohm"]), [])
	assert_eq(draw.offer(3, history, []), [&"ohm"])


func test_seed_and_history_repeat_without_duplicates() -> void:
	var a: GauntletDraw = _draw(7)
	var b: GauntletDraw = _draw(7)
	for n: int in range(2, 25):
		var offered: Array[StringName] = a.offer(n, [], [])
		assert_eq(offered, b.offer(n, [], []))
		assert_eq(offered.size(), 3)
		for id: StringName in offered:
			assert_eq(offered.count(id), 1)


func test_seeded_offers_consume_one_ticket_per_remaining_weighted_pool() -> void:
	var draw: GauntletDraw = _draw(19)
	var tickets: RandomNumberGenerator = RngRegistry.new(19).stream(&"gauntlet_offers")
	for sample: int in 40:
		var swift_first: bool = tickets.randi_range(1, 4) <= 3
		var first: StringName = &"swift" if swift_first else &"fast"
		var second: StringName = &"fast" if swift_first else &"swift"
		# Only the other row remains for slot two. The next offer starts after this ticket.
		@warning_ignore("return_value_discarded")
		tickets.randi_range(1, 1 if swift_first else 3)
		assert_eq(draw.offer(1, [], []), [first, second])
