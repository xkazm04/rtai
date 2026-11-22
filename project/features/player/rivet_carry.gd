class_name RivetCarry
extends RefCounted
## rivet-arsenal: the guns Rivet carries, one per carry slot (rivet_arsenal.json `slot` of the
## weapon's grip class: 1 sidearm, 2 long, 3 heavy, 4 thrown). A number key picks a slot,
## weapon_next / weapon_prev cycle the carried ones (the wheel), reload starts a reload. A switch
## swaps the fight's GunHand (each weapon keeps its own, so a half magazine survives the switch)
## and sets rivet.weapon; StagePilot's WeaponHold then plays the stow and the draw, and no shot
## leaves before the draw ends. Deterministic: only the tick's press edges move it.

const SLOTS: int = 4
## The contractor rifle fires CombatArena's finite magazine from combat.json.
const RIFLE: StringName = &"assault-rifle"
const SLOT_ACTIONS: Array[StringName] = [
	&"weapon_slot_1", &"weapon_slot_2", &"weapon_slot_3", &"weapon_slot_4"
]

## The weapon id in each slot (&"" = empty).
var slots: Array[StringName] = [&"", &"", &"", &""]
## The slot in the claw (-1 = none yet).
var current: int = -1
## In wheel controls the grip slots are shortcuts. Retain acquisition order across shared grips.
var wheel_inventory: bool = ControlsMode.wheel()
var first_seen: Array[StringName] = []
var rifle_spent: bool = false
var wheel_only: bool = false
var picked_up: bool = false
var story: RivetWheelStory = null
var switches: int = 0
## A bot holds the trigger: a semi gun re-taps (GunHand.tap).
var tap: bool = false
## Guns on the ground that walking over picks up (WeaponPickups).
var ground: WeaponPickups = WeaponPickups.new()
## rivet-arsenal: melee_weapons.json ids carried like guns (the katana in the long slot, the baton
## in the sidearm slot); selecting one puts the gun away (arena.gun = null).
var melee_ids: Array[StringName] = MeleeTable.weapon_ids()
## n7-melee, quest 1: the story hands Rivet his guns and the carry holds one blade. A press on the
## drawn blade's slot puts it away and gives back the weapon it replaced; when the story swaps the
## weapon (Brass's Gloria, a picked-up rifle) the blade counts as put away. false = the arena's.
var sheathe: bool = false
var _drawn_id: StringName = &""
var _stowed: StringName = &""
var _hands: Dictionary[StringName, GunHand] = {}
var _table: WeaponTable
var _arsenal: ArsenalTable
var _rng: RandomNumberGenerator


func _init(
	table: WeaponTable, arsenal: ArsenalTable, rng: RandomNumberGenerator, drawn: GunHand = null
) -> void:
	_table = table
	_arsenal = arsenal
	_rng = rng
	if drawn != null:
		_hands[drawn.trigger.spec.id] = drawn


## Puts a table gun into its class's slot (replacing what was there); returns the slot index,
## or -1 for an id that is not a weapons.json gun with a grip class.
func add(id: StringName) -> int:
	var grip: ArsenalTable.Grip = _arsenal.grip_of(id)
	if grip == null or not carries(id):
		return -1
	if story != null:
		story.apply(self)
	if id not in first_seen:
		first_seen.append(id)
	if id == RIFLE:
		rifle_spent = false
	slots[grip.slot - 1] = id
	return grip.slot - 1


## The tick's switch and reload presses.
func step(c: PlayerCommand, actions: PlayerActions, arena: CombatArena) -> void:
	if weapon() == RIFLE and arena.rifle_ammo == 0 and arena.rivet.weapon != RIFLE:
		slots[current] = &""
		current = -1
		var next: int = _cycle(1)
		if next >= 0:
			select(next, arena)
	if sheathe and current >= 0 and arena.rivet.weapon != slots[current]:
		current = -1  # the story put another weapon in the claw
	var want: int = current
	var pressed: int = -1
	for i: int in SLOTS:
		if c.was_pressed(actions, SLOT_ACTIONS[i]) and slots[i] != &"":
			want = i
			pressed = i
	if c.was_pressed(actions, &"weapon_next"):
		want = _cycle(1)
	elif c.was_pressed(actions, &"weapon_prev"):
		want = _cycle(-1)
	if sheathe and pressed >= 0 and pressed == current:
		arena.rivet.weapon = _stowed  # put away: the weapon it replaced comes back
		current = -1
		switches += 1
	elif want != current and want >= 0:
		select(want, arena)
	service(c, actions, arena)


## Pickups and reload are shared by the grip-slot and hands-first controls.
func service(c: PlayerCommand, actions: PlayerActions, arena: CombatArena) -> void:
	if c.was_pressed(actions, &"reload") and arena.gun != null:
		arena.gun.trigger.start_reload()
	ground.step(c, actions, arena, self)


## The slot `id` would sit in (-1: not a carried gun).
func slot_of(id: StringName) -> int:
	var grip: ArsenalTable.Grip = _arsenal.grip_of(id)
	return grip.slot - 1 if grip != null and carries(id) else -1


## The contractor rifle, a weapons.json gun or a melee_weapons.json weapon.
func carries(id: StringName) -> bool:
	return id == RIFLE or _table.weapons.has(id) or melee_ids.has(id)


## A picked-up gun into its slot and into the claw; the same gun again refills its magazine.
## Wheel controls keep the current selection until the player switches.
func take(id: StringName, arena: CombatArena) -> void:
	if id == RIFLE:
		arena.rifle_ammo = arena.tuning.weapon(RIFLE).magazine
	var hand: GunHand = _hands.get(id, null)
	if hand != null:
		hand.trigger.ammo = hand.trigger.spec.magazine
		hand.trigger.reload_left = 0
	var slot: int = add(id)
	picked_up = picked_up or slot >= 0
	if not wheel_inventory and slot >= 0 and (slot != current or arena.rivet.weapon != id):
		select(slot, arena)


## Puts the gun in slot `i` in the claw (the fight's GunHand and rivet.weapon).
func select(i: int, arena: CombatArena, wheel_id: StringName = &"") -> void:
	var id: StringName = slots[i] if wheel_id == &"" else wheel_id
	if id == &"":
		return
	if _table.weapons.has(id):
		if not _hands.has(id):
			_hands[id] = GunHand.make(_table, id, _rng)
		arena.gun = _hands[id]
		if arena.gun != null:
			arena.gun.tap = tap
	else:
		if id == RIFLE and arena.rifle_ammo == 0:
			arena.rifle_ammo = arena.tuning.weapon(RIFLE).magazine
		if sheathe and melee_ids.has(id) and not melee_ids.has(arena.rivet.weapon):
			_stowed = arena.rivet.weapon
		arena.gun = null
	arena.rivet.weapon = id
	record_drawn(i, id)
	switches += 1


func record_drawn(slot: int, id: StringName) -> void:
	current = slot
	_drawn_id = id


func weapon() -> StringName:
	if wheel_inventory:
		return _drawn_id if current >= 0 else &""
	return slots[current] if current >= 0 else &""


## Keep the stage's trigger, including a built-in weapon fired without a GunHand.
func remember_hand(hand: GunHand, replace: bool = false, builtin: StringName = &"") -> void:
	if hand != null and (replace or not _hands.has(hand.trigger.spec.id)):
		_hands[hand.trigger.spec.id] = hand
	elif hand == null and builtin != &"":
		_hands[builtin] = null


func hand_for(id: StringName) -> GunHand:
	return _hands.get(id, null)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(current)
	out.put_32(switches)
	for id: StringName in slots:
		var hand: GunHand = _hands.get(id, null)
		out.put_32(hand.trigger.ammo if hand != null else -1)
		out.put_32(hand.trigger.reload_left if hand != null else -1)
	ground.write_state(out)
	if sheathe:
		out.put_32(String(_stowed).hash())


## The next carried slot after the current one in `dir` (wraps; the current when alone).
func _cycle(dir: int) -> int:
	for k: int in range(1, SLOTS + 1):
		var i: int = posmod(current + dir * k, SLOTS)
		if slots[i] != &"":
			return i
	return current
