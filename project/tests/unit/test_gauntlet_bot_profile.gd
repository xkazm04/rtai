extends GutTest


func test_shipped_skill_rows_and_threat_weights() -> void:
	var n: BotProfile = BotProfile.shipped(&"novice")
	var a: BotProfile = BotProfile.shipped(&"average")
	var e: BotProfile = BotProfile.shipped(&"expert")
	assert_eq(a.id, &"average")
	assert_gt(n.reaction_ticks, a.reaction_ticks)
	assert_gt(a.reaction_ticks, e.reaction_ticks)
	assert_gt(n.aim_error_deg, e.aim_error_deg)
	assert_lt(n.tells_read, e.tells_read)
	assert_gt(e.threat_weights[&"rocket_trooper"], e.threat_weights[&"patrol_cop"])
	assert_null(BotProfile.shipped(&"missing"))


func test_random_picks_repeat_independently_of_aim_draws() -> void:
	var a: RngRegistry = RngRegistry.new(17)
	var b: RngRegistry = RngRegistry.new(17)
	var p: BotProfile = BotProfile.shipped(&"average")
	var first: BotPick = BotPick.new(&"random", p, a, {})
	var second: BotPick = BotPick.new(&"random", p, b, {})
	var offer: Array[StringName] = [&"a", &"b", &"c"]
	var seen: Dictionary[StringName, bool] = {}
	for wave: int in 30:
		var taken: StringName = first.pick(offer, wave)
		seen[taken] = true
		@warning_ignore("return_value_discarded")
		b.stream(&"test_player_aim").randf()
		assert_eq(taken, second.pick(offer, wave))
	assert_eq(seen.size(), 3)


func test_greedy_uses_kind_and_ref_with_stable_ties() -> void:
	var catalog: Dictionary = {
		"a": {"kind": "ghost", "ref": "kerf"},
		"b": {"kind": "stat", "ref": "damage"},
		"c": {"kind": "weapon", "ref": "gatling"}
	}
	var p: BotPick = BotPick.new(
		&"greedy", BotProfile.shipped(&"expert"), RngRegistry.new(1), catalog
	)
	assert_eq(p.pick([&"a", &"b", &"c"], 4), &"b")
	assert_eq(p.pick([&"c", &"a", &"b"], 9), &"c")
	assert_eq(p.pick([], 1), &"")
