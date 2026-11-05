class_name MeleeFeel
extends RefCounted
## n7-melee: Rivet's melee hits on the shared hit feel's camera side (FeelCam, lane n7-ranged).
## PlayerMelee lands through CombatArena.damage, which emits no `struck` (that would drive HitLink's
## sim knockback), so FeelCam never saw a claw, blade, baton or chainsaw hit. This connects the two
## view-only melee signals: kill_landed (a kill) and wounded (a hit that does not kill), for the
## melee weapons only, along Rivet -> victim, once per strike (the chainsaw grind lands every tick:
## MeleeWound's gap). The look is data: hit_feel.json class `melee` and its `weapons` rows; the
## off switch is `--feel=off` (HitFeel.enabled). View only: nothing here is read by the sim.

var cam: FeelCam
var hits: int = 0
var _arena: CombatArena
var _gate: MeleeWound = MeleeWound.new()


static func attach(p_cam: FeelCam, arena: CombatArena) -> MeleeFeel:
	var m: MeleeFeel = MeleeFeel.new()
	m.cam = p_cam
	m._arena = arena
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(m._on_kill)
	@warning_ignore("return_value_discarded")
	arena.wounded.connect(m._on_wounded)
	return m


func _on_kill(
	victim: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	if weapon in ReactLink.MELEE_IDS:
		_land(victim, weapon, true)


func _on_wounded(victim: Fighter, weapon: StringName) -> void:
	if weapon in ReactLink.MELEE_IDS and _gate.admit(victim.id, _arena.tick):
		_land(victim, weapon, false)


func _land(victim: Fighter, weapon: StringName, lethal: bool) -> void:
	var d: Vector2 = victim.pos - _arena.rivet.pos
	d = d.normalized() if d.length() > 0.001 else -victim.facing
	hits += 1
	@warning_ignore("return_value_discarded")
	cam.hit(weapon, &"melee", d, lethal, _arena.tick)
