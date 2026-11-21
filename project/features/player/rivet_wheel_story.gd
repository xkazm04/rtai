class_name RivetWheelStory
extends RefCounted
## Until the player uses the wheel, the stage owns its grants, including each gun's
## magazine and semi-auto trigger. Remember their order without drawing them again.

var _equipped: StringName = &""
var _shortcuts: Dictionary[int, StringName] = {}


## A launch loadout has already selected its grip. An external grant keeps its stage-owned
## magazine and defers the grip change until the player actually uses the wheel.
static func initial(carry: RivetCarry, arena: CombatArena) -> StringName:
	var id: StringName = arena.rivet.weapon
	if carry.story == null and carry.weapon() == id:
		carry.remember_hand(arena.gun, true)
		return RivetWheel.HANDS if id == &"" else id
	if carry.story == null:
		carry.story = RivetWheelStory.new()
	return carry.story.follow(carry, arena, RivetWheel.HANDS)


func follow(carry: RivetCarry, arena: CombatArena, previous: StringName) -> StringName:
	var id: StringName = arena.rivet.weapon
	if previous == RivetCarry.RIFLE and arena.rifle_ammo <= 0:
		carry.rifle_spent = true
		var rifle_slot: int = carry.slot_of(previous)
		_shortcuts[rifle_slot] = rifle_fallback(carry, rifle_slot)
	var slot: int = carry.slot_of(id)
	if slot < 0:
		_equipped = &""
		return RivetWheel.HANDS
	_equipped = id
	carry.remember_hand(arena.gun, true)
	if id not in carry.first_seen:
		carry.first_seen.append(id)
		_shortcuts[slot] = id
	elif id == RivetCarry.RIFLE and carry.rifle_spent:
		_shortcuts[slot] = id
	if id == RivetCarry.RIFLE:
		carry.rifle_spent = false
	return id


func apply(carry: RivetCarry) -> void:
	for slot: int in _shortcuts:
		carry.slots[slot] = _shortcuts[slot]
	_shortcuts.clear()
	if _equipped != &"":
		carry.record_drawn(carry.slot_of(_equipped), _equipped)
		_equipped = &""


static func rifle_fallback(carry: RivetCarry, slot: int) -> StringName:
	var fallback: StringName = &""
	for id: StringName in carry.first_seen:
		if id != RivetCarry.RIFLE and carry.slot_of(id) == slot:
			fallback = id
	return fallback
