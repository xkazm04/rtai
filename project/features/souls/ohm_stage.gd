class_name OhmStage
extends RefCounted
## Ohm (the elder spot-welding robot, the mage), lane ghost-powers, for the bound player on quest
## 1's stage or an arena stage. power `ohm` (powers.json) puts the soul on; while on, the melee
## press throws a forked bolt every bolt_gap_s (ghost_attacks.json `ohm`): the live hostile
## nearest the aim inside the cone and range is struck, then the bolt forks on to up to `forks`
## more within fork_radius_m (MeleeShock.chain_path, the claw shock's walk). Each body is stunned
## (the electro gun's FightAreas stun) and takes human_damage, or bolt_damage x machine_k on a
## robot (weapon ohm_bolt: a human's kill is the electro X-ray shock). Nothing in the cone: the
## car nearest the aim burns (car_damage). upgrade_tier >= 1: the mass arc (mass_targets, radius).

const ID: StringName = &"ohm"
const GHOST: StringName = &"ohm"
const WEAPON: StringName = &"ohm_bolt"
## The electrode fingertips: this far ahead of Rivet's centre (metres).
const HANDS_M: float = 0.45

var powers: SoulPowers
var attacks: GhostAttacks
var bolts: int = 0
var struck: int = 0
var cars_hit: int = 0
var activations: int = 0
## The last bolt: its tick (-1 = none) and the path, fingertips first (metres).
var bolt_tick: int = -1
var bolt_path: PackedVector2Array = PackedVector2Array()
## Each path point's source point (its index in bolt_path; -1 for the fingertips): the chain's
## previous body, or on the mass arc the first body (the arc fans out from it).
var bolt_from: PackedInt32Array = PackedInt32Array()
var _gap: int = 0
var _shared: bool = false


func _init(table: PowerTable, p_attacks: GhostAttacks = null) -> void:
	attacks = p_attacks if p_attacks != null else GhostAttacks.shipped()
	powers = SoulPowers.new(table)


## GhostPilot: the form's one SoulPowers drives the soul (no own activate or tick).
func share(p_powers: SoulPowers) -> void:
	powers = p_powers
	_shared = true


static func shipped() -> OhmStage:
	return OhmStage.new(PowerTable.load_default())


func num(key: StringName) -> float:
	return attacks.num(GHOST, key)


func on() -> bool:
	return powers.active == ID


## One tick: `power` takes the soul, `melee` throws a bolt, `aim` is Rivet's aim (unit).
func drive(stage: CollectCallStage, power: bool, melee: bool, aim: Vector2) -> void:
	var rivet: Fighter = stage.arena.rivet
	if not _shared:
		if power and not on() and rivet.alive() and powers.try_activate(ID) == &"ok":
			activations += 1
		powers.tick()
	_gap = maxi(0, _gap - 1)
	if on() and melee and _gap == 0 and rivet.alive():
		_bolt(stage, aim.normalized() if aim.length() > 0.001 else rivet.facing)


## True while the soul is on (the pilot skips the jab: melee is the bolt).
func owns_melee() -> bool:
	return on()


func _bolt(stage: CollectCallStage, aim: Vector2) -> void:
	var arena: CombatArena = stage.arena
	var hands: Vector2 = arena.rivet.pos + aim * HANDS_M
	var bodies: Array[Fighter] = []
	var pos: PackedVector2Array = PackedVector2Array()
	var first: int = -1
	var best: float = deg_to_rad(num(&"cone_deg"))
	for f: Fighter in arena.hostiles:
		var to: Vector2 = f.pos - arena.rivet.pos
		if not f.alive() or to.length() > num(&"range_m") or to.length() < 0.01:
			continue
		if absf(aim.angle_to(to)) < best:
			best = absf(aim.angle_to(to))
			first = bodies.size()
		bodies.append(f)
		@warning_ignore("return_value_discarded")
		pos.append(f.pos)
	_gap = PowerDef.ticks(num(&"bolt_gap_s"))
	bolts += 1
	bolt_tick = stage.tick
	bolt_path = PackedVector2Array([hands])
	bolt_from = PackedInt32Array([-1])
	if first < 0:
		_burn_car(stage, aim)
		return
	var metal: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	metal.resize(pos.size())
	metal.fill(1)
	var mass: bool = int(num(&"upgrade_tier")) >= 1
	var hops: int = int(num(&"mass_targets")) - 1 if mass else int(num(&"forks"))
	var reach: float = num(&"mass_radius_m") if mass else num(&"fork_radius_m")
	for i: int in MeleeShock.chain_path(pos, metal, first, hops, reach):
		_strike(arena, bodies[i], mini(1, bolt_path.size() - 1) if mass else bolt_path.size() - 1)


## Strikes `f` from bolt_path[src] (the chain's last point, or the mass arc's first body).
func _strike(arena: CombatArena, f: Fighter, src: int) -> void:
	@warning_ignore("return_value_discarded")
	bolt_path.append(f.pos)
	@warning_ignore("return_value_discarded")
	bolt_from.append(src)
	PlayerShock.stun_on(PlayerShock.areas_of(arena), f, PowerDef.ticks(num(&"stun_s")))
	var from: Vector2 = bolt_path[src]
	var dir: Vector2 = (f.pos - from).normalized() if f.pos != from else arena.rivet.facing
	arena.hit_dir = dir
	arena.hit_at = f.pos - dir * f.radius_m
	var robot: bool = f.kind == Fighter.Kind.BOSS
	var dmg: float = num(&"bolt_damage") * num(&"machine_k") if robot else num(&"human_damage")
	arena.damage(f, dmg, arena.rivet.id, WEAPON)
	arena.struck.emit(f, dir, not f.alive(), WEAPON)
	struck += 1


## Machines burn out: with no body in the cone, the live car nearest the aim (inside the cone and
## range) takes car_damage through the vehicles lane's damage rules.
func _burn_car(stage: CollectCallStage, aim: Vector2) -> void:
	var arena_stage: ArenaStage = stage as ArenaStage
	if arena_stage == null or arena_stage.vehicles == null:
		return
	var best: VehicleBody = null
	var best_a: float = deg_to_rad(num(&"cone_deg"))
	for b: VehicleBody in arena_stage.cars():
		var to: Vector2 = b.pos - stage.arena.rivet.pos
		var a: float = absf(aim.angle_to(to))
		if b.state != VehicleBody.State.WRECK and to.length() <= num(&"range_m") and a < best_a:
			best = b
			best_a = a
	if best == null:
		return
	var rules: VehicleDamage = arena_stage.vehicles.rules
	best.hp_lost = minf(rules.hp, best.hp_lost + num(&"car_damage"))
	best.state = rules.state_for(best.hp_lost, best.soul_hijacked)
	@warning_ignore("return_value_discarded")
	bolt_path.append(best.pos)
	@warning_ignore("return_value_discarded")
	bolt_from.append(0)
	cars_hit += 1


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(bolts)
	out.put_32(struck)
	out.put_32(cars_hit)
	out.put_32(_gap)
	out.put_32(powers.active_left)
