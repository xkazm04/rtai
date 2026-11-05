class_name KerfStage
extends RefCounted
## Kerf (the freed laser-cutter head), lane ghost-powers, for the bound player on quest 1's stage
## or an arena stage. power `kerf` (powers.json) puts the soul on; while on, Rivet walks at
## speed_k and the melee press blinks (ghost_attacks.json `kerf`): the live hostile nearest the
## aim inside the cone and range, with no wall between, is cut: Rivet blinks along the straight
## line to behind_m past it and the beam slices it (weapon kerf_slice: the human one-shot split
## with a teal-white cauterised edge, robot_damage on a robot). No target: a plain blink of dash_m
## along the aim. A chain of `charges` blinks, one back per recharge_s, gap_s apart.

const ID: StringName = &"kerf"
const GHOST: StringName = &"kerf"
## The hanging cut lines kept for the view (the chain's last blinks).
const KEEP: int = 4

var powers: SoulPowers
var attacks: GhostAttacks
var charges: int = 0
var blinks: int = 0
var slices: int = 0
var activations: int = 0
## The last blinks, oldest first: from, to (metres), tick, and the cut target's spot (or
## Vector2.INF on a plain dash).
var trail_from: PackedVector2Array = PackedVector2Array()
var trail_to: PackedVector2Array = PackedVector2Array()
var trail_cut: PackedVector2Array = PackedVector2Array()
var trail_tick: PackedInt32Array = PackedInt32Array()
var _recharge: int = 0
var _gap: int = 0
## GhostPilot owns the SoulPowers (one form at a time): no own activation, tick or speed_k.
var _shared: bool = false


func _init(table: PowerTable, p_attacks: GhostAttacks = null) -> void:
	attacks = p_attacks if p_attacks != null else GhostAttacks.shipped()
	powers = SoulPowers.new(table)
	charges = int(num(&"charges"))


## Lane ghost-forms: the SoulPowers behind GhostForms (the form's own top_mps moves Kerf).
func share(p_powers: SoulPowers) -> void:
	powers = p_powers
	_shared = true


static func shipped() -> KerfStage:
	return KerfStage.new(PowerTable.load_default())


func num(key: StringName) -> float:
	return attacks.num(GHOST, key)


func on() -> bool:
	return powers.active == ID


## One tick: `power` takes the soul, `melee` blinks, `aim` is Rivet's aim (unit). Returns the
## walk to use instead of `move_by` (scaled while on; zero on a blink tick).
func drive(
	stage: CollectCallStage, power: bool, melee: bool, aim: Vector2, move_by: Vector2
) -> Vector2:
	var rivet: Fighter = stage.arena.rivet
	if power and not on() and rivet.alive() and powers.try_activate(ID) == &"ok":
		activations += 1
		charges = int(num(&"charges"))
	if not _shared:
		powers.tick()
	_refill()
	if not on():
		return move_by
	if melee and charges > 0 and _gap == 0 and rivet.alive():
		_blink(stage, aim.normalized() if aim.length() > 0.001 else rivet.facing)
		return Vector2.ZERO
	return move_by if _shared else move_by * num(&"speed_k")


## True while the soul is on (the pilot skips the jab: melee is the blink).
func owns_melee() -> bool:
	return on()


func _refill() -> void:
	_gap = maxi(0, _gap - 1)
	if charges >= int(num(&"charges")):
		_recharge = 0
		return
	_recharge += 1
	if _recharge >= PowerDef.ticks(num(&"recharge_s")):
		_recharge = 0
		charges += 1


func _blink(stage: CollectCallStage, aim: Vector2) -> void:
	var rivet: Fighter = stage.arena.rivet
	var from: Vector2 = rivet.pos
	var target: Fighter = pick(stage, aim)
	var to: Vector2 = from + aim * num(&"dash_m")
	var cut: Vector2 = Vector2.INF
	if target != null:
		var dir: Vector2 = (target.pos - from).normalized()
		to = target.pos + dir * (num(&"behind_m") + target.radius_m)
		cut = target.pos
		_slice(stage, target, dir)
	var walls: ArenaWalls = _walls(stage)
	if walls != null:
		to = walls.push_out(to, rivet.radius_m)
	rivet.pos = to
	if target != null:
		rivet.facing = (target.pos - to).normalized() if target.pos != to else -rivet.facing
	charges -= 1
	_gap = PowerDef.ticks(num(&"gap_s"))
	blinks += 1
	_remember(stage.tick, from, to, cut)


## The target: the live hostile inside the aim cone and range, nearest the aim line (by angle),
## with no arena wall between; ties to the earlier hostile. Null = none (a plain dash).
func pick(stage: CollectCallStage, aim: Vector2) -> Fighter:
	var rivet: Fighter = stage.arena.rivet
	var walls: ArenaWalls = _walls(stage)
	var best: Fighter = null
	var best_a: float = deg_to_rad(num(&"cone_deg"))
	for h: Fighter in stage.arena.hostiles:
		var to: Vector2 = h.pos - rivet.pos
		if not h.alive() or to.length() > num(&"range_m") or to.length() < 0.01:
			continue
		var a: float = absf(aim.angle_to(to))
		if a > best_a or (a == best_a and best != null):
			continue
		if walls != null and walls.blocks(rivet.pos, h.pos):
			continue
		best = h
		best_a = a
	return best


func _slice(stage: CollectCallStage, target: Fighter, dir: Vector2) -> void:
	var robot: bool = target.kind == Fighter.Kind.BOSS
	stage.arena.hit_dir = dir
	stage.arena.hit_at = target.pos
	var dmg: float = num(&"robot_damage") if robot else num(&"human_damage")
	stage.arena.damage(target, dmg, stage.arena.rivet.id, &"kerf_slice")
	slices += 1


static func _walls(stage: CollectCallStage) -> ArenaWalls:
	var arena_stage: ArenaStage = stage as ArenaStage
	return arena_stage.walls if arena_stage != null else null


func _remember(tick: int, from: Vector2, to: Vector2, cut: Vector2) -> void:
	@warning_ignore("return_value_discarded")
	trail_from.push_back(from)
	@warning_ignore("return_value_discarded")
	trail_to.push_back(to)
	@warning_ignore("return_value_discarded")
	trail_cut.push_back(cut)
	@warning_ignore("return_value_discarded")
	trail_tick.push_back(tick)
	if trail_tick.size() > KEEP:
		trail_from.remove_at(0)
		trail_to.remove_at(0)
		trail_cut.remove_at(0)
		trail_tick.remove_at(0)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(charges)
	out.put_32(blinks)
	out.put_32(slices)
	out.put_32(_recharge)
	out.put_32(_gap)
	out.put_32(powers.active_left)
