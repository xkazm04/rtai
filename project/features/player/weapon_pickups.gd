class_name WeaponPickups
extends RefCounted
## rivet-arsenal: table guns lying on the ground (RivetCarry.ground). Walking within REACH_M of
## one takes it when its carry slot is empty (Rivet draws it) or holds the same gun (a full
## magazine). A gun for a slot that holds another gun stays down until `interact` is pressed over
## it: then the held one is dropped behind Rivet and the new one drawn (the swap is the drop).
## Deterministic: positions in metres, items in drop order.
## On the wheel an occupied grip still takes interact, and the previous item stays carried.

const REACH_M: float = 0.9
const DROP_BEHIND_M: float = 0.7


class Item:
	extends RefCounted
	var id: StringName = &""
	var pos: Vector2 = Vector2.ZERO


var items: Array[Item] = []
var picked: int = 0
var swapped: int = 0


func drop(id: StringName, at: Vector2) -> void:
	var it: Item = Item.new()
	it.id = id
	it.pos = at
	items.append(it)


## Takes what Rivet walks over (or swaps on an interact press); at most one item per tick.
func step(c: PlayerCommand, actions: PlayerActions, arena: CombatArena, carry: RivetCarry) -> void:
	for i: int in items.size():
		var it: Item = items[i]
		if it.pos.distance_to(arena.rivet.pos) > REACH_M:
			continue
		if collect(it.id, c.was_pressed(actions, &"interact"), arena, carry):
			items.remove_at(i)
			return


## Collects a reachable floor or rack weapon. Replacing an occupied slot takes an interact press.
func collect(id: StringName, interact: bool, arena: CombatArena, carry: RivetCarry) -> bool:
	var slot: int = carry.slot_of(id)
	if slot < 0:
		return false
	var held: StringName = carry.slots[slot]
	if held == &"" or held == id or (carry.wheel_inventory and id in carry.first_seen):
		picked += 1
	elif interact:
		if carry.wheel_inventory:
			picked += 1  # the shortcut changes, but the previous weapon stays on the wheel
		else:
			drop(held, arena.rivet.pos - arena.rivet.facing * DROP_BEHIND_M)
			swapped += 1
	else:
		return false
	carry.take(id, arena)
	return true


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(items.size())
	out.put_32(picked)
	out.put_32(swapped)
	for it: Item in items:
		out.put_float(it.pos.x)
		out.put_float(it.pos.y)
