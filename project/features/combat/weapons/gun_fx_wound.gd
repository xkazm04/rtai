class_name GunFxWound
extends RefCounted
## n31 melee 04e: a light round that stops on a body throws something off it (the owner: "impact on
## enemies is inconsistent"). A human throws a small red flick, the blood_fx.json `gun_flick` row's
## few drops along the round that land as specks; a robot throws the same few drops as white sparks
## that land as oil (CombatBlood's oil fluid: red is human blood only). Per gun: gun_fx.json `flick`
## (the row's switch); the cap is one value, gun_fx.json `flick_gap_ticks`: at most one flick per
## victim per that many ticks, so the gatling does not paint the street. CombatBlood.listen names
## the blood the flicks go to. Render only: BloodFx's own hash scatter, nothing written to the sim.

const KIND: String = "gun_flick"
const GAP_TICKS: int = 6

static var _blood: WeakRef = null
## Victim id -> the tick of its last flick.
static var _last: Dictionary[int, int] = {}


## The blood the flicks go to (CombatBlood.listen); clears the per-victim cap.
static func use(blood: CombatBlood) -> void:
	_blood = weakref(blood)
	_last.clear()


## Rivet's round (travelling `hop`, m a tick) stopped on hostile `on` at `at` (m) from the held gun:
## 0 nothing (no flick on the gun's row, no blood, inside the cap), 1 a red flick, 2 white sparks.
static func on_round(fx: GunFx, arena: CombatArena, on: Fighter, at: Vector2, hop: Vector2) -> int:
	var ref: Object = _blood.get_ref() if _blood != null else null
	var blood: CombatBlood = ref as CombatBlood
	if blood == null or not blood.bleeds() or on == null:
		return 0
	if not fx.look(arena.gun.trigger.spec.id).get("flick", false):
		return 0
	var gap: int = fx.p.get("flick_gap_ticks", GAP_TICKS)
	if not admit(on.id, arena.tick, gap):
		return 0
	var robot: bool = on.machine or blood.victims.robot_ids.has(on.id)
	var to: BloodFx = blood.blood
	if robot and blood.oil != null:
		to = blood.oil
	to.splash(at * SimConst.PX_PER_M, hop.normalized(), KIND)
	return 2 if robot else 1


## True (and the victim's clock restarted) when `id`'s last flick is `gap` ticks or more before
## `tick`; a tick that ran backwards (a new fight) admits.
static func admit(id: int, tick: int, gap: int) -> bool:
	if _last.has(id) and tick >= _last[id] and tick - _last[id] < gap:
		return false
	_last[id] = tick
	return true
