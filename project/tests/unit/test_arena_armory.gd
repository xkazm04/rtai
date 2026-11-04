extends GutTest


func _carry(first: StringName) -> RivetCarry:
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), ArsenalTable.shipped(), RngRegistry.new(7).stream(&"gunplay")
	)
	@warning_ignore("return_value_discarded")
	carry.add(first)
	return carry


func test_armory_is_off_in_a_plain_run_and_under_a_bot() -> void:
	assert_false(ArenaArmory.active(PackedStringArray(), false))
	assert_true(ArenaArmory.active(PackedStringArray(["--armory"]), false))
	assert_true(ArenaArmory.active(PackedStringArray(), true), "the showcase export lays it")
	assert_false(ArenaArmory.active(PackedStringArray(["--bot=reel"]), true))


func test_every_other_weapon_lies_on_the_floor_once_and_apart() -> void:
	var carry: RivetCarry = _carry(&"pistol")
	var armory: ArenaArmory = ArenaArmory.new()
	armory.lay(carry, Vector2(100.0, 50.0))
	assert_eq(armory.laid, ArenaArmory.ORDER.size() - 1, "all but the held pistol")
	var seen: Dictionary[StringName, bool] = {}
	for it: WeaponPickups.Item in carry.ground.items:
		assert_false(seen.has(it.id), "%s laid once" % it.id)
		seen[it.id] = true
		for other: WeaponPickups.Item in carry.ground.items:
			if other != it:
				assert_gt(it.pos.distance_to(other.pos), WeaponPickups.REACH_M, "apart")
	assert_false(seen.has(&"pistol"), "the held gun is not laid again")


func test_every_armory_weapon_has_a_carry_slot() -> void:
	var carry: RivetCarry = _carry(&"pistol")
	var armory: ArenaArmory = ArenaArmory.new()
	carry.ground.items.clear()
	for id: StringName in ArenaArmory.ORDER:
		assert_gte(carry.slot_of(id), 0, "%s has a carry slot" % id)
	armory.lay(carry, Vector2.ZERO)
	assert_eq(carry.ground.items.size(), armory.laid)
