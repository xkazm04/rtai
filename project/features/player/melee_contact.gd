class_name MeleeContact
extends RefCounted
## Delivers a melee contact and retains each human caught in the current saw drive.

var _bitten: Dictionary[Fighter, Vector2] = {}
var _swing: int = -1


func land(
	arena: CombatArena, f: Fighter, combo: MeleeCombo, dir: Vector2, outcome: MeleeLethal.Contact
) -> bool:
	if MeleeShutdown.land(arena, f, combo):
		return false
	match outcome:
		MeleeLethal.Contact.NORMAL:
			arena.damage(f, combo.current().damage, arena.rivet.id, combo.table.id)
		MeleeLethal.Contact.BLOCKED:
			arena.wounded.emit(f, MeleeLethal.BLOCK)
		MeleeLethal.Contact.GRIND:
			_bitten[f] = dir
			arena.wounded.emit(f, combo.table.id)
		MeleeLethal.Contact.LETHAL:
			arena.damage(f, f.hp, arena.rivet.id, combo.table.id, MeleeLethal.FINISH)
	if f.alive() and combo.current().stun_ticks > 0:
		PlayerShock.stun_on(PlayerShock.areas_of(arena), f, combo.current().stun_ticks)
	return true


## Once the teeth catch someone the committed grind runs to its end and the saw pulls free.
## Preserve the original contact even if the player turns or the shove carries a victim away.
func advance(arena: CombatArena, combo: MeleeCombo) -> void:
	if combo.starts != _swing or combo.hit_index == 0:
		_bitten.clear()
		_swing = combo.starts
	var hit: MeleeHit = combo.current()
	if not _bitten.is_empty() and combo.ground >= hit.grind_min_ticks:
		combo.holding = false
	combo.step()
	if _bitten.is_empty() or combo.phase() != MeleeCombo.Phase.RECOVERY:
		return
	for f: Fighter in _bitten:
		if f.alive() and f.exposed and f != arena.boss and MeleeLethal.human(f):
			arena.hit_dir = _bitten[f]
			arena.hit_at = f.pos
			arena.damage(f, f.hp, arena.rivet.id, combo.table.id, MeleeLethal.FINISH)
	_bitten.clear()


func write_bites(out: StreamPeerBuffer) -> void:
	out.put_32(_bitten.size())
	for f: Fighter in _bitten:
		out.put_32(f.id)
		out.put_float(_bitten[f].x)
		out.put_float(_bitten[f].y)
