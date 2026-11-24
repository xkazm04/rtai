extends GutTest
## The test player takes every offered mastery first, then picks among the rest as before.


func _picker(mode: StringName) -> BotPick:
	var pilot: GauntletTestPlayer = GauntletTestPlayer.new()
	pilot.configure(&"average", mode, 7)
	return pilot._picker


func test_greedy_takes_both_masteries_then_the_best_normal_card() -> void:
	var picker: BotPick = _picker(&"greedy")
	var hand: Array[StringName] = [&"stat_regen_10", &"master_kerf", &"master_ohm"]
	assert_eq(picker.pick(hand, 3), &"master_kerf")
	hand.erase(&"master_kerf")
	assert_eq(picker.pick(hand, 3), &"master_ohm")
	hand.erase(&"master_ohm")
	assert_eq(picker.pick(hand, 3), &"stat_regen_10")


func test_random_still_takes_masteries_first_and_then_stays_inside_the_rest() -> void:
	var picker: BotPick = _picker(&"random")
	var hand: Array[StringName] = [&"stat_regen_10", &"master_kerf", &"stat_damage_10"]
	assert_eq(picker.pick(hand, 3), &"master_kerf")
	hand.erase(&"master_kerf")
	for i: int in range(20):
		assert_has([&"stat_regen_10", &"stat_damage_10"], picker.pick(hand, 3))
