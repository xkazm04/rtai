class_name KerfStage
extends RefCounted
## Kerf's charged blink on quest and arena stages. Melee cuts the unobstructed hostile nearest
## the aim line and lands behind it, or dashes along the aim. ghost_attacks.json tunes the chain.

const ID: StringName = &"kerf"
const GHOST: StringName = &"kerf"
## The hanging cut lines kept for the view (the chain's last blinks).
const KEEP: int = 4

## BloodVictims.DRY_KILLS keeps the cut dry even under --gore=reduced.
const KILL_KIND: StringName = &"cauterised"

var powers: SoulPowers
var attacks: GhostAttacks
var charges: int = 0
var blinks: int = 0
var slices: int = 0
var activations: int = 0
## Last blinks, oldest first. Positions are in metres. A plain dash has no cut (Vector2.INF).
var trail_from: PackedVector2Array = PackedVector2Array()
var trail_to: PackedVector2Array = PackedVector2Array()
var trail_cut: PackedVector2Array = PackedVector2Array()
var trail_radius: Array[float] = []  ## Radius at impact for the view's spark exclusion.
var trail_tick: PackedInt32Array = PackedInt32Array()
## View only (n7-melee KerfView's sight): the aim of the last tick, never in write_state.
var sight_aim: Vector2 = Vector2.ZERO
var _recharge: int = 0
var _gap: int = 0
var _shared: bool = false


func _init(table: PowerTable, p_attacks: GhostAttacks = null) -> void:
	attacks = p_attacks if p_attacks != null else GhostAttacks.shipped()
	powers = SoulPowers.new(table)
	charges = int(num(&"charges"))


## GhostPilot owns activation and walking. A blink still consumes its movement tick.
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
	if not _shared:
		_take(power and rivet.alive())
	_refill()
	sight_aim = aim.normalized() if aim.length() > 0.001 else rivet.facing
	if not on():
		return move_by
	if melee and charges > 0 and _gap == 0 and rivet.alive():
		_blink(stage, aim.normalized() if aim.length() > 0.001 else rivet.facing)
		return Vector2.ZERO
	return move_by if _shared else move_by * num(&"speed_k")


func _take(power: bool) -> void:
	if power and not on() and powers.try_activate(ID) == &"ok":
		activations += 1
		charges = int(num(&"charges"))
	powers.tick()


## The blink gap's refill, 0 just after a blink to 1 when the next blink may fire (view only).
func ready_k() -> float:
	var gap: int = PowerDef.ticks(num(&"gap_s"))
	return 1.0 if gap <= 0 else 1.0 - float(_gap) / gap


## Fraction of the next charge's beam already regrown (view only).
func recharge_k() -> float:
	if charges >= int(num(&"charges")):
		return 0.0
	return float(_recharge) / maxi(1, PowerDef.ticks(num(&"recharge_s")))


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
		var blink: KerfBehind = KerfBehind.resolve(stage, target, num(&"behind_m"), _walls(stage))
		to = blink.landing
		cut = target.pos
		_slice(stage, target, blink.hit_dir)
		_cut_path(stage, from, to, target, blink.path_dir)
	var walls: ArenaWalls = _walls(stage)
	if walls != null:
		to = walls.push_out(to, rivet.radius_m)
	rivet.pos = to
	if target != null:
		rivet.facing = (target.pos - to).normalized() if target.pos != to else -rivet.facing
	charges -= 1
	_gap = PowerDef.ticks(num(&"gap_s"))
	blinks += 1
	_remember(stage.tick, from, to, cut, target.radius_m if target != null else 0.0)


## Nearest unobstructed hostile by aim angle within reach. The earlier hostile wins ties.
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
	stage.arena.damage(target, dmg, stage.arena.rivet.id, &"kerf_slice", KILL_KIND)
	slices += 1


## Positive path_cut_m also slices hostiles whose radius enters that band. Zero cuts only the pick.
func _cut_path(
	stage: CollectCallStage, from: Vector2, to: Vector2, target: Fighter, dir: Vector2
) -> void:
	var width: float = num(&"path_cut_m")
	if width <= 0.0:
		return
	for h: Fighter in stage.arena.hostiles.duplicate():
		if h == target or not h.alive():
			continue
		var near: Vector2 = Geometry2D.get_closest_point_to_segment(h.pos, from, to)
		if h.pos.distance_to(near) <= width + h.radius_m:
			_slice(stage, h, dir)


static func _walls(stage: CollectCallStage) -> ArenaWalls:
	var arena_stage: ArenaStage = stage as ArenaStage
	return arena_stage.walls if arena_stage != null else null


func _remember(tick: int, from: Vector2, to: Vector2, cut: Vector2, radius: float) -> void:
	@warning_ignore("return_value_discarded")
	trail_from.push_back(from)
	@warning_ignore("return_value_discarded")
	trail_to.push_back(to)
	@warning_ignore("return_value_discarded")
	trail_cut.push_back(cut)
	trail_radius.push_back(radius)
	@warning_ignore("return_value_discarded")
	trail_tick.push_back(tick)
	if trail_tick.size() > KEEP:
		trail_from.remove_at(0)
		trail_to.remove_at(0)
		trail_cut.remove_at(0)
		trail_radius.remove_at(0)
		trail_tick.remove_at(0)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(charges)
	out.put_32(blinks)
	out.put_32(slices)
	out.put_32(_recharge)
	out.put_32(_gap)
	out.put_32(powers.active_left)
