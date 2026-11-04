class_name ShieldSparks
extends RefCounted
## A round stopped on a riot shield (ReactLink.blocked) throws white sparks off the slab's face
## back toward the shooter (CombatBlood's oil fx, blood_fx.json `player.hit`: the metal kind,
## white sparks that land dark) instead of a body's red: the armored hp reads as steel taking the
## round. Render only: no RNG of the sim, nothing written back (lane human-reactions).

## The shield's face this far ahead of the body's centre, toward the shot (metres).
const FACE_M: float = 0.35


## Connects `link`'s blocks to the sparks; `blood_of`: Callable() -> CombatBlood (null = none yet).
static func wire(link: ReactLink, arena: CombatArena, blood_of: Callable) -> void:
	var spark: Callable = func(victim: int, dir: Vector2) -> void:
		var blood: CombatBlood = blood_of.call()
		var at: Vector2 = face_of(arena, victim, dir)
		if blood != null and at != Vector2.INF:
			throw(blood, at, dir)
	@warning_ignore("return_value_discarded")
	link.blocked.connect(spark)


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
