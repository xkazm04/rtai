extends GutTest

var actions: PlayerActions
var arena: CombatArena
var carry: RivetCarry
var wheel: RivetWheel


func before_each() -> void:
	LaunchArgs.parse(["--controls=wheel"])
	actions = PlayerActions.shipped()
	var rng: RngRegistry = RngRegistry.new(22)
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, rng.stream(&"combat"))
	carry = RivetCarry.new(WeaponTable.shipped(), ArsenalTable.shipped(), rng.stream(&"gunplay"))
	wheel = RivetWheel.new(carry)


func after_each() -> void:
	LaunchArgs.parse()


func _press(action: StringName = &"") -> void:
	arena.tick += 1
	var bits: int = 0 if action == &"" else 1 << actions.bit(action)
	wheel.step(PlayerCommand.decode(TickInput.new(bits), 0, actions), actions, arena)


func _take_three() -> void:
	for id: StringName in [&"katana", &"pistol", RivetCarry.RIFLE]:
		carry.take(id, arena)


func test_empty_wheel_keeps_hands_even_when_scrolled() -> void:
	assert_eq(wheel.order(), [&"hands"])
	assert_eq(wheel.selected(), &"hands")
	assert_eq(wheel.switched_tick, -1)
	for key: StringName in [&"weapon_next", &"weapon_prev", &"weapon_slot_4"]:
		_press(key)
		assert_eq(wheel.selected(), &"hands")
		assert_eq(wheel.switched_tick, -1)
	assert_null(arena.gun)
	assert_eq(arena.rivet.weapon, &"")


func test_melee_and_guns_keep_first_pickup_order_even_in_shared_grips() -> void:
	for id: StringName in [&"plasma_rifle", &"katana", &"pistol", &"chainsaw", &"katana"]:
		carry.take(id, arena)
	assert_eq(wheel.order(), [&"hands", &"katana", &"chainsaw", &"plasma_rifle", &"pistol"])
	assert_eq(wheel.selected(), &"hands")
	assert_eq(carry.slots[1], &"katana")
	_press(&"weapon_slot_2")
	assert_eq(arena.rivet.weapon, &"katana")


func test_next_and_prev_wrap_once_and_stow_to_bare_hands() -> void:
	_take_three()
	var ids: Array[StringName] = [&"hands", &"katana", &"pistol", RivetCarry.RIFLE]
	assert_eq(wheel.order(), ids)
	for i: int in range(1, ids.size() + 1):
		_press(&"weapon_next")
		var id: StringName = ids[i % ids.size()]
		assert_eq(wheel.selected(), id)
		assert_eq(arena.rivet.weapon, &"" if id == &"hands" else id)
		assert_eq(wheel.switched_tick, arena.tick)
	assert_null(arena.gun)
	assert_eq(carry.current, -1)
	for i: int in range(ids.size() - 1, -1, -1):
		_press(&"weapon_prev")
		assert_eq(wheel.selected(), ids[i])
	assert_eq(carry.switches, 8)


func test_four_shortcuts_keep_the_latest_pickup_and_draw_the_same_magazine() -> void:
	_take_three()
	carry.take(&"rocket_launcher", arena)
	carry.take(&"molotov", arena)
	_press(&"weapon_next")
	assert_eq(wheel.selected(), &"katana")
	var ids: Array[StringName] = [&"pistol", RivetCarry.RIFLE, &"rocket_launcher", &"molotov"]
	for i: int in RivetCarry.SLOTS:
		_press(RivetCarry.SLOT_ACTIONS[i])
		assert_eq(wheel.selected(), ids[i])
		assert_eq(arena.rivet.weapon, ids[i])
	_press(&"weapon_slot_1")
	var hand: GunHand = arena.gun
	hand.trigger.ammo = 1
	_press(&"weapon_slot_2")
	_press(&"weapon_slot_1")
	assert_same(arena.gun, hand)
	assert_eq(hand.trigger.ammo, 1)
	_press(&"reload")
	assert_true(hand.trigger.reloading())


func test_floor_pickup_keeps_displaced_grip_item_and_duplicates_refill() -> void:
	assert_true(carry.ground.collect(&"katana", false, arena, carry))
	assert_false(carry.ground.collect(RivetCarry.RIFLE, false, arena, carry))
	carry.ground.drop(RivetCarry.RIFLE, arena.rivet.pos)
	_press(&"interact")
	assert_true(carry.ground.items.is_empty())
	assert_eq(wheel.order(), [&"hands", &"katana", RivetCarry.RIFLE])
	assert_eq(carry.slots[1], RivetCarry.RIFLE)
	carry.take(&"pistol", arena)
	_press(&"weapon_slot_1")
	arena.gun.trigger.ammo = 1
	assert_true(carry.ground.collect(&"pistol", false, arena, carry))
	assert_eq(arena.gun.trigger.ammo, arena.gun.trigger.spec.magazine)
	assert_eq(carry.ground.swapped, 0)


func test_story_grant_preserves_hand_and_spent_rifle_releases_the_shortcut() -> void:
	_take_three()
	_press(&"weapon_slot_2")
	arena.rifle_ammo = 0
	arena.rivet.weapon = &"gloria"
	var hand: GunHand = GunHand.make(
		WeaponTable.shipped(), &"gloria", RngRegistry.new(8).stream(&"gunplay")
	)
	arena.gun = hand
	_press()
	assert_eq(wheel.selected(), &"gloria")
	assert_same(arena.gun, hand)
	assert_eq(wheel.order(), [&"hands", &"katana", &"pistol", &"gloria"])
	assert_eq(carry.slots[1], &"katana")
	carry.take(RivetCarry.RIFLE, arena)
	assert_eq(wheel.order(), [&"hands", &"katana", &"pistol", RivetCarry.RIFLE, &"gloria"])
	_press(&"weapon_slot_2")
	assert_eq(arena.rivet.weapon, RivetCarry.RIFLE)


func test_quest_gun_sync_cannot_replace_the_magazine_after_a_switch() -> void:
	var guns: StageGuns = StageGuns.make(RngRegistry.new(3).stream(&"quest_guns"))
	arena.rivet.weapon = &"gloria"
	guns.sync(arena)
	var initial: GunHand = arena.gun
	initial.trigger.ammo = 2
	_press()
	assert_eq(wheel.order(), [&"hands", &"gloria"])
	guns.sync(arena)
	_press(&"weapon_next")
	assert_same(arena.gun, initial)
	guns.sync(arena)
	_press()
	assert_same(arena.gun, initial)
	assert_eq(arena.gun.trigger.ammo, 2)


func test_wheel_state_distinguishes_same_grip_acquisitions_and_selection() -> void:
	carry.take(&"pistol", arena)
	_press()
	var a: StreamPeerBuffer = StreamPeerBuffer.new()
	wheel.write_state(a)
	carry.take(&"machine_pistol", arena)
	var b: StreamPeerBuffer = StreamPeerBuffer.new()
	wheel.write_state(b)
	assert_ne(a.data_array, b.data_array)
	_press(&"weapon_slot_1")
	var c: StreamPeerBuffer = StreamPeerBuffer.new()
	wheel.write_state(c)
	assert_ne(b.data_array, c.data_array)
