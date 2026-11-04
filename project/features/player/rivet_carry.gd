class_name RivetCarry
extends RefCounted
## rivet-arsenal: the guns Rivet carries, one per carry slot (rivet_arsenal.json `slot` of the
## weapon's grip class: 1 sidearm, 2 long, 3 heavy, 4 thrown). A number key picks a slot,
## weapon_next / weapon_prev cycle the carried ones (the wheel), reload starts a reload. A switch
## swaps the fight's GunHand (each weapon keeps its own, so a half magazine survives the switch)
## and sets rivet.weapon; StagePilot's WeaponHold then plays the stow and the draw, and no shot
## leaves before the draw ends. Deterministic: only the tick's press edges move it.

const SLOTS: int = 4
const SLOT_ACTIONS: Array[StringName] = [
	&"weapon_slot_1", &"weapon_slot_2", &"weapon_slot_3", &"weapon_slot_4"
]

## The weapon id in each slot (&"" = empty).
var slots: Array[StringName] = [&"", &"", &"", &""]
## The slot in the claw (-1 = none yet).
var current: int = -1
var switches: int = 0
## A bot holds the trigger: a semi gun re-taps (GunHand.tap).
var tap: bool = false
## Guns on the ground that walking over picks up (WeaponPickups).
var ground: WeaponPickups = WeaponPickups.new()
var _hands: Dictionary[StringName, GunHand] = {}
var _table: WeaponTable
var _arsenal: ArsenalTable
var _rng: RandomNumberGenerator


func _init(table: WeaponTable, arsenal: ArsenalTable, rng: RandomNumberGenerator) -> void:
	_table = table
	_arsenal = arsenal
	_rng = rng


## Puts a table gun into its class's slot (replacing what was there); returns the slot index,
## or -1 for an id that is not a weapons.json gun with a grip class.
func add(id: StringName) -> int:
	var grip: ArsenalTable.Grip = _arsenal.grip_of(id)
	if grip == null or not _table.weapons.has(id):
		return -1
	slots[grip.slot - 1] = id
	return grip.slot - 1


## The tick's switch and reload presses.
func step(c: PlayerCommand, actions: PlayerActions, arena: CombatArena) -> void:
	var want: int = current
	for i: int in SLOTS:
		if c.was_pressed(actions, SLOT_ACTIONS[i]) and slots[i] != &"":
			want = i
	if c.was_pressed(actions, &"weapon_next"):
		want = _cycle(1)
	elif c.was_pressed(actions, &"weapon_prev"):
		want = _cycle(-1)
	if want != current and want >= 0:
		select(want, arena)
	if c.was_pressed(actions, &"reload") and arena.gun != null:
		arena.gun.trigger.start_reload()
	ground.step(c, actions, arena, self)


## The slot `id` would sit in (-1: not a carried gun).
func slot_of(id: StringName) -> int:
	var grip: ArsenalTable.Grip = _arsenal.grip_of(id)
	return grip.slot - 1 if grip != null and _table.weapons.has(id) else -1


## A picked-up gun into its slot and into the claw; the same gun again refills its magazine.
func take(id: StringName, arena: CombatArena) -> void:
	var hand: GunHand = _hands.get(id, null)
	if hand != null:
		hand.trigger.ammo = hand.trigger.spec.magazine
		hand.trigger.reload_left = 0
	var slot: int = add(id)
	if slot >= 0 and (slot != current or arena.rivet.weapon != id):
		select(slot, arena)


## Puts the gun in slot `i` in the claw (the fight's GunHand and rivet.weapon).
func select(i: int, arena: CombatArena) -> void:
	var id: StringName = slots[i]
	if id == &"":
		return
	if not _hands.has(id):
		_hands[id] = GunHand.make(_table, id, _rng)
	var hand: GunHand = _hands[id]
	hand.tap = tap
	arena.gun = hand
	arena.rivet.weapon = id
	current = i
	switches += 1


func weapon() -> StringName:
	return slots[current] if current >= 0 else &""


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(current)
	out.put_32(switches)
	for id: StringName in slots:
		var hand: GunHand = _hands.get(id, null)
		out.put_32(hand.trigger.ammo if hand != null else -1)
		out.put_32(hand.trigger.reload_left if hand != null else -1)
	ground.write_state(out)


## The next carried slot after the current one in `dir` (wraps; the current when alone).
func _cycle(dir: int) -> int:
	for k: int in range(1, SLOTS + 1):
		var i: int = posmod(current + dir * k, SLOTS)
		if slots[i] != &"":
			return i
	return current
