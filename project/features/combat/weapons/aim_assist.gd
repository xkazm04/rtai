class_name AimAssist
extends RefCounted
## Pad aim assist (owner decision 2: light, pad only): the stick's aim bends part of the way
## toward the nearest living target inside a narrow cone and range. The mouse aims raw.
## Numbers from weapons.json `aim_assist`.

var cone_rad: float = 0.0
var range_m: float = 0.0
var strength: float = 0.0
var pad_only: bool = true


static func from_table(t: DataTable) -> AimAssist:
	var a: AimAssist = AimAssist.new()
	var row: Dictionary = t.object(t.raw, "aim_assist")
	a.cone_rad = deg_to_rad(t.num(row, "cone_deg"))
	a.range_m = t.num(row, "range_m")
	a.strength = clampf(t.num(row, "strength"), 0.0, 1.0)
	a.pad_only = row.get("pad_only", true) == true
	return a


## The aim direction after assist. `on_pad` false (mouse) returns `aim` untouched when pad_only.
func bend(aim: Vector2, origin: Vector2, targets: Array[RangeTarget], on_pad: bool) -> Vector2:
	if aim == Vector2.ZERO or (pad_only and not on_pad) or strength <= 0.0:
		return aim
	var best: RangeTarget = null
	var best_off: float = cone_rad
	for t: RangeTarget in targets:
		if not t.alive() or t.team == Projectile.TEAM_PLAYER:
			continue
		var to: Vector2 = t.pos - origin
		if to.length() > range_m or to == Vector2.ZERO:
			continue
		var off: float = absf(aim.angle_to(to))
		if off <= best_off:
			best_off = off
			best = t
	if best == null:
		return aim
	return aim.normalized().rotated(aim.angle_to(best.pos - origin) * strength)
