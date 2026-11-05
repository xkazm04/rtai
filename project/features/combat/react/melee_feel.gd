class_name MeleeFeel
extends RefCounted
## n7-melee: Rivet's melee hits on the shared hit feel's camera side (FeelCam, lane n7-ranged).
## PlayerMelee lands through CombatArena.damage, which emits no `struck` (that would drive HitLink's
## sim knockback), so FeelCam never saw a claw, blade, baton or chainsaw hit. This connects the two
## view-only melee signals: kill_landed (a kill) and wounded (a hit that does not kill), for the
## melee weapons only, along Rivet -> victim, once per strike (the chainsaw grind lands every tick:
## MeleeWound's gap). The look is data: hit_feel.json class `melee` and its `weapons` rows; the
## off switch is `--feel=off` (HitFeel.enabled). View only: nothing here is read by the sim.
## The ghost attacks that land the same way (kerf_slice, dent_blast, ohm_bolt, ...) ride the same
## path when their hit_feel.json `weapons` row names a `class` (HitFeel.weapon_class): each cut of
## Kerf's chain is its own short beat. No row class = not felt here (guns are left to `struck`).

const DEFLECT: StringName = &"plasma_deflect"

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
	@warning_ignore("return_value_discarded")
	arena.deflected.connect(m._on_deflected)
	return m


func _on_kill(
	victim: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	var cls: StringName = class_of(weapon)
	if cls != &"":
		_land(victim, weapon, cls, true)


func _on_wounded(victim: Fighter, weapon: StringName) -> void:
	var cls: StringName = class_of(weapon)
	if cls != &"" and _gate.admit(victim.id, _arena.tick):
		_land(victim, weapon, cls, false)


## The plasma sword's bat: a parry beat (weapons row `plasma_deflect`), kicked toward the shooter.
func _on_deflected(_at: Vector2, back: Vector2) -> void:
	var cls: StringName = cam.feel.weapon_class(DEFLECT)
	if cls != &"":
		hits += 1
		@warning_ignore("return_value_discarded")
		cam.hit(DEFLECT, cls, back.normalized(), false, _arena.tick)


## The feel class of a hit by `weapon`: `melee` for Rivet's melee weapons, else the weapons row's
## `class` (a ghost attack), else &"" (not felt here).
func class_of(weapon: StringName) -> StringName:
	if weapon in ReactLink.MELEE_IDS:
		return &"melee"
	return cam.feel.weapon_class(weapon)


func _land(victim: Fighter, weapon: StringName, cls: StringName, lethal: bool) -> void:
	var d: Vector2 = victim.pos - _arena.rivet.pos
	if cls != &"melee" and _arena.hit_dir.length() > 0.001:
		d = _arena.hit_dir  # a ghost attack sets its own (a blast: outward from the car)
	d = d.normalized() if d.length() > 0.001 else -victim.facing
	hits += 1
	@warning_ignore("return_value_discarded")
	cam.hit(weapon, cls, d, lethal, _arena.tick)
