class_name VehicleTraffic
extends RefCounted
## The service's book of sim traffic it touched: damage per sim slot from the rams, the render
## state each slot shows (custom.y through VehicleWorld.set_car_state), and the soul-hijack flag.
## A traffic car rammed to D2 or past it is disabled: it leaves the sim and becomes a service body
## (coasting to a stop, drawn with its D2 / wreck art), so carnage reads before the city view
## picks traffic art by custom.y. A D1 car keeps driving with its state on the channel.

## Sim slot -> VehicleBody.State shown.
var state: Dictionary[int, int] = {}
var _lost: Dictionary[int, float] = {}
var _rules: VehicleDamage


func _init(rules: VehicleDamage) -> void:
	_rules = rules


func lost_of(slot: int) -> float:
	return _lost.get(slot, 0.0)


func soul(slot: int) -> bool:
	return state.get(slot, 0) == VehicleBody.State.HIJACKED


func soul_hijack(slot: int, world: VehicleWorld) -> void:
	state[slot] = VehicleBody.State.HIJACKED
	world.set_car_state(slot, VehicleBody.State.HIJACKED)


## Applies this tick's ram speed changes; returns the slots to disable (D2 or worse).
func settle(hits: Dictionary[int, float], world: VehicleWorld) -> Array[int]:
	var out: Array[int] = []
	for slot: int in hits:
		var lost: float = lost_of(slot) + _rules.damage_for(hits[slot], true)
		_lost[slot] = lost
		var st: int = _rules.state_for(lost, soul(slot))
		state[slot] = st
		world.set_car_state(slot, st)
		if st == VehicleBody.State.D2 or st == VehicleBody.State.WRECK:
			out.append(slot)
	return out


## Drops a slot (taken over, or gone): its render state back to intact for the slot's next actor.
func forget(slot: int, world: VehicleWorld) -> void:
	world.set_car_state(slot, VehicleBody.State.INTACT)
	@warning_ignore("return_value_discarded")
	state.erase(slot)
	@warning_ignore("return_value_discarded")
	_lost.erase(slot)
