class_name RivetLean
extends RefCounted
## n17 rivet-strike item 2 (owner 2026-11-11 "attach movement with melee"; GhostLunge's idea for
## Rivet): through a melee weapon's strike the drawn figure leans about his feet (the card's
## origin, so the boot line stays planted): back off the target through the view's wind-up, into
## the blow from the contact on, then upright again over the recovery. The lean goes toward his
## facing's screen side (cos of the screen octant: full on the sides, 0.71 on the diagonals, none
## straight toward or away, where a lean cannot show). Per weapon in melee_weapons.json
## (`lean_back_deg`, `lean_in_deg`; absent = upright, as the claw). Render only.
## `--rivet-lean=off` (CastFlags) = before (every strike upright).

static var enabled: bool = true
static var _by: Dictionary[StringName, Vector2] = {}


## The lean (radians, + = clockwise on screen) of `rig` this frame; 0 outside a weapon strike.
static func rad(rig: CutRig) -> float:
	if not enabled or rig.dead or rig.clips.strike_t < 0.0:
		return 0.0
	var lean: Vector2 = of(RivetFrames.weapon_of(rig))
	if lean == Vector2.ZERO:
		return 0.0
	var side: float = cos(RivetFrames.oct_of(rig) * PI * 0.25)
	if absf(side) < 0.01:
		return 0.0
	return deg_to_rad(deg_at(lean, rig.clips.strike_t, rig.clips.strike_ph)) * side


## The lean in degrees (- = back) at `t` seconds into a strike of phases `ph` (wind-up, active,
## recovery seconds) for `lean` (x back, y in): eased back over the wind-up, full in from the
## contact through the active phase, eased upright over the recovery; 0 in the hold after it.
static func deg_at(lean: Vector2, t: float, ph: Vector3) -> float:
	var w: float = maxf(ph.x, 0.001)
	if t < ph.x:
		return -lean.x * smoothstep(0.0, 1.0, t / w)
	if t < ph.x + ph.y:
		return lean.y
	var r: float = maxf(ph.z, 0.001)
	return lean.y * (1.0 - smoothstep(0.0, 1.0, (t - ph.x - ph.y) / r))


## A weapon's (back, in) lean in degrees from melee_weapons.json, ZERO for a gun or the claw.
static func of(weapon: StringName) -> Vector2:
	if weapon == &"":
		return Vector2.ZERO
	if _by.is_empty():
		for id: StringName in MeleeTable.weapon_ids():
			var m: MeleeTable = MeleeTable.weapon(id)
			_by[id] = Vector2(m.lean_back_deg, m.lean_in_deg)
	return _by.get(weapon, Vector2.ZERO)
