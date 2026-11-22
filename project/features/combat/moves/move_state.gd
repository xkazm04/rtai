class_name MoveState
extends RefCounted
## Preserve replay field order. Each move omits its default state.


static func write_fighter(arena: CombatArena, h: Fighter, out: StreamPeerBuffer) -> void:
	OhmShortCircuit.write_state(arena.squad_ai, h, out)
	TonnageCrack.write_state(arena, h, out)
