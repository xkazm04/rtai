class_name GhostLunge
extends RefCounted
## n15 hero (combat feel): a drawn ghost puts its body into its strike. On the strike tick
## (GhostActs' counter rising) the figure leans toward its facing's screen x about the feet (the
## sprite's origin), so the feet stay planted and the head and arms reach, then eases back over the
## follow-through; a toward or away facing reaches along the screen's y instead (a lean cannot
## show there). While the sim holds a telegraphed strike (Tonnage's slam, Dent's arm jab) it leans
## back off the target first: the anticipation. Mirrors GhostRecoil (the hit leans away). Render
## only. `enabled` false (`--ghost-lunge=off`, CastFlags) = the figure strikes upright (the before).

## Per form: x the strike lean (deg), y the wind-up's lean back (deg), z the toward/away reach (m).
const DEFAULT: Vector3 = Vector3(9.0, 5.0, 0.12)
## Tonnage's drawn stomp already throws his weight (and he leans 4 on a hit: GhostRecoil); Ohm's
## bolt leaves his hands with his body still in the cells, so he leans into it the most.
const BY_FORM: Dictionary[String, Vector3] = {
	"tonnage": Vector3(4.0, 3.0, 0.06), "ohm": Vector3(13.0, 5.0, 0.18)
}
## Ticks the wind-up's lean takes to reach full (the slam's telegraph is longer than this).
const WIND_RAMP: int = 4

static var enabled: bool = true

var _wind_from: int = -1


static func of(form: String) -> Vector3:
	return BY_FORM[form] if BY_FORM.has(form) else DEFAULT


## The strike's weight `since` ticks after it (-1 = none): full on tick 1, held through the cut,
## eased out (squared) over the follow-through.
static func strike_k(since: int) -> float:
	var cut: int = GhostDrawn.CUT_TICKS
	if since < 0 or since >= cut + GhostDrawn.FOLLOW_TICKS:
		return 0.0
	if since < cut:
		return minf(1.0, float(since + 1) / 2.0)
	var k: float = 1.0 - float(since - cut) / float(GhostDrawn.FOLLOW_TICKS)
	return k * k


## The sprite's added screen rotation (rad) at `tick`: back while `windup`, else into the strike
## `since` ticks ago, facing `look`.
func lean(tick: int, since: int, windup: bool, look: float, form: String) -> float:
	if not enabled or is_nan(look):
		return 0.0
	if not windup:
		_wind_from = -1
		return cos(look) * deg_to_rad(of(form).x) * strike_k(since)
	if _wind_from < 0:
		_wind_from = tick
	var k: float = minf(1.0, float(tick - _wind_from + 1) / float(WIND_RAMP))
	return -cos(look) * deg_to_rad(of(form).y) * k


## The figure's world offset (metres) `since` ticks into a strike: the reach along the facing's
## y only (a profile facing leans instead and keeps its feet).
static func reach(since: int, look: float, form: String) -> Vector2:
	if not enabled or is_nan(look):
		return Vector2.ZERO
	return Vector2(0.0, sin(look)) * of(form).z * strike_k(since)
