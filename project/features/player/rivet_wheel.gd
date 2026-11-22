class_name RivetWheel
extends RefCounted
## Hands and the carried weapons, independent of the four grip shortcuts. Within each group
## the first acquisition wins. Selecting never reorders a shortcut or creates a new magazine.

const HANDS: StringName = &"hands"

var carry: RivetCarry
var switched_tick: int = -1
var readout_scroll_tick: int = 0  ## Opening or latest cycle press. Presentation only.
var _selected: StringName = HANDS
var _fresh: bool = true
var _touched: bool = false
var _start_drawn: bool = ControlsMode.start_drawn()


func _init(inventory: RivetCarry = null) -> void:
	bind(inventory)


func bind(inventory: RivetCarry) -> void:
	_touched = _used()
	carry = inventory
	if carry != null:
		carry.wheel_inventory = true
		if (carry.sheathe or carry.wheel_only) and carry.story == null:
			carry.story = RivetWheelStory.new()
	_selected = HANDS
	_fresh = true
	switched_tick = -1
	readout_scroll_tick = 0


## Stages without a loadout already own a seeded combat stream and may have a story gun.
static func carry_for(arena: CombatArena) -> RivetCarry:
	var c: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), ArsenalTable.shipped(), arena._rng, arena.gun
	)
	c.wheel_only = true
	if arena.gun != null:
		c.tap = arena.gun.tap
	return c


func order() -> Array[StringName]:
	var ids: Array[StringName] = [HANDS]
	if carry == null:
		return ids
	var guns: Array[StringName] = []
	for id: StringName in carry.first_seen:
		if id in carry.melee_ids:
			ids.append(id)
		elif id != RivetCarry.RIFLE or not carry.rifle_spent:
			guns.append(id)
	ids.append_array(guns)
	return ids


func selected() -> StringName:
	return _selected


func melee_selected() -> bool:
	return _selected == HANDS or (carry != null and _selected in carry.melee_ids)


## The quick melee action always starts a claw strike. Primary follows the selected combo
## after its stow/draw has finished (the bare claw is READY with an empty held id).
func swing_pressed(
	c: PlayerCommand,
	actions: PlayerActions,
	hold: WeaponHold,
	melee: PlayerMelee,
	ghosts: GhostPilot
) -> bool:
	if c.was_pressed(actions, &"melee"):
		return true
	if ghosts != null and ghosts.owns_melee():
		return false
	var id: StringName = MeleeTable.CLAW if _selected == HANDS else _selected
	return (
		hold.state == WeaponHold.State.READY
		and melee.weapon_id == id
		and c.is_held(actions, &"fire")
	)


func step(c: PlayerCommand, actions: PlayerActions, arena: CombatArena, tick: int = -1) -> void:
	if carry == null:
		bind(carry_for(arena))
	var previous: StringName = _selected
	if _fresh and _start_drawn:
		_selected = RivetWheelStory.initial(carry, arena)
		_fresh = false
		previous = _selected
	else:
		_sync(arena)
	var want: StringName = _selected
	for i: int in RivetCarry.SLOTS:
		if c.was_pressed(actions, RivetCarry.SLOT_ACTIONS[i]):
			_activate()
			if carry.slots[i] != &"":
				want = carry.slots[i]
	var dir: int = int(c.was_pressed(actions, &"weapon_next"))
	if dir == 0 and c.was_pressed(actions, &"weapon_prev"):
		dir = -1
	if dir != 0:
		readout_scroll_tick = arena.tick if tick < 0 else tick
		_activate()
		var ids: Array[StringName] = order()
		want = ids[posmod(ids.find(_selected) + dir, ids.size())]
	if want != _selected:
		_choose(want, arena)
	if _selected != previous:
		switched_tick = arena.tick if tick < 0 else tick
	carry.service(c, actions, arena)


## Import guns granted outside the carry (e.g. Brass's Gloria). The initial loadout enters the
## inventory with hands selected. Later story grants follow the stage's actual equipped weapon.
func _sync(arena: CombatArena) -> void:
	var id: StringName = arena.rivet.weapon
	var actual: StringName = HANDS if id == &"" else id
	if not _fresh and carry.story != null and not _used():
		if actual != _selected:
			_selected = carry.story.follow(carry, arena, _selected)
		return
	if not _fresh and actual == _selected:
		# Quest 1's gun sync can replace a just-selected hand. The carry owns its magazine.
		arena.gun = carry.hand_for(_selected)
		return
	if _selected == RivetCarry.RIFLE and arena.rifle_ammo <= 0:
		_spend_rifle()
	if id != &"" and carry.slot_of(id) >= 0:
		var builtin: StringName = id if id in arena.tuning.weapons else &""
		carry.remember_hand(arena.gun, false, builtin)
		if id not in carry.first_seen or (id == RivetCarry.RIFLE and carry.rifle_spent):
			@warning_ignore("return_value_discarded")
			carry.add(id)
	if _fresh:
		_stow(arena)
		_fresh = false
	elif id == &"" or id not in carry.first_seen:
		_choose(HANDS, arena)
	else:
		_choose(id, arena)


func _spend_rifle() -> void:
	carry.rifle_spent = true
	var slot: int = carry.slot_of(RivetCarry.RIFLE)
	if carry.slots[slot] == RivetCarry.RIFLE:
		carry.slots[slot] = RivetWheelStory.rifle_fallback(carry, slot)


func _choose(id: StringName, arena: CombatArena) -> void:
	if id == HANDS:
		_stow(arena)
	else:
		carry.select(carry.slot_of(id), arena, id)
	_selected = id


func _stow(arena: CombatArena) -> void:
	if carry.current >= 0 or arena.rivet.weapon != &"":
		carry.switches += 1
	carry.current = -1
	arena.rivet.weapon = &""
	arena.gun = null


func _activate() -> void:
	_touched = true
	if carry.story != null:
		carry.story.apply(carry)


func _used() -> bool:
	return _touched or (carry != null and carry.picked_up)


func writes_carry() -> bool:
	return carry != null and (not carry.wheel_only or _used() or not carry.ground.items.is_empty())


func write_state(out: StreamPeerBuffer) -> void:
	if not _used():
		return
	out.put_utf8_string(_selected)
	out.put_u8(int(_fresh))
	if carry != null:
		out.put_u8(int(carry.rifle_spent))
		out.put_32(carry.first_seen.size())
		for id: StringName in carry.first_seen:
			out.put_utf8_string(id)
			var hand: GunHand = carry.hand_for(id)
			out.put_32(hand.trigger.ammo if hand != null else -1)
			out.put_32(hand.trigger.reload_left if hand != null else -1)
		for id: StringName in carry.slots:
			out.put_utf8_string(id)
