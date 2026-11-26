class_name ShieldSparks
extends RefCounted
## A round stopped on a riot shield (ReactLink.blocked) throws white sparks off the slab's face
## back toward the shooter (CombatBlood's oil fx, blood_fx.json `player.hit`: the metal kind,
## white sparks that land dark) instead of a body's red: the armored hp reads as steel taking the
## round. Render only: no RNG of the sim, nothing written back (lane human-reactions).
## n31 04d: Rivet's melee too (CombatArena.wounded / kill_landed): a non-lethal hit on a robot
## throws its sparks that land as oil along the blow (blood_fx.json hits.thug_hit), and a weapon
## that cuts through the slab (melee_weapons.json vs_shield `through`) on a riot shield's front:
## the chainsaw throws the slab's white sparks back off its face (the baton's and the plasma
## sword's flicks are ClawMarks'). Once a
## strike per victim (MeleeWound's gap: the chainsaw grind lands every tick, 5 sprays a second).

## The shield's face this far ahead of the body's centre, toward the shot (metres).
const FACE_M: float = 0.35
## The robot's spray starts this far from its centre toward Rivet (the struck near side).
const NEAR_M: float = 0.2
const THUG_HIT: String = "thug_hit"
## The slab's white sparks are the saw's bite; the baton and plasma sword flick (ClawMarks).
const SAW: StringName = &"chainsaw"

static var _through: Dictionary[StringName, bool] = {}

## Sprays thrown: [robot hits, slab bites].
var thrown: PackedInt32Array = [0, 0]
var _arena: CombatArena = null
var _blood_of: Callable = Callable()
var _gate: MeleeWound = MeleeWound.new()


## Connects `link`'s blocks to the sparks; `blood_of`: Callable() -> CombatBlood (null = none yet).
static func wire(link: ReactLink, arena: CombatArena, blood_of: Callable) -> void:
	var spark: Callable = func(victim: int, dir: Vector2) -> void:
		var blood: CombatBlood = blood_of.call()
		var at: Vector2 = face_of(arena, victim, dir)
		if blood != null and at != Vector2.INF:
			throw(blood, at, dir)
	@warning_ignore("return_value_discarded")
	link.blocked.connect(spark)
	@warning_ignore("return_value_discarded")
	melee(arena, blood_of)


## Rivet's melee sprays (robot hits, through-the-slab bites) on `arena`'s hits.
static func melee(arena: CombatArena, blood_of: Callable) -> ShieldSparks:
	var s: ShieldSparks = ShieldSparks.new()
	s._arena = arena
	s._blood_of = blood_of
	@warning_ignore("return_value_discarded")
	arena.wounded.connect(s.on_hit.bind(false))
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(
		func(v: Fighter, w: StringName, _d: Vector2, _a: Vector2, _k: StringName) -> void:
			s.on_hit(v, w, true)
	)
	return s


## One melee contact on `victim` (a kill when `lethal`: only the slab sprays, a dead robot leaks
## through CombatBlood): 0 none, 1 the robot's sparks and oil, 2 the slab's sparks.
func on_hit(victim: Fighter, weapon: StringName, lethal: bool) -> int:
	var blood: CombatBlood = _blood_of.call() if _blood_of.is_valid() else null
	if blood == null or not blood.bleeds() or victim == _arena.rivet:
		return 0
	if not (weapon in MeleeWound.MELEE_IDS):
		return 0
	var d: Vector2 = victim.pos - _arena.rivet.pos
	d = d.normalized() if d.length() > 0.001 else -victim.facing
	var robot: bool = victim.machine or blood.victims.robot_ids.has(victim.id)
	var kind: int = 1 if robot and not lethal else 0
	if not robot and weapon == SAW and through(weapon) and fronts(victim, d):
		kind = 2
	if kind == 0 or not _gate.admit(victim.id, _arena.tick):
		return 0
	thrown[kind - 1] += 1
	var fx: BloodFx = blood.oil if blood.oil != null else blood.blood
	if kind == 1:
		fx.splash((victim.pos - d * NEAR_M) * SimConst.PX_PER_M, d, THUG_HIT)
	else:  # the bite's own lighter fan (10 drops, not a round's 26): 5 bites a second
		fx.splash((victim.pos - d * FACE_M) * SimConst.PX_PER_M, -d, THUG_HIT)
	return kind


## True when melee weapon `weapon` cuts through a riot shield (melee_weapons.json vs_shield).
static func through(weapon: StringName) -> bool:
	if not _through.has(weapon):
		_through[weapon] = MeleeTable.weapon(weapon).vs_shield == &"through"
	return _through[weapon]


## True when `victim` carries a shield and the blow along `dir` meets its front.
static func fronts(victim: Fighter, dir: Vector2) -> bool:
	var arch: EnemyRoster.Archetype = MeleeLethal.archetype(victim.archetype)
	if arch == null or arch.shield_front_mult >= 1.0:
		return false
	return victim.facing.dot(-dir) > arch.shield_cos


## The shield face's point (world px) of fighter `victim` hit along `dir`; INF when it is gone.
static func face_of(arena: CombatArena, victim: int, dir: Vector2) -> Vector2:
	for h: Fighter in arena.hostiles:
		if h.id == victim:
			return (h.pos - dir.normalized() * FACE_M) * SimConst.PX_PER_M
	return Vector2.INF


## White sparks off the face at `at` (px), fanned back against the round's travel `dir`.
static func throw(blood: CombatBlood, at: Vector2, dir: Vector2) -> void:
	var fx: BloodFx = blood.oil if blood.oil != null else blood.blood
	var player: Dictionary = blood.blood.p.get("player", {})
	var kind: String = player.get("hit", "robot_hit")
	fx.splash(at, -dir.normalized(), kind)
