class_name WeaponPickups
extends RefCounted
## rivet-arsenal: table guns lying on the ground (RivetCarry.ground). Walking within REACH_M of
## one takes it when its carry slot is empty (Rivet draws it) or holds the same gun (a full
## magazine). A gun for a slot that holds another gun stays down until `interact` is pressed over
## it: then the held one is dropped behind Rivet and the new one drawn (the swap is the drop).
## Deterministic: positions in metres, items in drop order.

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
	var rivet: Fighter = arena.rivet
	for i: int in items.size():
		var it: Item = items[i]
		var slot: int = carry.slot_of(it.id)
		if slot < 0 or it.pos.distance_to(rivet.pos) > REACH_M:
			continue
		var held: StringName = carry.slots[slot]
		if held == &"" or held == it.id:
			items.remove_at(i)
			carry.take(it.id, arena)
			picked += 1
			return
		if c.was_pressed(actions, &"interact"):
			items.remove_at(i)
			drop(held, rivet.pos - rivet.facing * DROP_BEHIND_M)
			carry.take(it.id, arena)
			swapped += 1
			return


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(items.size())
	out.put_32(picked)
	out.put_32(swapped)
	for it: Item in items:
		out.put_float(it.pos.x)
		out.put_float(it.pos.y)
