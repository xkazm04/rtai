extends GutTest

var carry: RivetCarry
var arena: CombatArena
var wheel: RivetWheel
var actions: PlayerActions


func before_each() -> void:
	LaunchArgs.parse(["--controls=wheel"])
	actions = PlayerActions.shipped()
	var rng: RngRegistry = RngRegistry.new(22)
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, rng.stream(&"combat"))
	carry = RivetWheel.carry_for(arena)
	wheel = RivetWheel.new(carry)
	_step()


func after_each() -> void:
	LaunchArgs.parse()


func _step(action: StringName = &"") -> void:
	var bits: int = 0 if action == &"" else 1 << actions.bit(action)
	wheel.step(PlayerCommand.decode(TickInput.new(bits), 0, actions), actions, arena)


func _grant(id: StringName) -> void:
	arena.rivet.weapon = id
	if WeaponTable.shipped().weapons.has(id):
		arena.gun = GunHand.make(WeaponTable.shipped(), id, arena._rng)
	else:
		arena.gun = null
	_step()


func test_a_story_rifle_with_one_round_keeps_the_more_recent_long_shortcut() -> void:
	arena.rifle_ammo = 1
	_grant(RivetCarry.RIFLE)
	_grant(&"plasma_rifle")
	assert_false(carry.rifle_spent)
	_grant(RivetCarry.RIFLE)
	_step(&"weapon_slot_2")
	assert_eq(wheel.selected(), &"plasma_rifle")
	assert_eq(carry.slots[1], &"plasma_rifle")


func test_the_latest_story_magazine_survives_and_a_later_pickup_keeps_its_shortcut() -> void:
	_grant(&"gloria")
	var old: GunHand = arena.gun
	_grant(&"katana")
	_grant(&"gloria")
	var now: GunHand = arena.gun
	assert_not_same(old, now)
	now.trigger.ammo = 2
	_step(&"weapon_slot_2")
	_step(&"weapon_slot_1")
	assert_same(arena.gun, now)
	assert_eq(arena.gun.trigger.ammo, 2)
	carry.take(&"machine_pistol", arena)
	_step(&"weapon_slot_1")
	assert_eq(wheel.selected(), &"machine_pistol")
	assert_eq(carry.slots[0], &"machine_pistol")
