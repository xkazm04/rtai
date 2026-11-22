class_name MoveCarry
extends ArenaHook
## Lives on the gauntlet squad only after a card grant. The hook hashes the held rank.

var rank: int = 0
var arcs: MoveCarryView = MoveCarryView.new()
var _row: MoveTable.Overkill
var _arsenal: ArsenalTable
var _forms: GhostForms
var _hops_left: int = 0


static func grant(stage: ArenaStage, next_rank: int) -> bool:
	var squad: ArenaSquad = stage.arena.squad_ai
	if squad == null or not squad.moves.overkill_carry.enabled:
		return false
	var held: int = squad.carry.rank if squad.carry != null else 0
	if next_rank != held + 1 or next_rank > 2:
		return false
	if squad.carry == null:
		squad.carry = MoveCarry.new()
		squad.carry._row = squad.moves.overkill_carry
		squad.carry._arsenal = stage.pilot.hold.table
		squad.carry._forms = stage.pilot.ghosts.forms
		stage.hooks.append(squad.carry)
	squad.carry.rank = next_rank
	return true


## CombatArena has resolved armour, damage_k, kill signals and drops. Finish the original hit
## before another can select its victim. A carried hit enters the very same damage path.
static func take(
	arena: CombatArena, victim: Fighter, amount: float, killer_id: int, weapon: StringName
) -> void:
	var leftover: float = amount - victim.hp
	victim.take(amount, arena.tick, arena.hit_dir)
	if leftover <= 0.0 or killer_id != arena.rivet.id or victim == arena.rivet:
		return
	var squad: ArenaSquad = arena.squad_ai
	if squad == null or squad.carry == null or not squad.moves.overkill_carry.enabled:
		return
	squad.carry._after_kill(arena, victim.pos, leftover, weapon)


func _after_kill(arena: CombatArena, origin: Vector2, leftover: float, weapon: StringName) -> void:
	var tuning: MoveTable.CarryRank = _row.first if rank == 1 else _row.second
	var hops: int = tuning.hops
	if weapon == MoveTable.OVERKILL:
		hops = _hops_left
	elif not _base_weapon(weapon):
		return
	if hops <= 0:
		return
	var target: Fighter = _nearest(arena.hostiles, origin, tuning.radius_m)
	if target == null:
		return
	# Nested damage inherits only this delivery's remaining hops.
	var previous: int = _hops_left
	_hops_left = hops - 1
	_jump(arena, origin, target, leftover * _row.carry_k)
	_hops_left = previous


func _base_weapon(weapon: StringName) -> bool:
	if not _forms.settled() or _forms.current() != GhostForms.BASE:
		return false
	return (
		_arsenal.weapon_grip.has(weapon) or weapon in [MeleeTable.CLAW, PlayerShock.WEAPON, &"burn"]
	)


func _jump(arena: CombatArena, origin: Vector2, target: Fighter, amount: float) -> void:
	var hp: float = target.hp
	var at: Vector2 = target.pos
	var old_dir: Vector2 = arena.hit_dir
	var old_at: Vector2 = arena.hit_at
	arena.hit_dir = origin.direction_to(at)
	arena.hit_at = at
	arena.damage(target, amount, arena.rivet.id, MoveTable.OVERKILL)
	arena.hit_dir = old_dir
	arena.hit_at = old_at
	if target.hp < hp:
		arena.move_tally.record(MoveTable.OVERKILL)
		arcs.record(origin, at, arena.tick, _row.arc_ticks)


static func _nearest(hostiles: Array[Fighter], origin: Vector2, radius_m: float) -> Fighter:
	var best: Fighter = null
	var nearest: float = INF
	var limit: float = radius_m * radius_m
	for foe: Fighter in hostiles:
		if not foe.alive():
			continue
		var distance: float = origin.distance_squared_to(foe.pos)
		if distance <= limit and distance < nearest:
			best = foe
			nearest = distance
	return best


func write_state(out: StreamPeerBuffer) -> void:
	if rank > 0 and _row.enabled:
		out.put_8(rank)
